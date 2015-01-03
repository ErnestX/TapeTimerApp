//
//  RulerScale.m
//  TapeTimer
//
//  Created by Jialiang Xiang on 2014-12-25.
//  Copyright (c) 2014 Jialiang Xiang. All rights reserved.
//

#import "RulerScaleLayer.h"

@implementation RulerScaleLayer

+ (id) newWithYPosition:(float)py WithHeight:(float)h WithWidth:(float)w WithRangeFrom:(NSInteger)f To:(NSInteger)t WithScaleFactor:(float)s
{
    RulerScaleLayer* rsl = [RulerScaleLayer layer];
    if (rsl) {
        rsl.anchorPoint = CGPointMake(0.5, 0); // set the anchor point to the top middle
        rsl.frame = CGRectMake(0, 0, w, h);
        rsl.position = CGPointMake(rsl.position.x, py);
        rsl.rangeFrom = f;
        rsl.rangeTo = t;
        rsl.scaleFactor = s;
    }
    return rsl;
}

- (void) drawInContext:(CGContextRef)ctx
{
    UIGraphicsPushContext(ctx);
    
    NSString* string = @"Hello World";
//  UIFont* font = [UIFont fontWithName:@"Futura" size:32.0f];
    
    UIFont* font = [UIFont systemFontOfSize:32.0f];
    NSDictionary* attributes = @{NSFontAttributeName: font,
                                 NSForegroundColorAttributeName: [UIColor blackColor]};
    
    [string drawAtPoint:CGPointMake(100, 100) withAttributes:attributes];
    
    [self drawRulerLines:ctx];
    [self drawNumbers:ctx];
    
    UIGraphicsPopContext();
}

- (void) drawRulerLines:(CGContextRef)ctx
{
    // stub
    
    CGContextSetStrokeColorWithColor(ctx, [UIColor redColor].CGColor);
    
    CGPoint arr[2];
    arr[0] = CGPointMake(10, 10);
    arr[1] = CGPointMake(100, 500);
    
    CGContextStrokeLineSegments(ctx, arr, 2);
}

- (void) drawNumbers:(CGContextRef)ctx
{
   // stub
}

@end
