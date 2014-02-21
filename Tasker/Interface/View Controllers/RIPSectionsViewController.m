//
//  RIPSectionsViewController.m
//  Notepad
//
//  Created by Nick on 1/22/14.
//  Copyright (c) 2014 Nick. All rights reserved.
//

#import "RIPNotesViewController.h"
#import "RIPCoreDataController+Sections.h"
#import "RIPCoreDataController.h"
#import "RIPErrorManager.h"
#import "Section.h"
#import "RIPSectionCell.h"
#import "RIPSectionsViewController.h"

@interface RIPSectionsViewController () <UIActionSheetDelegate>
@property (strong, nonatomic) NSMutableArray *sections;
@end

@implementation RIPSectionsViewController

- (id)initWithStyle:(UITableViewStyle)style {
    self = [super initWithStyle:style];
    if(self){
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _sections = [NSMutableArray arrayWithArray:@[]];
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(readSections) forControlEvents:UIControlEventValueChanged];
    [self readSections];
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"BACK", @"Back") style:UIBarButtonItemStylePlain target:nil action:nil];
    self.title = NSLocalizedString(@"APPLICATION_NAME", @"Application name");
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if(NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_6_1){
        [self.navigationController.navigationBar setTintColor:self.view.tintColor];
        [self.navigationController.navigationBar setBarTintColor:[UIColor clearColor]];
        [self.navigationController.navigationBar
         setTitleTextAttributes:@{NSForegroundColorAttributeName : self.view.tintColor}];
        [self.navigationController.navigationBar setTranslucent:YES];
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:YES];
        [self setNeedsStatusBarAppearanceUpdate];
    }else{
        [self.navigationController.navigationBar setTintColor:nil];
        [self.navigationController.navigationBar setBackgroundColor:[UIColor whiteColor]];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    if(!self.editing)
        [self updateSections];
}

- (BOOL)prefersStatusBarHidden {
    return NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    if(_sections == nil)
        return 0;
    return _sections.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"SectionCell";
    RIPSectionCell *cell = (RIPSectionCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    NSMutableDictionary *entry = _sections[indexPath.row];
    if(entry[kEntryTitleKey] == [NSNull null] || entry[kSectionColorKey] == [NSNull null]){
        Section *section = (Section *)[[[RIPCoreDataController shared] managedObjectContext] objectWithID:entry[kEntryObjectIDKey]];
        entry[kEntryTitleKey] = (section.title)?section.title:NSLocalizedString(@"UNTITLED", @"Untitled");
        entry[kSectionColorKey] = section.color;
    }
    
    [cell setTitle:entry[kEntryTitleKey]];
    [cell setColor:entry[kSectionColorKey]];
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if(editingStyle == UITableViewCellEditingStyleDelete){
        UIActionSheet *deleteConf = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"ARE_YOU_SURE", @"Confirm deletion") delegate:self cancelButtonTitle:NSLocalizedString(@"CANCEL", @"Cancel") destructiveButtonTitle:NSLocalizedString(@"DELETE_SECTION", @"Delete Section") otherButtonTitles:nil];
        deleteConf.tag = indexPath.row;
        [deleteConf showInView:self.view];
    }
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
    [super setEditing:editing animated:animated];
    if(editing)
        [self.navigationItem setLeftBarButtonItem:[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addSection)] animated:YES];
    else
        [self.navigationItem setLeftBarButtonItem:nil animated:YES];
    if(!editing){
        [self updateSections];
    }
}

