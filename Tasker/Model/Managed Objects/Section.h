//
//  Section.h
//  Notepad
//
//  Created by Nick on 1/24/14.
//  Copyright (c) 2014 Nick. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "Entry.h"

extern NSString * const kSectionColorKey;

@class Note;

@interface Section : Entry

@property (nonatomic, retain) UIColor *color;
@property (nonatomic, retain) NSSet *notes;

+ (UIColor *)getColor:(NSInteger)i;

@end

@interface Section (CoreDataGeneratedAccessors)

- (void)addNotesObject:(Note *)value;
- (void)removeNotesObject:(Note *)value;
- (void)addNotes:(NSSet *)values;
- (void)removeNotes:(NSSet *)values;

@end
