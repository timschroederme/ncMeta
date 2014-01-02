//
//  TSAppDelegate.m
//  ncMeta
//
//  Created by Tim Schröder on 06.08.12.
//  Copyright (c) 2012 Tim Schröder. All rights reserved.
//

#import "TSAppDelegate.h"
#import "TSAppRecord.h"
#import "TSNCMetaController.h"

#define menuIcon @"menuicon"
#define menuIconRed @"menuicon_red"
#define noNotificationString @"No new notifications"
#define oneNotificationString @"1 new notification"
#define multipleNotificationsString @"%li new notifications"
#define menuItemTag 50

@implementation TSAppDelegate


#pragma mark -
#pragma mark StatusItem Helper Methods

// Reset status icon and menu
-(void)setBlankIcon
{
    [self.statusItem setImage:[NSImage imageNamed:menuIcon]];
    [self.infoMenuItem setTitle:noNotificationString];
}

// Change status item icon
-(void)setRedIcon
{
    if (!self.ncVisible) [self.statusItem setImage:[NSImage imageNamed:menuIconRed]];
}

// compose display string for app menu entry
-(NSString*)titleForApp:(TSAppRecord*)appRecord
{
    NSInteger increase = appRecord.increase;
    NSInteger max = appRecord.show_count;
    if (increase > max) increase = max;
    NSString *countString = [NSString stringWithFormat:@"+%li %@", increase, [appRecord displayTitle]];
    return countString;
}

// creates new app entry in menu
-(void)addApp:(TSAppRecord*)app toMenu:(NSMenu*)menu
{
    NSString *path = [[NSWorkspace sharedWorkspace]absolutePathForAppBundleWithIdentifier:[app bundle_id]];
    NSImage *image = [[NSWorkspace sharedWorkspace]iconForFile:path];
    [image setSize:NSMakeSize(16.0, 16.0)];
    NSString *title = [self titleForApp:app];
    NSMenuItem *newItem = [[NSMenuItem alloc] initWithTitle:title action:nil keyEquivalent:@""];
    [newItem setImage:image];
    [newItem setIndentationLevel:1];
    [newItem setEnabled:YES];
    [newItem setTag:menuItemTag];
    [newItem setRepresentedObject:app];
    [menu insertItem:newItem atIndex:1];
}

-(void)updateGlobalNotificationCount
{
    NSInteger increase = 0;
    NSMutableArray *delArray = [NSMutableArray arrayWithCapacity:0];
    for (TSAppRecord *app in self.appArray) {
        if (app.shown) {
            NSInteger inc = app.increase;
            NSInteger max = app.show_count;
            if (inc > max) inc = max;
            increase += inc;
        }
        
        // Ggf. Menüzeilen löschen, wenn increase == 0 ist
        if (app.increase == 0) {
            NSInteger idx = [self.mainMenu indexOfItemWithRepresentedObject:app];
            if (idx != -1) {
                NSMenuItem *item = [self.mainMenu itemAtIndex:idx];
                [self.mainMenu removeItem:item];
            }
            [delArray addObject:app];
        }
    }
    [self.appArray removeObjectsInArray:delArray];
    NSString *newTitle;
    if (increase == 0) {
        newTitle = noNotificationString;
        [self setBlankIcon];
    } else {
        if (increase == 1) newTitle = oneNotificationString;
        if (increase > 1) newTitle = [NSString stringWithFormat:multipleNotificationsString, increase];
        [self setRedIcon];
    }
    [self.infoMenuItem setTitle:newTitle];
}

#pragma mark -
#pragma mark TSNCMetaController Delegate Methods

-(void)hasBecomeVisible
{
    // Reset Internal Data
    self.ncVisible = YES;
    
    // Reset Menu
    [self setBlankIcon];
    NSArray *items = [self.mainMenu itemArray];
    NSInteger i;
    for (i=0;i<[items count];i++) {
        NSMenuItem *item = [items objectAtIndex:i];
        if ([item tag] == menuItemTag) [self.mainMenu removeItem:item];
    }
    
    [self.appArray removeAllObjects];
}

-(void)hasBecomeInvisible
{
    self.ncVisible = NO;
}

-(void)newNotifications:(NSArray*)newNotifications
{
    if (self.ncVisible) return;
        
    // check if apps in newApps array are already shown in menu
    for (TSAppRecord *newApp in newNotifications) {
        BOOL alreadyThere = NO;
        NSString * bundleID = [newApp bundle_id];
        for (TSAppRecord *oldApp in self.appArray) {
            if (([bundleID isEqualToString:[oldApp bundle_id]])&&(!alreadyThere)) {
                alreadyThere = YES;
                
                // update item in menu
                NSString *title = [self titleForApp:oldApp];
                NSInteger idx = [self.mainMenu indexOfItemWithRepresentedObject:oldApp];
                if (idx != -1) [[self.mainMenu itemAtIndex:idx] setTitle:title];
            }
        }
        if ((!alreadyThere) && (newApp.shown)) {
            [self.appArray addObject:newApp];
            
            // add new item to menu
            [self addApp:newApp toMenu:self.mainMenu];
        }
    }
    
    // Update global notification count info
    [self updateGlobalNotificationCount];
}


#pragma mark -
#pragma mark Action Methods

// Shows the about window
-(IBAction)showAbout:(id)sender
{
    [NSApp activateIgnoringOtherApps:YES];
    [NSApp orderFrontStandardAboutPanel:self];
}


#pragma mark -
#pragma mark NSApplication Delegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Initialize properties
    self.ncVisible = NO;
    self.appArray = [NSMutableArray arrayWithCapacity:0];
    
    // Create status item
    NSStatusBar *bar = [NSStatusBar systemStatusBar];
    self.statusItem = [bar statusItemWithLength:NSSquareStatusItemLength];
    [self.statusItem setMenu:self.mainMenu];
    [self.statusItem setImage:[NSImage imageNamed:menuIcon]];

    // Start operations
    [[TSNCMetaController sharedController] setDelegate:self];
    [[TSNCMetaController sharedController] startOperations];
}

-(void)applicationWillTerminate:(NSNotification *)notification
{
    // Stop operations
    [[TSNCMetaController sharedController] stopOperations];
}


@end
