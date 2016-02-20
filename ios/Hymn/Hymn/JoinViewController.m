//
//  JoinViewController.m
//  Hymn
//
//  Created by Jason Scharff on 2/20/16.
//  Copyright © 2016 Jason Scharff. All rights reserved.
//

#import "JoinViewController.h"

#import "AutolayoutHelper.h"
#import "BottomBorderTextField.h"
#import "ImageArrangedButton.h"

@interface JoinViewController () <UITextFieldDelegate>

@property (nonatomic, strong) BottomBorderTextField *accessCodeField;
@property (nonatomic, strong) UIButton *submitButton;
@property (nonatomic, strong) NSLayoutConstraint *scanBottomConstraint;
@property (nonatomic, strong) NSDictionary *observingNotifications;

@end

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
  _accessCodeField.textAlignment = NSTextAlignmentCenter;
  [_accessCodeField addTarget:self
                action:@selector(textFieldDidChange:)
                forControlEvents:UIControlEventEditingChanged];
  
  UIFont *buttonFont = [UIFont fontWithName:@"AvenirNext-Regular" size:22];
   
  _submitButton = [[UIButton alloc]init];
  [_submitButton setTitle:@"Submit" forState:UIControlStateNormal];
  [_submitButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
  _submitButton.titleLabel.font = buttonFont;
  
  ImageArrangedButton *scanButton = [[ImageArrangedButton alloc]init];
  scanButton.imageView.image =[UIImage imageNamed:@"camera"];
  scanButton.caption.font = [UIFont fontWithName:@"AvenirNext-Regular" size:22];
  scanButton.caption.text = @"Scan QR Code";
  
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
                                                           constant:-60];
  
  [self.view addConstraint:self.scanBottomConstraint];
  [self registerForNotifications];
  
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
  self.scanBottomConstraint.constant -= keyboardSize.height;
  [UIView animateWithDuration:0.2 animations:^{
    [self.view layoutIfNeeded];
  }];
}

-(void)keyboardWillHide : (NSNotification *)notification {
  CGSize keyboardSize = [[notification.userInfo objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
  self.scanBottomConstraint.constant += keyboardSize.height;
  [UIView animateWithDuration:0.2 animations:^{
    [self.view layoutIfNeeded];
  }];
}

- (void)registerForNotifications {
  self.observingNotifications = @{UIKeyboardWillShowNotification : @"keyboardWillShow:",
                                  UIKeyboardWillHideNotification : @"keyboardWillHide:"};
  
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
