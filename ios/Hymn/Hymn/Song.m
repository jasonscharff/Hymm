//
//  Song.m
//  Hymn
//
//  Created by Jason Scharff on 2/20/16.
//  Copyright © 2016 Jason Scharff. All rights reserved.
//

#import "Song.h"

@implementation Song

-(void)setupFromJSONDictionary : (NSDictionary *)dictionary {
  self.name = dictionary[@"name"];
  self.spotifyURI = dictionary[@"uri"];
  NSArray *images = dictionary[@"album"][@"images"];
  if(images.count == 0) {
    self.imageURL = @"";
  }
  else if (images.count == 1) {
    self.imageURL = images[0][@"url"];
  }
  else {
    self.imageURL = images[1][@"url"];
  }
  
  self.artistName = dictionary[@"artists"][0][@"name"]; //Note, there could be multiple artists. I'm just using the first one listed.
}

// Specify default values for properties

//+ (NSDictionary *)defaultPropertyValues
//{
//    return @{};
//}

// Specify properties to ignore (Realm won't persist these)

//+ (NSArray *)ignoredProperties
//{
//    return @[];
//}

@end
