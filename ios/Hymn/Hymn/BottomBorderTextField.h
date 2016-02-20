//
//  BottomBorderTextField.h
//  Ink
//
//  Created by Jason Scharff on 1/23/16.
//  Copyright © 2016 Jason Scharff. All rights reserved.
//

@import UIKit;

@interface BottomBorderTextField : UITextField

@property (nonatomic) CGFloat borderWidth;
@property (nonatomic, strong) UIColor *borderColor;

- (instancetype)initWithBorderColor:(UIColor *)color
                        borderWidth:(CGFloat)width;

@end
