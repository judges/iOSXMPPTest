//
//  AutoColoseInfoDialog.m
//  BaccaratApp_QuerySystem
//
//  Created by MAC102 on 13-12-6.
//  Copyright (c) 2013年 MAC102. All rights reserved.
//

#import "AutoColoseInfoDialog.h"
#import "AppDelegate.h"

#if __has_feature(objc_arc)
#error This file cannot be compiled with ARC. Either turn off ARC for the project or use -fno-objc-arc flag
#endif
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
#define KScreenHeight                   [[UIScreen mainScreen] bounds].size.height
#define KScreenWidth                    [[UIScreen mainScreen] bounds].size.width
#define IS_IPAD                         (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)

#define ContentView_Tag    23460
static UIView *_contentView = nil;
@implementation AutoColoseInfoDialog
-(void)dealloc
{
    NSLog(@"%@被销毁,闪退就是因为%@",NSStringFromClass([self class]),NSStringFromClass([self class]));
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    if(_contentView){
        [_contentView release];
        _contentView = nil;
    }
    [super dealloc];
}

- (id)init
{
    if((self = [super init])){
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeCenterAddHeight) name:UIKeyboardDidShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeCenterCutHeight) name:UIKeyboardDidHideNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeOrientation:)
                                                     name:UIApplicationWillChangeStatusBarOrientationNotification object:nil];
    }
    return self;
}

- (void)changeCenterAddHeight
{
    [UIView animateWithDuration:0.3
                          delay:0
                        options:UIViewAnimationOptionAllowUserInteraction
                     animations:^(void) {
                         self.center = CGPointMake(self.center.x, 130);
                     } completion:^(BOOL finished) {
                         
                     }];
}

- (void)changeCenterCutHeight
{
    [UIView animateWithDuration:0.3
                          delay:0
                        options:UIViewAnimationOptionAllowUserInteraction
                     animations:^(void) {
                         self.center = CGPointMake(self.center.x, 140);
                     } completion:^(BOOL finished) {
                         
                     }];
}

- (void)changeOrientation:(NSNotification *)notification
{
    UIInterfaceOrientation newOrientation = [[notification.userInfo valueForKey:UIApplicationStatusBarOrientationUserInfoKey] integerValue];
    if(newOrientation == UIInterfaceOrientationLandscapeRight){
        _contentView.transform = CGAffineTransformMakeRotation(M_PI/2);
        _contentView.center = CGPointMake(KScreenWidth/2, KScreenHeight/2);
    }else{
        _contentView.transform = CGAffineTransformMakeRotation(0.0);
        _contentView.center = CGPointMake(KScreenWidth/2, KScreenHeight*2/5);
    }
}
- (void)hiddenView:(NSString *)string
{
    if([string intValue] == _contentView.tag){
        [UIView animateWithDuration:1
                              delay:0
                            options:UIViewAnimationOptionAllowUserInteraction
                         animations:^(void) {
                             _contentView.alpha = 0;
                         } completion:^(BOOL finished) {
                             [_contentView removeFromSuperview];
                         }];
    }
}

