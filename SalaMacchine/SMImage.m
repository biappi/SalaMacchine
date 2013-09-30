//
//  SMImage.m
//  SalaMacchine
//
//  Created by Antonio "Willy" Malara on 11/08/13.
//  Copyright (c) 2013 Antonio "Willy" Malara. All rights reserved.
//

#import "SMImage.h"
#import "NIImageConversions.h"

static const unsigned int ImageSize_8bpp     = NIMaschineDisplaysWidth * NIMaschineDisplaysHeight;
static const unsigned int ImageSize_Maschine = ImageSize_8bpp / 3 * 2;

NSFont * _LCDFont()
{
    static NSFont * font;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        NSString            * path   = [[NSBundle mainBundle] pathForResource:@"font" ofType:@"ttf"];
        NSData              * data   = [[NSData alloc] initWithContentsOfFile:path];
        CGDataProviderRef     prov   = CGDataProviderCreateWithCFData((__bridge CFDataRef)data);
        CGFontRef             cgFont = CGFontCreateWithDataProvider(prov);
        
        font = (__bridge NSFont *)(CTFontCreateWithGraphicsFont(cgFont, 8, NULL, NULL));
        
        CGFontRelease(cgFont);
    });
    
    return font;
}

NSFont * LCDFont()
{
    return [NSFont fontWithName:@"Monaco" size:15];
}

@implementation SMImage
{
    CGContextRef   context;
    CGImageRef     image;
    uint8_t        imageData[ImageSize_8bpp];
    uint8_t        maschineData[ImageSize_Maschine];
    
    NSGraphicsContext    * gc;
    NSData               * bitmapData;
    NIDisplayDrawMessage * message;
}

- (id)init;
{
    if ((self = [super init]) == nil)
        return nil;
    
    CGColorSpaceRef cs = CGColorSpaceCreateDeviceGray();
    context = CGBitmapContextCreate(imageData,
                                    NIMaschineDisplaysWidth,
                                    NIMaschineDisplaysHeight,
                                    8,
                                    NIMaschineDisplaysWidth,
                                    cs,
                                    kCGImageAlphaNone);
    CGColorSpaceRelease(cs);
    
    CGContextSetAllowsAntialiasing(context, false);
    CGContextSetAllowsFontSmoothing(context, false);
    CGContextSetAllowsFontSubpixelPositioning(context, false);
    CGContextSetAllowsFontSubpixelQuantization(context, false);

    gc = [NSGraphicsContext graphicsContextWithGraphicsPort:context flipped:NO];
    
    [NSGraphicsContext saveGraphicsState];
    [NSGraphicsContext setCurrentContext:gc];
    
    CGContextSetGrayFillColor(context, 1, 1);
    CGContextSetGrayStrokeColor(context, 0, 1);
    CGContextFillRect(context, CGRectMake(0, 0, NIMaschineDisplaysWidth, NIMaschineDisplaysHeight));

    NSFont * f = LCDFont();
    
    [@"Welcome to Sala Macchine" drawAtPoint:NSMakePoint(0, 0) withAttributes:@{NSFontAttributeName: f}];
    
    [NSGraphicsContext restoreGraphicsState];
    
    [self convertToMaschine];
        
    bitmapData = [NSData dataWithBytesNoCopy:maschineData
                                      length:ImageSize_Maschine
                                freeWhenDone:NO];
    
    message = [NIDisplayDrawMessage new];
    message.sizeWidth = NIMaschineDisplaysWidth;
    message.sizeHeight = NIMaschineDisplaysHeight;
    message.st7529EncodedImage = bitmapData;
    
    return self;
}

- (void)dealloc;
{
    CGContextRelease(context);
}

- (void)convertToMaschine;
{
    for (int i = 0; i < ImageSize_8bpp; i++)
    {
        uint8_t dstColor = *(imageData + i) > 0x7f ? 0x1F : 0x00;
        size_t  dstPixel = (i / 3) * 2;
        
        switch (i % 3)
        {
            case 0:
                maschineData[dstPixel    ]  = dstColor << 3;
                break;
                
            case 1:
                maschineData[dstPixel    ] |= dstColor >> 2;
                maschineData[dstPixel + 1]  = dstColor << 6;
                break;
                
            case 2:
                maschineData[dstPixel + 1] |= dstColor;
                break;
        }
    }
}

- (CGContextRef)asCGContext;
{
    return context;
}

- (NSGraphicsContext *)asNSGraphicsContext;
{
    return gc;
}

- (NSImage *)asNSImage;
{
    CGImageRef x = CGBitmapContextCreateImage(context);
    id y = [[NSImage alloc] initWithCGImage:x size:NSMakeSize(NIMaschineDisplaysWidth, NIMaschineDisplaysHeight)];
    CGImageRelease(x);

    return y;
}

- (NIDisplayDrawMessage *)asDrawMessage;
{
    [self convertToMaschine];
    return message;
}


@end
