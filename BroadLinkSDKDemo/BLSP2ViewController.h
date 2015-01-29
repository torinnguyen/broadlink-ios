//
//  BLSP2ViewController.h
//  BroadLinkSDKDemo
//
//  Created by yang on 3/31/14.
//  Copyright (c) 2014 BroadLink. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BLDeviceInfo.h"

@interface BLSP2ViewController : UIViewController

@property (nonatomic, strong) BLDeviceInfo *info;
@property (nonatomic, assign) int status;

@end
