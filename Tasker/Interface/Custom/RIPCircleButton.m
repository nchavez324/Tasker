//
//  RIPCircleButton.m
//  Notepad
//
//  Created by Nick on 1/25/14.
//  Copyright (c) 2014 Nick. All rights reserved.
//

#import "UIColor+Utils.h"
#import "RIPCircleButton.h"

@interface RIPCircleButton ()
@property (strong, nonatomic) UIColor *foregroundColor;
@property (assign, nonatomic) float completion;
@end

@implementation RIPCircleButton

- (id)initWithFrame:(CGRect)frame {
    if(self = [super initWithFrame:frame])
        [self initialize];
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    if(self = [super initWithCoder:aDecoder])
        [self initialize];
    return self;
}


- (void)initialize {
    self.backgroundColor = [UIColor clearColor];
    self.completion = 0.0;
    [self setColor:[UIColor darkGrayColor] animated:NO];
    self.titleLabel.text = @"";
}

- (void)setColor:(UIColor *)color animated:(BOOL)animated{
    _foregroundColor = color;
    UIImage *circle = [RIPCircleButton circleForRect:self.frame color:_foregroundColor completion:_completion];
    if(animated)
        [UIView beginAnimations:nil context:nil];
    [self setImage:circle forState:UIControlStateNormal];
    if(animated)
        [UIView commitAnimations];
}

- (void)setCompletion:(float)completion animated:(BOOL)animated{
    _completion = completion;
    UIImage *circle = [RIPCircleButton circleForRect:self.frame color:_foregroundColor completion:_completion];
    if(animated)
        [UIView beginAnimations:nil context:nil];
    [self setImage:circle forState:UIControlStateNormal];
    if(animated)
        [UIView commitAnimations];
}

- (float)getCompletion {
    return _completion;
}

static inline int radToDeg(float rad){
    return (int)((rad*180)/(M_PI));
}

+ (UIImage *)circleForRect:(CGRect)rect color:(UIColor *)color completion:(float)completion{
    CGFloat scale = [UIScreen mainScreen].scale;
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, scale);
    CGContextRef context = UIGraphicsGetCurrentContext();
    //CGContextScaleCTM(context, scale, scale);
    NSArray *rgba = [color getRGBAComponents];
    CGFloat r = [rgba[0] floatValue], g = [rgba[1] floatValue], b = [rgba[2] floatValue], a = [rgba[3] floatValue];
    CGContextSetRGBStrokeColor(context, r, g, b, a);
    CGContextSetAlpha(context, 1.0);
    CGContextSetLineWidth(context, 2.0);
    CGContextAddEllipseInRect(context, CGRectMake(1, 1, rect.size.width - 2, rect.size.height - 2));
    CGContextStrokePath(context);
    
    if(completion >= 1){
        CGContextSetRGBFillColor(context, r, g, b, a);
        CGContextSetAlpha(context, 1.0);
        CGContextFillEllipseInRect(context, CGRectMake(1, 1, rect.size.width - 2, rect.size.height - 2));
    }else if(completion > 0){
        static float minAngle = (M_PI - M_PI_4), maxSpace = 0.6;
        float interval = M_PI;
        
        float topAngle = minAngle - (interval*(1.0 - maxSpace)/2.0) - (completion*interval*maxSpace);
        float btmAngle = minAngle + (interval*(1.0 - maxSpace)/2.0) + (completion*interval*maxSpace);
        
        while(btmAngle > 2*M_PI)
            btmAngle -= (2*M_PI);
        while(topAngle > 2*M_PI)
            topAngle -= (2*M_PI);
        
        CGContextSetRGBFillColor(context, r, g, b, a);
        CGContextBeginPath(context);
        CGContextAddArc(context, rect.size.width/2.0, rect.size.height/2.0, rect.size.width/2.0 - 1,
                        topAngle, btmAngle, 0);
        CGContextFillPath(context);
    }
    
    CGImageRef imgRef = CGBitmapContextCreateImage(context);
    UIImage *img = [UIImage imageWithCGImage:imgRef];
    CGImageRelease(imgRef);
    CGContextRelease(context);
    return img;
}

@end
