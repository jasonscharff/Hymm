//
//  RESTSessionManager+Space.h
//  Hymn
//
//  Created by Jason Scharff on 2/20/16.
//  Copyright © 2016 Jason Scharff. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RESTSessionManager.h"

@interface RESTSessionManager(Space)

-(void)joinSpaceWithIdentifier : (NSString *)identifier;
-(void)createSpace : (void (^)(NSString * spaceIdentifier))completion;

@end
