//
//  SMAppDelegate.m
//  SalaMacchine
//
//  Created by Antonio "Willy" Malara on 11/08/13.
//  Copyright (c) 2013 Antonio "Willy" Malara. All rights reserved.
//

#import "SMAppDelegate.h"
#import "NIAgentClient.h"

@implementation SMAppDelegate
{
    NIAgentClient * mashineInterface;
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification;
{
    mashineInterface = [NIAgentClient new];
    [mashineInterface connect];
}

@end
