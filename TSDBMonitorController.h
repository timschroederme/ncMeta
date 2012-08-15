//
//  TSDBMonitorController.h
//  ncMeta
//
//  Created by Tim Schröder on 06.08.12.
//  Copyright (c) 2012 Tim Schröder. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface TSDBMonitorController : NSObject
{
    FSEventStreamRef monitorStream;
    BOOL monitoringIsActive;
}

+ (TSDBMonitorController *)sharedController;
- (BOOL)startMonitoring;
- (void)stopMonitoring;

@property (strong) NSURL *monitorURL;
@property (assign) id delegate;

@end
