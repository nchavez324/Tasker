//
//  UIColor+Utils.h
//  Notepad
//
//  Created by Nick on 1/23/14.
//  Copyright (c) 2014 Nick. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (Utils)

+ (UIColor *)colorWithColor:(UIColor *)color alpha:(CGFloat)alpha;

+ (UIColor *)goldColor;
+ (UIColor *)emeraldColor;
+ (UIColor *)ceruleanColor;
+ (UIColor *)tealColor;
+ (UIColor *)violetColor;
+ (UIColor *)colorWithRGBAArray:(NSArray *)rgbaArray;

- (NSArray *)getRGBAComponents;

@end
