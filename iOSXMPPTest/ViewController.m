//
//  ViewController.m
//  iOSXMPPTest
//
//  Created by 庞东明 on 14/12/10.
//  Copyright (c) 2014年 ZhongAo. All rights reserved.
//

#import "ViewController.h"

//XMPP Logging
static const int xmppLogLevel = XMPP_LOG_LEVEL_WARN;

@interface ViewController ()<XMPPStreamDelegate>{
    XMPPStream *myStream;
    NSString *password;
}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    myStream = [[XMPPStream alloc] init];

    //Configuring the connection
    myStream.hostName = @"214.214.1.45";
    myStream.hostPort = 5222;
    
    myStream.myJID = [XMPPJID jidWithString:@"admin@mit-pc"];
    password = @"112233";
    
 
    
    //Adding Delegates
    [myStream addDelegate:self delegateQueue:dispatch_get_main_queue()];
//    [myStream removeDelegate:self];
    
    
    XMPPReconnect *reconnect = [[XMPPReconnect alloc] init];
    //Adding Modules
    [reconnect activate:myStream];
    [reconnect addDelegate:self delegateQueue:dispatch_get_main_queue()];

    //Connecting
    NSError *error = nil;
    if (![myStream connectWithTimeout:30 error:&error]) {
        NSLog(@"Oops, I probably forgot something: %@", error);
    }

    
    
}

#pragma mark - XMPPStreamDelegate

- (void)xmppStreamDidConnect:(XMPPStream *)sender{
    NSError *error = nil;
     //Authenticating
    [myStream authenticateWithPassword:password error:&error];
    if (error != nil) {
        NSLog(@"authenticateWithPassword : error:%@ %@",error,error.userInfo);
    }
}

- (void)xmppStreamDidAuthenticate:(XMPPStream *)sender{
    
}

- (void)xmppStream:(XMPPStream *)sender didNotAuthenticate:(NSXMLElement *)error{
    
}

@end
