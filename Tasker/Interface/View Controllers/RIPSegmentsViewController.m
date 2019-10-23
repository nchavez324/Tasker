//
//  RIPSegmentsViewController.m
//  Notepad
//
//  Created by Nick on 1/22/14.
//  Copyright (c) 2014 Nick. All rights reserved.
//

#import "UIColor+Utils.h"
#import "Section.h"
#import "Note.h"
#import "Segment.h"
#import "RIPCircleButton.h"
#import "RIPSegmentCell.h"
#import "RIPCoreDataController.h"
#import "RIPCoreDataController+Segments.h"
#import "RIPEditSegmentViewController.h"
#import "RIPNotesViewController.h"
#import "RIPSegmentsViewController.h"

@interface RIPSegmentsViewController ()
@property (strong, nonatomic) UIBarButtonItem *backButton;
@property (strong, nonatomic) NSMutableArray *segments;
@end

@implementation RIPSegmentsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
    _segments = [NSMutableArray arrayWithArray:@[]];
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(readSegments) forControlEvents:UIControlEventValueChanged];
    [self readSegments];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if(_note != nil){
        [self.navigationController.navigationBar setBarTintColor:[UIColor colorWithColor:_note[kNoteColorKey] alpha:0.8]];
        [self.navigationController.navigationBar setTintColor:[UIColor whiteColor]];
        [self.navigationController.navigationBar setTranslucent:YES];
        // [self setNeedsStatusBarAppearanceUpdate];
        [self.navigationController.navigationBar setTitleTextAttributes:@{
           NSForegroundColorAttributeName : UIColor.whiteColor,
           NSFontAttributeName: [UIFont boldSystemFontOfSize:22],
        }];
        self.title = _note[kEntryTitleKey];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    if(!self.editing)
        [self updateSegments];
    [self updateCompletion];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
  return UIStatusBarStyleLightContent;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if(_segments == nil)
        return 0;
    return _segments.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"SegmentCell";
    RIPSegmentCell *cell = (RIPSegmentCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    NSMutableDictionary *entry = _segments[indexPath.row];
    if(entry[kEntryTitleKey] == [NSNull null] || entry[kSegmentCompletionKey] == [NSNull null] || entry[kSegmentContentKey] == [NSNull null] || entry[kSegmentDateKey] == [NSNull null]){
        Segment *segment = (Segment *)[[[RIPCoreDataController shared] managedObjectContext] objectWithID:entry[kEntryObjectIDKey]];
        entry[kEntryTitleKey] = (segment.title)?segment.title:NSLocalizedString(@"UNTITLED", @"Untitled");
        entry[kSegmentCompletionKey] = segment.completion;
        entry[kSegmentContentKey] = segment.content;
        entry[kSegmentDateKey] = segment.date;
        entry[kSegmentReminderKey] = (segment.reminder)?segment.reminder:[NSNull null];
    }
    [cell setTitle:entry[kEntryTitleKey]];
    [cell
     setCompletion: RIPCompletionFloatForCompletion([(NSNumber *)entry[kSegmentCompletionKey] intValue])
     animated:YES];
    [cell setContent:entry[kSegmentContentKey]];
    [cell setDate:entry[kSegmentDateKey]];
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [self deleteSegment:indexPath.row];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
    [super setEditing:editing animated:animated];
    if(editing){
        _backButton = self.navigationItem.leftBarButtonItem;
        [self.navigationItem setLeftBarButtonItem:[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addSegment)] animated:YES];
    }else{
        [self.navigationItem setLeftBarButtonItem:_backButton animated:YES];
        _backButton = nil;
    }
    if(!editing){
        [self updateSegments];
    }
}

- (IBAction)fieldsDidEndEditing:(RIPCircleButton *)sender {
    RIPSegmentCell *cell = (RIPSegmentCell *)sender.superview.superview;
    
    float comp = [sender getCompletion];
    comp += 0.5;
    if(comp > 1.0)
        comp = 0.0;
    [sender setCompletion:comp animated:YES];
    
    NSIndexPath *i = [self.tableView indexPathForCell:cell];
    NSMutableDictionary *entry = _segments[i.row];
    entry[kSegmentCompletionKey] = [NSNumber numberWithInt:RIPCompletionForFloat(comp)];
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
    NSMutableDictionary *entry = _segments[fromIndexPath.row];
    NSInteger incLb = (toIndexPath.row > fromIndexPath.row)?
        (fromIndexPath.row + 1):
        (toIndexPath.row);
    NSInteger incUb = (toIndexPath.row > fromIndexPath.row)?
        (toIndexPath.row):
        (fromIndexPath.row - 1);
    NSInteger delta = (toIndexPath.row > fromIndexPath.row)?1:-1;
    for(NSInteger i = incLb; i <= incUb; i++){
        NSMutableDictionary *d = _segments[i];
        d[kEntryPositionKey] =
        [NSNumber numberWithInteger:([(NSNumber *)d[kEntryPositionKey] integerValue] + delta)];
    }
    entry[kEntryPositionKey] = [NSNumber numberWithInteger:_segments.count - toIndexPath.row - 1];
    [_segments removeObjectAtIndex:fromIndexPath.row];
    [_segments insertObject:entry atIndex:toIndexPath.row];
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    RIPEditSegmentViewController *editSeg = (RIPEditSegmentViewController *)[sb instantiateViewControllerWithIdentifier:@"RIPEditSegmentViewController"];
    editSeg.segementsVC = self;
    editSeg.title = NSLocalizedString(@"EDIT_TASK", @"Edit Task");
    NSMutableDictionary *s = [NSMutableDictionary dictionaryWithDictionary:_segments[indexPath.row]];
    editSeg.segment = s;
    [self.navigationController pushViewController:editSeg animated:YES];
}

