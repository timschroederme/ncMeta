//
//  TSWindowMonitorController.m
//  ncMeta
//
//  Created by Tim Schröder on 14.08.12.
//  Copyright (c) 2012 Tim Schröder. All rights reserved.
//

#import "TSWindowMonitorController.h"
#import "TSWindowMonitorControllerDelegate.h"

#define updateInterval 1.0
#define ncURI @"com.apple.notificationcenterui"

@implementation TSWindowMonitorController

static TSWindowMonitorController *_sharedController = nil;

#pragma mark -
#pragma mark Singleton Methods

+ (TSWindowMonitorController *)sharedController
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
#pragma mark Internal Methods

// Retrieve PID of Notification Center
-(NSNumber*)getNCPID
{
    ProcessSerialNumber psn = { 0, kCurrentProcess };
    NSNumber *pid;
    BOOL finished = NO;
    do {
        // Get next process
        OSStatus err;
        err = GetNextProcess(&psn);
        if (err == procNotFound) {
            finished = YES;
        } else {
            // Get info about process
            CFDictionaryRef dictRef;
            UInt32 ui = kProcessDictionaryIncludeAllInformationMask;
            dictRef = ProcessInformationCopyDictionary (&psn, ui);
            NSDictionary *dict = (__bridge NSDictionary*)dictRef;
            NSString *bundleIdentifier = [dict objectForKey:(__bridge NSString*)kCFBundleIdentifierKey];
            if ([bundleIdentifier isEqualToString:ncURI]) {
                finished = YES;
                // Get PID
                pid_t _pid;
                err = GetProcessPID (&psn, &_pid);
                pid = [NSNumber numberWithInteger:(NSInteger)_pid];
            }
        }
        
    } while (!finished);
    return pid;
}


#pragma mark -
#pragma mark NSTimer callback

// Check if NC window has become (in-)visible since last check
-(void)checkWindows:(id)timer
{
    BOOL windowVisible = NO;
    NSNumber *number = (NSNumber*)[timer userInfo];
    NSInteger pid = [(NSNumber*)number integerValue];
    CFArrayRef arrayRef = CGWindowListCopyWindowInfo(kCGWindowListOptionOnScreenOnly | kCGWindowListExcludeDesktopElements, kCGNullWindowID);
    NSArray *windows = (__bridge NSMutableArray *)arrayRef;
    for (NSDictionary *window in windows) {
        NSNumber *pidCompare = [window objectForKey:(__bridge NSString*)kCGWindowOwnerPID];
        NSInteger intCompare = [pidCompare integerValue];
        
        // Have we found the NC window pid? 
        if (pid == intCompare) {
            
            // Exclude notifications which may be present on the desktop
            CGRect cRect;
            CFDictionaryRef dict = (__bridge CFDictionaryRef)([window objectForKey:(__bridge NSString*)kCGWindowBounds]);
            CGRectMakeWithDictionaryRepresentation (dict, &cRect);
            NSRect rect = NSRectFromCGRect(cRect);
            NSRect screenFrame = [[[NSScreen screens] objectAtIndex:0] frame];
            if ((screenFrame.size.width==rect.size.width) && (screenFrame.size.height=rect.size.height)) windowVisible = YES;
        }
    }
    CFRelease (arrayRef);
    
    // Check if we need to send info to delegate
    if (windowVisible) {
        if (!self.lastVisibleState) {
            self.lastVisibleState = YES;
            
            // Send info to delegate
            if (self.delegate &&
                [self.delegate conformsToProtocol:@protocol(TSWindowMonitorControllerDelegate)] &&
                [self.delegate respondsToSelector:@selector(NCDidShow)]) {
                [self.delegate NCDidShow];
            }
        }
    } else {
        if (self.lastVisibleState) {
            self.lastVisibleState = NO;
            
            // Send info to delegate
            if (self.delegate &&
                [self.delegate conformsToProtocol:@protocol(TSWindowMonitorControllerDelegate)] &&
                [self.delegate respondsToSelector:@selector(NCDidHide)]) {
                [self.delegate NCDidHide];
            }
        }
    }
}


#pragma mark -
#pragma mark Public Methods

- (void) startMonitoring
{    
    self.lastVisibleState = NO;
    
    // Init Timer
    if (self.timer) [self.timer invalidate];
    self.timer = [NSTimer scheduledTimerWithTimeInterval:updateInterval
                                                  target:self
                                                selector:@selector(checkWindows:)
                                                userInfo:[self getNCPID]
                                                 repeats:YES];
}

- (void) stopMonitoring
{
    [self.timer invalidate];
    self.timer = nil;
}


@end
