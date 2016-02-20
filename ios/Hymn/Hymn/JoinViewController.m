//
//  JoinViewController.m
//  Hymn
//
//  Created by Jason Scharff on 2/20/16.
//  Copyright © 2016 Jason Scharff. All rights reserved.
//

#import "JoinViewController.h"

#import "Constants.h"

#import "AutolayoutHelper.h"
#import "BottomBorderTextField.h"
#import "ImageArrangedButton.h"
#import "RESTSessionManager+Space.h"
#import "QRCodeScannerViewController.h"
#import "UIColor+ColorPalette.h"

@interface JoinViewController () <UITextFieldDelegate>

@property (nonatomic, strong) BottomBorderTextField *accessCodeField;
@property (nonatomic, strong) UIButton *submitButton;
@property (nonatomic, strong) NSLayoutConstraint *scanBottomConstraint;
@property (nonatomic, strong) NSDictionary *observingNotifications;

@end

static const int QRCODE_BUTTON_DISTANCE_FROM_BOTTOM = 60;

@implementation JoinViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  self.view.backgroundColor = [UIColor whiteColor];
  
  UITapGestureRecognizer *hideKeyboardRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(hideKeyboard:)];
  [self.view addGestureRecognizer:hideKeyboardRecognizer];
  
  
  _accessCodeField = [[BottomBorderTextField alloc]initWithBorderColor:[UIColor blackColor] borderWidth:1];
  _accessCodeField.autocorrectionType = UITextAutocorrectionTypeNo;
  _accessCodeField.autocapitalizationType = UITextAutocapitalizationTypeAllCharacters;
  _accessCodeField.placeholder = @"Enter your access code.";
  _accessCodeField.font = [UIFont fontWithName:@"AvenirNext-Regular" size:25];
  _accessCodeField.delegate = self;
  _accessCodeField.returnKeyType = UIReturnKeyGo;
  _accessCodeField.textAlignment = NSTextAlignmentCenter;
  [_accessCodeField addTarget:self
                action:@selector(textFieldDidChange:)
                forControlEvents:UIControlEventEditingChanged];
  
  UIFont *buttonFont = [UIFont fontWithName:@"AvenirNext-Regular" size:22];
   
  _submitButton = [[UIButton alloc]init];
  [_submitButton setTitle:@"Submit" forState:UIControlStateNormal];
  [_submitButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
  _submitButton.titleLabel.font = buttonFont;
  [_submitButton addTarget:self action:@selector(submitSpaceIdentifier:) forControlEvents:UIControlEventTouchDown];
  
  ImageArrangedButton *scanButton = [[ImageArrangedButton alloc]init];
  scanButton.imageView.image =[UIImage imageNamed:@"camera"];
  scanButton.caption.font = [UIFont fontWithName:@"AvenirNext-Regular" size:22];
  scanButton.caption.text = @"Scan QR Code";
  [scanButton addTarget:self action:@selector(scanQRCode:) forControlEvents:UIControlEventTouchDown];
  
  [AutolayoutHelper configureView:self.view
                         subViews:VarBindings(_accessCodeField, _submitButton, scanButton)
                      constraints:@[@"H:|-20-[_accessCodeField]-20-|",
                                    @"V:|-60-[_accessCodeField]-30-[_submitButton]",
                                    @"X:scanButton.centerX == superview.centerX",
                                    @"X:_submitButton.centerX == superview.centerX"]];
  
  self.scanBottomConstraint = [NSLayoutConstraint constraintWithItem:scanButton
                                                           attribute:NSLayoutAttributeBottom
                                                           relatedBy:NSLayoutRelationEqual
                                                           toItem:self.view
                                                           attribute:NSLayoutAttributeBottom
                                                           multiplier:1
                                                           constant:-QRCODE_BUTTON_DISTANCE_FROM_BOTTOM];
  
  [self.view addConstraint:self.scanBottomConstraint];
  [self registerForNotifications];
  
}

-(void)viewDidAppear:(BOOL)animated {
  if(_shouldBeginWithInvalidSpaceMessage) {
    [self invalidSpaceName:nil];
    _shouldBeginWithInvalidSpaceMessage = NO;
  }
}

-(void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  self.title = @"Join a space.";
}

-(IBAction)submitSpaceIdentifier:(id)sender {
  [[RESTSessionManager sharedSessionManager]joinSpaceWithIdentifier:self.accessCodeField.text];
}

-(IBAction)scanQRCode:(id)sender {
  QRCodeScannerViewController *qrVC = [[QRCodeScannerViewController alloc]init];
  qrVC.previousVC = self;
  UINavigationController *nav = [[UINavigationController alloc]init];
  nav.navigationBar.barTintColor = [UIColor navbarColor];
  nav.navigationBar.tintColor = [UIColor whiteColor];
  [nav pushViewController:qrVC animated:NO];
  [self presentViewController:nav animated:YES completion:nil];
  
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
  [self submitSpaceIdentifier:self];
  return YES;
}

-(void)textFieldDidChange : (UITextField *)textField {
  if(textField.text.length == 0) {
    self.submitButton.enabled = NO;
  }
  else {
    self.submitButton.enabled = YES;
  }
}

-(void)hideKeyboard : (UITapGestureRecognizer *)recognizer {
  [self.accessCodeField resignFirstResponder];
}

-(void)keyboardWillShow : (NSNotification *)notification {
  CGSize keyboardSize = [[notification.userInfo objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
  self.scanBottomConstraint.constant = -QRCODE_BUTTON_DISTANCE_FROM_BOTTOM - keyboardSize.height;
  [UIView animateWithDuration:0.2 animations:^{
    [self.view layoutIfNeeded];
  }];
}

-(void)keyboardWillHide : (NSNotification *)notification {
  self.scanBottomConstraint.constant = -QRCODE_BUTTON_DISTANCE_FROM_BOTTOM;
  [UIView animateWithDuration:0.2 animations:^{
    [self.view layoutIfNeeded];
  }];
}

- (void)registerForNotifications {
  self.observingNotifications = @{UIKeyboardWillShowNotification : @"keyboardWillShow:",
                                  UIKeyboardWillHideNotification : @"keyboardWillHide:",
                                  HAS_JOINED_SPACE : @"hasJoinedSpace:",
                                  INVALID_SPACE_NAME_NOTIFICATION : @"invalidSpaceName:"};
  
  [self.observingNotifications enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:NSSelectorFromString(obj)
                                                 name:key
                                               object:nil];
    
  }];
}

- (void)unregisterForNotifications {
  for (NSString *key in self.observingNotifications) {
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:key
                                                  object:nil];
  }
}

-(void)dealloc {
  [self unregisterForNotifications];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)hasJoinedSpace : (NSNotification *)notification {
  
}

-(void)invalidSpaceName : (NSNotification *)notification {
  UIAlertController *alertView = [UIAlertController alertControllerWithTitle:@"Invalid Space Name" message:@"The space name provided does not match a current space. Please confirm the name you recieved is correct and try again." preferredStyle:UIAlertControllerStyleAlert];
  [alertView addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
  [self presentViewController:alertView animated:YES completion:nil];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
