//
//  SpotifyRESTSessionManager.m
//  Hymn
//
//  Created by Jason Scharff on 2/20/16.
//  Copyright © 2016 Jason Scharff. All rights reserved.
//

#import "SpotifyRESTSessionManager.h"

#import "Constants.h"

#import "JNKeychain.h"
#import "Song.h"


@implementation SpotifyRESTSessionManager

+ (instancetype)sharedSessionManager {
  static dispatch_once_t once;
  static SpotifyRESTSessionManager *_sharedInstance;
  dispatch_once(&once, ^{
    _sharedInstance = [[self alloc] init];
  });
  
  return _sharedInstance;
}

-(id)init {
  NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
  configuration.requestCachePolicy = NSURLRequestReloadIgnoringLocalCacheData;
  self = [super initWithBaseURL:[NSURL URLWithString:SPOTIFY_BASE_URL] sessionConfiguration:configuration];
  return self;
}

-(void)searchWithQuery : (NSString *)query : (void (^)(NSArray<Song *> *))completion {
  [self.requestSerializer setValue:[NSString stringWithFormat:@"Bearer %@", [JNKeychain loadValueForKey:SPOTIFY_AUTH_KEY]] forHTTPHeaderField:@"Authorization"];
  NSDictionary *parameters = @{@"q" : query,
                               @"type" : @"track"};
  [self GET:@"search" parameters:parameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
    NSArray *tracks = responseObject[@"tracks"][@"items"];
    NSMutableArray *songs = [[NSMutableArray alloc]initWithCapacity:tracks.count];
    for (NSDictionary *trackDictionary in tracks) {
      Song *aSong = [[Song alloc]init];
      [aSong setupFromJSONDictionary:trackDictionary];
      [songs addObject:aSong];
    }
    completion(songs);
  } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
    NSLog(@"error = %@", error);
    [[NSNotificationCenter defaultCenter]postNotificationName:SEARCH_FAILED object:nil];
  }];
}

-(void)getSongFromIdentifier : (NSString *)identifier : (void (^)(Song * aSong))completion {
  [self.requestSerializer setValue:[NSString stringWithFormat:@"Bearer %@", [JNKeychain loadValueForKey:SPOTIFY_AUTH_KEY]] forHTTPHeaderField:@"Authorization"];
  [self GET:[NSString stringWithFormat:@"tracks/%@", identifier] parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
    Song *aSong = [[Song alloc]init];
    [aSong setupFromJSONDictionary:responseObject];
    completion(aSong);
  } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
    NSLog(@"error = %@", error);
  }];
}

@end
