//
//  RIPCoreDataController+Sections.h
//  Notepad
//
//  Created by Nick on 1/24/14.
//  Copyright (c) 2014 Nick. All rights reserved.
//

#import "RIPCoreDataController.h"

@interface RIPCoreDataController (Sections)

- (void)createSections:(NSArray *)entries completion:(void(^)(NSArray *))fCompletion;
- (void)readSectionsWithCompletion:(void(^)(NSArray *))bCompletion;
- (void)deleteSections:(NSArray *)sections completion:(void(^)(BOOL))fCompletion;

@end
