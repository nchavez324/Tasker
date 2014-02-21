//
//  Note.m
//  Notepad
//
//  Created by Nick on 1/25/14.
//  Copyright (c) 2014 Nick. All rights reserved.
//

#import "Note.h"
#import "Section.h"
#import "Segment.h"

NSString * const kNoteColorKey = @"kColor";
NSString * const kNoteCompletionKey = @"kCompletion";

@implementation Note

@dynamic color;
@dynamic section;
@dynamic segments;

@end
