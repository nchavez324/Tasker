//
//  RIPEditSegmentViewController.h
//  Notepad
//
//  Created by Nick on 1/25/14.
//  Copyright (c) 2014 Nick. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RIPSegmentsViewController;

@interface RIPEditSegmentViewController  : UITableViewController <UITextFieldDelegate>
@property (strong, nonatomic) NSMutableDictionary *segment;
@property (weak, nonatomic) RIPSegmentsViewController *segementsVC;

- (IBAction)pickerValueChanged:(UIDatePicker *)sender;
- (IBAction)titleEditingDidEnd:(UITextField *)sender;
- (void)updateReminderInterval:(NSNumber *)interval;

@end
