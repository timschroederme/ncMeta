//
//  TSWindowMonitorController.h
//  ncMeta
//
//  Created by Tim Schröder on 14.08.12.
//  Copyright (c) 2012 Tim Schröder. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TSWindowMonitorController : NSObject

+ (TSWindowMonitorController *)sharedController;
- (void) startMonitoring;
- (void) stopMonitoring;

@property (assign) id delegate;
@property (strong) NSTimer *timer;
@property (assign) BOOL lastVisibleState;

@end