- (void)addSegment {
    NSMutableDictionary *entry = [NSMutableDictionary dictionary];
    entry[kEntryTitleKey] = [NSNull null];
    entry[kSegmentCompletionKey] = [NSNull null];
    entry[kSegmentContentKey] = [NSNull null];
    entry[kSegmentDateKey] = [NSNull null];
    entry[kSegmentReminderKey] = [NSNull null];
    entry[kEntryPositionKey] = [NSNumber numberWithInteger:_segments.count];
    
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    RIPEditSegmentViewController *editSeg = (RIPEditSegmentViewController *)[sb instantiateViewControllerWithIdentifier:@"RIPEditSegmentViewController"];
    editSeg.segementsVC = self;
    editSeg.title = NSLocalizedString(@"NEW_TASK", @"New Task");
    editSeg.segment = entry;
    [self.navigationController pushViewController:editSeg animated:YES];
}

- (void)readSegments {
  [self.refreshControl beginRefreshing];
  __weak __typeof(self) weakSelf = self;
  [[RIPCoreDataController shared]
      readSegmentsFromNote:self.note[kEntryObjectIDKey]
                completion:^(NSArray *segments) {
                  dispatch_async(dispatch_get_main_queue(), ^{
                    if (!weakSelf) {
                      return;
                    }
                    weakSelf.segments = [NSMutableArray array];
                    for (NSInteger i = 0; i < segments.count; i++) {
                      NSManagedObjectID *mid = segments[i];
                      NSMutableDictionary *entry =
                          [NSMutableDictionary dictionary];
                      entry[kEntryObjectIDKey] = mid;
                      entry[kEntryTitleKey] = [NSNull null];
                      entry[kSegmentCompletionKey] = [NSNull null];
                      entry[kSegmentContentKey] = [NSNull null];
                      entry[kSegmentDateKey] = [NSNull null];
                      entry[kSegmentReminderKey] = [NSNull null];
                      entry[kEntryPositionKey] =
                          [NSNumber numberWithInteger:segments.count - i - 1];
                      [weakSelf.segments addObject:entry];
                    }
                    [weakSelf.tableView reloadData];
                    [weakSelf.refreshControl endRefreshing];
                  });
                }];
}

- (void)updateSegments {
  __weak __typeof(self) weakSelf = self;
  [[RIPCoreDataController shared] updateObjects:^(NSManagedObjectContext *moc) {
    if (!weakSelf) {
      return;
    }
    for (NSDictionary *d in weakSelf.segments) {
      NSManagedObjectID *mid = d[kEntryObjectIDKey];
      Segment *mo = (Segment *)[moc objectWithID:mid];
      [mo setTitle:d[kEntryTitleKey]];
      [mo setCompletion:d[kSegmentCompletionKey]];
      [mo setContent:d[kSegmentContentKey]];
      [mo setDate:d[kSegmentDateKey]];
      [mo setReminder:((d[kSegmentReminderKey] == [NSNull null])
                           ? nil
                           : d[kSegmentReminderKey])];
      [mo setPosition:d[kEntryPositionKey]];
    }
  }
                                     completion:nil];
}

- (void)deleteSegment:(NSInteger)index {
  for (NSInteger i = 0; i < index; i++) {
    NSMutableDictionary *entry = self.segments[i];
    entry[kEntryPositionKey] =
        [NSNumber numberWithInteger:self.segments.count - i - 2];
  }
  NSManagedObjectID *mid =
      (NSManagedObjectID *)self.segments[index][kEntryObjectIDKey];
  [self.segments removeObjectAtIndex:index];

  __weak __typeof(self) weakSelf = self;
  [[RIPCoreDataController shared]
      deleteSegments:@[ mid ]
          completion:^(BOOL success) {
            if (!success) {
              return;
            }
            [[RIPCoreDataController shared] updateObjects:^(
                                                NSManagedObjectContext *moc) {
              if (!weakSelf) {
                return;
              }
              for (NSInteger i = 0; i < index; i++) {
                NSDictionary *entry = weakSelf.segments[i];
                Segment *mo =
                    (Segment *)[moc objectWithID:entry[kEntryObjectIDKey]];
                [mo setPosition:[NSNumber
                                    numberWithInteger:
                                        [(NSNumber *)entry[kEntryPositionKey]
                                            integerValue]]];
              }
            }
                completion:^(BOOL s) {
                  NSArray *nots = [[UIApplication sharedApplication]
                      scheduledLocalNotifications];
                  UILocalNotification *toRemove = nil;
                  for (UILocalNotification * not in nots) {
                    if ([mid.description
                            isEqual:not.userInfo[kEntryObjectIDKey]])
                      toRemove = not;
                  }
                  if (toRemove)
                    [[UIApplication sharedApplication]
                        cancelLocalNotification:toRemove];
                }];
          }];
}

