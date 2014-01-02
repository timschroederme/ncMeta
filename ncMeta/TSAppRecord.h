//
//  TSAppRecord.h
//  ncMeta
//
//  Created by Tim Schröder on 09.08.12.
//  Copyright (c) 2012 Tim Schröder. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TSAppRecord : NSObject

-(BOOL) hasNote:(NSInteger)note;
-(NSString*) displayTitle;

@property (strong) NSString *app_id;
@property (strong) NSString *bundle_id;
@property (assign) NSInteger show_count;
@property (assign) NSInteger increase;
@property (assign) BOOL shown;
@property (strong) NSMutableArray *noteArray;
@property (assign) NSInteger oldIncrease;
@property (strong) NSMutableArray *oldNoteArray;

@end
