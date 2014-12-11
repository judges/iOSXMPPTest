//
//  ViewController.m
//  iOSXMPPTest
//
//  Created by 庞东明 on 14/12/10.
//  Copyright (c) 2014年 ZhongAo. All rights reserved.
//

#import "ViewController.h"
#include <AudioToolbox/AudioToolbox.h>
#include "FriendsViewController.h"
#define kFriendID @"root@mit-pc"

#define kUserID @"tom@mit-pc"
#define kHostName @"214.214.1.45"
#define kPassword @"123456"

static NSString *kFriendJIDKey = @"kFriendJIDKey";
//XMPP Logging
static const int xmppLogLevel = XMPP_LOG_LEVEL_WARN;

@interface ViewController ()<XMPPStreamDelegate,UIAlertViewDelegate,XMPPReconnectDelegate,UITextFieldDelegate>{
    XMPPStream *myStream;
    NSString *password;
}
@property (strong, nonatomic) IBOutlet UITextView *textView;
@property (strong, nonatomic) IBOutlet UITextField *textField;
@property (strong, nonatomic) IBOutlet UIButton *sendButton;
@property (strong, nonatomic) IBOutlet UITextField *friendTextField;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    password = kPassword;
    
    myStream = [self createXMPPStreamWithJID:kUserID];
    
    [self setReconnect:myStream];

    [self connect:myStream];

    NSString *string = [[NSUserDefaults standardUserDefaults] stringForKey:kFriendJIDKey];
    if (string == nil) {
        string = kFriendID;
        [[NSUserDefaults standardUserDefaults] setObject:string forKey:kFriendJIDKey];
    }
    self.friendTextField.text = string;
}

- (XMPPStream *)createXMPPStreamWithJID:(NSString *)jid{
    XMPPStream *stream = [[XMPPStream alloc] init];
    //Configuring the connection
    stream.hostName = kHostName;
    stream.myJID = [XMPPJID jidWithString:jid];

    //Adding Delegates
    [stream addDelegate:self delegateQueue:dispatch_get_main_queue()];
    return stream;
}

- (void)setReconnect:(XMPPStream *)stream{
    XMPPReconnect *reconnect = [[XMPPReconnect alloc] init];
    //Adding Modules
    [reconnect activate:stream];
    [reconnect addDelegate:self delegateQueue:dispatch_get_main_queue()];

}

- (void)connect:(XMPPStream *)stream{
    //Connecting
    NSError *error = nil;
    if (![stream connectWithTimeout:5 error:&error]) {
        NSLog(@"Oops, I probably forgot something: %@", error);
    }
}

- (IBAction)sendButtonClick:(UIButton *)sender {
    [self sendMessage:self.textField.text toUser:kFriendID];
}

- (IBAction)hiddenKeybord:(UITapGestureRecognizer *)sender {
    [self.textField resignFirstResponder];
}


- (void)sendMessage:(NSString *) string toUser:(NSString *) user {
//    <message type="chat" to="xiaoming@example.com">
//    　　<body>Hello World!<body />
//    <message />
    self.textView.text = [self.textView.text stringByAppendingString:[NSString stringWithFormat:@"\n我：%@",string]];
    [self.textView scrollRectToVisible:CGRectMake(0, self.textView.contentSize.height - 40, self.textView.bounds.size.width, 40) animated:NO];
    
    NSXMLElement *body = [NSXMLElement elementWithName:@"body" stringValue:string];
    NSXMLElement *message = [NSXMLElement elementWithName:@"message"];
    [message addAttributeWithName:@"type" stringValue:@"chat"];
    [message addAttributeWithName:@"to" stringValue:user];
    [message addChild:body];
    [myStream sendElement:message];
    
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

- (void)xmppStreamConnectDidTimeout:(XMPPStream *)sender{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"您的网络异常，请重新尝试进入安信" delegate:self cancelButtonTitle:@"重新连接" otherButtonTitles: nil];
    [alert show];
}

- (void)xmppStreamDidDisconnect:(XMPPStream *)sender withError:(NSError *)error{
    
}

- (void)xmppStreamDidAuthenticate:(XMPPStream *)sender{
    NSLog(@"验证成功");
    XMPPPresence *presence = [XMPPPresence presenceWithType:@"available"];
    [myStream sendElement:presence];
}
- (void)xmppStream:(XMPPStream *)sender didNotAuthenticate:(NSXMLElement *)error{
    NSLog(@"验证失败:%@",error);
}

- (void)xmppStream:(XMPPStream *)sender didSendMessage:(XMPPMessage *)message{

    self.textView.text = [self.textView.text stringByAppendingString:[NSString stringWithFormat:@"----%@",@"(发送成功)"]];

}
- (void)xmppStream:(XMPPStream *)sender didFailToSendMessage:(XMPPMessage *)message error:(NSError *)error{
    self.textView.text = [self.textView.text stringByAppendingString:[NSString stringWithFormat:@"----%@(%@)",@"(发送失败)",error.userInfo]];
}


- (BOOL)xmppStream:(XMPPStream *)sender didReceiveIQ:(XMPPIQ *)iq{
    return YES;
}
- (void)xmppStream:(XMPPStream *)sender didReceiveMessage:(XMPPMessage *)message{
    NSString *string = [[message elementForName:@"body"] stringValue];
    if (string != nil) {
        self.textView.text = [self.textView.text stringByAppendingString:[NSString stringWithFormat:@"\nTa：%@",string]];
        [self.textView scrollRectToVisible:CGRectMake(0, self.textView.contentSize.height - 40, self.textView.bounds.size.width, 40) animated:NO];
        
        [self playAlertSound];
    }
}

- (void)xmppStream:(XMPPStream *)sender didReceivePresence:(XMPPPresence *)presence{

}

#pragma mark - XMPPReconnectDelegate

- (void)xmppReconnect:(XMPPReconnect *)sender didDetectAccidentalDisconnect:(SCNetworkConnectionFlags)connectionFlags{
    NSLog(@"连接中断:%u",connectionFlags);
}

- (BOOL)xmppReconnect:(XMPPReconnect *)sender shouldAttemptAutoReconnect:(SCNetworkConnectionFlags)connectionFlags{
    NSLog(@"尝试自动重新连接:%u",connectionFlags);
//    [self connect:myStream];
    return YES;
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView willDismissWithButtonIndex:(NSInteger)buttonIndex{
    [self connect:myStream];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    if (textField == self.friendTextField) {
        [textField resignFirstResponder];
    }else{
        [self sendMessage:textField.text toUser:self.friendTextField.text];
        textField.text = nil;
    }
    
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField{
    if (textField == self.friendTextField) {
        [[NSUserDefaults standardUserDefaults] setObject:self.friendTextField.text forKey:kFriendJIDKey];

    }
}

#pragma mark - Event

- (void)playAlertSound{
//    static SystemSoundID soundObject;
//    if (soundObject == 0) {
//        CFURLRef soundURL = (__bridge CFURLRef)[[NSBundle mainBundle] URLForResource:@"sms-received1" withExtension:@"caf"];
//        AudioServicesCreateSystemSoundID(soundURL, &soundObject);
//    }
    AudioServicesPlayAlertSound(kSystemSoundID_Vibrate);
}



- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.identifier isEqual:@"myFriends"]) {
        FriendsViewController *vc = (FriendsViewController *)segue.destinationViewController;
        vc.myStream = myStream;

        [myStream addDelegate:vc delegateQueue:dispatch_get_main_queue()];
    }
    
}

@end
