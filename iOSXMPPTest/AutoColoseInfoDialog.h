//
//  AutoColoseInfoDialog.h
//  BaccaratApp_QuerySystem
//
//  Created by MAC102 on 13-12-6.
//  Copyright (c) 2013年 MAC102. All rights reserved.
//

#import <UIKit/UIKit.h>
//软性提示类，在没有必要使用alertView的时候使用

@interface AutoColoseInfoDialog : UIView

+ (void)popUpDialog:(NSString*) infoTip withView:(UIView *)view;

@end
