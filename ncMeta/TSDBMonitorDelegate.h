//
//  TSDBMonitorDelegate.h
//  ncMeta
//
//  Created by Tim Schröder on 13.08.12.
//  Copyright (c) 2012 Tim Schröder. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol TSDBMonitorDelegate <NSObject>

@required

-(void)fileHasChanged;

@end
