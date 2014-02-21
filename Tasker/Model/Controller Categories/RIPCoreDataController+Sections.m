//
//  RIPCoreDataController+Sections.m
//  Notepad
//
//  Created by Nick on 1/24/14.
//  Copyright (c) 2014 Nick. All rights reserved.
//

#import "Section.h"
#import "RIPErrorManager.h"
#import "RIPCoreDataController+Sections.h"

@implementation RIPCoreDataController (Sections)

- (void)createSections:(NSArray *)entries completion:(void(^)(NSArray *))fCompletion {
    void(^mainCompletion)(NSArray *) = ^(NSArray *ids) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if(ids != nil)
                [self saveContext];
            if(fCompletion != nil)
                fCompletion(ids);
        });
    };
    dispatch_async(self.backgroundQueue, ^{
        NSManagedObjectContext *moc = [self newChildManagedObjectContext];
        assert(moc != nil);
        NSMutableArray *objIDs = [NSMutableArray array];
        for (NSDictionary *entry in entries) {
            NSEntityDescription *entity = [NSEntityDescription entityForName:@"Section" inManagedObjectContext:moc];
            Section *section = [NSEntityDescription insertNewObjectForEntityForName:entity.name inManagedObjectContext:moc];
            [section setPosition:(NSNumber *)entry[kEntryPositionKey]];
            [section setColor:(UIColor *)entry[kSectionColorKey]];
            [section setTitle:(NSString *)entry[kEntryTitleKey]];
            [objIDs addObject:section.objectID];
        }
        NSError *error = nil;
        [moc save:&error];
        if(error){
            [RIPErrorManager printError:error location:@"createSections:completion:"];
            return mainCompletion(nil);
        }
        return mainCompletion(objIDs);
    });
}

- (void)readSectionsWithCompletion:(void (^)(NSArray *))bCompletion {
    void(^completion)(NSArray *);
    if(bCompletion == nil)
        completion = ^(NSArray *a){};
    else
        completion = bCompletion;
    
    dispatch_async(self.backgroundQueue, ^{
        NSManagedObjectContext *moc = [self newChildManagedObjectContext];
        assert(moc != nil);
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"Section" inManagedObjectContext:moc];
        NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:entity.name];
        NSSortDescriptor *byPosition = [[NSSortDescriptor alloc] initWithKey:@"position" ascending:NO];
        [request setSortDescriptors:@[byPosition]];
        NSError *error = nil;
        NSArray *sections = [moc executeFetchRequest:request error:&error];
        if(sections == nil){
            [RIPErrorManager printError:error location:@"readSectionsWithCompletion:"];
            return bCompletion(nil);
        }
        NSMutableArray *ids = [NSMutableArray array];
        for (NSManagedObject *mo in sections)
            [ids addObject:mo.objectID];
        
        bCompletion(ids);
    });
}

- (void)deleteSections:(NSArray *)sections completion:(void(^)(BOOL success))fCompletion {
    void(^mainCompletion)(BOOL) = ^(BOOL success){
        dispatch_async(dispatch_get_main_queue(), ^{
            if(success)
                [self saveContext];
            if(fCompletion != nil)
                fCompletion(success);
        });
    };
    dispatch_async(self.backgroundQueue, ^{
        NSManagedObjectContext *moc = [self newChildManagedObjectContext];
        for (NSManagedObjectID *mid in sections) {
            NSManagedObject *mo = [moc objectWithID:mid];
            [moc deleteObject:mo];
        }
        NSError *error = nil;
        [moc save:&error];
        if(error){
            [RIPErrorManager printError:error location:@"deleteSections:completion"];
            return mainCompletion(NO);
        }
        return mainCompletion(YES);
    });
}

@end
