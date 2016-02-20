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

@interface SpotifyLoginViewController ()

@end

@implementation SpotifyLoginViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  self.view.backgroundColor = [UIColor whiteColor];
  [self loginToSpotify:self];
  
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
  [self playUsingSession:_session];
}

-(void)playUsingSession:(SPTSession *)session {
  
  // Create a new player if needed
  if (self.player == nil) {
    self.player = [[SPTAudioStreamingController alloc] initWithClientId:[SPTAuth defaultInstance].clientID];
  }
  
  [self.player loginWithSession:session callback:^(NSError *error) {
    if (error != nil) {
      NSLog(@"*** Logging in got error: %@", error);
      return;
    }
    
    NSURL *trackURI = [NSURL URLWithString:@"spotify:track:58s6EuEYJdlb0kO7awm3Vp"];
    [self.player playURIs:@[ trackURI ] fromIndex:0 callback:^(NSError *error) {
      if (error != nil) {
        NSLog(@"*** Starting playback got error: %@", error);
        return;
      }
    }];
  }];
}


@end
