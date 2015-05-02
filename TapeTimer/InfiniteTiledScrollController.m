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
    float FRICTION;
    NSInteger currentTailTo;
    NSInteger currentHeadFrom;
    NSInteger NUM_PER_LAYER;
    
    CALayer* backgroundLayer;
}

// custom initializer. use this inistead of init
- (InfiniteTiledScrollController*) initWithTimerView:(TimerView *)tv
{
    self = [super init];
    if (self) {
        // init fields
        self.timerView = tv;
        self.currentAbsoluteRulerLocation = 0;
        timerViewDefaultSubLayerNumber = [self getTimerViewSubLayers].count;
        NSLog(@"layer number: %ld", (long)timerViewDefaultSubLayerNumber);
        FRICTION = 5;
        currentTailTo = -1;
        currentHeadFrom = 0;
        NUM_PER_LAYER = 10;
        
        backgroundLayer = [CALayer layer];
        backgroundLayer.backgroundColor = [UIColor blueColor].CGColor;
        backgroundLayer.frame = CGRectMake(0, 0, [self getScreenWidth], [self getScreenHeight]);
        
        [self.timerView.layer addSublayer:backgroundLayer]; // add background layer used for zooming
        
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
    NSLog(@"currentTailTo = %ld", (long)currentTailTo);
    NSInteger from = currentTailTo + 1;
    NSInteger to = from + NUM_PER_LAYER - 1;
    RulerScaleLayer* rsl = [RulerScaleLayer newWithYPosition:positionY WithHeight:self.timerView.frame.size.height
                                                   WithWidth:self.timerView.frame.size.width WithRangeFrom: from To: to WithScaleFactor:1];
    currentTailTo = to; // update currentTailTo
    rsl.absoluteRulerLocation = absRulerLoc;
    rsl.contentsScale = [[UIScreen mainScreen]scale];
    [backgroundLayer addSublayer:rsl];
    [rsl setNeedsDisplay];
    NSLog(@"tail layer added from %ld to %ld", (long)from, (long)to);
}

- (void) removeHeadRulerLayer
{
    [[self getHeadLayer] removeFromSuperlayer];
    currentHeadFrom += NUM_PER_LAYER; // increase currentHeadFrom by one layer
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
    NSInteger to = currentHeadFrom - 1;
    NSInteger from = to - NUM_PER_LAYER + 1;
    RulerScaleLayer* rsl = [RulerScaleLayer newWithYPosition:positionY WithHeight:self.timerView.frame.size.height
                                                   WithWidth:self.timerView.frame.size.width WithRangeFrom:from To:to WithScaleFactor:1];
    currentHeadFrom = from; // update currentHeadFrom
    rsl.absoluteRulerLocation = absRulerLoc;
    rsl.contentsScale = [[UIScreen mainScreen]scale];
    // important: need to make sure the new layer is at back instead of front
    // bug caused by the layer inserted at 0. Not all the sublayers are ruler layers!!! Thus, the non-ruler layers are pushed over the default layer numbers, and considered ruler layer, but they are merely CALayer.
    [backgroundLayer insertSublayer:rsl atIndex:(int)timerViewDefaultSubLayerNumber];
    [rsl setNeedsDisplay];
    NSLog(@"head layer added");
}

- (void) removeTailRulerLayer
{
    [[self getTailLayer] removeFromSuperlayer];
    currentTailTo -= NUM_PER_LAYER; // decrease currentTailTo by one layer
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
- (void) scrollToAbsoluteRulerLocationNotAnimated:(float)rulerLocation yScrollSpeed:(float)v
{
    // use CATransaction to disable transactions
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    
    [self scrollToAbsoluteRulerLocation:rulerLocation];
    
    [CATransaction commit];
    
    // scale the back layer of timerView with implicit animaiton
    float scale = [self calcScaleWithSpeed:v];
    backgroundLayer.transform = CATransform3DMakeScale(scale, scale, 1);
}

/*
 Handels momentum scrolling and edge bounce. Call after the finger released from the screen. 
 */
- (void) scrollWithFricAndEdgeBounceAtInitialSpeed:(float)v
{
    __block float vTemp = v * 0.1; // convert velocity to moving distance
    
    POPCustomAnimation *customAnimation = [POPCustomAnimation animationWithBlock:^BOOL(id obj, POPCustomAnimation *animation) {
        for (NSInteger i = 0; i < [self getRulerLayerCount]; i++)
        {
            RulerScaleLayer* rsl = [self getRulerLayerAtIndex:i];
            [rsl setPosition: CGPointMake(rsl.position.x, rsl.position.y + vTemp)];
        }
        
        float scale = [self calcScaleWithSpeed:vTemp*10]; // multiply by 10 to convert back to speed
        backgroundLayer.transform = CATransform3DMakeScale(scale, scale, 1);
        
        [self manageLayersOnScreen]; // add and remove layers as needed
        
        if (vTemp > 0) {
            vTemp -= FRICTION; // scrolling up
        } else {
            vTemp += FRICTION; // scrolling down
        }
        NSLog(@"velocity = %f", vTemp);
        if (fabsf(vTemp) < FRICTION) {
            return NO; // animation stop
        } else {
            return YES; // not there yet
        }
    }];
    
    [self pop_addAnimation:customAnimation forKey:@"custom_animation"];
}

#pragma mark - Getters

/*
 Calculate the scale factor given the scrolling speed.
 Output: scale factor used in transform matrix
 */

- (float) calcScaleWithSpeed: (float) v
{
    float absV = abs(v);
    
    if (absV < 5.0) // don't bother to zoom if speed is too low???
        return 1.0;
    else
        return MAX(0.001, 1.0 - absV * 0.0002); // make sure scale factor is not too small (turn upside down if < 0)
}

/*
 index = 0: return the first ruler layer
 index = 1: return the ruler layer after the first one
 etc.
 */
- (RulerScaleLayer*) getRulerLayerAtIndex:(NSInteger) index
{
    return [[self getTimerViewSubLayers] objectAtIndex:(index + timerViewDefaultSubLayerNumber)];
}

/*
 return the TimerView delegate's ruler layers
 */
- (NSArray*) getTimerViewSubLayers
{
    //return self.timerView.layer.sublayers;
    return backgroundLayer.sublayers;
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
    return ((CALayer*)[[self getTimerViewSubLayers] objectAtIndex:timerViewDefaultSubLayerNumber]).frame.size.height;
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

- (float) getScreenWidth
{
    return [[UIScreen mainScreen] bounds].size.width;
}

@end
