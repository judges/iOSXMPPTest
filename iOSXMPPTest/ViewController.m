//
//  ViewController.m
//  iOSXMPPTest
//
//  Created by 庞东明 on 14/12/10.
//  Copyright (c) 2014年 ZhongAo. All rights reserved.
//

#import "ViewController.h"
#include <AudioToolbox/AudioToolbox.h>
#import "FriendsViewController.h"
#import "RegistrationViewController.h"
#import <objc/runtime.h>
#import "AutoColoseInfoDialog.h"
#define kFriendID @"root"
#define kDomain @"mit-pc"
#define kHostName @"214.214.1.100"

#define kUserID @"qqqqqq"
#define kPassword @"qqqqqq"

static NSString *kFriendJIDKey = @"kFriendJIDKey";
static NSString *kUserIDKey = @"kUserIDKey";
static NSString *kPasswordKey = @"kPasswordKey";

//XMPP Logging
static const int xmppLogLevel = XMPP_LOG_LEVEL_WARN;

@interface ViewController ()<XMPPStreamDelegate,UIAlertViewDelegate,XMPPReconnectDelegate,UITextFieldDelegate>{
    XMPPStream *myStream;
    NSString *password;
    NSUInteger reconnectCount;
    dispatch_semaphore_t sema;
}
@property (strong, nonatomic) IBOutlet UITextView *textView;
@property (strong, nonatomic) IBOutlet UITextField *textField;
@property (strong, nonatomic) IBOutlet UIButton *sendButton;
@property (strong, nonatomic) IBOutlet UITextField *friendTextField;
@property (strong, nonatomic) IBOutlet UIButton *availableButton;
@property (strong, nonatomic) IBOutlet UIButton *unavailableButton;
@property (strong, nonatomic) IBOutlet UITextField *senderIDTextField;
@property (strong, nonatomic) IBOutlet UITextField *senderPasswordTextField;

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
    
    NSString *senderID = [[NSUserDefaults standardUserDefaults] stringForKey:kUserIDKey];
    if (senderID == nil) {
        senderID = kUserID;
        [[NSUserDefaults standardUserDefaults] setObject:string forKey:kUserIDKey];
    }
    self.senderIDTextField.text = senderID;
    
    NSString *senderPassword = [[NSUserDefaults standardUserDefaults] stringForKey:kPasswordKey];
    if (senderPassword == nil) {
        senderPassword = kPassword;
        [[NSUserDefaults standardUserDefaults] setObject:string forKey:kPasswordKey];
    }
    self.senderPasswordTextField.text = senderPassword;
}

- (IBAction)jidTextField:(UITextField *)sender {
    myStream.myJID = [XMPPJID jidWithUser:sender.text domain:kDomain resource:@"iPhone"];
}
- (IBAction)passwordTextField:(UITextField *)sender {
    password = sender.text;
}

- (XMPPStream *)createXMPPStreamWithJID:(NSString *)jid{
    XMPPStream *stream = [[XMPPStream alloc] init];
    //Configuring the connection
    stream.hostName = kHostName;

    XMPPJID *myJID = [XMPPJID jidWithUser:kUserID domain:kDomain resource:@"iPhone"];
    
    stream.myJID = myJID;

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
    [self.view endEditing:YES];
}
//online上线
- (IBAction)presenceAvailable:(id)sender {
    [self connect:myStream];
//    XMPPPresence *presence = [XMPPPresence presenceWithType:@"available"];
//    [myStream sendElement:presence];
}
//offline下线
- (IBAction)presenceUnavailable:(id)sender {
    XMPPPresence *presence = [XMPPPresence presenceWithType:@"unavailable"];
    [myStream sendElement:presence];
    [myStream disconnectAfterSending];
}

