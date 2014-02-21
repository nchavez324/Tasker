//
//  RIPNotesViewController.h
//  Notepad
//
//  Created by Nick on 1/22/14.
//  Copyright (c) 2014 Nick. All rights reserved.
//

#import "RIPCompletion.h"
#import <UIKit/UIKit.h>

@class Section;

@interface RIPNotesViewController : UITableViewController

@property (strong, nonatomic) NSDictionary *section;

- (IBAction)fieldsDidEndEditing:(UIView *)sender;
- (void)updateCompletion:(float)average forNoteWithID:(NSManagedObjectID *)mid;

@end