//
//  RegistrationViewController.m
//  iOSXMPPTest
//
//  Created by 庞东明 on 14/12/15.
//  Copyright (c) 2014年 ZhongAo. All rights reserved.
//

#import "RegistrationViewController.h"

@interface RegistrationViewController ()<XMPPStreamDelegate,UITextFieldDelegate>
@property (strong, nonatomic) IBOutlet UIWebView *webView;
@property (strong, nonatomic) IBOutlet UIButton *dismissButton;
@property (strong, nonatomic) IBOutlet UITextField *accountTextField;
@property (strong, nonatomic) IBOutlet UITextField *nickNameTextField;
@property (strong, nonatomic) IBOutlet UITextField *passwordTextField;
@property (strong, nonatomic) IBOutlet UITextField *passwordConfirmTextField;

@end

@implementation RegistrationViewController

- (void)dealloc{

}
- (void)viewDidLoad {
    [super viewDidLoad];

    [self.stream addDelegate:self delegateQueue:dispatch_get_main_queue()];

}

- (IBAction)handleDismissButton:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
    
}
- (IBAction)handleNextButton:(id)sender {
    [self sendElementWithSetUserInfo];
}

- (void)sendElementWithSetUserInfo{
    
//    <iq id="y0Huv-45" to="mit-pc" type="set" from="mit-pc/55725971">
//    <query xmlns="jabber:iq:register">
//    <username>god34</username>
//    <sex/>
//    <email/>
//    <name/>
//    <password>112233</password>
//    </query>
//    </iq>
    
    DDXMLElement *query = [DDXMLElement elementWithName:@"query" xmlns:@"jabber:iq:register"];

    DDXMLElement *userName = [DDXMLElement elementWithName:@"username" stringValue:self.accountTextField.text];
    DDXMLElement *password = [DDXMLElement elementWithName:@"password" stringValue:self.passwordTextField.text];
    DDXMLElement *gentle = [DDXMLElement elementWithName:@"sex" stringValue:@"male"];

    [query addChild:userName];
    [query addChild:password];
    [query addChild:gentle];
    
    XMPPIQ *iq = [[XMPPIQ alloc] initWithType:@"set" child:query];
    [iq addAttributeWithName:@"id" stringValue:@"reg1"];
    [iq addAttributeWithName:@"to" stringValue:@"mit-pc"];

    [self.stream sendElement:iq];
}

- (void)xmppStream:(XMPPStream *)sender didSendIQ:(XMPPIQ *)iq{
    
}

- (void)xmppStream:(XMPPStream *)sender didFailToSendIQ:(XMPPIQ *)iq error:(NSError *)error{
    
}

- (BOOL)xmppStream:(XMPPStream *)sender didReceiveIQ:(XMPPIQ *)iq{
    
    return YES;
}


- (void)xmppStream:(XMPPStream *)sender didReceiveError:(NSXMLElement *)error{
    
}


- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return  YES;
}
@end