int contentView_tag = 213246;
+ (void)popUpDialog:(NSString*) infoTip withView:(UIView *)superView
{
    _contentView.transform = CGAffineTransformMakeRotation(0.0);
    if(infoTip.length<1){
        return;
    }
    if (_contentView ==nil) {
        _contentView = [[self alloc] init];
    }
    for(UIView *a in _contentView.subviews){
        [a removeFromSuperview];
    }
    _contentView.alpha = 1.0;
    _contentView.layer.cornerRadius = 5;
    _contentView.layer.masksToBounds = YES;
    _contentView.tag = contentView_tag;
    contentView_tag ++;
    CGSize size = [infoTip sizeWithFont:[UIFont boldSystemFontOfSize:(IS_IPAD?25.0:18.0)] constrainedToSize:CGSizeMake(KScreenWidth-(IS_IPAD?200:120), 10000) lineBreakMode:NSLineBreakByCharWrapping];
    UILabel * lable = [[UILabel alloc] initWithFrame:CGRectMake(10.0, 10.0, size.width, size.height)];
    lable.text = infoTip;
    lable.textColor = [UIColor whiteColor];
    lable.backgroundColor = [UIColor clearColor];
    lable.textAlignment = NSTextAlignmentCenter;
    lable.numberOfLines = 0;
    lable.lineBreakMode = NSLineBreakByCharWrapping;
    lable.font = [UIFont boldSystemFontOfSize:(IS_IPAD?25.0:18.0)];
    _contentView.frame = CGRectMake(0, 0, size.width+20, size.height+20);
//    NSLog(@"size == %@",NSStringFromCGRect(_contentView.frame));
    if([UIApplication sharedApplication].statusBarOrientation == UIInterfaceOrientationLandscapeRight){
        
        
//        NSLog(@"%f,,,,%f",kScreenWidth,kScreenHeight);
        _contentView.center = CGPointMake(KScreenWidth/2, KScreenHeight/2);
        
        UIView * colorView = [[UIView alloc] initWithFrame:_contentView.bounds];
        [_contentView addSubview:colorView];
        colorView.backgroundColor = [UIColor blackColor];
        [colorView release];
        [_contentView addSubview:lable];
//        NSLog(@"size2222222 == %@",NSStringFromCGRect(colorView.frame));
        for (UIView * view in [superView subviews]) {
            if([view isKindOfClass:[self class]]){
                [view removeFromSuperview];
            }
        }
        
        [superView addSubview:_contentView];
        [superView bringSubviewToFront:_contentView];
        [lable release];
        
        _contentView.transform = CGAffineTransformMakeRotation(M_PI/2);
        NSInteger timeIndex = [[[NSUserDefaults standardUserDefaults]objectForKey:@"autoTimeSetting"] integerValue];
        if (!timeIndex) {
            timeIndex = 3;
        }
        [_contentView performSelector:@selector(hiddenView:) withObject:[NSString stringWithFormat:@"%ld",(long)_contentView.tag] afterDelay:timeIndex];
        
    }else{
        
        _contentView.center = CGPointMake([superView frame].size.width/2, [superView frame].size.height*2/5);
        lable.center = CGPointMake(_contentView.frame.size.width/2, _contentView.frame.size.height/2);
        
        UIView * colorView = [[UIView alloc] initWithFrame:_contentView.bounds];
        [_contentView addSubview:colorView];
        colorView.backgroundColor = [UIColor blackColor];
        [colorView release];
        [_contentView addSubview:lable];
        
        _contentView.transform = CGAffineTransformMakeScale(0.01,0.01);
        
        for (UIView * view in [superView subviews]) {
            if([view isKindOfClass:[self class]]){
                [view removeFromSuperview];
            }
        }
        [superView addSubview:_contentView];
        [UIView animateWithDuration:0.3
                              delay:0
                            options:UIViewAnimationOptionAllowUserInteraction
                         animations:^(void){
                             _contentView.transform = CGAffineTransformMakeScale(1.2,1.2);
                         } completion:^(BOOL finished) {
                             [UIView animateWithDuration:0.2
                                                   delay:0
                                                 options:UIViewAnimationOptionAllowUserInteraction
                                              animations:^(void){
                                                  _contentView.transform = CGAffineTransformMakeScale(0.9,0.9);
                                              } completion:^(BOOL finished) {
                                                  [UIView animateWithDuration:0.2
                                                                        delay:0
                                                                      options:UIViewAnimationOptionAllowUserInteraction
                                                                   animations:^(void){
                                                                       _contentView.transform = CGAffineTransformMakeScale(1,1);
                                                                   } completion:^(BOOL finished) {
                                                                   }];
                                              }];
                         }];
        
        [superView bringSubviewToFront:_contentView];
        [lable release];
        
//        NSInteger timeIndex = [[[NSUserDefaults standardUserDefaults]objectForKey:@"autoTimeSetting"] integerValue];
//        if (!timeIndex) {
//            timeIndex = 3;
//        }
        
        NSInteger timeIndex = 1;
        [_contentView performSelector:@selector(hiddenView:) withObject:[NSString stringWithFormat:@"%ld",(long)_contentView.tag] afterDelay:timeIndex];

    }
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
