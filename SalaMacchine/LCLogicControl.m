//
//  LCLogicControl.m
//  ControlSurface
//
//  Created by Antonio "Willy" Malara on 05/02/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <CoreMIDI/CoreMIDI.h>
#import "LCLogicControl.h"

static void InputPortCallback (const MIDIPacketList *pktlist, void *refCon, void *connRefCon);
static char Mackie7SegDisplayCharToChar(uint8_t c, BOOL * dotted);

@implementation LCLogicControl
{
    NSString      * name;
    
	MIDIClientRef   client;
	
	MIDIEndpointRef source;
	MIDIEndpointRef destination;
	
	uint8_t         modelId;
	char            tcrCodeCString[13];
	char            stripTopCString[58];
	char            stripBottomCString[58];
}

- (id)init;
{
	return [self initWithName:@"LogicControl"];
}

- (id)initWithName:(NSString *)theName;
{
	if ((self = [super init]) == nil)
		return nil;
	
	name = [theName copy];
	
	memset(tcrCodeCString, 0x20, sizeof(tcrCodeCString));
	tcrCodeCString[sizeof(tcrCodeCString)-1] = 0;
	
	memset(stripTopCString, 0x20, sizeof(stripTopCString));
	stripTopCString[sizeof(stripTopCString)-1] = 0;
	
	memset(stripBottomCString, 0x20, sizeof(stripTopCString));
	stripBottomCString[sizeof(stripBottomCString)-1] = 0;
	
	[self createMidiClient];
    
	return self;
}

- (void)dealloc;
{
    [self disposeMidiClient];
}

- (void)createMidiClient;
{
	CFStringRef theName = (__bridge CFStringRef)name;
    SInt32 uniqueId = (SInt32)name.hash;

    MIDIClientCreate(theName, NULL, NULL, &client);
    MIDIObjectSetIntegerProperty(client, kMIDIPropertyUniqueID, uniqueId);
    
    MIDISourceCreate(client, theName, &source);
    MIDIObjectSetIntegerProperty(source, kMIDIPropertyUniqueID, uniqueId + 1);
    
    MIDIDestinationCreate(client, theName, InputPortCallback, (__bridge void *)(self), &destination);
    MIDIObjectSetIntegerProperty(destination, kMIDIPropertyUniqueID, uniqueId + 2);
}

- (void)disposeMidiClient;
{
	// TODO
}

- (uint8_t)modelId;
{
	return 0x10;
}

- (uint8_t *)sysexPrefix;
{
	static uint8_t prefix[] = { 0xF0, 0x00, 0x00, 0x66, 0x10 };
	prefix[4] = self.modelId;
	return prefix;
}

- (BOOL)acceptsSysexWithPrefix:(uint8_t *)sysex;
{
	return (memcmp(sysex, self.sysexPrefix, 5) == 0);
}

- (void)prefixBufferWithSysex:(uint8_t *)buffer;
{
	memcpy(buffer, self.sysexPrefix, 5);
}

- (void)sendHostConnectionQuery;
{
	uint8_t reply[] =
	{
		0x00, 0x00, 0x00, 0x00, 0x00,      // Prefix
		0x01,                              // Host Connection Query
		'a', 'b', 'c', 'd', 'e', 'f', 'g', // Serial Number
		0x01, 0x02, 0x03, 0x04,            // Challenge Code
		0xF7                               // EOX
	};
	
	NILog(@" -- SENDING MAKIE HOST CONNECTION QUERY MODEL");
	
	[self prefixBufferWithSysex:reply];
	[self sendMidiBytes:reply count:sizeof(reply)];
}

- (void)sendHostConnectionConfirmation;
{
	uint8_t reply[] =
	{
		0x00, 0x00, 0x00, 0x00, 0x00,      // Prefix
		0x03,                              // Connection Confirmation
		'a', 'b', 'c', 'd', 'e', 'f', 'g', // Serial Number
		0xF7                               // EOX
	};
	
	NILog(@" -- SENDING MAKIE CONNECTION CONFIRMATION");
	
	[self prefixBufferWithSysex:reply];
	[self sendMidiBytes:reply count:sizeof(reply)];	
}

- (void)sendVersionReply;
{
	uint8_t reply[] =
	{
		0x00, 0x00, 0x00, 0x00, 0x00, // Prefix
		0x14,                         // Version Reply
		'a', 'b', 'c', 'd', '0',      // Version
		0xF7,                         // EOX
	};
	
	NILog(@" -- SENDING MAKIE VERSION REPLY");
	
	[self prefixBufferWithSysex:reply];
	[self sendMidiBytes:reply count:sizeof(reply)];	
}

/* - */

- (void)setButton:(LCLogicControlLayout)button pressed:(BOOL)pressed;
{
    [self sendNoteOn:0 note:button velocity:pressed ? 127 : 0];
}

/* - */

- (void)sendNoteOn:(uint8_t)channel note:(uint8_t)note velocity:(uint8_t)velocity;
{
	unsigned char reply[] = { 0x90 | (channel & 0x0F), note, velocity };
	[self sendMidiBytes:reply count:sizeof(reply)];
}

// 0x9x
- (void)receivedNoteOnChannel:(uint8_t)channel note:(uint8_t)note velocity:(uint8_t)velocity;
{
    NILog(@"Mackie Set Led %02x Status %02x", note, velocity);
    dispatch_async(dispatch_get_main_queue(),
                   ^{
                       [self.controlObserver setLed:note on:!!velocity];
                   });
}

