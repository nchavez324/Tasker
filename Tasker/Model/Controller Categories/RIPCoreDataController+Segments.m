//
//  RIPCoreDataController+Segments.m
//  Notepad
//
//  Created by Nick on 1/24/14.
//  Copyright (c) 2014 Nick. All rights reserved.
//

#import "Note.h"
#import "Segment.h"
#import "RIPErrorManager.h"
#import "RIPCoreDataController+Segments.h"

@implementation RIPCoreDataController (Segments)

- (void)createSegments:(NSArray *)entries forNote:(NSManagedObjectID *)noteID completion:(void(^)(NSArray *))fCompletion {
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
        Note *note = (Note *)[moc objectWithID:noteID];
        NSMutableSet *mos = [note mutableSetValueForKey:@"segments"];
        for (NSDictionary *entry in entries) {
            NSEntityDescription *entity = [NSEntityDescription entityForName:@"Segment" inManagedObjectContext:moc];
            Segment *segment = [NSEntityDescription insertNewObjectForEntityForName:entity.name inManagedObjectContext:moc];
            [segment setPosition:(NSNumber *)entry[kEntryPositionKey]];
            [segment setTitle:(NSString *)entry[kEntryTitleKey]];
            [segment setCompletion:(NSNumber *)entry[kSegmentCompletionKey]];
            [segment setContent:(NSString *)entry[kSegmentContentKey]];
            [segment setDate:(NSDate *)entry[kSegmentDateKey]];
            [segment setReminder:((entry[kSegmentReminderKey]==[NSNull null])?nil:(NSNumber *)entry[kSegmentReminderKey])];
            [segment setNote:note];
            [objIDs addObject:segment.objectID];
            [mos addObject:segment];
        }
        NSError *error = nil;
        [moc save:&error];
        if(error){
            [RIPErrorManager printError:error location:@"createSegments:forNote:completion:"];
            return mainCompletion(nil);
        }
        return mainCompletion(objIDs);
    });
}

- (void)readSegmentsFromNote:(NSManagedObjectID *)noteID completion:(void(^)(NSArray *))bCompletion {
    void(^completion)(NSArray *) = ^(NSArray *ids){
        if(bCompletion != nil)
            bCompletion(ids);
    };
    dispatch_async(self.backgroundQueue, ^{
        NSManagedObjectContext *moc = [self newChildManagedObjectContext];
        Note *note = (Note *)[moc objectWithID:noteID];
        NSSet *osSegments = note.segments;
        NSMutableArray *ids = [NSMutableArray array];
        for (Segment *segment in osSegments)
            [ids addObject:segment.objectID];
        [ids sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
            NSManagedObjectID *mid1 = (NSManagedObjectID *)obj1,
            *mid2 = (NSManagedObjectID *)obj2;
            Segment *seg1 = (Segment *)[moc objectWithID:mid1],
                    *seg2 = (Segment *)[moc objectWithID:mid2];
            //in reverse lol since a higher position means higher up
            return [seg2.position compare:seg1.position];
        }];
        return completion(ids);
    });

}

- (void)deleteSegments:(NSArray *)segments completion:(void(^)(BOOL))fCompletion {
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
        for (NSManagedObjectID *mid in segments) {
            Segment *mo = (Segment *)[moc objectWithID:mid];
            NSMutableSet *ms = [mo.note mutableSetValueForKey:@"segments"];
            [ms removeObject:mo];
            [moc deleteObject:mo];
        }
        NSError *error = nil;
        [moc save:&error];
        if(error){
            [RIPErrorManager printError:error location:@"deleteNotes:completion"];
            return mainCompletion(NO);
        }
        return mainCompletion(YES);
    });
}


@end
