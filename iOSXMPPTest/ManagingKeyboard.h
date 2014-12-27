//
//  ManagingKeyboard.h
//  iOSXMPPTest
//
//  Created by 庞东明 on 14/12/22.
//  Copyright (c) 2014年 ZhongAo. All rights reserved.
//

#import <Foundation/Foundation.h>
///键盘共享文本输入框滚动定位
@interface ManagingKeyboard : NSObject<UITextFieldDelegate>
/**
 *在textFieldDidEndEditing设为nil
 *textFieldDidBeginEditing
 */
@property (nonatomic,strong) UITextField *activeField;

//+ (instancetype)sharedManagingKeyboard;

/**
 *在viewWillAppear注册
 *在viewWillDisappear注销
 */
+ (instancetype)managingKeyboardWithScrollView:(UIScrollView *)scrollView contentsController:(UIViewController *)viewController;
- (void)registerForKeyboardNotifications;
- (void)unregisterForKeyboardNotifications;
@end
