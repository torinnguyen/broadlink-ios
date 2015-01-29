//
//  BLDeviceInfo.m
//  BroadLinkSDKDemo
//
//  Created by yang on 3/31/14.
//  Copyright (c) 2014 BroadLink. All rights reserved.
//

#import "BLDeviceInfo.h"

@implementation BLDeviceInfo

- (void)dealloc
{
    [self setName:nil];
    [self setType:nil];
    [self setMac:nil];
    [self setKey:nil];
}

@end
