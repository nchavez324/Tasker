//
//  RIPSegmentCell.m
//  Notepad
//
//  Created by Nick on 1/24/14.
//  Copyright (c) 2014 Nick. All rights reserved.
//

#import "NSDate+Utils.h"
#import "RIPCircleButton.h"
#import "RIPSegmentCell.h"

@interface RIPSegmentCell ()
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UILabel *contentPreviewLabel;
@property (weak, nonatomic) IBOutlet RIPCircleButton *completionButton;
@end

@implementation RIPSegmentCell

- (id)init {
    if(self = [super init])
        [self initialize];
    return self;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if(self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])
        [self initialize];
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    if(self = [super initWithCoder:aDecoder])
        [self initialize];
    return self;
}


- (void)initialize {
    _titleLabel.text = NSLocalizedString(@"UNTITLED", @"Untitled");
    _dateLabel.font = [UIFont systemFontOfSize:14];
    _dateLabel.text = @"";
    _contentPreviewLabel.text = @"";
    [_completionButton setCompletion:0.5 animated:NO];
    [self setSelectedMode:NO];
}

- (void)setTitle:(NSString *)title {
    _titleLabel.text = title;
}

- (void)setCompletion:(float)completion animated:(BOOL)animated {
    [_completionButton setCompletion:completion animated:animated];
    [_completionButton setColor:self.tintColor animated:NO];

}

- (void)setContent:(NSString *)content {
    _contentPreviewLabel.text = content;
}

- (void)setDate:(NSDate *)date {
    NSString *ans = @"";
    CGFloat alpha = 1.0;
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.locale = [NSLocale currentLocale];
    NSDate *currentDate = [NSDate date];
  NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
  NSDateComponents *dateComps = [gregorian components:(NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitWeekOfMonth | NSCalendarUnitWeekday | NSCalendarUnitMinute | NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitTimeZone) fromDate:currentDate];
    [dateComps setMinute:0];
    [dateComps setTimeZone:[NSTimeZone localTimeZone]];
    
    [dateComps setHour:-24];
    NSDate *yesterdayMidnight = [gregorian dateFromComponents:dateComps];
    if([date compare:yesterdayMidnight] == NSOrderedAscending) {
        ans = NSLocalizedString(@"PAST", @"Past");
        alpha = 0.3;
    }else{
        [dateComps setHour:0];
        NSDate *lastMidnight = [gregorian dateFromComponents:dateComps];
        if([date compare:lastMidnight] == NSOrderedAscending){
            ans = NSLocalizedString(@"YESTERDAY", @"Yesterday");
            alpha = 0.4;
        }else{
            [dateComps setHour:24];
            NSDate *midnight = [gregorian dateFromComponents:dateComps];
            if([date compare:midnight] == NSOrderedAscending){
                //get time!
                [dateFormatter setDateStyle:NSDateFormatterNoStyle];
                [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
                ans = [dateFormatter stringFromDate:date];
                alpha = 1.0;
            }else{
                [dateComps setHour:48];
                NSDate *tmrwMidnight = [gregorian dateFromComponents:dateComps];
                if([date compare:tmrwMidnight] == NSOrderedAscending){
                    ans = NSLocalizedString(@"TOMORROW", @"Tomorrow");
                    alpha = 1.0;
                }else{
                    [dateComps setHour:24*7];
                    NSDate *nextWeek = [gregorian dateFromComponents:dateComps];
                    if([date compare:nextWeek] == NSOrderedAscending){
                        dateFormatter.dateFormat = [NSDateFormatter dateFormatFromTemplate:@"EEEE" options:0 locale:[NSLocale currentLocale]];
                        ans = [dateFormatter stringFromDate:date];
                        alpha = 0.7;
                    }else{
                        dateFormatter.dateFormat = [NSDateFormatter dateFormatFromTemplate:@"LLLL, d" options:0 locale:[NSLocale currentLocale]];
                        ans = [dateFormatter stringFromDate:date];
                        alpha = 0.5;
                    }
                }
            }
        }
    }
    _dateLabel.text = ans;
    _dateLabel.alpha = alpha;
}

- (NSString *)getTitle {
    return _titleLabel.text;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    [self setSelectedMode:selected];
}

- (void)setSelectedMode:(BOOL)selected {
    UIColor *textColor = selected?[UIColor whiteColor]:[UIColor blackColor];
    UIColor *altTextColor = selected?[UIColor darkGrayColor]:[UIColor lightGrayColor];
    UIColor *bgColor = selected?[UIColor lightGrayColor]:[UIColor whiteColor];
    
    _titleLabel.textColor = textColor;
    _dateLabel.textColor = textColor;
    _contentPreviewLabel.textColor = altTextColor;
    
    self.backgroundColor = bgColor;
}

@end
