//
//  RIPEditSegmentViewController.m
//  Notepad
//
//  Created by Nick on 1/25/14.
//  Copyright (c) 2014 Nick. All rights reserved.
//

#import "RIPCompletion.h"
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
@property (strong, nonatomic) NSNumber *timeInterval;
@property (strong, nonatomic) NSDate *date;
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
    _date = [NSDate date];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelButton)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneButton)];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    _datePickerVisible = NO;
    if(_segment){
        UITableViewCell *titleCell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
        UITextField *tf = (UITextField *)[titleCell viewWithTag:kEditTitleFieldTag];
        if(tf.text.length == 0)
            tf.text = _segment[kEntryTitleKey];
        
        if(_timeInterval == nil)
            _timeInterval = _segment[kSegmentReminderKey];
        
        if(_date == nil)
            _date = _segment[kSegmentDateKey];
        
        UITableViewCell *contentCell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1]];
        UITextView *tv = (UITextView *)[contentCell viewWithTag:kEditContentViewTag];
        if(tv.text.length == 0)
            tv.text = _segment[kSegmentContentKey];
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
                break;
            }
            case 1:{
                cell = [tableView dequeueReusableCellWithIdentifier:@"SegmentReminderCell"];
                cell.textLabel.text = NSLocalizedString(@"REMINDER", @"Reminder");
                cell.detailTextLabel.text = [Segment stringForReminderInterval:_timeInterval];
                break;
            }
            case 2:{
                cell = [tableView dequeueReusableCellWithIdentifier:@"SegmentDateCell"];
                UILabel *dueLabel = (UILabel *)[cell viewWithTag:kEditDateDueLabelTag];
                UILabel *dateLabel = (UILabel *)[cell viewWithTag:kEditDateDateLabelTag];
                UILabel *timeLabel = (UILabel *)[cell viewWithTag:kEditDateTimeLabelTag];
                dueLabel.text = NSLocalizedString(@"DUE", @"Due");
                dateLabel.text = [self dateStringFromDate:_date];
                timeLabel.text = [self timeStringFromTime:_date];
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
                datePicker.date = _date;
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
        reminderVc.timeInterval = _timeInterval;
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
    _date = sender.date;
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:0]];
    UILabel *dateLabel = (UILabel *)[cell viewWithTag:kEditDateDateLabelTag];
    UILabel *timeLabel = (UILabel *)[cell viewWithTag:kEditDateTimeLabelTag];
    dateLabel.text = [self dateStringFromDate:_date];
    timeLabel.text = [self timeStringFromTime:_date];
    [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:2 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
    [self hideKeyboard];
}

- (void)textViewDidBeginEditing:(UITextView *)textView {
    /*NSLog(@">");
    if(_datePickerVisible)
        [self closeDatePicker];
     */
}

- (IBAction)textEditingBegan:(id)sender {
    /*NSLog(@"<");
    if(_datePickerVisible)
        [self closeDatePicker];
     */
}

- (void)cancelButton {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)doneButton {
    NSMutableDictionary *segment = [NSMutableDictionary dictionary];
    
    UITableViewCell *titleCell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    UITextField *titleField = (UITextField *)[titleCell viewWithTag:kEditTitleFieldTag];
    NSString *t = [titleField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if(t == nil || t.length == 0)
        segment[kEntryTitleKey] = NSLocalizedString(@"UNTITLED", @"Untitled");
    else
        segment[kEntryTitleKey] = t;
    
    segment[kSegmentDateKey] = _date;
    
    UITableViewCell *contentCell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1]];
    UITextView *textView = (UITextView *)[contentCell viewWithTag:kEditContentViewTag];
    segment[kSegmentContentKey] = [textView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if(_segment[kEntryObjectIDKey])
        segment[kEntryObjectIDKey] = _segment[kEntryObjectIDKey];
    
    if(_segment[kSegmentCompletionKey])
        segment[kSegmentCompletionKey] = _segment[kSegmentCompletionKey];
    else
        segment[kSegmentCompletionKey] = [NSNumber numberWithInt:RIPCompletionNotStarted];
    
    segment[kSegmentReminderKey] = _timeInterval;
    
    segment[kEntryPositionKey] = _segment[kEntryPositionKey];
    
    [_segementsVC updateSegmentsWith:segment];
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

- (void)updateReminderInterval:(NSObject *)interval {
    _timeInterval = (NSNumber *)interval;
    [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:1 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
}

@end
