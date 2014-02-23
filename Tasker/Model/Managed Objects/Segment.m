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

+ (NSNumber *)intervalForIndex:(NSInteger)index {
    if(index == 0)
        return nil;
    if(kReminderIntervals == nil)
        [Segment initReminders];
    return [NSNumber numberWithFloat:([(NSNumber *)kReminderIntervals[index-1][0] floatValue]*[(NSNumber *)kReminderIntervals[index-1][1] integerValue])];
}

+ (void)initReminders {
    
    kReminderIntervals = @[
                           @[@60.0, @0, @"REM_AT_TIME_OF_EVENT"],
                           @[@60.0, @5, minutesBefore],
                           @[@60.0, @15, minutesBefore],
                           @[@60.0, @30, minutesBefore],
                           
                           @[[NSNumber numberWithFloat:60*60], @1, [NSString stringWithFormat:@"%@_S", hoursBefore]],
                           @[[NSNumber numberWithFloat:60*60], @2, [NSString stringWithFormat:@"%@_P", hoursBefore]],
                           
                           @[[NSNumber numberWithFloat:60*60*24], @1, [NSString stringWithFormat:@"%@_S", daysBefore]],
                           @[[NSNumber numberWithFloat:60*60*24], @2, [NSString stringWithFormat:@"%@_P", daysBefore]],
                           
                           @[[NSNumber numberWithFloat:60*60*24*7], @1, @"REM_WEEK_BEFORE"],
                           ];
}

+ (NSInteger)numReminderIntervals {
    if(kReminderIntervals == nil)
        [Segment initReminders];
    return kReminderIntervals.count + 1;
}

+ (NSInteger)indexForInterval:(NSNumber *)interval {
    if(interval == nil || ![interval.class isSubclassOfClass:[NSNumber class]])
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

+ (NSString *)stringForReminderInterval:(NSNumber *)interval {
    if(interval == nil || ![interval.class isSubclassOfClass:[NSNumber class]])
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

+ (BOOL)scheduleNotification:(NSDictionary *)segment withSectionName:(NSString *)sectionName{
    if(segment[kSegmentReminderKey] != [NSNull null]){
        NSNumber *interval = segment[kSegmentReminderKey];
        UILocalNotification *notification = [[UILocalNotification alloc] init];
        NSDate *date = segment[kSegmentDateKey];
        notification.fireDate = [NSDate dateWithTimeInterval:(interval.floatValue==0)?0:(-1*interval.floatValue) sinceDate:date];
        notification.userInfo = @{kEntryObjectIDKey: [(NSManagedObjectID *)segment[kEntryObjectIDKey] description]};
        notification.alertAction = @"";
        notification.alertBody = [NSString stringWithFormat:@"%@:\n%@", sectionName, segment[kEntryTitleKey]];
        notification.soundName = UILocalNotificationDefaultSoundName;
        [[UIApplication sharedApplication] scheduleLocalNotification:notification];
        return YES;
    }
    return NO;
}

@end
