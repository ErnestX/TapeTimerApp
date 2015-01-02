//
//  RulerScrollController.m
//  TapeTimer
//
//  Created by Jialiang Xiang on 2014-12-31.
//  Copyright (c) 2014 Jialiang Xiang. All rights reserved.
//

#import "RulerScrollController.h"
#import "RulerScaleLayer.h"

@implementation RulerScrollController

// custom initializer. use this inistead of init
- (RulerScrollController*) initWithTimerView:(TimerView *)tv
{
    self = [super init];
    if (self) {
        self.timerView = tv;
        self.currentAbsoluteRulerLocation = 0;
        
        [self addNewTailRulerLayer];
//        RulerScaleLayer* rulerScale = [RulerScaleLayer newTailForTimerView:tv WithRangeFrom:0 to:10 withScaleFactor:1];
//        rulerScale.contentsScale = [[UIScreen mainScreen] scale];
//        [tv.layer addSublayer:rulerScale];
//        [rulerScale setNeedsDisplay];
    }
    return self;
}

- (void) addNewTailRulerLayer
{
    float positionY;
    float absRulerLoc;
        
    if ([self getRulerLayers].count != 0) {
        // set the layer right after the current tail layer
        RulerScaleLayer* currentTail = [self getRulerLayers].lastObject;
        // adjust to tail position
        positionY = currentTail.position.y + currentTail.frame.size.height;
        // calculate absolute position based on current tail
        absRulerLoc = currentTail.absoluteRulerLocation + currentTail.frame.size.height;
    } else {
        // this must be the head layer
        // in this case the frame is already correct, no need to adjust position
        // calculate absolute position based on current tail
        positionY = 0;
        absRulerLoc = 0;
    }
    RulerScaleLayer* rsl = [RulerScaleLayer newWithYPosition:positionY WithHeight:self.timerView.frame.size.height
                            WithWidth:self.timerView.frame.size.width WithRangeFrom:0 To:10 WithScaleFactor:1];
    
    rsl.contentsScale = [[UIScreen mainScreen]scale];
    [self.timerView.layer addSublayer:rsl];
    [rsl setNeedsDisplay];
}

- (void) removeHeadRulerLayer
{
    // stub
}

- (void) scrollToAbsoluteRulerLocation:(float)rl
{
    // use CATransaction to disable transactions
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    
    if ([self getRulerLayers].count != 0) {
        float distance = rl - self.currentAbsoluteRulerLocation; // positive: scroll down or pan up
        for (RulerScaleLayer* rsl in [self getRulerLayers])
        {
            rsl.position = CGPointMake(rsl.position.x, rsl.position.y + distance);
        }
    }
    
    [CATransaction commit];
    
    // update absolute location
    self.currentAbsoluteRulerLocation = rl;
}

/*
 return the TimerView delegate's ruler layers
 */
- (NSArray*) getRulerLayers
{
    return self.timerView.layer.sublayers;
}

- (float) getCurrentAbsoluteRulerLocation
{
    return self.currentAbsoluteRulerLocation;
}

@end
