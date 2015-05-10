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

    [self drawDecorationPattern:ctx];
    [self drawNumbers:ctx];
    [self drawLargeNumbers:ctx];
    
    UIGraphicsPopContext();
}

- (void) drawDecorationPattern:(CGContextRef)ctx
{
    CGContextSetStrokeColorWithColor(ctx, [UIColor lightGrayColor].CGColor);
    CGContextSetLineWidth(ctx, 0.5);
    
    //float distanceFromCenter = 80;
    float patternWidth = 10;
    
    [self drawPatternInContext:ctx BaseXPosition:self.frame.size.width/2 - 70 - patternWidth/2 BaseYPosition:-3 Width:patternWidth];
    [self drawPatternInContext:ctx BaseXPosition:self.frame.size.width/2 + 70 - patternWidth/2 BaseYPosition:-3 Width:patternWidth];
    
    [self drawPatternInContext:ctx BaseXPosition:self.frame.size.width/2 - 130 - patternWidth/2 BaseYPosition:-3 Width:patternWidth];
    [self drawPatternInContext:ctx BaseXPosition:self.frame.size.width/2 + 130 - patternWidth/2 BaseYPosition:-3 Width:patternWidth];
    
    [self drawPatternInContext:ctx BaseXPosition:self.frame.size.width/2 - 190 - patternWidth/2 BaseYPosition:-3 Width:patternWidth];
    [self drawPatternInContext:ctx BaseXPosition:self.frame.size.width/2 + 190 - patternWidth/2 BaseYPosition:-3 Width:patternWidth];
    
    [self drawPatternInContext:ctx BaseXPosition:self.frame.size.width/2 - 250 - patternWidth/2 BaseYPosition:-3 Width:patternWidth];
    [self drawPatternInContext:ctx BaseXPosition:self.frame.size.width/2 + 250 - patternWidth/2 BaseYPosition:-3 Width:patternWidth];
}

- (void) drawPatternInContext:(CGContextRef)ctx BaseXPosition:(float)baseXPos BaseYPosition:(float)baseYPos Width:(float)width
{
    float xPos = baseXPos;
    float yPos = baseYPos;
    NSInteger numOfSegments = self.rangeTo - self.rangeFrom + 1;
    
    CGContextMoveToPoint(ctx, xPos, yPos);
    for (NSInteger i = 0; i < numOfSegments + 1; i++) { // add one more to make sure fill the whole page even with initial y padding
        if (i % 2 == 1) {
            xPos -= width;
        } else {
            xPos += width;
        }
        yPos += [self getDistanceBetweenTwoNumbers];
        
        CGContextAddLineToPoint(ctx, xPos, yPos);
    }
    
    xPos = baseXPos + width;
    yPos = baseYPos;
    CGContextMoveToPoint(ctx, xPos, yPos);
    for (NSInteger i = 0; i < numOfSegments + 1; i++) {
        if (i % 2 == 1) {
            xPos += width;
        } else {
            xPos -= width;
        }
        yPos += [self getDistanceBetweenTwoNumbers];
        
        CGContextAddLineToPoint(ctx, xPos, yPos);
    }
    
    CGContextStrokePath(ctx);
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
        drawPos += [self getDistanceBetweenTwoNumbers];
    }
}

- (void) drawLargeNumbers:(CGContextRef)ctx
{
    float fontSize = 280.0f;
    UIFont* font = [UIFont fontWithName:@"Avenir" size:fontSize];
    NSDictionary* attributes = @{NSFontAttributeName: font,
                                 NSForegroundColorAttributeName: [UIColor blackColor]};
    NSString* numS = [NSString stringWithFormat:@"%ld", self.rangeFrom / 60];
    
    [numS drawAtPoint:CGPointMake(self.frame.size.width/2 - 243, self.frame.size.height/2 - fontSize/2) withAttributes:attributes];
    [numS drawAtPoint:CGPointMake(self.frame.size.width/2 + 88, self.frame.size.height/2 - fontSize/2) withAttributes:attributes];
}

- (float) getDistanceBetweenTwoNumbers
{
    return self.frame.size.height/(self.rangeTo - self.rangeFrom + 1);
}

@end
