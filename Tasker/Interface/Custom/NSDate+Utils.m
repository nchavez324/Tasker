//
//  NSDate+Utils.m
//  Tasker
//
//  Created by Nick on 1/27/14.
//  Copyright (c) 2014 Nick. All rights reserved.
//

#import "NSDate+Utils.h"

@implementation NSDate (Utils)

- (NSString *)naturalString {
    NSString *ans = @"";
    CGFloat alpha = 1.0;
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.locale = [NSLocale currentLocale];
    NSDate *currentDate = [NSDate date];
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *dateComps = [gregorian components:(NSDayCalendarUnit | NSHourCalendarUnit | NSWeekCalendarUnit | NSWeekdayCalendarUnit | NSMinuteCalendarUnit | NSYearCalendarUnit | NSMonthCalendarUnit | NSTimeZoneCalendarUnit) fromDate:currentDate];
    [dateComps setMinute:0];
    [dateComps setTimeZone:[NSTimeZone localTimeZone]];
    
    [dateComps setHour:-24];
    NSDate *yesterdayMidnight = [gregorian dateFromComponents:dateComps];
    if([self compare:yesterdayMidnight] == NSOrderedAscending) {
        ans = NSLocalizedString(@"PAST", @"Past");
        alpha = 0.3;
    }else{
        [dateComps setHour:0];
        NSDate *lastMidnight = [gregorian dateFromComponents:dateComps];
        if([self compare:lastMidnight] == NSOrderedAscending){
            ans = NSLocalizedString(@"YESTERDAY", @"Yesterday");
            alpha = 0.4;
        }else{
            [dateComps setHour:24];
            NSDate *midnight = [gregorian dateFromComponents:dateComps];
            if([self compare:midnight] == NSOrderedAscending){
                //get time!
                [dateFormatter setDateStyle:NSDateFormatterNoStyle];
                [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
                ans = [dateFormatter stringFromDate:self];
                alpha = 1.0;
            }else{
                [dateComps setHour:48];
                NSDate *tmrwMidnight = [gregorian dateFromComponents:dateComps];
                if([self compare:tmrwMidnight] == NSOrderedAscending){
                    ans = NSLocalizedString(@"TOMORROW", @"Tomorrow");
                    alpha = 1.0;
                }else{
                    [dateComps setHour:24*7];
                    NSDate *nextWeek = [gregorian dateFromComponents:dateComps];
                    if([self compare:nextWeek] == NSOrderedAscending){
                        dateFormatter.dateFormat = [NSDateFormatter dateFormatFromTemplate:@"EEEE" options:0 locale:[NSLocale currentLocale]];
                        ans = [dateFormatter stringFromDate:self];
                        alpha = 0.7;
                    }else{
                        dateFormatter.dateFormat = [NSDateFormatter dateFormatFromTemplate:@"LLLL, d" options:0 locale:[NSLocale currentLocale]];
                        ans = [dateFormatter stringFromDate:self];
                        alpha = 0.5;
                    }
                }
            }
        }
    }
    return ans;
}

- (NSDate *)removeSeconds {
    NSDateComponents *dateComps = [[NSCalendar currentCalendar] components:NSSecondCalendarUnit fromDate:self];
    [dateComps setSecond:-[dateComps second]];
    return [[NSCalendar currentCalendar] dateByAddingComponents:dateComps toDate:self options:0];
}

@end
