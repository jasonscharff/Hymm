//
//  Song.h
//  Hymn
//
//  Created by Jason Scharff on 2/20/16.
//  Copyright © 2016 Jason Scharff. All rights reserved.
//

#import <Realm/Realm.h>

@interface Song : RLMObject

@property NSString *name;
@property NSString *imageURL;
@property NSString *artistName;
@property NSString *spotifyURI;

-(void)setupFromJSONDictionary : (NSDictionary *)dictionary;

@end

// This protocol enables typed collections. i.e.:
// RLMArray<Song>
RLM_ARRAY_TYPE(Song)
