//
//  SMController.h
//  SalaMacchine
//
//  Created by Antonio "Willy" Malara on 11/08/13.
//  Copyright (c) 2013 Antonio "Willy" Malara. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SMController : NSObject

@property (nonatomic, strong) NSString * tcrStirng;
@property (nonatomic, strong) NSString * stripTopString;
@property (nonatomic, strong) NSString * stripBottomString;

@property (nonatomic, strong) NSImage  * leftDisplayImage;
@property (nonatomic, strong) NSImage  * rightDisplayImage;

@end
