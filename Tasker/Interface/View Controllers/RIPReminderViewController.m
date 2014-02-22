//
//  RIPReminderViewController.m
//  Tasker
//
//  Created by Nick on 2/17/14.
//  Copyright (c) 2014 Nick. All rights reserved.
//

#import "Segment.h"
#import "RIPReminderViewController.h"
#import "RIPEditSegmentViewController.h"

@interface RIPReminderViewController ()

@end

@implementation RIPReminderViewController

- (id)initWithStyle:(UITableViewStyle)style {
    if (self = [super initWithStyle:style]) {
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Cell"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [_editSegVc updateReminderInterval:_timeInterval];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    NSIndexPath *i = [NSIndexPath indexPathForRow:[Segment indexForInterval:_timeInterval] inSection:0];
    UITableViewCell *c = [self.tableView cellForRowAtIndexPath:i];
    c.accessoryType = UITableViewCellAccessoryCheckmark;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [Segment numReminderIntervals];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    NSNumber *ti = [Segment intervalForIndex:indexPath.row];
    cell.textLabel.text = [Segment stringForReminderInterval:ti];
    BOOL bothNull = (_timeInterval == nil && ti == nil);
    cell.accessoryType = ([ti isEqual:_timeInterval] || bothNull)?UITableViewCellAccessoryCheckmark:UITableViewCellAccessoryNone;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)tableView:(UITableView *)tableView didUnhighlightRowAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger i = [Segment indexForInterval:_timeInterval];
    UITableViewCell *oldCell = [tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
    oldCell.accessoryType = UITableViewCellAccessoryNone;
    
    UITableViewCell *newCell = [tableView cellForRowAtIndexPath:indexPath];
    newCell.accessoryType = UITableViewCellAccessoryCheckmark;
    _timeInterval = (NSNumber *)[Segment intervalForIndex:indexPath.row];
}

@end
