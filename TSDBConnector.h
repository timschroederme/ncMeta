//
//  TSDBConnector.h
//  ncMeta
//
//  Created by Tim Schröder on 08.08.12.
//  Copyright (c) 2012 Tim Schröder. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TSDBConnector : NSObject

+ (TSDBConnector *)sharedConnector;
- (void)checkForChange;
- (void)resetCount;
- (void)performInitialFetch;

@property (strong) NSMutableArray *appArray;
@property (assign) BOOL initializing;
@property (strong) NSString *path;
@property (assign) id delegate;

@end
