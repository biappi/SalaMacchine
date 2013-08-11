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
#import "NIMaschineLayouts.h"
#import "LCLogicControlLayout.h"

#define translate( from , to ) case from : x = to ; break;

@interface SMController () <NIControllerNotificationsObserver, LCLogicControlObserver>
@end

@implementation SMController
{
    NIAgentClient  * mashineInterface;
    NILedState     * ledState;
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
    logicInterface.controlObserver = self;
    
    ledState = [NILedState new];
    
    return self;
}

#pragma mark - Maschine Callbacks

- (void)gotFocus;
{
    [mashineInterface allLedsOff];
    [mashineInterface blankLcds];
}

- (void)buttonChanged:(NIMaschineButtonsLayout)button pressed:(BOOL)pressed;
{
    LCLogicControlLayout x;
    switch (button) {
        translate(NIMaschineButton_Play,    LCLogicControl_Play);
        translate(NIMaschineButton_Rec,     LCLogicControl_Record);
        translate(NIMaschineButton_Erase,   LCLogicControl_Stop);
        translate(NIMaschineButton_Forward, LCLogicControl_FastFwd);
        translate(NIMaschineButton_Rewind,  LCLogicControl_Rewind);
        default: return;
    }
    
    [logicInterface setButton:x pressed:pressed];
}

#pragma mark - Logic Control Callbacks

- (void)tcrCodeStringChanged:(NSString *)tcrCode;
{
    self.tcrStirng = tcrCode;
}

- (void)topStripStringChanged:(NSString *)topStrip;
{
    self.stripTopString = topStrip;
}

- (void)bottomStripStringChanged:(NSString *)bottomStrip;
{
    self.stripBottomString = bottomStrip;
}

- (void)setLed:(LCLogicControlLayout)logicLed on:(BOOL)on;
{
    NIMaschineLedsLayout x;
    
    switch (logicLed) {
        translate(LCLogicControl_Rewind,  NIMaschineLed_Rewind);
        translate(LCLogicControl_FastFwd, NIMaschineLed_Forward);
        translate(LCLogicControl_Stop,    NIMaschineLed_Erase);
        translate(LCLogicControl_Play,    NIMaschineLed_Play);
        translate(LCLogicControl_Record,  NIMaschineLed_Rec);
        default: return;
    }
    
    [ledState setLed:x intensity:on ? 0xff : 0];
    [mashineInterface setLedState:ledState];    
}

@end
