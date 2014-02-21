//
//  RIPAppDelegate.h
//  Notepad
//
//  Created by Nick on 1/22/14.
//  Copyright (c) 2014 Nick. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RIPCoreDataController;

@interface RIPAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) RIPCoreDataController *coreDataController;

+ (RIPAppDelegate *)shared;

@end
