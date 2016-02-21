//
//  SpotifyRESTSessionManager.h
//  Hymn
//
//  Created by Jason Scharff on 2/20/16.
//  Copyright © 2016 Jason Scharff. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AFNetworking/AFNetworking.h>

@class Song;

@interface SpotifyRESTSessionManager : AFHTTPSessionManager

+ (instancetype)sharedSessionManager;
- (void)searchWithQuery : (NSString *)query : (void (^)(NSArray<Song *> *))completion;
-(void)getSongFromIdentifier : (NSString *)identifier : (void (^)(Song * aSong))completion;

@end