- (void)sendMessage:(NSString *) string toUser:(NSString *) user {
//    <message type="chat" to="xiaoming@example.com">
//    　　<body>Hello World!<body />
//    <message />
    self.textView.text = [self.textView.text stringByAppendingString:[NSString stringWithFormat:@"\n我(%@)：%@",myStream.myJID.user,string]];
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
//     Authenticating
//    [myStream authenticateWithPassword:password error:&error];
    //匿名验证
//    if ([myStream supportsAnonymousAuthentication]) {
//        [myStream authenticateAnonymously:&error];
//    }
  
        
        self.unavailableButton.enabled = YES;
        self.availableButton.enabled = NO;
   

    
    id<XMPPSASLAuthentication> auth = nil;
    if ([sender supportsPlainAuthentication]) {
        //base64编码
        auth = [[XMPPPlainAuthentication alloc] initWithStream:sender password:password];
    }else if ([sender supportsDigestMD5Authentication]){
        //MD5
        auth = [[XMPPDigestMD5Authentication alloc] initWithStream:sender password:password];
    }
    [sender authenticate:auth error:&error];
    if (error != nil) {
        NSLog(@"authenticateWithPassword : error:%@ %@",error,error.userInfo);
    }
    //    <iq id="S99ge-0" type="get"><query xmlns="jabber:iq:auth"><username>hl</username></query></iq>
    //不加密
//    DDXMLElement *query = [DDXMLElement elementWithName:@"query" xmlns:@"jabber:iq:auth"];
//    DDXMLElement *userName = [DDXMLElement elementWithName:@"username" stringValue:kUserID];
//    [query addChild:userName];
//    XMPPIQ *iq = [XMPPIQ iqWithType:@"get" elementID:@"abcd12345678" child:query];
//    [sender sendElement:iq];
}



- (void)xmppStream:(XMPPStream *)sender willSecureWithSettings:(NSMutableDictionary *)settings{
    
}

- (void)xmppStreamConnectDidTimeout:(XMPPStream *)sender{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"您的网络异常，请重新尝试进入安信" delegate:self cancelButtonTitle:@"重新连接" otherButtonTitles: nil];
    [alert show];
}

- (void)xmppStreamDidDisconnect:(XMPPStream *)sender withError:(NSError *)error{
    NSLog(@"xmppStreamDidDisconnect:流已断开");
    [AutoColoseInfoDialog popUpDialog:@"xmppStreamDidDisconnect流已断开" withView:self.view];

    self.unavailableButton.enabled = NO;
    self.availableButton.enabled = YES;
}

- (void)xmppStreamDidAuthenticate:(XMPPStream *)sender{
    NSLog(@"验证成功");
    [AutoColoseInfoDialog popUpDialog:@"验证成功" withView:self.view];
    XMPPPresence *presence = [XMPPPresence presenceWithType:@"available"];
    [myStream sendElement:presence];
}
- (void)xmppStream:(XMPPStream *)sender didNotAuthenticate:(NSXMLElement *)error{
    
    NSLog(@"验证失败:%@",error);
    [AutoColoseInfoDialog popUpDialog:@"验证失败" withView:self.view];

    self.unavailableButton.enabled = YES;
    self.availableButton.enabled = YES;
}

- (void)xmppStream:(XMPPStream *)sender didSendMessage:(XMPPMessage *)message{

    self.textView.text = [self.textView.text stringByAppendingString:[NSString stringWithFormat:@"----%@",@"(发送成功)"]];

}
- (void)xmppStream:(XMPPStream *)sender didFailToSendMessage:(XMPPMessage *)message error:(NSError *)error{
    
    self.textView.text = [self.textView.text stringByAppendingString:[NSString stringWithFormat:@"----%@(%@)",@"(发送失败)",error.userInfo]];
}


- (BOOL)xmppStream:(XMPPStream *)sender didReceiveIQ:(XMPPIQ *)iq{
//    RECV: <iq xmlns="jabber:client" type="result" id="abcd12345678"><query xmlns="jabber:iq:auth"><username>Test_Beta</username><password/><digest/><resource/></query></iq>
//    if ([[iq attributeForName:@"id"].stringValue isEqualToString:@"abcd12345678"]) {
//        
//        NSXMLElement *query = [NSXMLElement elementWithName:@"query" xmlns:@"jabber:iq:auth"];
//        NSXMLElement *userName = [NSXMLElement elementWithName:@"username" stringValue:kUserID];
//        NSXMLElement *passWord = [NSXMLElement elementWithName:@"password" stringValue:password];
//        NSXMLElement *resource = [NSXMLElement elementWithName:@"resource" stringValue:@"iPhone"];
//
//        [query addChild:userName];
//        [query addChild:passWord];
//        [query addChild:resource];
//
//        XMPPIQ *retIq = [XMPPIQ iqWithType:@"set" elementID:@"987654321abcdefg" child:query];
//        [sender sendElement:retIq];
//    }
    
    
    
    
    return YES;
}
- (void)xmppStream:(XMPPStream *)sender didReceiveMessage:(XMPPMessage *)message{
    NSString *string = [[message elementForName:@"body"] stringValue];
    if (string != nil) {
        [self playAlertSound];

        NSString *ta = [message attributeStringValueForName:@"from" withDefaultValue:@"Ta"];
        NSString *newTa = nil;
        NSScanner *scanner = [NSScanner scannerWithString:ta];
        if ([scanner scanUpToString:@"@" intoString:&newTa]) {
            ta = newTa;
        }
        self.textView.text = [self.textView.text stringByAppendingString:[NSString stringWithFormat:@"\n%@：%@",ta,string]];
        [self.textView scrollRectToVisible:CGRectMake(0, self.textView.contentSize.height - 40, self.textView.bounds.size.width, 40) animated:NO];
        
    }
}

