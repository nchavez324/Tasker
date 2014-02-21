//
//  Entry.h
//  Notepad
//
//  Created by Nick on 1/24/14.
//  Copyright (c) 2014 Nick. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

extern NSString * const kEntryObjectIDKey;
extern NSString * const kEntryPositionKey;
extern NSString * const kEntryTitleKey;

@interface Entry : NSManagedObject

@property (nonatomic, retain) NSNumber *position;
@property (nonatomic, retain) NSString *title;

@end
