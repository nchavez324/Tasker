//
//  RIPCoreDataController+Notes.m
//  Notepad
//
//  Created by Nick on 1/24/14.
//  Copyright (c) 2014 Nick. All rights reserved.
//

#import "RIPCompletion.h"
#import "Section.h"
#import "Note.h"
#import "RIPErrorManager.h"
#import "RIPCoreDataController+Notes.h"

@implementation RIPCoreDataController (Notes)

- (void)createNotes:(NSArray *)entries forSection:(NSManagedObjectID *)sectionID completion:(void(^)(NSArray *))fCompletion {
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
        Section *section = (Section *)[moc objectWithID:sectionID];
        NSMutableSet *mos = [section mutableSetValueForKey:@"notes"];
        for (NSDictionary *entry in entries) {
            NSEntityDescription *entity = [NSEntityDescription entityForName:@"Note" inManagedObjectContext:moc];
            Note *note = [NSEntityDescription insertNewObjectForEntityForName:entity.name inManagedObjectContext:moc];
            [note setPosition:(NSNumber *)entry[kEntryPositionKey]];
            [note setColor:(UIColor *)entry[kNoteColorKey]];
            [note setTitle:(NSString *)entry[kEntryTitleKey]];
            [note setSection:section];
            [objIDs addObject:note.objectID];
            [mos addObject:note];
        }
        NSError *error = nil;
        [moc save:&error];
        if(error){
            [RIPErrorManager printError:error location:@"createNotes:completion:"];
            return mainCompletion(nil);
        }
        return mainCompletion(objIDs);
    });
}

- (void)readNotesFromSection:(NSManagedObjectID *)sectionID completion:(void(^)(NSArray *))bCompletion {
    void(^completion)(NSArray *) = ^(NSArray *minNotes){
        if(bCompletion != nil)
            bCompletion(minNotes);
    };
    dispatch_async(self.backgroundQueue, ^{
        NSManagedObjectContext *moc = [self newChildManagedObjectContext];
        Section *section = (Section *)[moc objectWithID:sectionID];
        NSSet *osNotes = section.notes;
        NSMutableArray *minNotes = [NSMutableArray array];
        for (Note *note in osNotes){
            NSMutableDictionary *d = [NSMutableDictionary dictionary];
            d[kEntryObjectIDKey] = note.objectID;
            d[kNoteCompletionKey] =
                [NSNumber numberWithFloat:[self getAverageCompletionForNote:note inContext:moc]];
            [minNotes addObject:d];
        }
        [minNotes sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
            NSDictionary *d1 = (NSDictionary *)obj1,
                         *d2 = (NSDictionary *)obj2;
            NSManagedObjectID *mid1 = (NSManagedObjectID *)d1[kEntryObjectIDKey],
                              *mid2 = (NSManagedObjectID *)d2[kEntryObjectIDKey];
            Note *note1 = (Note *)[moc objectWithID:mid1],
                 *note2 = (Note *)[moc objectWithID:mid2];
            
            //in reverse lol since a higher position means higher up
            return [note2.position compare:note1.position];
        }];
        return completion(minNotes);
    });
}

- (void)deleteNotes:(NSArray *)notes completion:(void(^)(BOOL success))fCompletion {
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
        for (NSManagedObjectID *mid in notes) {
            Note *mo = (Note *)[moc objectWithID:mid];
            NSMutableSet *ms = [mo.section mutableSetValueForKey:@"notes"];
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

- (float)getAverageCompletionForNote:(Note *)note inContext:(NSManagedObjectContext *)moc{
    assert(moc != nil);
    NSFetchRequest *req = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Segment" inManagedObjectContext:moc];
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"note == %@", note];
    [req setEntity:entity];
    [req setPropertiesToFetch:@[@"completion"]];
    [req setResultType:NSDictionaryResultType];
    [req setPredicate:pred];
    
    NSError *error = nil;
    NSArray *results = [moc executeFetchRequest:req error:&error];
    if(error){
        [RIPErrorManager printError:error location:@"getCompletionsForNotes:completion"];
        return RIPCompletionFloatForCompletion(RIPCompletionInProgess);
    }
    if(results.count == 0)
        return RIPCompletionFloatForCompletion(RIPCompletionDone);
    else{
        CGFloat avg = 0.0;
        for (NSDictionary *d in results) {
            NSNumber *c = d[@"completion"];
            avg += RIPCompletionFloatForCompletion((RIPCompletion)c.intValue);
        }
        avg /= (float)results.count;
        return avg;
    }
}


@end
