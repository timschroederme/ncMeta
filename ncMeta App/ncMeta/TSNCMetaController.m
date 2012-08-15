//
//  TSNCMetaController.m
//  ncMeta
//
//  Created by Tim Schröder on 14.08.12.
//  Copyright (c) 2012 Tim Schröder. All rights reserved.
//

#import "TSNCMetaController.h"
#import "TSDBMonitorController.h"
#import "TSWindowMonitorController.h"
#import "TSNCMetaControllerDelegate.h"
#import "TSDBConnector.h"

#define monitorURLString @"/Library/Application Support/NotificationCenter"

@implementation TSNCMetaController

static TSNCMetaController *_sharedController = nil;

#pragma mark -
#pragma mark Singleton Methods

+ (TSNCMetaController *)sharedController
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
#pragma mark Public Methods

- (void)startOperations
{
    // Prepare Monitoring Path
    NSString *home = NSHomeDirectory();
    NSArray *pathArray = [home componentsSeparatedByString:@"/"];
    NSString *absolutePath;
    if ([pathArray count] > 2) {
        absolutePath = [NSString stringWithFormat:@"/%@/%@", [pathArray objectAtIndex:1], [pathArray objectAtIndex:2]];
    }
    NSString *path = [NSString stringWithFormat:@"%@%@", absolutePath, monitorURLString];
    
    // Initialize Database Connector
    NSString *dirPath = [path stringByAppendingString:@"/"];
    TSDBConnector *dbConnector = [TSDBConnector sharedConnector];
    [dbConnector setPath:dirPath];
    [dbConnector setDelegate:self];
    [dbConnector performInitialFetch];
    
    // Start NC Database Monitoring
    NSURL *URL = [NSURL fileURLWithPath:path];
    TSDBMonitorController *dbMonitor = [TSDBMonitorController sharedController];
    [dbMonitor setMonitorURL:URL];
    [dbMonitor setDelegate:self];
    [dbMonitor startMonitoring];
    
    // Start NC Window Monitoring
    TSWindowMonitorController *windowMonitor = [TSWindowMonitorController sharedController];
    [windowMonitor setDelegate:self];
    [windowMonitor startMonitoring];
}

- (void)stopOperations
{
    [[TSDBMonitorController sharedController] stopMonitoring];
}

- (void)resetCount
{
    [[TSDBConnector sharedConnector] resetCount];
}


#pragma mark -
#pragma mark - TSWindowMonitorControllerDelegate Protocol Methods

-(void)NCDidShow
{
    // Send info to delegate
    if (self.delegate &&
        [self.delegate conformsToProtocol:@protocol(TSNCMetaControllerDelegate)] &&
        [self.delegate respondsToSelector:@selector(hasBecomeVisible)]) {
        [self.delegate hasBecomeVisible];
    }
}

-(void)NCDidHide
{
    // Reset DB info
    [[TSDBConnector sharedConnector] resetCount];
    
    // Send info to delegate
    if (self.delegate &&
        [self.delegate conformsToProtocol:@protocol(TSNCMetaControllerDelegate)] &&
        [self.delegate respondsToSelector:@selector(hasBecomeInvisible)]) {
        [self.delegate hasBecomeInvisible];
    }
}


#pragma mark -
#pragma mark TSMonitorDelegate Protocol Methods

-(void)fileHasChanged
{
    [[TSDBConnector sharedConnector] checkForChange];
}


#pragma mark -
#pragma mark TSDBConnector Protocol Methods

-(void)newNotifications:(NSArray*)array
{
    if (self.delegate &&
        [self.delegate conformsToProtocol:@protocol(TSNCMetaControllerDelegate)] &&
        [self.delegate respondsToSelector:@selector(newNotifications:)]) {
        [self.delegate newNotifications:array];
    }
}


@end
