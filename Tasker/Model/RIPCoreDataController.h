//
//  RIPCoreDataController.h
//  Notepad
//
//  Created by Nick on 1/22/14.
//  Copyright (c) 2014 Nick. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RIPCoreDataController : NSObject

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (strong, nonatomic) dispatch_queue_t backgroundQueue;

+ (RIPCoreDataController *)shared;
- (NSManagedObjectContext *)newChildManagedObjectContext;
- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;

/* App Delegate Methods */
- (void)applicationWillResignActive:(UIApplication *)application;
- (void)applicationDidEnterBackground:(UIApplication *)application;
- (void)applicationWillEnterForeground:(UIApplication *)application;
- (void)applicationDidBecomeActive:(UIApplication *)application;
- (void)applicationWillTerminate:(UIApplication *)application;

- (void)updateObjects:(void(^)(NSManagedObjectContext *))update completion:(void (^)(BOOL))fCompletion;

@end
