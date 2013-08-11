//
//  LCLogicControl.h
//  ControlSurface
//
//  Created by Antonio "Willy" Malara on 05/02/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <CoreMIDI/CoreMIDI.h>

@interface LCLogicControl : NSObject

@property(nonatomic, retain, readonly) NSString * tcrCode;
@property(nonatomic, retain, readonly) NSString * stripTop;
@property(nonatomic, retain, readonly) NSString * stripBottom;

- (id)initWithName:(NSString *)name;

- (void)buttonPress:(uint8_t)buttonId;

@end
