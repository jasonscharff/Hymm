//
//  SpotifyLoginViewController.m
//  Hymn
//
//  Created by Jason Scharff on 2/20/16.
//  Copyright © 2016 Jason Scharff. All rights reserved.
//

#import "SpotifyLoginViewController.h"

#import "Constants.h"

#import <Spotify/Spotify.h>

#import "AppDelegate.h"
#import "AutolayoutHelper.h"
#import "ImageArrangedButton.h"
#import "JoinOrCreateViewController.h"
#import "RESTSessionManager+Auth.h"
#import "UIColor+ColorPalette.h"

@interface SpotifyLoginViewController ()

@end

@implementation SpotifyLoginViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  self.view.backgroundColor = [UIColor whiteColor];
  UIImageView *backgroundView = [[UIImageView alloc]initWithFrame:self.view.frame];
  [self.view addSubview:backgroundView];
  backgroundView.image = [UIImage imageNamed:@"gradient"];
  
  UILabel *welcomeLabel = [UILabel new];
  welcomeLabel.text = @"Welcome.";
  welcomeLabel.font = [UIFont fontWithName:@"AvenirNext-Regular" size:30];
  [AutolayoutHelper configureView:self.view subViews:VarBindings(welcomeLabel) constraints:@[@"X:welcomeLabel.centerX == superview.centerX"]];
  
  NSLayoutConstraint *centerWelcomeLabelVertically = [NSLayoutConstraint constraintWithItem:welcomeLabel
                                                              attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterY multiplier:1 constant:0];
  [self.view addConstraint:centerWelcomeLabelVertically];
  
  
  UILabel *descriptionLabel = [UILabel new];
  descriptionLabel.text = @"In order to listen, we will need you to sign in with your Spotify premium account.";
  descriptionLabel.alpha = 0;
  
  descriptionLabel.font = [UIFont fontWithName:@"AvenirNext-Regular" size:16];
  descriptionLabel.textAlignment = NSTextAlignmentCenter;
  descriptionLabel.numberOfLines = 0;
  
  ImageArrangedButton *loginWithSpotifyButton = [[ImageArrangedButton alloc]init];
  loginWithSpotifyButton.imageView.image = [UIImage imageNamed:@"spotify_logo"];
  loginWithSpotifyButton.caption.text = @"Login";
  loginWithSpotifyButton.caption.font = [UIFont fontWithName:@"AvenirNext-Regular" size:24];
  loginWithSpotifyButton.alpha = 0;
  [loginWithSpotifyButton addTarget:self action:@selector(loginToSpotify:) forControlEvents:UIControlEventTouchUpInside];
  
  
  
  dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.8 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
    [AutolayoutHelper configureView:self.view
                           subViews:VarBindings(welcomeLabel, descriptionLabel, loginWithSpotifyButton)
                        constraints:@[@"|-[descriptionLabel]-|",
                                      @"X:loginWithSpotifyButton.centerX == superview.centerX",
                                      @"V:|-45-[welcomeLabel]-12-[descriptionLabel]-25-[loginWithSpotifyButton]"]];
    [self.view layoutIfNeeded];
    [self.view removeConstraint:centerWelcomeLabelVertically];
    
    [UIView animateWithDuration:1.2 animations:^{
      [self.view layoutIfNeeded];
    } completion:^(BOOL finished) {
      [UIView animateWithDuration:0.5 animations:^{
        loginWithSpotifyButton.alpha = 1;
        descriptionLabel.alpha = 1;
      } completion:nil];
    }];
});
  
  
  
  
  // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

-(IBAction)loginToSpotify:(id)sender {
  [[SPTAuth defaultInstance] setClientID:SPOTIFY_CLIENT_ID];
  [[SPTAuth defaultInstance] setRedirectURL:[NSURL URLWithString:SPOTIFY_CALLBACK_URL]];
  [[SPTAuth defaultInstance] setRequestedScopes:@[SPTAuthStreamingScope]];
  
  // Construct a login URL and open it
  NSURL *loginURL = [[SPTAuth defaultInstance] loginURL];
  [[UIApplication sharedApplication] performSelector:@selector(openURL:)
                                          withObject:loginURL afterDelay:0.1];
}

-(void)setSession:(SPTSession *)session {
  _session = session;
  
  [[RESTSessionManager sharedSessionManager]loginWithSession:session];
  
  UINavigationController *navController = [[UINavigationController alloc]init];
  navController.navigationBar.barTintColor = [UIColor navbarColor];
  navController.navigationBar.tintColor = [UIColor whiteColor];
  navController.navigationBar.translucent = NO;
  
  [navController.navigationBar setTitleTextAttributes:
   @{NSForegroundColorAttributeName:[UIColor blackColor],
     NSFontAttributeName:[UIFont fontWithName:@"AvenirNext-Regular" size:21]}];
  
  JoinOrCreateViewController *nextVC = [[JoinOrCreateViewController alloc]init];
  [navController pushViewController:nextVC animated:NO];
  [self presentViewController:navController animated:YES completion:nil];
  
}


@end
