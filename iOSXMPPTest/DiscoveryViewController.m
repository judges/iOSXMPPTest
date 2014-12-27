//
//  DiscoveryViewController.m
//  iOSXMPPTest
//
//  Created by 庞东明 on 14/12/23.
//  Copyright (c) 2014年 ZhongAo. All rights reserved.
//

#import "DiscoveryViewController.h"

#define kxmlnsdiscoitems @"http://jabber.org/protocol/disco#info"
@interface DiscoveryViewController ()<XMPPStreamDelegate>{
    NSString *_last;
    NSString *_first;

}
@property (strong, nonatomic) IBOutlet UITextView *textView;

@end

@implementation DiscoveryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [_xmppStream addDelegate:self delegateQueue:dispatch_get_main_queue()];

}


- (void)sendDiscoWithAfterResultSet{
    //    <iq type='get' from='stpeter@jabber.org/roundabout' to='conference.jabber.org' id='ex2'>
    //    <query xmlns='http://jabber.org/protocol/disco#items'>
    //    <set xmlns='http://jabber.org/protocol/rsm'>
    //    <max>20</max>
    //    </set>
    //    </query>
    //    </iq>
    
    XMPPIQ *iq = [XMPPIQ iqWithType:@"get" to:[XMPPJID jidWithUser:nil domain:_xmppStream.myJID.domain resource:nil] elementID:@"disco1"];
    DDXMLElement *query = [DDXMLElement elementWithName:@"query" xmlns:kxmlnsdiscoitems];
    [iq addChild:query];
    XMPPResultSet *resultSet = [XMPPResultSet resultSetWithMax:1 after:_last];
    [query addChild:resultSet];
    [_xmppStream sendElement:iq];
}

- (void)sendDiscoWithBeforeResultSet{
    //    <iq type='get' from='stpeter@jabber.org/roundabout' to='conference.jabber.org' id='ex2'>
    //    <query xmlns='http://jabber.org/protocol/disco#items'>
    //    <set xmlns='http://jabber.org/protocol/rsm'>
    //    <max>20</max>
    //    </set>
    //    </query>
    //    </iq>
    
    XMPPIQ *iq = [XMPPIQ iqWithType:@"get" to:[XMPPJID jidWithUser:nil domain:_xmppStream.myJID.domain resource:nil] elementID:@"disco1"];
    DDXMLElement *query = [DDXMLElement elementWithName:@"query" xmlns:kxmlnsdiscoitems];
    [iq addChild:query];
    XMPPResultSet *resultSet = [XMPPResultSet resultSetWithMax:1 before:_first];
    [query addChild:resultSet];
    [_xmppStream sendElement:iq];
}

- (IBAction)prevButton:(id)sender {
    [self sendDiscoWithBeforeResultSet];
}

- (IBAction)nextButton:(id)sender {
    [self sendDiscoWithAfterResultSet];
}

#pragma mark - XMPPStreamDelegate

- (BOOL)xmppStream:(XMPPStream *)sender didReceiveIQ:(XMPPIQ *)iq{
    
    if ([[[iq childElement] xmlns] isEqualToString:kxmlnsdiscoitems]) {
        self.textView.text = iq.XMLString;
        
        DDXMLElement *element = nil;
        element = [iq elementForName:@"query" xmlns:@"http://jabber.org/protocol/disco#items"];
        element = [element elementForName:@"set" xmlns:@"http://jabber.org/protocol/rsm"];
        
        XMPPResultSet *resultSet = [XMPPResultSet resultSetFromElement:element];
        _first = [resultSet first];
        _last = [resultSet last];
        
        
        

        
    }
   
    
    
    
    
    return YES;
}

@end
