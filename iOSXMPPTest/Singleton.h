//
//  Singleton.h
//  iOSXMPPTest
//
//  Created by 庞东明 on 14/12/22.
//  Copyright (c) 2014年 ZhongAo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Singleton : NSObject
+ (instancetype)sharedSingleton;
@property (nonatomic, strong) UITextView *textView;
@end
