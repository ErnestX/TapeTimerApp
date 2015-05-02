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
        rsl.frame = CGRectMake(0, 0, w, h);
        rsl.position = CGPointMake(rsl.position.x, py);
        rsl.rangeFrom = f;
        rsl.rangeTo = t;
        rsl.scaleFactor = s;
        
        rsl.backgroundColor = [UIColor whiteColor].CGColor;
    }
    return rsl;
}

- (void) drawInContext:(CGContextRef)ctx
{
    //[self drawRulerLines:ctx];
    [self drawNumbers:ctx];
    
    UIGraphicsPopContext();
}

- (void) drawRulerLines:(CGContextRef)ctx
{
    CGContextSetStrokeColorWithColor(ctx, [UIColor redColor].CGColor);
    
    CGPoint arr[2];
    arr[0] = CGPointMake(50, 0);
    arr[1] = CGPointMake(100, 600);
    
    CGContextStrokeLineSegments(ctx, arr, 2);
}

- (void) drawNumbers:(CGContextRef)ctx
{
    UIGraphicsPushContext(ctx);
    
    float drawPos = 16.0f; // the position of the first number from the top
    
    for (NSInteger num = self.rangeFrom; num <= self.rangeTo; num++) {
        UIFont* font = [UIFont fontWithName:@"Futura" size:32.0f];
        NSDictionary* attributes = @{NSFontAttributeName: font,
                                     NSForegroundColorAttributeName: [UIColor blackColor]};
        NSString* numS = [NSString stringWithFormat:@"- %ld -", num];
        [numS drawAtPoint:CGPointMake(115, drawPos) withAttributes:attributes];
        
        drawPos += 50.0; // TODO: extract a method to calculate this based on layer size.
    }
}

@end
