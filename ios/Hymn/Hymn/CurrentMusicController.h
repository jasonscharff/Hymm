//
//  CurrentMusicController.h
//  Hymn
//
//  Created by Jason Scharff on 2/20/16.
//  Copyright © 2016 Jason Scharff. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CurrentMusicController : UIViewController

-(void)updateProgresss : (CGFloat)progress;
-(void)goToEmptyRoom;
-(void)newSongWithURI : (NSString *)uri;
-(void)setPauseButtonImage;
-(void)setPlayButtonImage;

@end
