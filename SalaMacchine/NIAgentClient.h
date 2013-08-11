//
//  NIAgentClient.h
//  Macchina
//
//  Created by Antonio "Willy" Malara on 16/08/12.
//  Copyright (c) 2012 Antonio "Willy" Malara. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol NIControllerNotificationsObserver <NSObject>
- (void)gotFocus;
@end

@interface NIAgentClient : NSObject

@property(nonatomic, weak) id<NIControllerNotificationsObserver> notificationObserver;

- (void)connect;

- (void)allLedsOff;
- (void)blankLcds;

@end
