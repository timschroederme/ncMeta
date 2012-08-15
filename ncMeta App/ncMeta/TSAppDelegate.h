//
//  TSAppDelegate.h
//  ncMeta
//
//  Created by Tim Schröder on 06.08.12.
//  Copyright (c) 2012 Tim Schröder. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "TSNCMetaControllerDelegate.h"

@interface TSAppDelegate : NSObject <NSApplicationDelegate, TSNCMetaControllerDelegate>

@property (assign) BOOL ncVisible;
@property (strong) NSMutableArray *appArray;
@property (strong) NSStatusItem *statusItem;
@property (assign) IBOutlet NSMenu *mainMenu;
@property (assign) IBOutlet NSMenuItem *infoMenuItem;

@end
