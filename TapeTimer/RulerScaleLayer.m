//
//  RulerScale.m
//  TapeTimer
//
//  Created by Jialiang Xiang on 2014-12-25.
//  Copyright (c) 2014 Jialiang Xiang. All rights reserved.
//

#import "RulerScaleLayer.h"

@implementation RulerScaleLayer

+ (id) newWithYPosition:(float)py WithHeight:(float)h WithWidth:(float)w WithRangeFrom:(NSInteger)f To:(NSInteger)t
{
    RulerScaleLayer* rsl = [RulerScaleLayer layer];
    if (rsl) {
        rsl.frame = CGRectMake(0, 0, w, h);
        rsl.position = CGPointMake([UIScreen mainScreen].bounds.size.width/2 , py);
        rsl.rangeFrom = f;
        rsl.rangeTo = t;
        
        rsl.backgroundColor = [UIColor whiteColor].CGColor;
    }
    return rsl;
}

- (void) drawInContext:(CGContextRef)ctx
{
    UIGraphicsPushContext(ctx);
    //[self drawRulerLines:ctx];
    [self drawNumbers:ctx];
    [self drawLargeNumbers:ctx];
    
    UIGraphicsPopContext();
}

- (void) drawRulerLines:(CGContextRef)ctx
{
    // stub
    CGContextSetStrokeColorWithColor(ctx, [UIColor redColor].CGColor);
    
    CGPoint arr[2];
    arr[0] = CGPointMake(50, 0);
    arr[1] = CGPointMake(100, 600);
    
    CGContextStrokeLineSegments(ctx, arr, 2);
}

- (void) drawNumbers:(CGContextRef)ctx
{
    float drawPos = 0.0f; // the position of the first number from the top
    
    for (NSInteger num = self.rangeFrom; num <= self.rangeTo; num++) {
        UIFont* font = [UIFont fontWithName:@"Futura" size:32.0f];
        NSDictionary* attributes = @{NSFontAttributeName: font,
                                     NSForegroundColorAttributeName: [UIColor blackColor]};
        NSString* numS = [NSString stringWithFormat:@"- %02ld -", num % 60]; //number only goes from 0-60
        [numS drawAtPoint:CGPointMake(self.frame.size.width/2 - 40, drawPos) withAttributes:attributes];
        drawPos += self.frame.size.height/10;
    }
}

- (void) drawLargeNumbers:(CGContextRef)ctx
{
    float fontSize = 280.0f;
    UIFont* font = [UIFont fontWithName:@"Avenir" size:fontSize];
    NSDictionary* attributes = @{NSFontAttributeName: font,
                                 NSForegroundColorAttributeName: [UIColor blackColor]};
    NSString* numS = [NSString stringWithFormat:@"%ld", self.rangeFrom / 60];
    [numS drawAtPoint:CGPointMake(0, self.frame.size.height/2 - fontSize/2) withAttributes:attributes];
    [numS drawAtPoint:CGPointMake(self.frame.size.width - 155, self.frame.size.height/2 - fontSize/2) withAttributes:attributes];
}

@end
