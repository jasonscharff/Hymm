//
//  RESTSessionManager+Space.m
//  Hymn
//
//  Created by Jason Scharff on 2/20/16.
//  Copyright © 2016 Jason Scharff. All rights reserved.
//

#import "RESTSessionManager+Space.h"

#import "Constants.h"

#import <JNKeychain/JNKeychain.h>

#import "SocketManager.h"
#import "Song.h"

@implementation RESTSessionManager(Space)

-(void)joinSpaceWithIdentifier : (NSString *)identifier {
  identifier = [identifier lowercaseString];
  NSDictionary *parameters = @{@"share_id" : identifier};
  
  [self.requestSerializer setValue:[JNKeychain loadValueForKey:AUTH_TOKEN_KEY] forHTTPHeaderField:@"x-access-token"];

  [self GET:@"user/space" parameters:parameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
    if(![responseObject[@"success"]boolValue]) {
      [[NSNotificationCenter defaultCenter]postNotificationName:INVALID_SPACE_NAME_NOTIFICATION object:nil];
    }
    else {
      if(responseObject[@"song_uri"] != [NSNull null]) {
        [SocketManager sharedSocket].songURI = [NSURL URLWithString:responseObject[@"song_uri"]];
      }
      NSString *nsp = responseObject[@"space_id"];
      [SocketManager sharedSocket].nsp = nsp;
      [SocketManager sharedSocket].baseURL = responseObject[@"base_url"];
      [[NSNotificationCenter defaultCenter]postNotificationName:HAS_JOINED_SPACE object:nil];
    }
  } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
    NSLog(@"error = %@", error);
  }];
}

-(void)createSpace : (void (^)(NSString * spaceIdentifier))completion {
  [self.requestSerializer setValue:[JNKeychain loadValueForKey:AUTH_TOKEN_KEY] forHTTPHeaderField:@"x-access-token"];
  [self POST:@"user/space" parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
    NSString *nsp = responseObject[@"space_id"];
    [SocketManager sharedSocket].nsp = nsp;
    [SocketManager sharedSocket].baseURL = responseObject[@"base_url"];
    completion(responseObject[@"share_id"]);
  } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
    NSLog(@"error = %@", error);
  }];
}

- (void)addSongToQueue : (Song *)aSong {
  [self.requestSerializer setValue:[JNKeychain loadValueForKey:AUTH_TOKEN_KEY] forHTTPHeaderField:@"x-access-token"];
  NSDictionary *parameters = @{@"space_id" : [SocketManager sharedSocket].nsp,
                               @"spotify_uri" : aSong.spotifyURI,
                               @"song_length" : @(aSong.duration)};
  
  [self POST:@"space/queue" parameters:parameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
    
  } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
    
  }];
}

- (void)getQueue : (void (^)(NSArray <Song *> *))completion {
  [self.requestSerializer setValue:[JNKeychain loadValueForKey:AUTH_TOKEN_KEY] forHTTPHeaderField:@"x-access-token"];
  
  NSDictionary *parameters = @{@"space_id" : [SocketManager sharedSocket].nsp};
  
  [self GET:@"space/queue" parameters:parameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
    
    
    
  } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
    
  }];
}

@end
