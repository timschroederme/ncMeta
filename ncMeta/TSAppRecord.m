//
//  TSAppRecord.m
//  ncMeta
//
//  Created by Tim Schröder on 09.08.12.
//  Copyright (c) 2012 Tim Schröder. All rights reserved.
//

#import "TSAppRecord.h"


@implementation TSAppRecord 

-(id)init
{
    if (self = [super init]) {
        self.noteArray = [NSMutableArray arrayWithCapacity:0];
        self.oldNoteArray = [NSMutableArray arrayWithCapacity:0];
    }
    return self;
}

-(BOOL) hasNote:(NSInteger)note
{
    BOOL result = NO;
    for (NSNumber *num in self.noteArray) {
        if (note == [num integerValue]) result = YES;
    }
    for (NSNumber *num in self.oldNoteArray) {
        if (note == [num integerValue]) result = YES;
    }
    return result;
}

-(NSString*) displayTitle
{
    NSString *path = [[NSWorkspace sharedWorkspace]absolutePathForAppBundleWithIdentifier:[self bundle_id]];
    NSString *title = [[NSFileManager defaultManager] displayNameAtPath:path];
    return title;
}


@end
