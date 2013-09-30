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
    [ledState setLed:NIMaschineLed_PageLeft intensity:0x7f];
    [ledState setLed:NIMaschineLed_PageRight intensity:0x7f];

    [ledState setLed:NIMaschineLed_GroupB intensity:0x7f];
    [ledState setLed:NIMaschineLed_GroupE intensity:0x7f];
    [ledState setLed:NIMaschineLed_GroupF intensity:0x7f];
    [ledState setLed:NIMaschineLed_GroupG intensity:0x7f];
    
    leftDisplay = [SMImage new];
    leftDisplay.asDrawMessage.displayNumber = 0;
    
    rightDisplay = [SMImage new];
    rightDisplay.asDrawMessage.displayNumber = 1;
    
    [self blitDisplays];
    
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
        translate(NIMaschineButton_Play,      LCLogicControl_Play);
        translate(NIMaschineButton_Rec,       LCLogicControl_Record);
        translate(NIMaschineButton_Restart,   LCLogicControl_Stop);
        translate(NIMaschineButton_Forward,   LCLogicControl_FastFwd);
        translate(NIMaschineButton_Rewind,    LCLogicControl_Rewind);
            
        translate(NIMaschineButton_PageLeft,  LCLogicControl_FaderBanks_BankLeft);
        translate(NIMaschineButton_PageRight, LCLogicControl_FaderBanks_BankRight);
        
        translate(NIMaschineButton_GroupB,    LCLogicControl_CursorUp);
        translate(NIMaschineButton_GroupE,    LCLogicControl_CursorLeft);
        translate(NIMaschineButton_GroupF,    LCLogicControl_CursorDown);
        translate(NIMaschineButton_GroupG,    LCLogicControl_CursorRight);
            
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
    [self drawTopStripInMashine];
}

- (void)bottomStripStringChanged:(NSString *)bottomStrip;
{
    self.stripBottomString = bottomStrip;
    [self drawBottomStripInMashine];
}

- (void)setLed:(LCLogicControlLayout)logicLed on:(BOOL)on;
{
    NIMaschineLedsLayout x;
    
    switch (logicLed) {
        translate(LCLogicControl_Rewind,  NIMaschineLed_Rewind);
        translate(LCLogicControl_FastFwd, NIMaschineLed_Forward);
        translate(LCLogicControl_Stop,    NIMaschineLed_Restart);
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
        .origin.x    = 20,
        .origin.y    = 20,
        .size.width  = NIMaschineDisplaysWidth - 2 * 20,
        .size.height = NIMaschineDisplaysHeight  - 2 * 20
    };
    
    [NSGraphicsContext saveGraphicsState];
    [NSGraphicsContext setCurrentContext:rightDisplay.asNSGraphicsContext];
    
    [[NSColor blackColor] setStroke];
    [[NSColor blackColor] setFill];
  
    [[NSBezierPath bezierPathWithRect:tcrLabelSize] fill];
    
    [self.tcrStirng drawInRect:tcrLabelSize
                withAttributes:@{
                       NSFontAttributeName: LCDFont(),
            NSForegroundColorAttributeName: [NSColor whiteColor],
     }];
    
    [NSGraphicsContext restoreGraphicsState];
    
    {
        static NSDate * lastDate;
        
        if (!lastDate)
            lastDate = [NSDate date];
        
        NSDate * now = [NSDate date];
        NSTimeInterval delta = [now timeIntervalSinceDate:lastDate];
        if (delta > 0.1) {
            [self blitDisplays];
            lastDate = now;
        }
    }
}

- (void)drawTopStripInMashine;
{
    const NSRect topStripRect = {
        .origin.x    = 0,
        .origin.y    = 12,
        .size.width  = NIMaschineDisplaysWidth,
        .size.height = 12
    };
    
    [NSGraphicsContext saveGraphicsState];
    [NSGraphicsContext setCurrentContext:leftDisplay.asNSGraphicsContext];
    
    [[NSColor whiteColor] setStroke];
    [[NSColor whiteColor] setFill];
    
    [[NSBezierPath bezierPathWithRect:topStripRect] fill];
    
    [[self.stripTopString substringToIndex:27] drawInRect:topStripRect
                                           withAttributes:@{
                                      NSFontAttributeName: LCDFont(),
                           NSForegroundColorAttributeName: [NSColor blackColor],
    }];
    
    [NSGraphicsContext restoreGraphicsState];
    
    [NSGraphicsContext saveGraphicsState];
    [NSGraphicsContext setCurrentContext:rightDisplay.asNSGraphicsContext];
    
    [[NSColor whiteColor] setStroke];
    [[NSColor whiteColor] setFill];
    
    [[NSBezierPath bezierPathWithRect:topStripRect] fill];
    
    [[self.stripTopString substringFromIndex:27] drawInRect:topStripRect
                                             withAttributes:@{
                                        NSFontAttributeName: LCDFont(),
                             NSForegroundColorAttributeName: [NSColor blackColor],
     }];
    
    [NSGraphicsContext restoreGraphicsState];

    [self blitDisplays];
}

- (void)drawBottomStripInMashine;
{
    const NSRect bottomStripRect = {
        .origin.x    = 0,
        .origin.y    = 0,
        .size.width  = NIMaschineDisplaysWidth,
        .size.height = 12
    };
    
    [NSGraphicsContext saveGraphicsState];
    [NSGraphicsContext setCurrentContext:leftDisplay.asNSGraphicsContext];
    
    [[NSColor whiteColor] setStroke];
    [[NSColor whiteColor] setFill];
    
    [[NSBezierPath bezierPathWithRect:bottomStripRect] fill];
    
    [[self.stripBottomString substringToIndex:27] drawInRect:bottomStripRect
                                              withAttributes:@{
                                         NSFontAttributeName: LCDFont(),
                              NSForegroundColorAttributeName: [NSColor blackColor],
     }];
    
    [NSGraphicsContext restoreGraphicsState];
    
    [NSGraphicsContext saveGraphicsState];
    [NSGraphicsContext setCurrentContext:rightDisplay.asNSGraphicsContext];
    
    [[NSColor whiteColor] setStroke];
    [[NSColor whiteColor] setFill];
    
    [[NSBezierPath bezierPathWithRect:bottomStripRect] fill];
    
    [[self.stripBottomString substringFromIndex:27] drawInRect:bottomStripRect
                                                withAttributes:@{
                                           NSFontAttributeName: LCDFont(),
                                NSForegroundColorAttributeName: [NSColor blackColor],
    }];
    
    [NSGraphicsContext restoreGraphicsState];

    [self blitDisplays];
}

@end
