//
//  RulerScrollController.m
//  TapeTimer
//
//  Created by Jialiang Xiang on 2014-12-31.
//  Copyright (c) 2014 Jialiang Xiang. All rights reserved.
//

#import "InfiniteTiledScrollController.h"
#import "RulerScaleLayer.h"

@implementation InfiniteTiledScrollController
{
    float TOLARANCE;
}

// custom initializer. use this inistead of init
- (InfiniteTiledScrollController*) initWithTimerView:(TimerView *)tv
{
    self = [super init];
    if (self) {
        self.timerView = tv;
        self.currentAbsoluteRulerLocation = 0;
        
        [self addNewTailRulerLayer];
    }
    TOLARANCE = 100.0f;
    return self;
}

- (void) addNewTailRulerLayer
{
    float positionY;
    float absRulerLoc;
        
    if ([self getRulerLayers].count != 0) {
        // set the layer right after the current tail layer
        RulerScaleLayer* currentTail = [self getTailLayer];
        // calculate new tail position
        positionY = currentTail.position.y + [self getLayerHeight];
        // calculate absolute position based on current tail
        absRulerLoc = currentTail.absoluteRulerLocation + [self getLayerHeight];
    } else {
        // the new layer must be the only layer
        // position and abs location is just 0
        positionY = 0;
        absRulerLoc = 0;
    }
    
    // TODO: calculate initial range and scale
    RulerScaleLayer* rsl = [RulerScaleLayer newWithYPosition:positionY WithHeight:self.timerView.frame.size.height
                            WithWidth:self.timerView.frame.size.width WithRangeFrom:0 To:10 WithScaleFactor:1];
    
    rsl.contentsScale = [[UIScreen mainScreen]scale];
    [self.timerView.layer addSublayer:rsl];
    [rsl setNeedsDisplay];
}

- (void) removeHeadRulerLayer
{
    [[self getHeadLayer] removeFromSuperlayer];
}

- (void) addNewHeadRulerLayer
{
    float positionY;
    float absRulerLoc;
    
    if ([self getRulerLayers].count != 0) {
        // set the layer right before the current head layer
        RulerScaleLayer* currentHead = [self getHeadLayer];
        // calculate new head position
        positionY = currentHead.position.y - [self getLayerHeight];
        // calculate absolute position based on current tail
        absRulerLoc = currentHead.absoluteRulerLocation - [self getLayerHeight];
    } else {
        // the new layer must be the only layer
        // position and abs location is just 0
        positionY = 0;
        absRulerLoc = 0;
    }
    
    // TODO: calculate initial range and scale
    RulerScaleLayer* rsl = [RulerScaleLayer newWithYPosition:positionY WithHeight:self.timerView.frame.size.height
                                                   WithWidth:self.timerView.frame.size.width WithRangeFrom:0 To:10 WithScaleFactor:1];
    
    rsl.contentsScale = [[UIScreen mainScreen]scale];
    // important: need to make sure the new layer is at back instead of front
    [self.timerView.layer insertSublayer:rsl atIndex:0];
    [rsl setNeedsDisplay];
}

- (void) removeTailLayer
{
    [[self getTailLayer] removeFromSuperlayer];
}

/*
 scroll with implicit animation. Don't call directly
 */
- (void)scrollToAbsoluteRulerLocation:(float)rulerLocation
{
    if ([self getRulerLayers].count != 0) {
        // step1: add and remove layer if necessary
        
        // add tail when: the tail view is on screen
        // add head when: the head view is on screen, unless the absLoc is 0 (at the beginning)
        // remove tail when it is off screen by height *2 (position off by height)
        // remove head when it is off screen by height *2 (position off by height*2)
        if ([self getTailLayer].position.y < [[UIScreen mainScreen]bounds].size.height + TOLARANCE)
        {
            // remove the head layer, unless it's the only layer present
            if ([self getRulerLayers].count > 1) {
                //[self removeHeadRulerLayer];
                NSLog(@"head layer deleted");
            }
            // add a tail layer
            [self addNewTailRulerLayer];
            NSLog(@"new tail layer added");
        }
        
        if ([self getHeadLayer].position.y + [self getLayerHeight] - TOLARANCE > 0)
        {
            // remove the tail layer, unless it's the only layer present
            if ([self getRulerLayers].count > 1) {
                //[self removeTailLayer];
                NSLog(@"tail layer deleted");
            }
            // add a head layer
            [self addNewHeadRulerLayer];
            NSLog(@"new head layer added");
        }
        // step2: scroll all layers
        float distance = rulerLocation - self.currentAbsoluteRulerLocation; // positive: scroll down or pan up
        for (RulerScaleLayer* rsl in [self getRulerLayers])
        {
            rsl.position = CGPointMake(rsl.position.x, rsl.position.y + distance);
        }
    }
    
    // update absolute location
    self.currentAbsoluteRulerLocation = rulerLocation;
}

/*
 scroll with implicit animation disabled
 */
- (void) scrollToAbsoluteRulerLocationNotAnimated:(float)rulerLocation
{
    // use CATransaction to disable transactions
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    
    [self scrollToAbsoluteRulerLocation:rulerLocation];
    
    [CATransaction commit];
}

/*
 
 */
- (void) scrollToAbsoluteRulerLocationWithFriction:(float)rulerLocation WithInitialSpeed:(float)v
{
    
}

- (void) scrollToAbsRulerLocWithFricAndEdgeBounce:(float)rulerLocation WithInitialSpeed:(float)v
{
    
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

- (float) getLayerHeight
{
    // should I use presentation layer?
    return ((CALayer*)[[self getRulerLayers] objectAtIndex:0]).frame.size.height;
}

- (RulerScaleLayer*) getHeadLayer
{
    return [[self getRulerLayers] objectAtIndex:0];
}

- (RulerScaleLayer*) getTailLayer
{
    return [self getRulerLayers].lastObject;
}

@end
