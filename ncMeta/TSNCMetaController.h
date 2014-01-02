//
//  TSNCMetaController.h
//  ncMeta
//
//  Created by Tim Schröder on 14.08.12.
//  Copyright (c) 2012 Tim Schröder. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TSDBMonitorDelegate.h"
#import "TSWindowMonitorControllerDelegate.h"
#import "TSDBConnectorDelegate.h"

@interface TSNCMetaController : NSObject <TSDBMonitorDelegate, TSWindowMonitorControllerDelegate, TSDBConnectorDelegate>

+ (TSNCMetaController *)sharedController;
- (void)startOperations;
- (void)stopOperations;
- (void)resetCount;

@property (assign) id delegate;


@end
