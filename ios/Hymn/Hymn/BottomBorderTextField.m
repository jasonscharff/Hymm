//
//  BottomBorderTextField.m
//  Ink
//
//  Created by Jason Scharff on 1/23/16.
//  Copyright © 2016 Jason Scharff. All rights reserved.
//

#import "BottomBorderTextField.h"

@implementation BottomBorderTextField

- (instancetype)initWithBorderColor:(UIColor *)color borderWidth:(CGFloat)width {
  self = [super init];
  self.borderColor = color;
  self.borderWidth = width;
  return self;
}

- (void)drawRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();
    //Set the line color and width
    CGContextSetStrokeColorWithColor(context, self.borderColor.CGColor);
    CGContextSetLineWidth(context, self.borderWidth);
    //Start a new Path
    CGContextBeginPath(context);
    
    CGContextMoveToPoint(context, self.bounds.origin.x, self.font.lineHeight);
    CGContextAddLineToPoint(context, self.bounds.size.width, self.font.lineHeight);
    
    //Close our Path and Stroke (draw) it
    CGContextClosePath(context);
    CGContextStrokePath(context);
}

@end
