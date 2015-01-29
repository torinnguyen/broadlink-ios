//
//  BLDeviceInfo.h
//  BroadLinkSDKDemo
//
//  Created by yang on 3/31/14.
//  Copyright (c) 2014 BroadLink. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BLDeviceInfo : NSObject

@property (nonatomic, copy) NSString *mac;
@property (nonatomic, copy) NSString *type;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, assign) int lock;
@property (nonatomic, assign) uint32_t password;
@property (nonatomic, assign) int terminal_id;
@property (nonatomic, assign) int sub_device;
@property (nonatomic, copy) NSString *key;

//RM2 & A1
@property (nonatomic, copy) NSNumber *temperature;      //float

//SP2
@property (nonatomic, copy) NSNumber *status;           //BOOL on/off

//A1
@property (nonatomic, copy) NSNumber *humidity;         //float
@property (nonatomic, copy) NSNumber *light;            //int
@property (nonatomic, copy) NSNumber *air;              //int
@property (nonatomic, copy) NSNumber *noisy;            //int

@end
