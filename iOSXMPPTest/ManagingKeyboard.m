//
//  ManagingKeyboard.m
//  iOSXMPPTest
//  参考KeyboardManagement.html#//apple_ref/doc/uid/TP40009542-CH5-SW1
//  Created by 庞东明 on 14/12/22.
//  Copyright (c) 2014年 ZhongAo. All rights reserved.
//

#import "ManagingKeyboard.h"

#define kTopInset (([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) ? 64.0:0.0)

@implementation ManagingKeyboard{
    BOOL isIOS7;
    UIScrollView *aScrollView;
    UIViewController *aViewController;
}

//+ (instancetype)sharedManagingKeyboard{
//    static ManagingKeyboard *sSharedManagingKeyboard = nil;
//    static dispatch_once_t onceToken;
//    dispatch_once(&onceToken, ^{
//        sSharedManagingKeyboard = [[self alloc] init];
//    });
//    return sSharedManagingKeyboard;
//}

+ (instancetype)managingKeyboardWithScrollView:(UIScrollView *)scrollView contentsController:(UIViewController *)viewController{
    return [[self alloc] initWithManagingKeyboardWithScrollView:scrollView contentsController:viewController];
}

- (id)initWithManagingKeyboardWithScrollView:(UIScrollView *)scrollView contentsController:(UIViewController *)viewController{
    
    if (self = [super init]) {
        aScrollView = scrollView;
        aViewController = viewController;
        
        [self extendedLayoutForView];
    }
    
    return self;
}

//- (void)registerForKeyboardNotificationsWithScrollView:(UIScrollView *)scrollView contentsController:(UIViewController *)viewController{
//    aScrollView = scrollView;
//    aViewController = viewController;
//    
////    [self extendedLayoutForView];
//    [self registerForKeyboardNotifications];
//}



- (void)extendedLayoutForView{
    //使用iOS7自动延展布局
    if ([UIViewController instancesRespondToSelector:@selector(automaticallyAdjustsScrollViewInsets)]) {
        aViewController.automaticallyAdjustsScrollViewInsets = YES;
        aViewController.edgesForExtendedLayout = (UIRectEdgeTop | UIRectEdgeBottom);
    }
}

#pragma mark - RegisterNotification
- (void)registerForKeyboardNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWasShown:) name:UIKeyboardDidShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillBeHidden:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)unregisterForKeyboardNotifications
{
//    aScrollView = nil;
//    aViewController = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

// Called when the UIKeyboardDidShowNotification is sent.
- (void)keyboardWasShown:(NSNotification*)aNotification
{
    NSDictionary* info = [aNotification userInfo];
    //UIKeyboardFrameBeginUserInfoKey height constraint to 184.0
    //UIKeyboardFrameEndUserInfoKey height from 184.0 to 251.5
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    //iOS7高度延展了64
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(kTopInset, 0.0, kbSize.height, 0.0);
    aScrollView.contentInset = contentInsets;
    aScrollView.scrollIndicatorInsets = contentInsets;
    
    // If active text field is hidden by keyboard, scroll it so it's visible
    // Your app might not need or want this behavior.
    CGRect aRect = aViewController.view.frame;
    aRect.size.height -= kbSize.height;
    if (!CGRectContainsPoint(aRect, _activeField.frame.origin) ) {
        [aScrollView scrollRectToVisible:_activeField.frame animated:YES];
    }
}

// Called when the UIKeyboardWillHideNotification is sent
- (void)keyboardWillBeHidden:(NSNotification*)aNotification
{
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(kTopInset, 0.0, 0.0, 0.0);;
    aScrollView.contentInset = contentInsets;
    aScrollView.scrollIndicatorInsets = contentInsets;
}

#pragma mark - UITextFieldDelegate

//- (void)textFieldDidEndEditing:(UITextField *)textField
//{
//    activeField = nil;
//}
//
//- (void)textFieldDidBeginEditing:(UITextField *)textField
//{
//    activeField = textField;
//}
@end
