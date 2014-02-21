//
//  RIPSectionCell.h
//  Notepad
//
//  Created by Nick on 1/22/14.
//  Copyright (c) 2014 Nick. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RIPSectionCell : UITableViewCell

- (void)setTitle:(NSString *)title;
- (NSString *)getTitle;
- (void)setColor:(UIColor *)color;

@end
