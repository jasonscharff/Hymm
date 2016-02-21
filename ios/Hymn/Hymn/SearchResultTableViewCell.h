//
//  SearchResultTableViewCell.h
//  Hymn
//
//  Created by Jason Scharff on 2/20/16.
//  Copyright © 2016 Jason Scharff. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Song;

@interface SearchResultTableViewCell : UITableViewCell

-(void)configureFromSong: (Song *)song;

@end
