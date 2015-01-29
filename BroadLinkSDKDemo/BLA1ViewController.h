//
//  BLA1ViewController.h
//  BroadLinkSDKDemo
//
//  Created by yzm157 on 14-6-6.
//  Copyright (c) 2014年 BroadLink. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BLDeviceInfo.h"

@interface BLA1ViewController : UIViewController

@property (nonatomic, strong) BLDeviceInfo *info;

@property (nonatomic, assign) float temperature;
@property (nonatomic, assign) float humidity;
@property (nonatomic, assign) int light;
@property (nonatomic, assign) int airQuality;
@property (nonatomic, assign) int noisy;

@end
