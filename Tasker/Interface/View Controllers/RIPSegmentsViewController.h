//
//  RIPSegmentsViewController.h
//  Notepad
//
//  Created by Nick on 1/22/14.
//  Copyright (c) 2014 Nick. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Section, Note, RIPNotesViewController, RIPCircleButton;

@interface RIPSegmentsViewController : UITableViewController

@property (strong, nonatomic) NSDictionary *section;
@property (strong, nonatomic) NSDictionary *note;
@property (weak, nonatomic) RIPNotesViewController *notesVC;

- (IBAction)fieldsDidEndEditing:(RIPCircleButton *)sender;
- (void)updateSegmentsWith:(NSMutableDictionary *)segment;

@end
