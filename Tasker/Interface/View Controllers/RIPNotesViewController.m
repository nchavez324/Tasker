//
//  RIPNotesViewController.m
//  Notepad
//
//  Created by Nick on 1/22/14.
//  Copyright (c) 2014 Nick. All rights reserved.
//

#import "Section.h"
#import "Note.h"
#import "UIColor+Utils.h"
#import "RIPCircleButton.h"
#import "RIPNoteCell.h"
#import "RIPSegmentsViewController.h"
#import "RIPCoreDataController+Notes.h"
#import "RIPCoreDataController.h"
#import "RIPNotesViewController.h"

@interface RIPNotesViewController ()
@property (strong, nonatomic) UIBarButtonItem *backButton;
@property (strong, nonatomic) NSMutableArray *notes;
@end

@implementation RIPNotesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
    _notes = [NSMutableArray arrayWithArray:@[]];
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(readNotes) forControlEvents:UIControlEventValueChanged];
    [self readNotes];
}

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  if (!self.section) {
    return;
  }
  UIColor *navBarColor =
      [UIColor colorWithColor:self.section[kSectionColorKey] alpha:0.8];
  [self.navigationController.navigationBar setTintColor:UIColor.whiteColor];
  [self.navigationController.navigationBar setBarTintColor:navBarColor];
  [self.navigationController.navigationBar setTranslucent:YES];
  [self.navigationController.navigationBar setTitleTextAttributes:@{
    NSForegroundColorAttributeName : UIColor.whiteColor,
    NSFontAttributeName : [UIFont boldSystemFontOfSize:22],
  }];
  [self.navigationController.navigationBar setBarStyle:UIBarStyleBlack];
  [self setNeedsStatusBarAppearanceUpdate];

  [self setTitle:self.section[kEntryTitleKey]];
  self.navigationItem.backBarButtonItem =
      [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"BACK", @"Back")
                                       style:UIBarButtonItemStylePlain
                                      target:nil
                                      action:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    if(!self.editing)
        [self updateNotes];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
  return UIStatusBarStyleLightContent;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if(_notes == nil)
        return 0;
    return _notes.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"NoteCell";
    RIPNoteCell *cell = (RIPNoteCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    NSMutableDictionary *entry = _notes[indexPath.row];
    if(entry[kEntryTitleKey] == [NSNull null] || entry[kNoteColorKey] == [NSNull null]){
        Note *note = (Note *)[[[RIPCoreDataController shared] managedObjectContext] objectWithID:entry[kEntryObjectIDKey]];
        entry[kEntryTitleKey] = (note.title)?note.title:NSLocalizedString(@"UNTITLED", @"Untitled");
        entry[kNoteColorKey] = note.color;
    }
    [cell setTitle:entry[kEntryTitleKey]];
    [cell setCompletion:[(NSNumber *)entry[kNoteCompletionKey] floatValue] animated:NO];
    [cell setColor:entry[kNoteColorKey] animated:NO];
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if(editingStyle == UITableViewCellEditingStyleDelete){
        [self deleteNote:indexPath.row];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
    [super setEditing:editing animated:animated];
    if(editing){
        _backButton = self.navigationItem.leftBarButtonItem;
        [self.navigationItem setLeftBarButtonItem:[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addNote)] animated:YES];
    }else{
        [self.navigationItem setLeftBarButtonItem:_backButton animated:YES];
        _backButton = nil;
    }
    if(!editing){
        [self updateNotes];
    }
}

