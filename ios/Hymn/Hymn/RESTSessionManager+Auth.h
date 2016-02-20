//
//  RESTSessionManager+Auth.h
//  Hymn
//
//  Created by Jason Scharff on 2/20/16.
//  Copyright © 2016 Jason Scharff. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RESTSessionManager.h"

@class SPTSession;

@interface RESTSessionManager(Auth)

-(void)loginWithSession : (SPTSession *)session;

@end
