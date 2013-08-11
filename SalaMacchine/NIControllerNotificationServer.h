//
//  NIControllerNotificationServer.h
//  Macchina
//
//  Created by Antonio "Willy" Malara on 16/08/12.
//  Copyright (c) 2012 Antonio "Willy" Malara. All rights reserved.
//

#import "NIServer.h"

@protocol NIControllerNotificationsObserver <NSObject>
- (void)gotFocus;
@end

@interface NIControllerNotificationServer : NIServer
@property __weak id<NIControllerNotificationsObserver> observer;
@end
