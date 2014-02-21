//
//  RIPSegmentCell.h
//  Notepad
//
//  Created by Nick on 1/24/14.
//  Copyright (c) 2014 Nick. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RIPCompletion.h"

@interface RIPSegmentCell : UITableViewCell

- (void)setTitle:(NSString *)title;
- (void)setCompletion:(float)completion animated:(BOOL)animated;
- (void)setContent:(NSString *)content;
- (void)setDate:(NSDate *)date;

- (NSString *)getTitle;
@end
