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
    NSInteger defaultSubLayerNumber;
    float MOMENTUM_FRICTION;
    NSInteger NUM_PER_LAYER;
    float TIMER_LAYER_HEIGHT;
    float TIMER_LAYER_WEIDTH;
    
    NSInteger currentTailTo;
    NSInteger currentHeadFrom;
    
    CALayer* backgroundLayer;
    float scrollUpFriction;
}

// custom initializer. use this inistead of init
- (InfiniteTiledScrollController*) initWithTimerView:(TimerView *)tv
{
    self = [super init];
    if (self) {
        // init fields
        self.timerView = tv;
        self.currentAbsoluteRulerLocation = 0;
        defaultSubLayerNumber = [self getTimerViewSubLayers].count;
        NSLog(@"layer number: %ld", (long)defaultSubLayerNumber);
        MOMENTUM_FRICTION = 5.0;
        currentTailTo = -1;
        currentHeadFrom = 0;
        NUM_PER_LAYER = 10;
        scrollUpFriction = 1.0;
        //outOfBound = NO;
        
        backgroundLayer = [CALayer layer];
        backgroundLayer.backgroundColor = [UIColor whiteColor].CGColor;
        backgroundLayer.frame = CGRectMake(0, 0, [self getScreenWidth], [self getScreenHeight]);
        [self.timerView.layer addSublayer:backgroundLayer];
        
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
    return [self getHeadLayer].position.y > 0 && [self getHeadLayer].rangeFrom > 0;
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
    if ([self getRulerLayerCount] > 0) {
        // set the layer right after the current tail layer
        RulerScaleLayer* currentTail = [self getTailLayer];
        // calculate new tail position
        positionY = currentTail.position.y + [self getLayerHeight];
        // calculate absolute position based on current tail
    } else {
        // the new layer must be the only layer
        positionY = [self getScreenHeight];
    }
    
    // TODO: calculate initial range and scale
    NSLog(@"currentTailTo = %ld", (long)currentTailTo);
    NSInteger from = currentTailTo + 1;
    NSInteger to = from + NUM_PER_LAYER - 1;
    RulerScaleLayer* rsl = [RulerScaleLayer newWithYPosition:positionY WithHeight:self.timerView.frame.size.height WithWidth:self.timerView.frame.size.width WithRangeFrom: from To: to];
    currentTailTo = to; // update currentTailTo
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
    } else {
        // the new layer must be the only layer
        // position and abs location is just 0
        positionY = 0;
        absRulerLoc = 0;
    }
    
    // TODO: calculate initial range and scale
    NSInteger to = currentHeadFrom - 1;
    NSInteger from = to - NUM_PER_LAYER + 1;
    RulerScaleLayer* rsl = [RulerScaleLayer newWithYPosition:positionY WithHeight:self.timerView.frame.size.height WithWidth:self.timerView.frame.size.width WithRangeFrom:from To:to];
    currentHeadFrom = from; // update currentHeadFrom
    rsl.contentsScale = [[UIScreen mainScreen]scale];
    // important: need to make sure the new layer is at back instead of front
    // bug caused by the layer inserted at 0. Not all the sublayers are ruler layers!!! Thus, the non-ruler layers are pushed over the default layer numbers, and considered ruler layer, but they are merely CALayer. (this mechanism is no longer needed since I added a new background layer whose default sub layer number is 0)
    [backgroundLayer insertSublayer:rsl atIndex:(int)defaultSubLayerNumber];
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
- (void)scrollByTranslation:(float)translation
{
    if ([self getRulerLayerCount] > 0) {
        // step1: add and remove layer if necessary
        [self manageLayersOnScreen];
        
        // step2: scroll
        // TODO: add condition. scroll all layers only if distance is small
        for (NSInteger i = 0; i < [self getRulerLayerCount]; i++)
        {
            RulerScaleLayer* rsl = [self getRulerLayerAtIndex:i];
            rsl.position = CGPointMake(rsl.position.x, rsl.position.y + translation);
        }
        
        //TODO: otherwise, do nothing, and throw error
        
    }
}

/*
 scroll with implicit animation disabled
 Cannot scroll more than one screen at a time
 */
- (void) scrollByTranslationNotAnimated:(float)translation yScrollSpeed:(float)v
{
    float scale = [self calcScaleWithSpeed:v];
    
    // use CATransaction to disable transactions
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    
    if (translation > 0) {
        if ([self checkOutOfBound]) {
            [self slowDown];
        } else {
            [self reverseSlowDown];
        }
        [self scrollByTranslation:translation * scrollUpFriction];
    } else {
        [self scrollByTranslation:translation];
    }
    
    [CATransaction commit];
    
    // scale the back layer of timerView with implicit animaiton
    backgroundLayer.transform = CATransform3DMakeScale(scale, scale, 1);
}

/*
 Handels momentum scrolling and edge bounce. Call after the finger released from the screen. 
 */
- (void) scrollWithFricAndEdgeBounceAtInitialSpeed:(float)v
{
    __block float vTemp = v * 0.1; // convert velocity to moving distance
    
    POPCustomAnimation *customAnimation = [POPCustomAnimation animationWithBlock:^BOOL(id obj, POPCustomAnimation *animation) {
        vTemp *= scrollUpFriction;
        for (NSInteger i = 0; i < [self getRulerLayerCount]; i++)
        {
            RulerScaleLayer* rsl = [self getRulerLayerAtIndex:i];
            [rsl setPosition: CGPointMake(rsl.position.x, rsl.position.y + vTemp)];
        }
        
        float scale = [self calcScaleWithSpeed:vTemp*10]; // multiply by 10 to convert back to speed
        backgroundLayer.transform = CATransform3DMakeScale(scale, scale, 1);
        
        [self manageLayersOnScreen]; // add and remove layers as needed
        
        if (vTemp > MOMENTUM_FRICTION) {
            vTemp -= MOMENTUM_FRICTION; // scrolling up
        } else if (vTemp < -1 * MOMENTUM_FRICTION) {
            vTemp += MOMENTUM_FRICTION; // scrolling down
        }
        NSLog(@"velocity = %f", vTemp);
        if (fabsf(vTemp) < MOMENTUM_FRICTION) {
            return NO; // animation stop
        } else { // add condition here can interrupt animation
            if ([self checkOutOfBound]) {
                [self slowDown];
            }
            return YES; // not there yet
        }
    }];
    
    [customAnimation setCompletionBlock:^(POPAnimation *anim, BOOL finished) {
        [self checkBoundAndFix];
    }];
    
    [self pop_addAnimation:customAnimation forKey:@"momentum_scrolling"];
}

- (BOOL) checkOutOfBound
{
    // the head layer is the first layer and is already on screen.
    return [self getHeadLayer].rangeFrom < 2 && [self getHeadLayer].position.y >= [self getScreenHeight];
}

- (void) slowDown
{
    scrollUpFriction = MAX(1 - ([self getHeadLayer].position.y - [self getScreenHeight])*0.01, 0);
}

- (void) reverseSlowDown
{
    scrollUpFriction = 1.0; // no friction
}

- (void) bounceBackResetTransformAndReverseSlowDown
{
    //[self pop_removeAnimationForKey:@"momentum_scrolling"];
    backgroundLayer.transform = CATransform3DMakeScale(1.0, 1.0, 1.0);
    [self scrollByTranslation:[self getScreenHeight] - [self getHeadLayer].position.y];
    [self reverseSlowDown];
}

- (void) checkBoundAndFix
{
    if ([self checkOutOfBound]) {
        [self bounceBackResetTransformAndReverseSlowDown];
    }
}

- (void) interruptAndReset
{
    [self pop_removeAnimationForKey:@"momentum_scrolling"];
    backgroundLayer.transform = CATransform3DMakeScale(1.0, 1.0, 1.0);
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
    return [[self getTimerViewSubLayers] objectAtIndex:(index + defaultSubLayerNumber)];
}

/*
 return the TimerView delegate's ruler layers
 */
- (NSArray*) getTimerViewSubLayers
{
    return backgroundLayer.sublayers;
}

- (NSInteger) getRulerLayerCount
{
    return [self getTimerViewSubLayers].count - defaultSubLayerNumber;
}

- (float) getCurrentAbsoluteRulerLocation
{
    return self.currentAbsoluteRulerLocation;
}

- (float) getLayerHeight
{
    // should I use presentation layer?
    return ((CALayer*)[[self getTimerViewSubLayers] objectAtIndex:defaultSubLayerNumber]).frame.size.height;
}

- (RulerScaleLayer*) getHeadLayer
{
    return [[self getTimerViewSubLayers] objectAtIndex:defaultSubLayerNumber];
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
