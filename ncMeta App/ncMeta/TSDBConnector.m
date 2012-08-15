//
//  TSDBConnector.m
//  ncMeta
//
//  Created by Tim Schröder on 08.08.12.
//  Copyright (c) 2012 Tim Schröder. All rights reserved.
//

#import "TSDBConnector.h"
#import "FMDatabase.h"
#import "TSAppDelegate.h"
#import "TSAppRecord.h"
#import "TSDBConnectorDelegate.h"


@implementation TSDBConnector

static TSDBConnector *_sharedConnector = nil;


#pragma mark -
#pragma mark Singleton Methods

+ (TSDBConnector *)sharedConnector
{
	if (!_sharedConnector) {
        _sharedConnector = [[super allocWithZone:NULL] init];
    }
    return _sharedConnector;
}

+ (id)allocWithZone:(NSZone *)zone
{
    return [self sharedConnector];
}

- (id)copyWithZone:(NSZone *)zone
{
    return self;
}


#pragma mark -
#pragma mark Housekeeping Methods

-(id)init
{
    if (self=[super init]) {
        self.appArray = [NSMutableArray arrayWithCapacity:0];
    }
    return self;
}


#pragma mark -
#pragma mark Public Methods

-(void)checkForChange
{
    // Get full path for NC database
    NSString *filename;
    NSArray *files = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:self.path
                                                                         error:nil];
    for (NSString *file in files) {
        if ([file hasSuffix:@".db"]) filename = file;
    }
    if (!filename) return;
    NSString *filePath = [self.path stringByAppendingFormat:@"%@", filename];
    
    // Access database
    FMDatabase *db = [FMDatabase databaseWithPath:filePath];
    if (!db) return;
    if ([db open]) {
        
        // Get/Update App Data
        FMResultSet *entries = [db executeQuery:@"SELECT app_id, bundleid, show_count, flags FROM app_info"];
        while ([entries next]) {
            NSString *app_id = [entries stringForColumn:@"app_id"];
            NSString *bundle_id = [entries stringForColumn:@"bundleid"];
            NSInteger show_count = [entries intForColumn:@"show_count"];
            NSInteger flags = [entries intForColumn:@"flags"];
            BOOL shown = NO;
            shown = (!(flags&1));
            
            // Check if we already have the app in our array
            BOOL alreadyThere = NO;
            TSAppRecord *alreadyThereApp;
            for (TSAppRecord *app in self.appArray) {
                if (!alreadyThere) {
                    NSString *compare_bundle_id = [app bundle_id];
                    if ([bundle_id isEqualToString:compare_bundle_id]) {
                        alreadyThere = YES;
                        alreadyThereApp = app;
                    }
                }
            }
            
            // No, app isn't already there, add it
            if (!alreadyThere) {
                // Hinzufügen
                TSAppRecord *newRecord = [[TSAppRecord alloc] init];
                newRecord.app_id = app_id;
                newRecord.bundle_id = bundle_id;
                newRecord.shown = shown;
                alreadyThereApp.increase = 0;
                newRecord.show_count = show_count;
                [self.appArray addObject:newRecord];
            } else {
                
                // Yes, app is there, update its record
                alreadyThereApp.shown = shown;
                alreadyThereApp.show_count = show_count;
                alreadyThereApp.oldIncrease = alreadyThereApp.increase;
            }
        }
                        
        // Get Number of notifications shown from each app
        NSMutableArray *tempNoteArray = [NSMutableArray arrayWithCapacity:0];
        FMResultSet *notifications = [db executeQuery:@"SELECT app_id, note_id FROM presented_notifications ORDER BY sort_order"];
        while ([notifications next]) {
            // Bring all notifications from DB to our array
            NSString *app_id = [notifications stringForColumn:@"app_id"];
            if (app_id) {
                NSInteger note_id = [notifications intForColumn:@"note_id"];
                [tempNoteArray addObject:[NSNumber numberWithInteger:note_id]];
                for (TSAppRecord *app in self.appArray) {
                    if ([app_id isEqualToString:app.app_id]) {
                        
                        if (self.initializing) {
                            [app.oldNoteArray addObject:[NSNumber numberWithInteger:note_id]];
                        } else {
                            // Check if notification is already in our array
                            if (![app hasNote:note_id]) { 
                                // No, add notification to our array and increase the notification count
                                app.increase = app.increase + 1;
                                [app.noteArray addObject:[NSNumber numberWithInteger:note_id]];
                            }
                        }
                    }
                }
            }
        }
        
        // Check for notifications which are in our array but not anymore in NC
        for (TSAppRecord *app in self.appArray) {
            NSMutableArray *delArray = [NSMutableArray arrayWithCapacity:0];
            for (NSNumber *note in app.noteArray) {
                BOOL numberThere = NO;
                for (NSNumber *compareNote in tempNoteArray) {
                    if ([compareNote integerValue] == [note integerValue]) numberThere = YES;
                }
                if (!numberThere) [delArray addObject:note];
            }
            NSInteger delCount = [delArray count];
            app.increase = app.increase - delCount;
            if (app.increase < 0) app.increase = 0;
            [app.noteArray removeObjectsInArray:delArray];
        }
        
        // Check for Increase of shown Notifications
        BOOL increase = NO;
        NSMutableArray *infoArray = [NSMutableArray arrayWithCapacity:0];
        for (TSAppRecord *app in self.appArray) {
            if ((!self.initializing) && (app.shown)) {
                if ((app.increase > 0) || (app.increase != app.oldIncrease)) {
                    increase = YES;
                    [infoArray addObject:app];
                }
            }
        }
    
        if (increase) {
            if (self.delegate &&
                [self.delegate conformsToProtocol:@protocol(TSDBConnectorDelegate)] &&
                [self.delegate respondsToSelector:@selector(newNotifications:)]) {
                [self.delegate newNotifications:infoArray];
            }
        }
        [db close];
    }
}

- (void)resetCount
{
    for (TSAppRecord *app in self.appArray) {
        app.increase = 0;
        app.oldIncrease = 0;
        [app.oldNoteArray addObjectsFromArray:app.noteArray];
        [app.noteArray removeAllObjects];
    }
}

- (void) performInitialFetch
{
    self.initializing = YES;
    [self checkForChange];
    self.initializing = NO;
}


@end
