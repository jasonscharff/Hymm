//
//  SearchResultTableViewCell.m
//  Hymn
//
//  Created by Jason Scharff on 2/20/16.
//  Copyright © 2016 Jason Scharff. All rights reserved.
//

#import "SearchResultTableViewCell.h"

#import "AutolayoutHelper.h"

#import "UIImageView+AFNetworking.h"
#import "Song.h"


@interface SearchResultTableViewCell()

@property (nonatomic, strong) UIImageView *coverArtImageView;
@property (nonatomic, strong) UILabel *artistLabel;
@property (nonatomic, strong) UILabel *songLabel;

@end

@implementation SearchResultTableViewCell

-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
  self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
  
  self.coverArtImageView = [[UIImageView alloc]init];
  [AutolayoutHelper configureView:self.contentView fillWithSubView:self.coverArtImageView];
  
  UIVisualEffect *blurEffect;
  blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
  
  UIVisualEffectView *visualEffectView;
  visualEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
  
  [AutolayoutHelper configureView:self.contentView fillWithSubView:visualEffectView];
  
  
  UIView *parentView = [UIView new];
  
  self.songLabel = [UILabel new];
  self.songLabel.font = [UIFont fontWithName:@"AvenirNext-DemiBold" size:24];
  self.songLabel.textColor = [UIColor whiteColor];
  self.songLabel.numberOfLines = 0;
  self.songLabel.textAlignment = NSTextAlignmentCenter;
  
  self.artistLabel = [UILabel new];
  self.artistLabel.font = [UIFont fontWithName:@"AvenirNext-Regular" size:20];
  self.artistLabel.textColor = [UIColor whiteColor];
  [AutolayoutHelper configureView:parentView
                         subViews:VarBindings(_songLabel, _artistLabel)
                      constraints:@[@"H:|-20-[_songLabel]-20-|",
                                    @"X:_artistLabel.centerX == superview.centerX",
                                    @"V:|[_songLabel]-16-[_artistLabel]|"]];
  
  [AutolayoutHelper configureView:self.contentView
                         subViews:VarBindings(parentView)
                         constraints:@[@"X:parentView.centerX == superview.centerX",
                                       @"X:parentView.centerY == superview.centerY",
                                       @"X:parentView.width <= superview.width"]];
  
  
  
  return self;
}

-(void)configureFromSong: (Song *)song {
  [self.coverArtImageView setImageWithURL:[NSURL URLWithString:song.imageURL]];
  self.artistLabel.text = song.artistName;
  self.songLabel.text = song.name;
}


@end
