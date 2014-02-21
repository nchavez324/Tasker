//
//  RIPReminderViewController.h
//  Tasker
//
//  Created by Nick on 2/17/14.
//  Copyright (c) 2014 Nick. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RIPEditSegmentViewController;

@interface RIPReminderViewController : UITableViewController
@property (strong, nonatomic) NSNumber *timeInterval;
@property (strong, nonatomic) RIPEditSegmentViewController *editSegVc;
@end
