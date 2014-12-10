//
//  ViewController.m
//  iOSXMPPTest
//
//  Created by 庞东明 on 14/12/10.
//  Copyright (c) 2014年 ZhongAo. All rights reserved.
//

#import "ViewController.h"
#import "XMPP.h"
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    XMPPStream *myStream = [[XMPPStream alloc] init];
    myStream.myJID = [XMPPJID jidWithString:@"test@gmail.com"];
    myStream.hostName = @"mail.mycompany.com";
    myStream.hostName = @"214.214.1.42";
    myStream.hostPort = 5222;
    
    [myStream addDelegate:self delegateQueue:dispatch_get_main_queue()];
    [myStream removeDelegate:self];
    
    
}



@end
