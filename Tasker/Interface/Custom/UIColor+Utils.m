//
//  UIColor+Utils.m
//  Notepad
//
//  Created by Nick on 1/23/14.
//  Copyright (c) 2014 Nick. All rights reserved.
//

#import "UIColor+Utils.h"

@implementation UIColor (Utils)

+ (UIColor *)colorWithColor:(UIColor *)color alpha:(CGFloat)alpha {
    NSArray *rgba = [color getRGBAComponents];
    return [UIColor colorWithRed:[rgba[0] floatValue] green:[rgba[1] floatValue] blue:[rgba[2] floatValue] alpha:alpha];
}

- (NSArray *)getRGBAComponents {
    CGFloat r, g, b, a;
    if(![self getRed:&r green:&g blue:&b alpha:&a]){
        [self getWhite:&r alpha:&a];
        g = r;
        b = r;
    }
    return @[[NSNumber numberWithFloat:r],
             [NSNumber numberWithFloat:g],
             [NSNumber numberWithFloat:b],
             [NSNumber numberWithFloat:a]];
}

+ (UIColor *)colorWithRGBAArray:(NSArray *)rgbaArray {
    float r = [(NSNumber *)[rgbaArray objectAtIndex:0] floatValue];
    float g = [(NSNumber *)[rgbaArray objectAtIndex:1] floatValue];
    float b = [(NSNumber *)[rgbaArray objectAtIndex:2] floatValue];
    float a = 1.0;
    if(rgbaArray.count >= 4)
        a = [(NSNumber *)[rgbaArray objectAtIndex:3] floatValue];
    return [UIColor colorWithRed:r green:g blue:b alpha:a];
}

+ (UIColor *)goldColor {
    return [UIColor colorWithRed:0.94 green:0.84 blue:0 alpha:1.0];
}

+ (UIColor *)emeraldColor {
    return [UIColor colorWithRed:0.1 green:0.9 blue:0.25 alpha:1.0];
}

+ (UIColor *)ceruleanColor {
    return [UIColor colorWithRed:0.2 green:0 blue:0.86 alpha:1.0];
}

+ (UIColor *)tealColor {
    return [UIColor colorWithRed:0.0 green:0.87 blue:0.87 alpha:1.0];
}

+ (UIColor *)violetColor {
    return [UIColor colorWithRed:0.65 green:0.2 blue:0.62 alpha:1.0];
}

@end