- (IBAction)fieldsEditingDidEnd:(UIView *)sender {
    RIPSectionCell *cell;
    if(NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_6_1){
        cell = (RIPSectionCell *)sender.superview.superview.superview;
    }else{
        cell = (RIPSectionCell *)sender.superview.superview;
    }
    NSString *t = [[cell getTitle] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if(t.length == 0)
        t = NSLocalizedString(@"UNTITLED", @"Untitled");
    [cell setTitle:t];

    NSIndexPath *i = [self.tableView indexPathForCell:cell];
    NSMutableDictionary *entry = _sections[i.row];
    entry[kEntryTitleKey] = t;
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
    NSMutableDictionary *entry = _sections[fromIndexPath.row];
    NSInteger incLb = (toIndexPath.row > fromIndexPath.row)?
        (fromIndexPath.row + 1):
        (toIndexPath.row);
    NSInteger incUb = (toIndexPath.row > fromIndexPath.row)?
        (toIndexPath.row):
        (fromIndexPath.row - 1);
    NSInteger delta = (toIndexPath.row > fromIndexPath.row)?1:-1;
    for(NSInteger i = incLb; i <= incUb; i++){
        NSMutableDictionary *d = _sections[i];
        d[kEntryPositionKey] =
            [NSNumber numberWithInteger:([(NSNumber *)d[kEntryPositionKey] integerValue] + delta)];
    }
    entry[kEntryPositionKey] = [NSNumber numberWithInteger:_sections.count - toIndexPath.row - 1];
    [_sections removeObjectAtIndex:fromIndexPath.row];
    [_sections insertObject:entry atIndex:toIndexPath.row];
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSMutableDictionary *entry = _sections[indexPath.row];
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    RIPNotesViewController *notes = [sb instantiateViewControllerWithIdentifier:@"RIPNotesViewController"];
    notes.section = entry;
    [self.navigationController pushViewController:notes animated:YES];
}

- (void)addSection {
    NSString *title = NSLocalizedString(@"UNTITLED", @"Untitled");
    UIColor *color = [Section getColor:_sections.count];
    NSMutableDictionary *entry = [NSMutableDictionary dictionary];
    entry[kEntryTitleKey] = title;
    entry[kSectionColorKey] = color;
    entry[kEntryPositionKey] = [NSNumber numberWithInteger:_sections.count];
    [self.tableView beginUpdates];
    [_sections insertObject:entry atIndex:0];
    [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
    [self.tableView endUpdates];
    
    [[RIPCoreDataController shared] createSections:@[entry] completion:^(NSArray *objIDs) {
        //main
        entry[kEntryObjectIDKey] = (NSManagedObjectID *)objIDs[0];
    }];
}

- (void)readSections {
    [self.refreshControl beginRefreshing];
    [[RIPCoreDataController shared] readSectionsWithCompletion:^(NSArray *sections) {
        dispatch_async(dispatch_get_main_queue(), ^{
            _sections = [NSMutableArray array];
            for(NSInteger i = 0; i < sections.count; i++){
                NSManagedObjectID *mid = sections[i];
                NSMutableDictionary *entry = [NSMutableDictionary dictionary];
                entry[kEntryObjectIDKey] = mid;
                entry[kSectionColorKey] = [NSNull null];
                entry[kEntryTitleKey] = [NSNull null];
                entry[kEntryPositionKey] = [NSNumber numberWithInteger:(sections.count - i - 1)];
                [_sections addObject:entry];
            }
            [self.tableView reloadData];
            [self.refreshControl endRefreshing];
        });
    }];
}

- (void)updateSections {
    [[RIPCoreDataController shared] updateObjects:^(NSManagedObjectContext *moc) {
        for (NSDictionary *d in _sections) {
            NSManagedObjectID *mid = d[kEntryObjectIDKey];
            Section *mo = (Section *)[moc objectWithID:mid];
            [mo setTitle:d[kEntryTitleKey]];
            [mo setColor:d[kSectionColorKey]];
            [mo setPosition:d[kEntryPositionKey]];
        }
    } completion:nil];
}

- (void)deleteSection:(NSInteger)index {
    for(NSInteger i = 0; i < index; i++){
        NSMutableDictionary *entry = _sections[i];
        entry[kEntryPositionKey] = [NSNumber numberWithInteger:_sections.count - i - 2];
    }
    NSManagedObjectID *mid = (NSManagedObjectID *)_sections[index][kEntryObjectIDKey];
    [_sections removeObjectAtIndex:index];
    [[RIPCoreDataController shared] deleteSections:@[mid] completion:^(BOOL success) {
        if(success){
            [[RIPCoreDataController shared] updateObjects:^(NSManagedObjectContext *moc) {
                for (NSInteger i = 0; i < index; i++) {
                    NSDictionary *entry = _sections[i];
                    Section *mo = (Section *)[moc objectWithID:entry[kEntryObjectIDKey]];
                    [mo setPosition:[NSNumber numberWithInteger:[(NSNumber *)entry[kEntryPositionKey] integerValue]]];
                }
            } completion:nil];
        }
    }];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if(buttonIndex == actionSheet.destructiveButtonIndex){
        [self deleteSection:actionSheet.tag];
        [self.tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:actionSheet.tag inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
    }
}

@end