- (IBAction)fieldsDidEndEditing:(UIView *)sender {
    RIPNoteCell *cell = (RIPNoteCell *)sender.superview.superview;
    NSString *t = [[cell getTitle] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if(t.length == 0)
        t = NSLocalizedString(@"UNTITLED", @"Untitled");
    [cell setTitle:t];
    
    NSIndexPath *i = [self.tableView indexPathForCell:cell];
    NSMutableDictionary *entry = _notes[i.row];
    entry[kEntryTitleKey] = t;
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
    NSMutableDictionary *entry = _notes[fromIndexPath.row];
    NSInteger incLb = (toIndexPath.row > fromIndexPath.row)?
        (fromIndexPath.row + 1):
        (toIndexPath.row);
    NSInteger incUb = (toIndexPath.row > fromIndexPath.row)?
        (toIndexPath.row):
        (fromIndexPath.row - 1);
    NSInteger delta = (toIndexPath.row > fromIndexPath.row)?1:-1;
    for(NSInteger i = incLb; i <= incUb; i++){
        NSMutableDictionary *d = _notes[i];
        d[kEntryPositionKey] =
            [NSNumber numberWithInteger:([(NSNumber *)d[kEntryPositionKey] integerValue] + delta)];
    }
    entry[kEntryPositionKey] = [NSNumber numberWithInteger:_notes.count - toIndexPath.row - 1];
    [_notes removeObjectAtIndex:fromIndexPath.row];
    [_notes insertObject:entry atIndex:toIndexPath.row];
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSMutableDictionary *entry = _notes[indexPath.row];
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    RIPSegmentsViewController *segments = [sb instantiateViewControllerWithIdentifier:@"RIPSegmentsViewController"];
    segments.note = entry;
    segments.section = _section;
    segments.notesVC = self;
    [self.navigationController pushViewController:segments animated:YES];
}

- (void)addNote {
    NSString *title = NSLocalizedString(@"UNTITLED", @"Untitled");
    UIColor *color = [Section getColor:_notes.count];
    NSMutableDictionary *entry = [NSMutableDictionary dictionary];
    entry[kEntryTitleKey] = title;
    entry[kNoteColorKey] = color;
    entry[kNoteCompletionKey] = [NSNumber numberWithFloat:RIPCompletionFloatForCompletion(RIPCompletionDone)];
    entry[kEntryPositionKey] = [NSNumber numberWithInteger:_notes.count];
    [self.tableView beginUpdates];
    [_notes insertObject:entry atIndex:0];
    [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
    [self.tableView endUpdates];
    
    [[RIPCoreDataController shared] createNotes:@[entry] forSection:(NSManagedObjectID *)_section[kEntryObjectIDKey] completion:^(NSArray *objIDs) {
        //main
        entry[kEntryObjectIDKey] = (NSManagedObjectID *)objIDs[0];
    }];
}

- (void)readNotes {
  [self.refreshControl beginRefreshing];
  __weak __typeof(self) weakSelf = self;
  [[RIPCoreDataController shared]
      readNotesFromSection:self.section[kEntryObjectIDKey]
                completion:^(NSArray *notes) {
                  dispatch_async(dispatch_get_main_queue(), ^{
                    if (!weakSelf) {
                      return;
                    }
                    weakSelf.notes = [NSMutableArray array];
                    for (NSInteger i = 0; i < notes.count; i++) {
                      NSDictionary *d = notes[i];
                      NSMutableDictionary *entry =
                          [NSMutableDictionary dictionary];
                      entry[kEntryObjectIDKey] = d[kEntryObjectIDKey];
                      entry[kEntryTitleKey] = [NSNull null];
                      entry[kNoteColorKey] = [NSNull null];
                      entry[kNoteCompletionKey] = [NSNumber
                          numberWithFloat:[d[kNoteCompletionKey] floatValue]];
                      entry[kEntryPositionKey] =
                          [NSNumber numberWithInteger:notes.count - i - 1];
                      [weakSelf.notes addObject:entry];
                    }
                    [self.tableView reloadData];
                    [self.refreshControl endRefreshing];
                  });
                }];
}

- (void)updateNotes {
  __weak __typeof(self) weakSelf = self;
  [[RIPCoreDataController shared] updateObjects:^(NSManagedObjectContext *moc) {
    if (!weakSelf) {
      return;
    }
    for (NSDictionary *d in weakSelf.notes) {
      NSManagedObjectID *mid = d[kEntryObjectIDKey];
      Note *mo = (Note *)[moc objectWithID:mid];
      [mo setTitle:d[kEntryTitleKey]];
      [mo setColor:d[kNoteColorKey]];
      [mo setPosition:d[kEntryPositionKey]];
    }
  }
                                     completion:nil];
}

- (void)deleteNote:(NSInteger)index {
  for (NSInteger i = 0; i < index; i++) {
    NSMutableDictionary *entry = self.notes[i];
    entry[kEntryPositionKey] =
        [NSNumber numberWithInteger:self.notes.count - i - 2];
  }
  NSManagedObjectID *mid =
      (NSManagedObjectID *)self.notes[index][kEntryObjectIDKey];
  [self.notes removeObjectAtIndex:index];

  __weak __typeof(self) weakSelf = self;
  [[RIPCoreDataController shared]
      deleteNotes:@[ mid ]
       completion:^(BOOL success) {
         if (!success) {
           return;
         }
         [[RIPCoreDataController shared]
             updateObjects:^(NSManagedObjectContext *moc) {
               if (!weakSelf) {
                 return;
               }
               for (NSInteger i = 0; i < index; i++) {
                 NSDictionary *entry = weakSelf.notes[i];
                 Note *mo = (Note *)[moc objectWithID:entry[kEntryObjectIDKey]];
                 [mo setPosition:@([entry[kEntryPositionKey] integerValue])];
               }
             }
                completion:nil];
       }];
}

- (void)updateCompletion:(float)average forNoteWithID:(NSManagedObjectID *)mid {
    if(_notes != nil){
        for (NSInteger i = 0; i < _notes.count; i++) {
            NSMutableDictionary *entry = _notes[i];
            NSManagedObjectID *eMid = entry[kEntryObjectIDKey];
            if([eMid isEqual:mid]){
                entry[kNoteCompletionKey] = [NSNumber numberWithFloat:average];
                // TODO: Logs an error since this can't be called from
                // viewWillDisappear.
                [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:i inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
                break;
            }
        }
    }
}

@end
