//
//  SMController.m
//  SalaMacchine
//
//  Created by Antonio "Willy" Malara on 11/08/13.
//  Copyright (c) 2013 Antonio "Willy" Malara. All rights reserved.
//

#import "SMController.h"
#import "NIAgentClient.h"
#import "LCLogicControl.h"

@interface SMController () <NIControllerNotificationsObserver>
@end

@implementation SMController
{
    NIAgentClient  * mashineInterface;
    LCLogicControl * logicInterface;
}

- (id)init;
{
    if ((self = [super init]) == nil)
        return nil;
    
    mashineInterface = [NIAgentClient new];
    mashineInterface.notificationObserver = self;
    [mashineInterface connect];
    
    logicInterface = [LCLogicControl new];
    
    return self;
}

- (void)gotFocus;
{
    [mashineInterface allLedsOff];
    [mashineInterface blankLcds];
}

@end
