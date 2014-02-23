//
//  RIPEditSegmentViewController.m
//  Notepad
//
//  Created by Nick on 1/25/14.
//  Copyright (c) 2014 Nick. All rights reserved.
//

#import "RIPCompletion.h"
#import "NSDate+Utils.h"
#import "Segment.h"
#import "RIPReminderViewController.h"
#import "SZTextView.h"
#import "RIPSegmentsViewController.h"
#import "RIPEditSegmentViewController.h"

static NSInteger const kEditTitleFieldTag    = 1;

static NSInteger const kEditDateDueLabelTag  = 1;
static NSInteger const kEditDateDateLabelTag = 2;
static NSInteger const kEditDateTimeLabelTag = 3;

static NSInteger const kEditDatePickerTag    = 1;

static NSInteger const kEditContentViewTag  = 1;

@interface RIPEditSegmentViewController ()
@property (assign, nonatomic) BOOL datePickerVisible;
@property (assign, nonatomic) BOOL beganEditing;
@end

@implementation RIPEditSegmentViewController

- (id)initWithStyle:(UITableViewStyle)style {
    if (self = [super initWithStyle:style]) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelButton)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneButton)];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    _datePickerVisible = NO;
    if(_segment && !_beganEditing){
        UITableViewCell *titleCell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
        UITextField *tf = (UITextField *)[titleCell viewWithTag:kEditTitleFieldTag];
        if(_segment[kEntryTitleKey] == [NSNull null])
            _segment[kEntryTitleKey] = @"";
        tf.text = _segment[kEntryTitleKey];

        if(_segment[kSegmentReminderKey] == [NSNull null]){
            NSNumber *n = [Segment intervalForIndex:0];
            _segment[kSegmentReminderKey] = (n)?n:[NSNull null];
        }
        
        UITableViewCell *reminderCell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
        
        NSObject *o = _segment[kSegmentReminderKey];
        reminderCell.detailTextLabel.text = [Segment stringForReminderInterval:(o)?(NSNumber *)o:nil];
        
        if(_segment[kSegmentDateKey] == [NSNull null]){
            NSDate *d = [NSDate date];
            NSDateComponents *dateComps = [[NSCalendar currentCalendar] components:NSSecondCalendarUnit fromDate:d];
            [dateComps setSecond:-[dateComps second]];
            d = [[NSCalendar currentCalendar] dateByAddingComponents:dateComps toDate:d options:0];
            _segment[kSegmentDateKey] = d;
        }
        UITableViewCell *dateCell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:0]];
        UILabel *dueLabel = (UILabel *)[dateCell viewWithTag:kEditDateDueLabelTag];
        UILabel *dateLabel = (UILabel *)[dateCell viewWithTag:kEditDateDateLabelTag];
        UILabel *timeLabel = (UILabel *)[dateCell viewWithTag:kEditDateTimeLabelTag];
        dueLabel.text = NSLocalizedString(@"DUE", @"Due");
        dateLabel.text = [self dateStringFromDate:_segment[kSegmentDateKey]];
        timeLabel.text = [self timeStringFromTime:_segment[kSegmentDateKey]];
        
        UITableViewCell *contentCell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1]];
        UITextView *tv = (UITextView *)[contentCell viewWithTag:kEditContentViewTag];
        if(_segment[kSegmentContentKey] == [NSNull null])
            _segment[kSegmentContentKey] = @"";
        tv.text = _segment[kSegmentContentKey];
        
        _beganEditing = YES;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger r = 0;
    switch (section) {
        case 0:
            r = _datePickerVisible?4:3;
            break;
        case 1:
            r = 1;
            break;
        default:
            break;
    }
    return r;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell;
    if(indexPath.section == 0){
        switch (indexPath.row) {
            case 0:{
                cell = [tableView dequeueReusableCellWithIdentifier:@"SegmentTitleCell"];
                UITextField *tf = (UITextField *)[cell viewWithTag:kEditTitleFieldTag];
                [tf setPlaceholder:NSLocalizedString(@"TITLE", @"Title")];
                [tf setBorderStyle:UITextBorderStyleNone];
                if(_segment && _segment[kEntryTitleKey] != [NSNull null])
                    tf.text = _segment[kEntryTitleKey];
                break;
            }
            case 1:{
                cell = [tableView dequeueReusableCellWithIdentifier:@"SegmentReminderCell"];
                cell.textLabel.text = NSLocalizedString(@"REMINDER", @"Reminder");
                if(_segment){
                    NSObject *o = _segment[kSegmentReminderKey];
                    cell.detailTextLabel.text = [Segment stringForReminderInterval:(o)?(NSNumber *)o:nil];
                }
                break;
            }
            case 2:{
                cell = [tableView dequeueReusableCellWithIdentifier:@"SegmentDateCell"];
                UILabel *dueLabel = (UILabel *)[cell viewWithTag:kEditDateDueLabelTag];
                UILabel *dateLabel = (UILabel *)[cell viewWithTag:kEditDateDateLabelTag];
                UILabel *timeLabel = (UILabel *)[cell viewWithTag:kEditDateTimeLabelTag];
                dueLabel.text = NSLocalizedString(@"DUE", @"Due");
                if(_segment && _segment[kSegmentDateKey] != [NSNull null]){
                    dateLabel.text = [self dateStringFromDate:_segment[kSegmentDateKey]];
                    timeLabel.text = [self timeStringFromTime:_segment[kSegmentDateKey]];
                }
                break;
            }
            case 3:{
                if(NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_6_1)
                    cell = [tableView dequeueReusableCellWithIdentifier:@"SegmentDatePickerCell"];
                else{
                    cell = [tableView dequeueReusableCellWithIdentifier:@"SegmentDatePicker6Cell"];
                    UIDatePicker *datePicker = (UIDatePicker *)[cell viewWithTag:kEditDatePickerTag];
                    CGRect pickerFrame = datePicker.frame;
                    CGRect cellBounds = cell.bounds;
                    datePicker.frame = CGRectMake((cellBounds.size.width - pickerFrame.size.width)/2.0, (cellBounds.size.height - pickerFrame.size.height)/2.0, pickerFrame.size.width, pickerFrame.size.height);
                }
                UIDatePicker *datePicker = (UIDatePicker *)[cell viewWithTag:kEditDatePickerTag];
                if(_segment && _segment[kSegmentDateKey] != [NSNull null])
                    datePicker.date = _segment[kSegmentDateKey];
                break;
            }
            default:
                break;
        }
    }else if(indexPath.section == 1){
        cell = [tableView dequeueReusableCellWithIdentifier:@"SegmentContentCell"];
        SZTextView *tv = (SZTextView *)[cell viewWithTag:kEditContentViewTag];
        tv.editable = YES;
        tv.placeholder = NSLocalizedString(@"NOTES", @"Notes");
        tv.placeholderTextColor = [UIColor lightGrayColor];
        if(_segment && _segment[kSegmentContentKey] != [NSNull null])
            tv.text = _segment[kSegmentContentKey];
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat h = 44;
    if(indexPath.section == 0 && indexPath.row == 3)
        h = 162;
    else if(indexPath.section == 1 && indexPath.row == 0)
        h = 180;

    return h;
}

