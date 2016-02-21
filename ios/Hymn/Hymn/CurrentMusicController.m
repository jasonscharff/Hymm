//
//  CurrentMusicController.m
//  Hymn
//
//  Created by Jason Scharff on 2/20/16.
//  Copyright © 2016 Jason Scharff. All rights reserved.
//

#import "CurrentMusicController.h"


#import "AutolayoutHelper.h"
#import "EmptyRoomViewController.h"
#import "SocketManager.h"
#import "Song.h"
#import <Spotify/Spotify.h>
#import "SpotifyRESTSessionManager.h"
#import "UIImageView+AFNetworking.h"
#import "Utilities.h"

@interface CurrentMusicController ()

@property (nonatomic, strong) UIImageView *albumArtwork;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *artistLabel;
@property (nonatomic, strong) UIProgressView *progressView;
@property (nonatomic, strong) UIButton *playpause;


@end

@implementation CurrentMusicController

- (void)viewDidLoad {
  [super viewDidLoad];
  self.view.backgroundColor = [UIColor whiteColor];
  self.title = @"Now Playing";
  _albumArtwork = [[UIImageView alloc]init];
  _titleLabel = [[UILabel alloc]init];
  _titleLabel.textAlignment = NSTextAlignmentCenter;
  _titleLabel.font = [UIFont fontWithName:@"AvenirNext-DemiBold" size:24];
  _artistLabel = [[UILabel alloc]init];
  _artistLabel.textAlignment = NSTextAlignmentCenter;
  _artistLabel.font = [UIFont fontWithName:@"AvenirNext-Regular" size:20];
  _progressView = [[UIProgressView alloc]initWithProgressViewStyle:UIProgressViewStyleDefault];
  _playpause = [[UIButton alloc]init];
  UIButton *next = [[UIButton alloc]init];
  UIButton *previous = [[UIButton alloc]init];
  
  [next addTarget:self action:@selector(nextButtonPressed:) forControlEvents:UIControlEventTouchDown];
  [previous addTarget:self action:@selector(previousButtonPressed:) forControlEvents:UIControlEventTouchDown];
  [_playpause addTarget:self action:@selector(playPausePressed:) forControlEvents:UIControlEventTouchDown];
  
  [next setBackgroundImage:[UIImage imageNamed:@"next"] forState:UIControlStateNormal];
  [previous setBackgroundImage:[UIImage imageNamed:@"previous"] forState:UIControlStateNormal];
  [self setPlayPauseImage];
  
  
  UIStackView *stackView = [[UIStackView alloc]initWithArrangedSubviews:@[previous, _playpause, next]];
  stackView.axis = UILayoutConstraintAxisHorizontal;
  stackView.distribution = UIStackViewDistributionEqualCentering;
  
  [AutolayoutHelper configureView:self.view
                         subViews:VarBindings(_albumArtwork, _titleLabel, _artistLabel, _progressView, stackView)
                      constraints:@[@"H:|[_albumArtwork]|",
                                    @"H:|[_progressView]|",
                                    @"H:|-20-[_titleLabel]-20-|",
                                    @"H:|-20-[_artistLabel]-20-|",
                                    @"|-40-[stackView]-40-|",
                                    @"V:|[_albumArtwork][_progressView]-(<=25)-[_titleLabel]-[_artistLabel]-(>=8)-[stackView]-(>=40)-|"]];
  
  NSLayoutConstraint *squareAlbum = [NSLayoutConstraint constraintWithItem:_albumArtwork
                                                                 attribute:NSLayoutAttributeHeight
                                                                 relatedBy:NSLayoutRelationEqual
                                                                 toItem:_albumArtwork
                                                                 attribute:NSLayoutAttributeWidth
                                                                 multiplier:1 constant:0];
  
  [self.view addConstraint:squareAlbum];
                            
  
}

-(void)setPlayPauseImage {
  if([SocketManager sharedSocket].player.isPlaying) {
    [_playpause setBackgroundImage:[UIImage imageNamed:@"pause"] forState:UIControlStateNormal];
  }
  else {
    [_playpause setBackgroundImage:[UIImage imageNamed:@"play"] forState:UIControlStateNormal];
  }
}

- (IBAction)playPausePressed:(id)sender {
  if([SocketManager sharedSocket].player.isPlaying) {
    [[SocketManager sharedSocket].player setIsPlaying:NO callback:^(NSError *error) {
      
    }];
  }
  [[SocketManager sharedSocket].player setIsPlaying:YES callback:^(NSError *error) {
    
  }];
  [self setPlayPauseImage];
}

-(IBAction)nextButtonPressed:(id)sender {
  [[SocketManager sharedSocket].player skipNext:^(NSError *error) {
    
  }];
}

-(IBAction)previousButtonPressed:(id)sender {
  [[SocketManager sharedSocket].player skipPrevious:^(NSError *error) {
    
  }];
}

-(void)newSongWithURI : (NSString *)uri {
  NSString *identifier = [Utilities getSpotifyIDFromURI:uri];
  [[SpotifyRESTSessionManager sharedSessionManager]getSongFromIdentifier:identifier :^(Song *aSong) {
    self.titleLabel.text = aSong.name;
    self.artistLabel.text = aSong.artistName;
    [self.albumArtwork setImageWithURL:[NSURL URLWithString:aSong.imageURL]];
  }];
}

-(void)goToEmptyRoom {
  self.navigationItem.hidesBackButton = YES;
  self.navigationItem.leftBarButtonItem = nil;
  EmptyRoomViewController *vc = [[EmptyRoomViewController alloc]init];
  [self.navigationController pushViewController:vc animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)updateProgresss:(CGFloat)progress {
  _progressView.progress = progress;
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
