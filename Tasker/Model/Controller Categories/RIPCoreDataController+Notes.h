//
//  RIPCoreDataController+Notes.h
//  Notepad
//
//  Created by Nick on 1/24/14.
//  Copyright (c) 2014 Nick. All rights reserved.
//

#import "RIPCoreDataController.h"

@interface RIPCoreDataController (Notes)

- (void)createNotes:(NSArray *)entries forSection:(NSManagedObjectID *)sectionID completion:(void(^)(NSArray *))fCompletion;
- (void)readNotesFromSection:(NSManagedObjectID *)sectionID completion:(void(^)(NSArray *))bCompletion;
- (void)deleteNotes:(NSArray *)notes completion:(void(^)(BOOL))fCompletion;

@end
