//
//  LCLogicControl.h
//  ControlSurface
//
//  Created by Antonio "Willy" Malara on 05/02/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <CoreMIDI/CoreMIDI.h>

@protocol LCLogicControlObserver <NSObject>
- (void)tcrCodeStringChanged:(NSString *)tcrCode;
- (void)topStripStringChanged:(NSString *)topStrip;
- (void)bottomStripStringChanged:(NSString *)bottomStrip;
@end

@interface LCLogicControl : NSObject

@property(nonatomic, weak) id<LCLogicControlObserver> controlObserver;

- (id)initWithName:(NSString *)name;
- (void)buttonPress:(uint8_t)buttonId;

@end
