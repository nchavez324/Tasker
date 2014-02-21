//
//  Note.h
//  Notepad
//
//  Created by Nick on 1/25/14.
//  Copyright (c) 2014 Nick. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "Entry.h"

extern NSString * const kNoteColorKey;
extern NSString * const kNoteCompletionKey;

@class Section, Segment;

@interface Note : Entry

@property (nonatomic, retain) UIColor *color;
@property (nonatomic, retain) Section *section;
@property (nonatomic, retain) NSSet *segments;
@end

@interface Note (CoreDataGeneratedAccessors)

- (void)addSegmentsObject:(Segment *)value;
- (void)removeSegmentsObject:(Segment *)value;
- (void)addSegments:(NSSet *)values;
- (void)removeSegments:(NSSet *)values;

@end
