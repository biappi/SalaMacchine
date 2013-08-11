//
//  NIAgentClient.m
//  Macchina
//
//  Created by Antonio "Willy" Malara on 16/08/12.
//  Copyright (c) 2012 Antonio "Willy" Malara. All rights reserved.
//

#import "NIAgentClient.h"
#import "NIImageConversions.h"

@interface NIAgentClient () <NIControllerNotificationsObserver>
@end

@implementation NIAgentClient

- (id)init;
{
    if ((self = [super init]) == nil)
        return nil;
    
    _mainHandler = [[NIMainHandlerClient alloc] initWithName:@"NIHWMainHandler"];
    
    return self;
}

- (void)connect;
{
    NIDeviceConnectResponse * r = [self.mainHandler connectToControllerWithId:0x00000808
                                                                          boh:'NiMS'
                                                                   clientRole:'prmy'
                                                                   clientName:@"Testing 123"];
    
    NILog(@" - %@", r);
    NILog(@" ");
    
    if (r.success == NO)
        return;
    
    _requestClient      = [[NIControllerRequestClient alloc]      initWithName:r.inPortName];
    _notificationServer = [[NIControllerNotificationServer alloc] initWithName:r.outPortName];
    _notificationServer.observer = self;
    
    [_notificationServer scheduleInRunLoop:[NSRunLoop currentRunLoop]];
    [_requestClient setNotificationPortName:r.outPortName];
}

- (void)allLedsOff;
{
    NISetLedStateMessage * setLed = [NISetLedStateMessage new];
    setLed.state = [NILedState new];
    [self.requestClient sendMessage:setLed];
}

- (void)blankLcds;
{
    NIDisplayDrawMessage * blank = [NIDisplayDrawMessage new];
    blank.sizeWidth  = NIMaschineDisplaysWidth;
    blank.sizeHeight = NIMaschineDisplaysHeight;
    blank.st7529EncodedImage = [NSMutableData dataWithLength:NIMaschineDisplaysWidth * NIMaschineDisplaysHeight / 3 * 2];
    
    [self.requestClient sendMessage:blank];
    
    blank.displayNumber = 1;
    [self.requestClient sendMessage:blank];
}

- (void)gotFocus;
{
    [self allLedsOff];
    [self blankLcds];
}

@end
