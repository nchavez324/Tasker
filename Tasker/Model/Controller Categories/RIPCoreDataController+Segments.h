//
//  RIPCoreDataController+Segments.h
//  Notepad
//
//  Created by Nick on 1/24/14.
//  Copyright (c) 2014 Nick. All rights reserved.
//

#import "RIPCoreDataController.h"

@interface RIPCoreDataController (Segments)

- (void)createSegments:(NSArray *)entries forNote:(NSManagedObjectID *)noteID completion:(void(^)(NSArray *))fCompletion;
- (void)readSegmentsFromNote:(NSManagedObjectID *)noteID completion:(void(^)(NSArray *))bCompletion;
- (void)deleteSegments:(NSArray *)segments completion:(void(^)(BOOL))fCompletion;

@end
