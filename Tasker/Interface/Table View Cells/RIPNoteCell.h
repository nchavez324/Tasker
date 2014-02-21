//
//  RIPNoteCell.h
//  Notepad
//
//  Created by Nick on 1/23/14.
//  Copyright (c) 2014 Nick. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RIPCompletion.h"

@interface RIPNoteCell : UITableViewCell

- (void)setCompletion:(float)completion animated:(BOOL)animated;
- (void)setTitle:(NSString *)title;
- (void)setColor:(UIColor *)color animated:(BOOL)animated;

- (NSString *)getTitle;
- (float)getCompletion;

@end