- (void)xmppStream:(XMPPStream *)sender didReceivePresence:(XMPPPresence *)presence{
    NSString *presenceFromUser = presence.to.bare;
    if ([presenceFromUser isEqual:sender.myJID.bare] ) {
     
    }
    
}

- (NSString *)xmppStream:(XMPPStream *)sender alternativeResourceForConflictingResource:(NSString *)conflictingResource{
   
    return [self generateNewUUIDResource];
}

- (NSString *)generateNewUUIDResource{
    NSString *uuid = [[[NSUUID UUID].UUIDString substringWithRange:NSMakeRange(0, 8)] lowercaseString];
    UIDevice *device = [UIDevice currentDevice];
    NSString *resource = [NSString stringWithFormat:@"%@%@",device.model,uuid];
    return resource;
}

#pragma mark - XMPPReconnectDelegate

- (void)xmppReconnect:(XMPPReconnect *)sender didDetectAccidentalDisconnect:(SCNetworkConnectionFlags)connectionFlags{
    [AutoColoseInfoDialog popUpDialog:@"连接中断" withView:self.view];

    NSLog(@"连接中断:SCNetworkConnectionFlags = %u",connectionFlags);
}

- (BOOL)xmppReconnect:(XMPPReconnect *)sender shouldAttemptAutoReconnect:(SCNetworkConnectionFlags)connectionFlags{
    [AutoColoseInfoDialog popUpDialog:@"尝试自动重新连接" withView:self.view];

    NSLog(@"尝试自动重新连接:SCNetworkConnectionFlags = %u",connectionFlags);
//    [self connect:myStream];
    return YES;
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView willDismissWithButtonIndex:(NSInteger)buttonIndex{
    if (alertView.tag == 1204) {

    }else{
        [self connect:myStream];
    }
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    if (textField == self.friendTextField) {
        [textField resignFirstResponder];
    }else{
        NSString *messageString = [NSString stringWithFormat:@"%@@%@",self.friendTextField.text,kDomain];
        [self sendMessage:textField.text toUser:messageString];
        textField.text = nil;
    }
    
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField{
    if (textField == self.friendTextField) {
        [[NSUserDefaults standardUserDefaults] setObject:self.friendTextField.text forKey:kFriendJIDKey];
    }else if (textField == self.senderIDTextField){
        [[NSUserDefaults standardUserDefaults] setObject:self.senderIDTextField.text forKey:kUserIDKey];
    }else if (textField == self.senderPasswordTextField){
        [[NSUserDefaults standardUserDefaults] setObject:self.senderPasswordTextField.text forKey:kPasswordKey];
    }
}

#pragma mark - Event

- (void)playAlertSound{
    static SystemSoundID soundObject;
    if (soundObject == 0) {
        CFURLRef soundURL = (__bridge CFURLRef)[[NSBundle mainBundle] URLForResource:@"incoming" withExtension:@"wav"];
        AudioServicesCreateSystemSoundID(soundURL, &soundObject);
    }
    AudioServicesPlayAlertSound(soundObject);
}



- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.identifier isEqual:@"myFriends"]) {
        FriendsViewController *vc = (FriendsViewController *)segue.destinationViewController;
        vc.myStream = myStream;

        [myStream addDelegate:vc delegateQueue:dispatch_get_main_queue()];
    }else if ([segue.identifier isEqual:@"presentRegisterView"]){
        RegistrationViewController *vc = (RegistrationViewController *)segue.destinationViewController;
        vc.stream = myStream;
    }
    
}

@end
