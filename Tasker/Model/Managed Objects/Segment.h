//
//  Segment.h
//
//
//  Created by Nick on 2/17/14.
//  Copyright (c) 2014 Nick. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "Entry.h"

extern NSString * const kSegmentContentKey;
extern NSString * const kSegmentCompletionKey;
extern NSString * const kSegmentDateKey;
extern NSString * const kSegmentReminderKey;

@class Note;

@interface Segment : Entry

@property (nonatomic, retain) NSNumber * completion;
@property (nonatomic, retain) NSString * content;
@property (nonatomic, retain) NSDate * date;
@property (nonatomic, retain) NSNumber * reminder;
@property (nonatomic, retain) Note *note;

+ (NSInteger)indexForInterval:(NSObject *)interval;
+ (NSInteger)numReminderIntervals;
+ (NSObject *)intervalForIndex:(NSInteger)index;
+ (NSString *)stringForReminderInterval:(NSObject *)interval;
+ (BOOL)scheduleNotification:(NSDictionary *)segment withSectionName:(NSString *)sectionName;

@end
