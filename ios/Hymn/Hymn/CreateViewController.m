//
//  CreateViewController.m
//  Hymn
//
//  Created by Jason Scharff on 2/20/16.
//  Copyright © 2016 Jason Scharff. All rights reserved.
//

#import "CreateViewController.h"

#import "AutolayoutHelper.h"
#import "CurrentMusicController.h"
#import "SearchViewController.h"
#import "SocketManager.h"
#import "QueueViewController.h"
#import "Utilities.h"
#import "UIColor+ColorPalette.h"

@interface CreateViewController()

@property (nonatomic, strong) UILabel *codeLabel;
@property (nonatomic, strong) UIImageView *qrCodeImage;
@property (nonnull, strong) UIView *parentView;

@end

@implementation CreateViewController

-(void)viewDidLoad {
  [super viewDidLoad];
  self.view.backgroundColor = [UIColor whiteColor];
  
  UIImage *image = [Utilities createQRForString:self.code];
  _codeLabel = [UILabel new];
  _codeLabel.font = [UIFont fontWithName:@"AvenirNext-Regular" size:25];
  _codeLabel.textColor = [UIColor blackColor];
  _codeLabel.text = self.code;
  _codeLabel.textAlignment = NSTextAlignmentCenter;
  
  _codeLabel.layer.cornerRadius = 8.0;
  _codeLabel.layer.borderWidth = 1.0;
  _codeLabel.layer.borderColor = [UIColor blackColor].CGColor;
  
  _qrCodeImage = [[UIImageView alloc]initWithImage:image];
  _qrCodeImage.layer.cornerRadius = 8.0;
  _qrCodeImage.layer.borderWidth = 1.0;
  _qrCodeImage.layer.borderColor = [UIColor blackColor].CGColor;
  
  UIButton *shareButton = [[UIButton alloc]init];
  [shareButton setTitle:@"Share" forState:UIControlStateNormal];
  [shareButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
  shareButton.titleLabel.font = [UIFont fontWithName:@"AvenirNext-Regular" size:20];
  shareButton.contentEdgeInsets = UIEdgeInsetsMake(10, 12, 10, 12);
  [shareButton addTarget:self action:@selector(shareButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
  shareButton.layer.borderWidth = 1.0;
  shareButton.layer.borderColor = [UIColor blackColor].CGColor;
  shareButton.layer.cornerRadius = 8.0;
  
  UIButton *continueButton = [[UIButton alloc]init];
  [continueButton setTitle:@"Continue" forState:UIControlStateNormal];
  [continueButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
  continueButton.titleLabel.font = [UIFont fontWithName:@"AvenirNext-Regular" size:20];
  continueButton.contentEdgeInsets = UIEdgeInsetsMake(10, 12, 10, 12);
  [continueButton addTarget:self action:@selector(continueButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
  continueButton.layer.borderWidth = 1.0;
  continueButton.layer.borderColor = [UIColor blackColor].CGColor;
  continueButton.layer.cornerRadius = 8.0;
  
  self.parentView = [UIView new];
  
  
  [AutolayoutHelper configureView:self.view
                      subViews:VarBindings(shareButton, _parentView, continueButton)
                      constraints:@[@"H:|-20-[_parentView]-20-|",
                                    @"X:shareButton.centerX == superview.centerX",
                                    @"X:continueButton.centerX == superview.centerX",
                                    @"V:|-60-[_parentView]-25-[shareButton]-40-[continueButton]"]];
  
  NSLayoutConstraint *squareCode = [NSLayoutConstraint constraintWithItem:self.parentView
                                                                attribute:NSLayoutAttributeHeight
                                                                relatedBy:NSLayoutRelationEqual
                                                                toItem:self.parentView
                                                                attribute:NSLayoutAttributeWidth
                                                                multiplier:1 constant:0];
  
  
  [self.parentView addConstraint:squareCode];
  [AutolayoutHelper configureView:self.parentView fillWithSubView:self.qrCodeImage];
  [AutolayoutHelper configureView:self.parentView fillWithSubView:self.codeLabel];
  
  UITapGestureRecognizer *flipRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(flipDisplayItem:)];
  flipRecognizer.numberOfTapsRequired = 1;
  
  self.parentView.userInteractionEnabled = YES;
  
  [self.parentView addGestureRecognizer:flipRecognizer];
  
  self.qrCodeImage.hidden = YES;
}

-(void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  self.title = @"Create a space.";
}

-(void)flipDisplayItem : (UITapGestureRecognizer *)recognizer {
    [UIView transitionWithView:_parentView
                      duration:0.5
                       options:UIViewAnimationOptionTransitionFlipFromLeft
                    animations:^{
                      if(self.qrCodeImage.hidden) {
                        self.qrCodeImage.hidden = NO;
                        self.codeLabel.hidden = YES;
                      }
                      else {
                        self.qrCodeImage.hidden = YES;
                        self.codeLabel.hidden = NO;
                      }
                    } completion:nil];
}

-(IBAction)shareButtonTapped:(id)sender {
  UIActivityViewController *shareSheet;
  if(self.qrCodeImage.hidden) {
    shareSheet = [[UIActivityViewController alloc]initWithActivityItems:@[self.code] applicationActivities:nil];
  }
  else {
    shareSheet = [[UIActivityViewController alloc]initWithActivityItems:@[self.qrCodeImage.image] applicationActivities:nil];
  }
  [self presentViewController:shareSheet animated:YES completion:nil];
}

-(IBAction)continueButtonTapped:(id)sender {
  
  UITabBarController *tabBarController = [[UITabBarController alloc]init];
  tabBarController.tabBar.translucent = NO;

  UIImage *search = [UIImage imageNamed:@"search"];
  UIImage *queue = [UIImage imageNamed:@"queue"];
  UIImage *play = [UIImage imageNamed:@"play"];
  
  UITabBarItem *item1 = [[UITabBarItem alloc]initWithTitle:@"Search" image:search selectedImage:search];
  UITabBarItem *item2 = [[UITabBarItem alloc]initWithTitle:@"Queue" image:queue selectedImage:queue];
  UITabBarItem *item3 = [[UITabBarItem alloc]initWithTitle:@"Now Playing" image:play selectedImage:play];

  
  SearchViewController *searchController = [[SearchViewController alloc]init];
  searchController.tabBarItem = item1;
  
  QueueViewController *queueController = [[QueueViewController alloc]init];
  queueController.tabBarItem = item2;
  
  CurrentMusicController *playController = [[CurrentMusicController alloc]init];
  playController.tabBarItem = item3;
  [SocketManager sharedSocket].musicVC = playController;
  
  tabBarController.viewControllers = @[searchController, queueController, playController];
  
  
  
  UIBarButtonItem *backButton = [[UIBarButtonItem alloc]
                                 initWithTitle: @"Back"
                                 style: UIBarButtonItemStylePlain
                                 target: nil action: nil];
  [backButton setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                      [UIFont fontWithName:@"AvenirNext-Regular" size:18.0], NSFontAttributeName,
                                      [UIColor blackColor], NSForegroundColorAttributeName,
                                      nil] forState:UIControlStateNormal];
  
  [self.navigationItem setBackBarButtonItem: backButton];
  
  [self.navigationController pushViewController:tabBarController animated:YES];
}

@end
