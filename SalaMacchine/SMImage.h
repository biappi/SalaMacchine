//
//  SMImage.h
//  SalaMacchine
//
//  Created by Antonio "Willy" Malara on 11/08/13.
//  Copyright (c) 2013 Antonio "Willy" Malara. All rights reserved.
//

#import "NIProtocolMessages.h"

@interface SMImage : NSObject
@property(nonatomic, readonly) CGContextRef           asCGContext;
@property(nonatomic, readonly) NSImage              * asNSImage;
@property(nonatomic, readonly) NIDisplayDrawMessage * asDrawMessage;
@end
