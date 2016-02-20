//
//  ImageArrangedButton.m
//  Hymn
//
//  Created by Jason Scharff on 2/20/16.
//  Copyright © 2016 Jason Scharff. All rights reserved.
//

#import "ImageArrangedButton.h"

@interface ImageArrangedButton()


@end

#import "AutolayoutHelper.h"


@implementation ImageArrangedButton

-(id)initWithCoder:(NSCoder *)aDecoder {
  self = [super initWithCoder:aDecoder];
  [self commonInit];
  return self;
}

-(id)initWithFrame:(CGRect)frame {
  self = [super initWithFrame:frame];
  [self commonInit];
  return self;
}

-(void)commonInit {
  self.imageView = [[UIImageView alloc]init];
  self.caption = [UILabel new];
  
  [AutolayoutHelper configureView:self
                      subViews:VarBindings(_imageView, _caption)
                      constraints:@[@"H:|[_imageView]-[_caption]|",
                                    @"V:|[_caption]|",
                                    @"V:|[_imageView]|"]];
  
  
}

//-(CGSize)intrinsicContentSize {
//  return CGSizeMake(self.frame, self.caption.frame.size.height);
//}

- (void) setHighlighted: (BOOL) highlighted {
  [super setHighlighted: highlighted];
//  self.tintShield.alpha = highlighted ? 0.2f : 0.0f;
}

@end