- (void)updateCompletion {
    if (_note != nil && _segments != nil && _notesVC != nil) {
        float avg = 0;
        if(_segments.count == 0)
            avg = 1.0;
        else{
            for (NSMutableDictionary *entry in _segments) {
                if(entry[kEntryTitleKey] == [NSNull null] || entry[kSegmentCompletionKey] == [NSNull null] || entry[kSegmentContentKey] == [NSNull null] || entry[kSegmentDateKey] == [NSNull null]){
                    Segment *segment = (Segment *)[[[RIPCoreDataController shared] managedObjectContext] objectWithID:entry[kEntryObjectIDKey]];
                    entry[kEntryTitleKey] = segment.title;
                    entry[kSegmentCompletionKey] = segment.completion;
                    entry[kSegmentContentKey] = segment.content;
                    entry[kSegmentDateKey] = segment.date;
                    entry[kSegmentReminderKey] = (segment.reminder)?segment.reminder:[NSNull null];
                }
                NSNumber *c = entry[kSegmentCompletionKey];
                avg += RIPCompletionFloatForCompletion((RIPCompletion)c.intValue);
            }
            avg /= _segments.count;
        }
       [_notesVC updateCompletion:avg forNoteWithID:_note[kEntryObjectIDKey]];
    }
}

- (void)updateSegmentsWith:(NSMutableDictionary *)segment {
  if (segment[kEntryObjectIDKey] == nil) {
    // new seg
    [self.tableView beginUpdates];
    [self.segments insertObject:segment atIndex:0];
    [self.tableView
        insertRowsAtIndexPaths:@[ [NSIndexPath indexPathForRow:0 inSection:0] ]
              withRowAnimation:UITableViewRowAnimationAutomatic];
    [self.tableView endUpdates];

    __weak __typeof(self) weakSelf = self;
    [[RIPCoreDataController shared]
        createSegments:@[ segment ]
               forNote:(NSManagedObjectID *)self.note[kEntryObjectIDKey]
            completion:^(NSArray *objIDs) {
              if (!weakSelf) {
                return;
              }
              // main
              segment[kEntryObjectIDKey] = (NSManagedObjectID *)objIDs[0];
              [Segment scheduleNotification:segment
                            withSectionName:weakSelf.note[kEntryTitleKey]];
            }];
  } else {
    for (NSInteger i = 0; i < self.segments.count; i++) {
      NSMutableDictionary *entry = self.segments[i];
      if ([entry[kEntryObjectIDKey] isEqual:segment[kEntryObjectIDKey]]) {
        entry[kEntryTitleKey] = segment[kEntryTitleKey];
        entry[kSegmentContentKey] = segment[kSegmentContentKey];

        [self updateNotificationsForOld:entry new:segment];

        entry[kSegmentDateKey] = segment[kSegmentDateKey];
        entry[kSegmentReminderKey] = segment[kSegmentReminderKey];
        [self.tableView
            reloadRowsAtIndexPaths:@[ [NSIndexPath indexPathForRow:i
                                                         inSection:0] ]
                  withRowAnimation:UITableViewRowAnimationNone];
        [self updateSegments];
      }
    }
  }
}

- (void)updateNotificationsForOld:(NSDictionary *)entry new:(NSDictionary *)segment {
    if(entry[kSegmentReminderKey] != [NSNull null]){
        [self cancelNotificationWithID:entry[kEntryObjectIDKey]];
        if(segment[kSegmentReminderKey] != [NSNull null])
            [Segment scheduleNotification:segment withSectionName:_note[kEntryTitleKey]];
        
    }else if(segment[kSegmentReminderKey] != [NSNull null]){
        //simply make a new one
        [Segment scheduleNotification:segment withSectionName:_note[kEntryTitleKey]];
    }
}

- (void)cancelNotificationWithID:(NSManagedObjectID *)moid{
    NSArray *notifications = [[UIApplication sharedApplication] scheduledLocalNotifications];
    UILocalNotification *toRemove = nil;
    for (UILocalNotification *not in notifications) {
        NSDictionary *d = not.userInfo;
        NSString *entryMoidStr = moid.description;
        NSString *moidStr = d[kEntryObjectIDKey];
        if([moidStr isEqualToString:entryMoidStr])
            toRemove = not;
    }
    if(toRemove){
        NSLog(@"Removed %@ for %@", toRemove.alertBody, toRemove.fireDate);
        [[UIApplication sharedApplication] cancelLocalNotification:toRemove];
    }
}

@end