- (void)openDatePicker {
    [self.tableView beginUpdates];
    [self hideKeyboard];
    [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:3 inSection:0]] withRowAnimation:UITableViewRowAnimationTop];
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:0]];
    UILabel *dateLabel = (UILabel *)[cell viewWithTag:kEditDateDateLabelTag];
    UILabel *timeLabel = (UILabel *)[cell viewWithTag:kEditDateTimeLabelTag];
    if(NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_6_1){
        dateLabel.textColor = self.tableView.tintColor;
        timeLabel.textColor = self.tableView.tintColor;
    }else{
        dateLabel.textColor = [UIColor whiteColor];
        timeLabel.textColor = [UIColor whiteColor];
    }
    NSDate *d = _segment[kSegmentDateKey];
    _segment[kSegmentDateKey] = [d removeSeconds];
    [self.tableView endUpdates];
}

- (void)closeDatePicker {
    [self.tableView beginUpdates];
    [self.tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:3 inSection:0]] withRowAnimation:UITableViewRowAnimationTop];
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:0]];
    UILabel *dateLabel = (UILabel *)[cell viewWithTag:kEditDateDateLabelTag];
    UILabel *timeLabel = (UILabel *)[cell viewWithTag:kEditDateTimeLabelTag];
    dateLabel.textColor = [UIColor blackColor];
    timeLabel.textColor = [UIColor blackColor];
    [self.tableView endUpdates];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.section == 0 && indexPath.row == 2){
        _datePickerVisible = !_datePickerVisible;
        if(_datePickerVisible)
            [self openDatePicker];
        else
            [self closeDatePicker];
    }else if(indexPath.section == 0 && indexPath.row == 1){
        RIPReminderViewController *reminderVc = [[RIPReminderViewController alloc] initWithStyle:UITableViewStyleGrouped];
        reminderVc.timeInterval = (_segment[kSegmentReminderKey] != [NSNull null])?(NSNumber *)_segment[kSegmentReminderKey]:nil;
        reminderVc.editSegVc = self;
        [self.navigationController pushViewController:reminderVc animated:YES];
    }
}

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath {
    return (indexPath.section == 0 && (indexPath.row == 2 || indexPath.row == 1));
}

