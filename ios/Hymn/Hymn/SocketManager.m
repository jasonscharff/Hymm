//
//  SocketManager.m
//  Hymn
//
//  Created by Jason Scharff on 2/20/16.
//  Copyright © 2016 Jason Scharff. All rights reserved.
//

#import "SocketManager.h"

#import "Constants.h"

@interface SocketManager()

@property (nonatomic, strong) CADisplayLink *displayLink;
@property (nonatomic) int displayCounter;
@property (nonatomic) NSTimer *timer;

@end

@implementation SocketManager

+ (instancetype)sharedSocket {
  static dispatch_once_t once;
  static SocketManager *_sharedInstance;
  dispatch_once(&once, ^{
    _sharedInstance = [[self alloc] init];
  });
  
  return _sharedInstance;
}

-(id)init {
  self = [super init];
  self.player = [[SPTAudioStreamingController alloc] initWithClientId:[SPTAuth defaultInstance].clientID];
  return self;
}

-(void)setBaseURL:(NSString *)baseURL {
  _baseURL = baseURL;
  if(self.nsp) {
    [self configureSocket];
  }
}

-(void)setNsp:(NSString *)nsp {
  _nsp = nsp;
  if(self.baseURL) {
    [self configureSocket];
  }
}

-(void)configureSocket {
  self.socketIOClient = [[SocketIOClient alloc] initWithSocketURL:[NSURL URLWithString:_baseURL] options:@{@"nsp" : self.nsp, @"log" : @NO}];
  [self.socketIOClient on:@"connect" callback:^(NSArray* data, SocketAckEmitter* ack) {
    NSLog(@"connect data = %@", data);
    //    self.displayCounter = 0;
    //    _displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(sendUpdate:)];
    //    [_displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
    
  }];
  [self.socketIOClient on:@"stop_timer" callback:^(NSArray * _Nonnull data, SocketAckEmitter * _Nonnull ack) {
    [_displayLink removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
  }];
  [self.socketIOClient on:@"next_song" callback:^(NSArray * _Nonnull data, SocketAckEmitter * _Nonnull ack) {
    if(data[0] == [NSNull null]) {
      if(self.timer) {
        [self.timer invalidate];
        self.timer = nil;
      }
      [self.musicVC goToEmptyRoom];
    }
    else {
      [self setSongURI:[NSURL URLWithString:data[0]]];
      if(!self.timer) {
        [[NSNotificationCenter defaultCenter]postNotificationName:SONG_HAS_BEEN_CHOSEN object:nil];
        self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(updateProgress:) userInfo:nil repeats:YES];
      }
      
    }
    
  }];
  [self.socketIOClient on:@"seek" callback:^(NSArray * _Nonnull data, SocketAckEmitter * _Nonnull ack) {
    int serverTime = [data[0]intValue];
    if(ABS(self.player.currentPlaybackPosition - serverTime) > 1000) {
      [self.player seekToOffset:[data[0]intValue] callback:nil];
    }
  }];
  
  [self.socketIOClient connect];
}

-(void)setSpotifySession:(SPTSession *)spotifySession {
  _spotifySession = spotifySession;
  [self.player loginWithSession:spotifySession callback:^(NSError *error) {
    NSLog(@"error = %@", error);
  }];
}

-(void)setSongURI:(NSURL *)songURI {
  _songURI = songURI;
  [self.player playURIs:@[songURI] fromIndex:0 callback:^(NSError *error) {
    if(error) {
      NSLog(@"an error has occurred");
    }
    else {
      [self.musicVC newSongWithURI:[songURI absoluteString]];
    }
  }];
}

-(void)sendUpdate : (CADisplayLink *)displayLink {
//  if(self.displayCounter %3 == 0) {
//    [self.socketIOClient emit:@"time_update" withItems:@[@(_player.currentPlaybackPosition)]];
//  }
//  self.displayCounter++;
  
}

-(void)updateProgress: (NSTimer *)timer {
  CGFloat ratio = ((CGFloat)self.player.currentPlaybackPosition) / ((CGFloat)self.player.currentTrackDuration);
  [self.musicVC updateProgresss:ratio];
}



@end
