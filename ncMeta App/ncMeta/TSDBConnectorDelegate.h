//
//  TSDBConnectorDelegate.h
//  ncMeta
//
//  Created by Tim Schröder on 14.08.12.
//  Copyright (c) 2012 Tim Schröder. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol TSDBConnectorDelegate <NSObject>

@required

-(void)newNotifications:(NSArray*)array;


@end
