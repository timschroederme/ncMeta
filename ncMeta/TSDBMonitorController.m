//
//  TSDBMonitorController.m
//  ncMeta
//
//  Created by Tim Schröder on 06.08.12.
//  Copyright (c) 2012 Tim Schröder. All rights reserved.
//

#import "TSDBMonitorController.h"
#import "TSDBMonitorDelegate.h"
#import <CoreServices/CoreServices.h>


@implementation TSDBMonitorController

NSDate *_lastChangeDate;

static TSDBMonitorController *_sharedController = nil;

#pragma mark -
#pragma mark Singleton Methods

+ (TSDBMonitorController *)sharedController
{
	if (!_sharedController) {
        _sharedController = [[super allocWithZone:NULL] init];
    }
    return _sharedController;
}

+ (id)allocWithZone:(NSZone *)zone
{
    return [self sharedController];
}

- (id)copyWithZone:(NSZone *)zone
{
    return self;
}


#pragma mark -
#pragma mark Overriden Methods

-(id)init
{
    if (self = [super init]) {
        monitoringIsActive = NO;
        _lastChangeDate = nil;
    }
    return (self);
}


#pragma mark -
#pragma mark Monitoring Callback Method

void fsevents_callback(ConstFSEventStreamRef streamRef,
                       void *userData,
                       size_t numEvents,
                       void *eventPaths,
                       const FSEventStreamEventFlags eventFlags[],
                       const FSEventStreamEventId eventIds[])
{
    id delegate = [[TSDBMonitorController sharedController] delegate];
    if (delegate &&
        [delegate conformsToProtocol:@protocol(TSDBMonitorDelegate)] &&
        [delegate respondsToSelector:@selector(fileHasChanged)]) {
        [delegate fileHasChanged];
    }
}


#pragma mark -
#pragma mark Monitoring Administration Methods

-(FSEventStreamRef)startMonitoringForStream:(FSEventStreamRef)stream withPath:(NSString*)path
{
    NSArray *pathsToWatch = [NSArray arrayWithObject:path];
    void *appPointer = (__bridge void*)self;
    FSEventStreamContext context = {0, appPointer, NULL, NULL, NULL};
    NSTimeInterval latency = 3.0;
    stream = FSEventStreamCreate(NULL,
                                 &fsevents_callback,
                                 &context,
                                 (__bridge CFArrayRef) pathsToWatch,
                                 kFSEventStreamEventIdSinceNow,
                                 (CFAbsoluteTime) latency,
                                 kFSEventStreamCreateFlagUseCFTypes
                                 );
    FSEventStreamScheduleWithRunLoop(stream,
                                     CFRunLoopGetCurrent(),
                                     kCFRunLoopDefaultMode);
    FSEventStreamStart (stream);
    return stream;
}

-(void)stopMonitoringForStream:(FSEventStreamRef)stream
{
    if (stream != NULL) {
        FSEventStreamStop (stream);
        FSEventStreamInvalidate(stream);
        FSEventStreamRelease (stream);
    }
}


#pragma mark -
#pragma mark 'Public' Methods

-(BOOL)startMonitoring
// Will return YES if monitoring was started successfully, NO if starting failed
{
    // Return if we're already running or if we don't have an URL
    if ((monitoringIsActive) || (!self.monitorURL)) return NO;
    
    // Start Monitoring
    monitorStream = [self startMonitoringForStream:monitorStream withPath:[self.monitorURL path]];
    monitoringIsActive = YES;
    return YES;
}

-(void)stopMonitoring
{
    // Don't stop if we aren't monitoring
    if ((!monitoringIsActive) || (!monitorStream)) return;
    [self stopMonitoringForStream:monitorStream];
    monitoringIsActive = NO;
}


@end
