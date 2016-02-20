//
//  RESTSessionManager.m
//  Hymn
//
//  Created by Jason Scharff on 2/20/16.
//  Copyright © 2016 Jason Scharff. All rights reserved.
//

#import "RESTSessionManager.h"

#import "Constants.h"

@implementation RESTSessionManager

+ (instancetype)sharedSessionManager {
  static dispatch_once_t once;
  static RESTSessionManager *_sharedInstance;
  dispatch_once(&once, ^{
    _sharedInstance = [[self alloc] init];
  });
  
  return _sharedInstance;
}

-(id)init {
  NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
  configuration.requestCachePolicy = NSURLRequestReloadIgnoringLocalCacheData;
  self = [super initWithBaseURL:[NSURL URLWithString:BASE_URL] sessionConfiguration:configuration];
  return self;
}



@end
