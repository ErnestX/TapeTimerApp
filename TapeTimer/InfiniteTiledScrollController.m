//
//  RulerScrollController.m
//  TapeTimer
//
//  Created by Jialiang Xiang on 2014-12-31.
//  Copyright (c) 2014 Jialiang Xiang. All rights reserved.
//

#import "InfiniteTiledScrollController.h"
#import "RulerScaleLayer.h"
#import "POP.h"

@implementation InfiniteTiledScrollController
{
    NSInteger timerViewDefaultSubLayerNumber;
}

// custom initializer. use this inistead of init
- (InfiniteTiledScrollController*) initWithTimerView:(TimerView *)tv
{
    self = [super init];
    if (self) {
        self.timerView = tv;
        self.currentAbsoluteRulerLocation = 0;
        timerViewDefaultSubLayerNumber = [self getTimerViewSubLayers].count;
        NSLog(@"layer number: %ld", (long)timerViewDefaultSubLayerNumber);
        [self addNewTailRulerLayer];
    }
    return self;
}

#pragma mark - Layer Management

/*
 add tail when: the tail view is on screen or further up
 */
- (BOOL) shouldAddNewTail
{
    return [self getTailLayer].position.y < [self getScreenHeight];
}

/*
 remove tail when it is off screen by height *2 (position off by height)
 */
- (BOOL) shouldRemoveTail
{
    return [self getTailLayer].position.y > [self getScreenHeight] * 2;
}

/*
 add head when: the head view is on screen or further down, unless the absLoc is 0 (at the beginning)
 */
- (BOOL) shouldAddNewHead
{
    return [self getHeadLayer].position.y > 0 && [self getHeadLayer].absoluteRulerLocation != 0;
}

/*
 remove head when it is off screen by height *2 (position off by height*2)
 */
- (BOOL) shouldRemoveHead
{
    return [self getHeadLayer].position.y < -1 * [self getScreenHeight] * 2;
}

- (void) addNewTailRulerLayer
{
    float positionY;
    float absRulerLoc;
    if ([self getRulerLayerCount] > 0) {
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
    rsl.absoluteRulerLocation = absRulerLoc;
    rsl.contentsScale = [[UIScreen mainScreen]scale];
    [self.timerView.layer addSublayer:rsl];
    [rsl setNeedsDisplay];
    NSLog(@"tail layer added");
}

- (void) removeHeadRulerLayer
{
    [[self getHeadLayer] removeFromSuperlayer];
    NSLog(@"head layer removed");
}

- (void) addNewHeadRulerLayer
{
    float positionY;
    float absRulerLoc;
    
    if ([self getRulerLayerCount] > 0) {
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
    rsl.absoluteRulerLocation = absRulerLoc;
    rsl.contentsScale = [[UIScreen mainScreen]scale];
    // important: need to make sure the new layer is at back instead of front
    [self.timerView.layer insertSublayer:rsl atIndex:0];
    [rsl setNeedsDisplay];
    NSLog(@"head layer added");
}

- (void) removeTailRulerLayer
{
    [[self getTailLayer] removeFromSuperlayer];
    NSLog(@"tail layer removed");
}

- (void)manageLayersOnScreen
{
    if ([self shouldAddNewTail]) {
        [self addNewTailRulerLayer];
    }
    else if ([self shouldRemoveTail]) {
        [self removeTailRulerLayer];
    }
    
    if ([self shouldAddNewHead]) {
        [self addNewHeadRulerLayer];
    }
    else if ([self shouldRemoveHead]) {
        [self removeHeadRulerLayer];
    }
}

#pragma mark - Scrolling

/*
 scroll with implicit animation. Don't call directly
 Cannot scroll more than one screen at a time
 */
- (void)scrollToAbsoluteRulerLocation:(float)rulerLocation
{
    if ([self getRulerLayerCount] > 0) {
        // step1: add and remove layer if necessary
        [self manageLayersOnScreen];
        
        // step2: scroll
        float distance = rulerLocation - self.currentAbsoluteRulerLocation; // positive: scroll down or pan up
        
        // TODO: add condition. simply scroll all layers if distance is small
        // for (RulerScaleLayer* rsl in [self getTimerViewSubLayers])
        for (NSInteger i = 0; i < [self getRulerLayerCount]; i++)
        {
            RulerScaleLayer* rsl = [self getRulerLayerAtIndex:i];
            rsl.position = CGPointMake(rsl.position.x, rsl.position.y + distance);
        }
        
        //TODO: otherwise, do nothing, and throw error
    
        // update absolute location
        self.currentAbsoluteRulerLocation = rulerLocation;
    }
}

/*
 scroll with implicit animation disabled
 Cannot scroll more than one screen at a time
 */
- (void) scrollToAbsoluteRulerLocationNotAnimated:(float)rulerLocation
{
    // use CATransaction to disable transactions
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    
    [self scrollToAbsoluteRulerLocation:rulerLocation];
    
    [CATransaction commit];
}


- (void) scrollWithFricAndEdgeBounceAtInitialSpeed:(CGPoint)v
{
//    v.x = 0;
//    POPDecayAnimation *decayAnimation = [POPDecayAnimation animation];
//    
//    POPAnimatableProperty *prop = [POPAnimatableProperty propertyWithName:@"position_on_screen" initializer:^(POPMutableAnimatableProperty *prop) {
//        prop.readBlock = ^(id obj, CGFloat values[]) {
//            for (NSInteger i = timerViewDefaultSubLayerNumber; i < [self getRulerLayerCount] + timerViewDefaultSubLayerNumber; i++)
//            {
//                RulerScaleLayer* rsl = [[self getTimerViewSubLayers] objectAtIndex:i];
//                values[i] = rsl.position.y;
//            }
//        };
//    }];
    
    //TODO: call scrollToAbsRulerLocation page by page, with each initial speed calculated
    
    [self scrollToAbsoluteRulerLocation:self.currentAbsoluteRulerLocation + 30]; // stub
}

#pragma mark - Getters

- (RulerScaleLayer*) getRulerLayerAtIndex:(NSInteger) index
{
    return [[self getTimerViewSubLayers] objectAtIndex:index + timerViewDefaultSubLayerNumber];
}

/*
 return the TimerView delegate's ruler layers
 */
- (NSArray*) getTimerViewSubLayers
{
    return self.timerView.layer.sublayers;
}

- (NSInteger) getRulerLayerCount
{
    return [self getTimerViewSubLayers].count - timerViewDefaultSubLayerNumber;
}

- (float) getCurrentAbsoluteRulerLocation
{
    return self.currentAbsoluteRulerLocation;
}

- (float) getLayerHeight
{
    // should I use presentation layer?
    // 2 instead of 0 b/c backing layer
    return ((CALayer*)[[self getTimerViewSubLayers] objectAtIndex:2]).frame.size.height;
}

- (RulerScaleLayer*) getHeadLayer
{
    return [[self getTimerViewSubLayers] objectAtIndex:timerViewDefaultSubLayerNumber];
}

- (RulerScaleLayer*) getTailLayer
{
    return [self getTimerViewSubLayers].lastObject;
}

- (float) getScreenHeight
{
    return [[UIScreen mainScreen] bounds].size.height;
}

@end
