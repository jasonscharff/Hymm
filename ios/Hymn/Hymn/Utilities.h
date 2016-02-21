//
//  Utilities.h
//  Hymn
//
//  Created by Jason Scharff on 2/20/16.
//  Copyright © 2016 Jason Scharff. All rights reserved.
//

#import <Foundation/Foundation.h>

@import UIKit;

@interface Utilities : NSObject

+ (UIImage *)createQRForString:(NSString *)qrString;
+ (NSString *)getSpotifyIDFromURI : (NSString *)uri;

@end
