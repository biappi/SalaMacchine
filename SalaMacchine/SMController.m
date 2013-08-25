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
#import "NIImageConversions.h"
#import "LCLogicControlLayout.h"
#import "SMImage.h"

#define translate( from , to ) case from : x = to ; break;

@interface SMController () <NIControllerNotificationsObserver, LCLogicControlObserver>
@end

@implementation SMController
{
    NIAgentClient  * mashineInterface;
    NILedState     * ledState;
    LCLogicControl * logicInterface;
    SMImage        * leftDisplay;
    SMImage        * rightDisplay;
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
    
    leftDisplay = [SMImage new];
    leftDisplay.asDrawMessage.displayNumber = 0;
    
    rightDisplay = [SMImage new];
    rightDisplay.asDrawMessage.displayNumber = 1;
    
    [self blitDisplays];
    
    [self performSelector:@selector(test) withObject:nil afterDelay:3];
    
    return self;
}

#pragma mark - Maschine Callbacks

- (void)gotFocus;
{
    [mashineInterface setLedState:ledState];
    [mashineInterface sendDrawMessage:leftDisplay.asDrawMessage];
    [mashineInterface sendDrawMessage:rightDisplay.asDrawMessage];
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
    [self drawTCRInMashine];
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

- (void)blitDisplays;
{
    [mashineInterface sendDrawMessage:leftDisplay.asDrawMessage];
    [mashineInterface sendDrawMessage:rightDisplay.asDrawMessage];

    self.leftDisplayImage  = nil;
    self.rightDisplayImage = nil;
    
    self.leftDisplayImage  = leftDisplay.asNSImage;
    self.rightDisplayImage = rightDisplay.asNSImage;
}

- (void)drawTCRInMashine;
{
    const NSRect tcrLabelSize = {
        .origin.x    = 0,
        .origin.y    = 0,
        .size.width  = NIMaschineDisplaysWidth,
        .size.height = NIMaschineDisplaysHeight
    };
    
    CGContextSetGrayFillColor(rightDisplay.asCGContext, 1, 1);
    CGContextSetGrayStrokeColor(rightDisplay.asCGContext, 0, 1);
    CGContextFillRect(rightDisplay.asCGContext, CGRectMake(0, 0, NIMaschineDisplaysWidth, NIMaschineDisplaysHeight));

    [NSGraphicsContext saveGraphicsState];
    [NSGraphicsContext setCurrentContext:rightDisplay.asNSGraphicsContext];
    
    [[NSColor blackColor] setStroke];
    [[NSColor blackColor] setFill];
    
    [self.tcrStirng drawInRect:tcrLabelSize withAttributes:@{NSFontAttributeName: LCDFont()}];
    
    [NSGraphicsContext restoreGraphicsState];
    
    [self blitDisplays];
}

- (void)test;
{
    static int test = 0;
    
    self.tcrStirng = [NSString stringWithFormat:@"%d", test++];
    [self drawTCRInMashine];
    
    [self performSelector:@selector(test) withObject:nil afterDelay:3];
}

@end
