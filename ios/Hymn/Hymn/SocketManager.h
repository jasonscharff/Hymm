//
//  SocketManager.h
//  Hymn
//
//  Created by Jason Scharff on 2/20/16.
//  Copyright © 2016 Jason Scharff. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <Spotify/Spotify.h>

#import <SocketIOClientSwift/SocketIOClientSwift-Swift.h>

#import "CurrentMusicController.h"

@interface SocketManager : NSObject

+ (instancetype)sharedSocket;

@property (nonatomic, strong) SPTSession *spotifySession;
@property (nonatomic, strong) SPTAudioStreamingController *player;
@property (nonatomic, strong) NSURL *songURI;
@property (nonatomic, strong) NSString *baseURL;
@property (nonatomic, strong) SocketIOClient *socketIOClient;
@property (nonatomic, strong) NSString *nsp;

@property (nonatomic, strong) CurrentMusicController *musicVC;

@end
