//
//  BLNetwork.h
//  BLNetwork
//
//  Created by yang on 3/28/14.
//  Copyright (c) 2014 BroadLink. All rights reserved.
//

#import <Foundation/Foundation.h>

#define BROADLINK_LICENSE_KEY       @"hXZiAvxNl65WX29d0rbNkiO6O/EoAC26K60zaushO2raU5ilXywBh7Jg6awMUV52iVlVZq7x/5elBh47qYMMwpRSYh5e4Txcrw9UfrrF7KZr5jRqWAw="

@interface BLNetwork : NSObject

- (NSData *)requestDispatch:(NSData *)input;

@end
