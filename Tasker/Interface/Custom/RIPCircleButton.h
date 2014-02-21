//
//  RIPCircleButton.h
//  Notepad
//
//  Created by Nick on 1/25/14.
//  Copyright (c) 2014 Nick. All rights reserved.
//

#import "RIPCompletion.h"
#import <UIKit/UIKit.h>

@interface RIPCircleButton : UIButton

- (void)setColor:(UIColor *)color animated:(BOOL)animated;
- (void)setCompletion:(float)completion animated:(BOOL)animated;

- (float)getCompletion;

@end
