//
//  SMAppDelegate.m
//  SalaMacchine
//
//  Created by Antonio "Willy" Malara on 11/08/13.
//  Copyright (c) 2013 Antonio "Willy" Malara. All rights reserved.
//

#import "SMAppDelegate.h"
#import "SMController.h"

@implementation SMAppDelegate
{
    SMController * controller;
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification;
{
    controller = [SMController new];
}

@end
