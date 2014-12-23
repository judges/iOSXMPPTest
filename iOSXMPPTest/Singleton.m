//
//  Singleton.m
//  iOSXMPPTest
//
//  Created by 庞东明 on 14/12/22.
//  Copyright (c) 2014年 ZhongAo. All rights reserved.
//

#import "Singleton.h"

@implementation Singleton

+ (instancetype)sharedSingleton{
    static Singleton *aSharedSingleton = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        aSharedSingleton = [[self alloc] init];
    });
    return aSharedSingleton;
}

@end
