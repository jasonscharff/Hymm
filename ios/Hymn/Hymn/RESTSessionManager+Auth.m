//
//  RESTSessionManager+Auth.m
//  Hymn
//
//  Created by Jason Scharff on 2/20/16.
//  Copyright © 2016 Jason Scharff. All rights reserved.
//

#import "RESTSessionManager+Auth.h"

#import "Constants.h"

#import <Spotify/Spotify.h>
#import <JNKeychain/JNKeychain.h>

@implementation RESTSessionManager(Auth)

-(void)loginWithSession:(SPTSession *)session {
  NSDictionary *parameters = @{@"username" : session.canonicalUsername,
                               @"access_token" : session.accessToken};
  [self POST:@"user/login" parameters:parameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
    [JNKeychain saveValue:responseObject[@"auth_token"] forKey:AUTH_TOKEN_KEY];
    
  } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
    NSLog(@"error = %@", error);
  }];
}

@end
