//
//  RIPCoreDataController.m
//  Notepad
//
//  Created by Nick on 1/22/14.
//  Copyright (c) 2014 Nick. All rights reserved.
//

#import "Segment.h"
#import "Note.h"
#import "Section.h"
#import "UIColor+Utils.h"
#import "RIPAppDelegate.h"
#import "RIPErrorManager.h"
#import "RIPCoreDataController.h"

@interface RIPCoreDataController ()
@property (assign, nonatomic) BOOL newStore;
@end

@implementation RIPCoreDataController

@synthesize managedObjectContext       = _managedObjectContext;
@synthesize managedObjectModel         = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

+ (RIPCoreDataController *)shared {
    return [[RIPAppDelegate shared] coreDataController];
}

- (id)init {
    if(self = [super init])
        _newStore = NO;
    return self;
}

- (void)applicationWillResignActive:(UIApplication *)application { }

- (void)applicationDidEnterBackground:(UIApplication *)application { }

- (void)applicationWillEnterForeground:(UIApplication *)application { }

- (void)applicationDidBecomeActive:(UIApplication *)application { }

- (void)applicationWillTerminate:(UIApplication *)application {
    [self saveContext];
}

- (void)saveContext {
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if(managedObjectContext != nil){
        if([managedObjectContext hasChanges] && ![managedObjectContext save:&error]){
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

- (void)writeDefaultStore:(NSManagedObjectContext *)moc {
    NSString *defaultDataPath = [[NSBundle mainBundle] pathForResource:@"DefaultData" ofType:@"plist"];
    NSArray *sections = [NSArray arrayWithContentsOfFile:defaultDataPath];
    if(sections != nil){
        for (NSDictionary *sectionD in sections) {
            NSEntityDescription *entity = [NSEntityDescription entityForName:@"Section" inManagedObjectContext:moc];
            Section *section = [NSEntityDescription insertNewObjectForEntityForName:entity.name inManagedObjectContext:moc];
            [section setPosition:sectionD[kEntryPositionKey]];
            [section setTitle:sectionD[kEntryTitleKey]];
            [section setColor:[UIColor colorWithRGBAArray:sectionD[kSectionColorKey]]];
            for (NSDictionary *noteD in sectionD[@"notes"]) {
                entity = [NSEntityDescription entityForName:@"Note" inManagedObjectContext:moc];
                Note *note = [NSEntityDescription insertNewObjectForEntityForName:entity.name inManagedObjectContext:moc];
                [note setPosition:noteD[kEntryPositionKey]];
                [note setTitle:noteD[kEntryTitleKey]];
                [note setColor:[UIColor colorWithRGBAArray:noteD[kNoteColorKey]]];
                [note setSection:section];
                for (NSDictionary *segmentD in noteD[@"segments"]) {
                    entity = [NSEntityDescription entityForName:@"Segment" inManagedObjectContext:moc];
                    Segment *segment = [NSEntityDescription insertNewObjectForEntityForName:entity.name inManagedObjectContext:moc];
                    [segment setPosition:segmentD[kEntryPositionKey]];
                    [segment setTitle:segmentD[kEntryTitleKey]];
                    [segment setCompletion:segmentD[kSegmentCompletionKey]];
                    [segment setContent:segmentD[kSegmentContentKey]];
                    [segment setDate:[NSDate date]];
                    [segment setNote:note];
                }
            }
        }
    }
}

- (NSManagedObjectContext *)managedObjectContext {
    if(_managedObjectContext != nil){
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil){
        _managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
        if(_newStore){
            [self writeDefaultStore:_managedObjectContext];
            [self saveContext];
            _newStore = NO;
        }
    }
    return _managedObjectContext;
}

- (NSManagedObjectContext *)newChildManagedObjectContext {
    NSManagedObjectContext *moc = nil;
    moc = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    moc.parentContext = self.managedObjectContext;
    if(moc.parentContext == nil)
        return nil;
    return moc;
}

- (NSManagedObjectModel *)managedObjectModel {
    if(_managedObjectModel != nil){
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"Tasker" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    if(_persistentStoreCoordinator != nil){
        return _persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"Tasker.sqlite"];
    
    _newStore = ![[NSFileManager defaultManager] fileExistsAtPath:[storeURL path]];
    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if(![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:@{NSMigratePersistentStoresAutomaticallyOption:@YES, NSInferMappingModelAutomaticallyOption:@YES} error:&error]){
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
         
         Typical reasons for an error here include:
         * The persistent store is not accessible;
         * The schema for the persistent store is incompatible with current managed object model.
         Check the error message to determine what the actual problem was.
         
         
         If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
         
         If you encounter schema incompatibility errors during development, you can reduce their frequency by:
         * Simply deleting the existing store:
         [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
         
         * Performing automatic lightweight migration by passing the following dictionary as the options parameter:
         @{NSMigratePersistentStoresAutomaticallyOption:@YES, NSInferMappingModelAutomaticallyOption:@YES}
         
         Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
         
         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    
    return _persistentStoreCoordinator;
}

- (NSURL *)applicationDocumentsDirectory {
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (dispatch_queue_t)backgroundQueue {
    if(_backgroundQueue == nil)
        _backgroundQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    return _backgroundQueue;
}

- (void)updateObjects:(void(^)(NSManagedObjectContext *))update completion:(void (^)(BOOL))fCompletion {
    void(^mainCompletion)(BOOL) = ^(BOOL success) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if(success)
                [self saveContext];
            if(fCompletion != nil)
                fCompletion(success);
        });
    };
    dispatch_async(self.backgroundQueue, ^{
        NSManagedObjectContext *moc = [self newChildManagedObjectContext];
        update(moc);
        NSError *error = nil;
        [moc save:&error];
        if(error){
            [RIPErrorManager printError:error location:@"updateObjects:completion"];
            return mainCompletion(NO);
        }
        return mainCompletion(YES);
    });
}

@end
