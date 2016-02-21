//
//  Utilities.m
//  Hymn
//
//  Created by Jason Scharff on 2/20/16.
//  Copyright © 2016 Jason Scharff. All rights reserved.
//

#import "Utilities.h"

@implementation Utilities

+ (UIImage *)createQRForString:(NSString *)qrString {
  NSData *stringData = [qrString dataUsingEncoding: NSISOLatin1StringEncoding];
  
  CIFilter *qrFilter = [CIFilter filterWithName:@"CIQRCodeGenerator"];
  [qrFilter setValue:stringData forKey:@"inputMessage"];
  
  return [Utilities createNonInterpolatedUIImageFromCIImage:qrFilter.outputImage withScale:10];
}

+ (UIImage *)createNonInterpolatedUIImageFromCIImage:(CIImage *)image withScale:(CGFloat)scale
{
  // Render the CIImage into a CGImage
  CGImageRef cgImage = [[CIContext contextWithOptions:nil] createCGImage:image fromRect:image.extent];
  
  // Now we'll rescale using CoreGraphics
  UIGraphicsBeginImageContext(CGSizeMake(image.extent.size.width * scale, image.extent.size.width * scale));
  CGContextRef context = UIGraphicsGetCurrentContext();
  // We don't want to interpolate (since we've got a pixel-correct image)
  CGContextSetInterpolationQuality(context, kCGInterpolationNone);
  CGContextDrawImage(context, CGContextGetClipBoundingBox(context), cgImage);
  // Get the image out
  UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();
  // Tidy up
  UIGraphicsEndImageContext();
  CGImageRelease(cgImage);
  return scaledImage;
}

+ (NSString *)getSpotifyIDFromURI : (NSString *)uri {
  NSRange range = [uri rangeOfString:@":"];
  NSString *truncateOne = [uri substringFromIndex:range.location + range.length];
  range = [truncateOne rangeOfString:@":"];
  NSString *truncateTwo = [truncateOne substringFromIndex:range.location + range.length];
  return truncateTwo;
}

@end
