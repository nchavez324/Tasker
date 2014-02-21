//
//  Segment.m
//  Tasker
//
//  Created by Nick on 2/17/14.
//  Copyright (c) 2014 Nick. All rights reserved.
//

#import "Segment.h"
#import "Note.h"

static NSArray * kReminderIntervals = nil;

NSString * const kSegmentContentKey = @"kContent";
NSString * const kSegmentCompletionKey = @"kCompletion";
NSString * const kSegmentDateKey = @"kDate";
NSString * const kSegmentReminderKey = @"kReminder";

static NSString *minutesBefore = @"REM_MINUTES_BEFORE";
static NSString *hoursBefore = @"REM_HOURS_BEFORE";
static NSString *daysBefore = @"REM_DAYS_BEFORE";

@implementation Segment

@dynamic completion;
@dynamic content;
@dynamic date;
@dynamic reminder;
@dynamic note;

+ (NSObject *)intervalForIndex:(NSInteger)index {
    if(index == 0)
        return [NSNull null];
    if(kReminderIntervals == nil)
        [Segment initReminders];
    return [NSNumber numberWithFloat:([(NSNumber *)kReminderIntervals[index-1][0] floatValue]*[(NSNumber *)kReminderIntervals[index-1][1] integerValue])];
}

+ (void)initReminders {
    
    kReminderIntervals = @[
                           @[[NSNumber numberWithFloat:60], [NSNumber numberWithInt:0], @"REM_AT_TIME_OF_EVENT"],
                           @[[NSNumber numberWithFloat:60], [NSNumber numberWithInt:5], minutesBefore],
                           @[[NSNumber numberWithFloat:60], [NSNumber numberWithInt:15], minutesBefore],
                           @[[NSNumber numberWithFloat:60], [NSNumber numberWithInt:30], minutesBefore],
                           
                           @[[NSNumber numberWithFloat:60*60], [NSNumber numberWithInt:1], [NSString stringWithFormat:@"%@_S", hoursBefore]],
                           @[[NSNumber numberWithFloat:60*60], [NSNumber numberWithInt:2], [NSString stringWithFormat:@"%@_P", hoursBefore]],
                           
                           @[[NSNumber numberWithFloat:60*60*24], [NSNumber numberWithInt:1], [NSString stringWithFormat:@"%@_S", daysBefore]],
                           @[[NSNumber numberWithFloat:60*60*24], [NSNumber numberWithInt:2], [NSString stringWithFormat:@"%@_P", daysBefore]],
                           
                           @[[NSNumber numberWithFloat:60*60*24*7], [NSNumber numberWithInt:1], @"REM_WEEK_BEFORE"],
                           ];
}

+ (NSInteger)numReminderIntervals {
    if(kReminderIntervals == nil)
        [Segment initReminders];
    return kReminderIntervals.count + 1;
}

+ (NSInteger)indexForInterval:(NSObject *)interval {
    if(interval == nil || interval == [NSNull null] || ![interval.class isSubclassOfClass:[NSNumber class]])
        return 0;
    NSNumber *n = (NSNumber *)interval;
    NSTimeInterval ti = n.doubleValue;
    
    if(kReminderIntervals == nil){
        [Segment initReminders];
    }
    
    NSInteger index = 0;
    for(NSInteger i = 0; i < kReminderIntervals.count; i++){
        NSTimeInterval t = [(NSNumber *)kReminderIntervals[i][0] floatValue]*[(NSNumber *)kReminderIntervals[i][1] integerValue];
        if(t == ti){
            index = i + 1;
        }
    }
    return index;
}

+ (NSString *)stringForReminderInterval:(NSObject *)interval {
    if(interval == nil || interval == [NSNull null] || ![interval.class isSubclassOfClass:[NSNumber class]])
        return NSLocalizedString(@"NONE", @"None");
    NSNumber *n = (NSNumber *)interval;
    NSTimeInterval ti = n.doubleValue;
    
    //supported times:
    //nil, 0, 5m, 15m, 30m, 1h, 2h, 1d, 2d, 1w
    
    if(kReminderIntervals == nil){
        [Segment initReminders];
    }
    
    NSString *s = NSLocalizedString(@"NONE", @"None");
    
    for(NSInteger i = 0; i < kReminderIntervals.count; i++){
        NSTimeInterval t = [(NSNumber *)kReminderIntervals[i][0] floatValue]*[(NSNumber *)kReminderIntervals[i][1] integerValue];
        if(t == ti){
            if(i == 0){
                s = NSLocalizedString((NSString *)kReminderIntervals[i][2], @"");
            }else{
                NSString *pfx = [NSString stringWithFormat:@"%@_PREFIX", (NSString *)kReminderIntervals[i][2]];
                NSString *prefix = NSLocalizedString(pfx, @"");
                NSString *sfx = [NSString stringWithFormat:@"%@_SUFFIX", (NSString *)kReminderIntervals[i][2]];
                NSString *suffix = NSLocalizedString(sfx, @"");
                s = [NSString stringWithFormat:@"%@%d%@", prefix, [(NSNumber *)kReminderIntervals[i][1] intValue], suffix];
            }
        }
    }
    
    return s;
}

@end
