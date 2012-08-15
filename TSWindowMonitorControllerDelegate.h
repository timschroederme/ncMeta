//
//  TSWindowMonitorControllerDelegate.h
//  ncMeta
//
//  Created by Tim Schröder on 14.08.12.
//  Copyright (c) 2012 Tim Schröder. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol TSWindowMonitorControllerDelegate <NSObject>

@required

-(void)NCDidShow;
-(void)NCDidHide;

@end