// 0xBx
- (void)receivedControlChangeChannel:(uint8_t)channel controller:(uint8_t)controller value:(uint8_t)value;
{
	if ((controller & 0xF0) == 0x10)
	{
		NSLog(@"Mackie V-Pot %02x direction %02x delta %02x", controller, value & 0x40, value & 0x3F);
	}
	
	if ((controller & 0xF0) == 0x30)
	{
		NSLog(@"Mackie Set LED Ring %02x to %02x", controller, value);
	}
	
	if ((controller & 0xF0) == 0x40)
	{
		BOOL dotted;
		int  digit = controller & 0x0F;
		
		if (digit < 0x0C)
		{
			tcrCodeCString[11 - digit] = Mackie7SegDisplayCharToChar(value, &dotted);
            
            NSString * tcr = [NSString stringWithCString:tcrCodeCString encoding:NSUTF8StringEncoding];
            dispatch_async(dispatch_get_main_queue(),
                           ^{
                               [self.controlObserver tcrCodeStringChanged:tcr];
                           });
		}
	}
}

// 0xDx
- (void)receivedChannelPressureChannel:(uint8_t)channel value:(uint8_t)value;
{
//	NSLog(@"Mackie Peak Level %02x", value);
}

// 0xEx
- (void)receivedPitchWheelChannel:(uint8_t)channel value:(uint16_t)value;
{
//	NSLog(@"Mackie Fader Position %02x %04x", channel, value);
}

// 0xF0
- (void)receivedSysEx:(uint8_t *)d;
{	
	switch (d[5])
	{
		case 0x00:
			NILog(@"Mackie Device Query Model");
			[self sendHostConnectionQuery];
			break;
		
		case 0x02:
			NILog(@"Mackie Host Connection Reply %c%c%c%c%c%c%c %02x %02x %02x %02x", d[6], d[7], d[8], d[9], d[10], d[11], d[12], d[13], d[14], d[15], d[16]);
			[self sendHostConnectionConfirmation];
			break;
		
		case 0x10:
			NSLog(@"Not Impl: TCR LCD");
			break;
			
		case 0x12:
		{
			unsigned char   i   = d[6];
			unsigned char * src = &d[7];
			
			while (*src != 0xF7)
			{
				if (i < 56)
					stripTopCString[i] = *src;
				else
					stripBottomCString[i - 0x38] = *src;
				
				src++;
				i++;
			}

            
            NSString * top    = [NSString stringWithCString:stripTopCString encoding:NSUTF8StringEncoding];
            NSString * bottom = [NSString stringWithCString:stripBottomCString encoding:NSUTF8StringEncoding];
            
			dispatch_async(dispatch_get_main_queue(),
                           ^{
                               [self.controlObserver topStripStringChanged:top];
                               [self.controlObserver bottomStripStringChanged:bottom];
                           });
			break;
		}
			
		case 0x13:
			NILog(@"Mackie Device Version Request");
			[self sendVersionReply];
			break;
		
		case 0x0A:
			NSLog(@"Mackie Transport Button Click %02x", d[6]);
			break;
		
		case 0x0B:
			NSLog(@"Mackie LCD Backlight saver %02x ", d[6]);
			break;
		
		case 0x0C:
			NSLog(@"Mackie Touchless movable fader %02x ", d[6]);
			break;
		
		case 0x0E:
			NSLog(@"Mackie Fader %02x touch sensitivity %02x ", d[6], d[7]);
			break;
		
		case 0x20:
		{
			char * lcd  = d[7] & 0x4 ? "LCD " : "----";
			char * peak = d[7] & 0x2 ? "PEAK" : "----";
			char * sign = d[7] & 0x1 ? "SIGN" : "----";
			
			NSLog(@"Mackie Channel %02x meter mode ( %s %s %s ) ", d[6], lcd, peak, sign);
			
			break;
		}
		
		case 0x21:
			NSLog(@"Mackie Global LCD Meter Mode %s", d[6] ? "verical" : "horizontal");
			break;
	}
}

- (void)sendMidiBytes:(uint8_t *)bytes count:(size_t)count;
{
	char packetListData[1024];
	
	MIDIPacketList * packetList = (MIDIPacketList *)packetListData;
	MIDIPacket     * curPacket  = NULL;
	
	curPacket = MIDIPacketListInit(packetList);
	curPacket = MIDIPacketListAdd(packetList, 1024, curPacket, 0, count, bytes);
	
	MIDIReceived(source, packetList);
}

@end

static void InputPortCallback(const MIDIPacketList * pktlist, void * refCon, void * connRefCon)
{
    @autoreleasepool {
        MIDIPacket     * packet = (MIDIPacket *)pktlist->packet;
        LCLogicControl * zelf   = (__bridge LCLogicControl *)refCon;

        for (unsigned int j = 0; j < pktlist->numPackets; j++)
        {
            uint8_t * d = packet->data;
            uint8_t   c = d[0] & 0xF0;
            
            switch (d[0] & 0xF0)
            {
                case 0x90:
                    [zelf receivedNoteOnChannel:c note:d[1] velocity:d[2]];
                    break;
                    
                case 0xB0:
                    [zelf receivedControlChangeChannel:c controller:d[1] value:d[2]];
                    break;
                    
                case 0xD0:
                    [zelf receivedChannelPressureChannel:c value:(d[1] | (d[2] << 7))];
                    break;
                    
                case 0xF0:
                    if ([zelf acceptsSysexWithPrefix:packet->data])
                        [zelf receivedSysEx:packet->data];
                    break;
            }
            
            packet = MIDIPacketNext(packet);		
        }
	}
}

static char Mackie7SegDisplayCharToChar(uint8_t c, BOOL * dotted)
{
    static const char * table = "@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\]^_ !\"#$%&'()*+,-./0123456789:;<=>?";
    *dotted = !!(c & 0x40);
    return table[c & 0x3f];
}
