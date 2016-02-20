//
//  SpotifyLoginViewController.h
//  Hymn
//
//  Created by Jason Scharff on 2/20/16.
//  Copyright © 2016 Jason Scharff. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SPTSession, SPTAudioStreamingController;

@interface SpotifyLoginViewController : UIViewController

@property (nonatomic, strong) SPTSession *session;
@property (nonatomic, strong) SPTAudioStreamingController *player;



-(void)setSession:(SPTSession *)session;

@end