- (NSString *)dateStringFromDate:(NSDate *)date {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterLongStyle];
    [dateFormatter setTimeStyle:NSDateFormatterNoStyle];
    return [dateFormatter stringFromDate:date];
}

- (NSString *)timeStringFromTime:(NSDate *)date {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterNoStyle];
    [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
    return [dateFormatter stringFromDate:date];
}

- (IBAction)pickerValueChanged:(UIDatePicker *)sender {
    _segment[kSegmentDateKey] = [sender.date removeSeconds];
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:0]];
    UILabel *dateLabel = (UILabel *)[cell viewWithTag:kEditDateDateLabelTag];
    UILabel *timeLabel = (UILabel *)[cell viewWithTag:kEditDateTimeLabelTag];
    dateLabel.text = [self dateStringFromDate:_segment[kSegmentDateKey]];
    timeLabel.text = [self timeStringFromTime:_segment[kSegmentDateKey]];
    [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:2 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
    [self hideKeyboard];
}

- (IBAction)titleEditingDidEnd:(UITextField *)sender {
    NSString *titleText = [sender.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if(titleText && titleText.length > 0)
        _segment[kEntryTitleKey] = titleText;

}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    NSString *titleText = [textField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if(titleText && titleText.length > 0)
        _segment[kEntryTitleKey] = titleText;
}

- (void)cancelButton {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)collectData {
    UITableViewCell *titleCell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    UITextField *tf = (UITextField *)[titleCell viewWithTag:kEditTitleFieldTag];
    NSString *titleText = [tf.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if(titleText && titleText.length > 0)
        _segment[kEntryTitleKey] = titleText;
    
    UITableViewCell *contentCell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1]];
    tf = (UITextField *)[contentCell viewWithTag:kEditContentViewTag];
    NSString *contentText = [tf.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if(contentText && contentText.length > 0)
        _segment[kSegmentContentKey] = contentText;
}

- (void)doneButton {
    
    [self collectData];
    
    NSMutableDictionary *doneSeg = [NSMutableDictionary dictionary];
    NSString *title = _segment[kEntryTitleKey];
    if(title && title.length > 0)
        doneSeg[kEntryTitleKey] = title;
    else
        doneSeg[kEntryTitleKey] = NSLocalizedString(@"UNTITLED", @"Untitled");
    
    doneSeg[kSegmentDateKey] = _segment[kSegmentDateKey];
    
    NSString *content = _segment[kSegmentContentKey];
    doneSeg[kSegmentContentKey] = content;
        
    if(_segment[kEntryObjectIDKey] && _segment[kEntryObjectIDKey] != [NSNull null])
        doneSeg[kEntryObjectIDKey] = _segment[kEntryObjectIDKey];
    
    if(_segment[kSegmentCompletionKey] != [NSNull null])
        doneSeg[kSegmentCompletionKey] = _segment[kSegmentCompletionKey];
    else
        doneSeg[kSegmentCompletionKey] = [NSNumber numberWithInt:RIPCompletionNotStarted];
    
    doneSeg[kSegmentReminderKey] = _segment[kSegmentReminderKey];
    
    doneSeg[kEntryPositionKey] = _segment[kEntryPositionKey];
    
    [_segementsVC updateSegmentsWith:doneSeg];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)hideKeyboard {
    UITableViewCell *titleCell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    UITextField *titleField = (UITextField *)[titleCell viewWithTag:kEditTitleFieldTag];
    [titleField resignFirstResponder];
    UITableViewCell *contentCell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1]];
    UITextView *textView = (UITextView *)[contentCell viewWithTag:kEditContentViewTag];
    [textView resignFirstResponder];
    [self.tableView setEditing:NO animated:YES];
}

- (void)updateReminderInterval:(NSNumber *)interval {
    _segment[kSegmentReminderKey] = interval?interval:[NSNull null];
    [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:1 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
}

@end
