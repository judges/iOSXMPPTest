//
//  FriendsViewController.m
//  iOSXMPPTest
//
//  Created by 庞东明 on 14/12/11.
//  Copyright (c) 2014年 ZhongAo. All rights reserved.
//

#import "FriendsViewController.h"

@interface FriendsViewController ()<XMPPStreamDelegate>
@property (strong, nonatomic) IBOutlet UITextView *textView;

@end

@implementation FriendsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self queryRoster];
    
    
}

#pragma mark - 获取好友列表

- (void)queryRoster {
//    <iq from="tom@mit-pc/28ba84fb" to="mit-pc" id="6705A015-66A1-4A24-8563-3BADF762285F" type="get"><query xmlns="jabber:iq:roster"/></iq>
    NSXMLElement *query = [NSXMLElement elementWithName:@"query" xmlns:@"jabber:iq:roster"];
    NSXMLElement *iq = [NSXMLElement elementWithName:@"iq"];
    XMPPJID *myJID = _myStream.myJID;
    [iq addAttributeWithName:@"from" stringValue:myJID.description];
    [iq addAttributeWithName:@"to" stringValue:myJID.domain];
    [iq addAttributeWithName:@"id" stringValue:[NSUUID UUID].UUIDString];
    [iq addAttributeWithName:@"type" stringValue:@"get"];
    
//    XMPPIQ *iq = [XMPPIQ iqWithType:@"get" elementID:[NSUUID UUID].UUIDString child:query];
        [iq addChild:query];
    [_myStream sendElement:iq];
}


- (BOOL)xmppStream:(XMPPStream *)sender didReceiveIQ:(XMPPIQ *)iq{
//    <iq type="result"
//    　　id="1234567"
//    　　to="xiaoming@example.com">
//    　　<query xmlns="jabber:iq:roster">
//    　　　　<item jid="xiaoyan@example.com" name="小燕" />
//    　　　　<item jid="xiaoqiang@example.com" name="小强"/>
//    　　<query />
//    <iq />
    

    self.textView.text = iq.XMLString;
    if ([@"result" isEqualToString:iq.type]) {
        NSXMLElement *query = iq.childElement;
        if ([@"query" isEqualToString:query.name]) {
            NSArray *items = [query children];
            for (NSXMLElement *item in items) {
                NSString *jid = [item attributeStringValueForName:@"jid"];
                XMPPJID *xmppJID = [XMPPJID jidWithString:jid];
//                [self.roster addObject:xmppJID];
            }
        }
    }
    return YES;
}

- (void)xmppStream:(XMPPStream *)sender didReceiveError:(NSXMLElement *)error{
    NSLog(@"didReceiveError:%@",error.XMLString);
}

@end
