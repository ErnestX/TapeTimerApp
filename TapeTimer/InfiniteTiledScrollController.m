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

typedef enum {
    head,
    tail,
    inBound
}CheckBoundResult;

@implementation InfiniteTiledScrollController
{
    float LETTER_HEIGHT;
    NSInteger defaultSubLayerNumber;
    float MIN_SCROLL_SPEED;
    NSInteger MINUITES_PER_LAYER;
    float TIMER_LAYER_HEIGHT;
    float TIMER_LAYER_WIDTH;
    float DISTANCE_PER_MINUTE;
    NSInteger TAPE_LENGTH;
    
    NSInteger currentTailTo;
    NSInteger currentHeadFrom;
    
    CALayer* backgroundLayer;
    float scrollUpFriction;
    float scrollDownFriction;
    
    float RULER_LINE_PADDING;

    float VELOCITY_FACTOR;
}

/* 
 custom initializer. use this inistead of init
 */
- (InfiniteTiledScrollController*) initWithTimerView:(TimerView *)tv
{
    self = [super init];
    if (self) {
        // init fields
        self.timerView = tv;
        defaultSubLayerNumber = [self getTimerViewSubLayers].count;
        NSLog(@"layer number: %ld", (long)defaultSubLayerNumber);
        MIN_SCROLL_SPEED = 0.05;
        currentTailTo = -1;
        currentHeadFrom = 0;
        MINUITES_PER_LAYER = 10;
        scrollUpFriction = 1.0;
        scrollDownFriction = 1.0;
        TIMER_LAYER_HEIGHT = [self getScreenHeight];
        TIMER_LAYER_WIDTH = [self getScreenWidth] + 350;
        LETTER_HEIGHT = 37.0;
        DISTANCE_PER_MINUTE = [self getScreenHeight] / MINUITES_PER_LAYER;
        TAPE_LENGTH = 10 * 60 - 1; // 9 hours 59 min
        RULER_LINE_PADDING = 7.0;
        VELOCITY_FACTOR = 0.05;
        
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
 add tail when: the tail view is on screen + another screen or further up, unless it is the end
 */
- (BOOL) shouldAddNewTail
{
    return [self getTailLayer].position.y < [self getScreenHeight] * 2 && [self getTailLayer].rangeTo + 1 < TAPE_LENGTH;
}

/*
 remove tail when it is off screen by height *3 (position off by height).
 */
- (BOOL) shouldRemoveTail
{
    return [self getTailLayer].position.y > [self getScreenHeight] * 3;
}

/*
 add head when: the head view is half on screen + another screen or further down, unless the rangeFrom of the head > 0 (at the beginning)
 */
- (BOOL) shouldAddNewHead
{
    return [self getHeadLayer].position.y + [self getScreenHeight] > 0 && [self getHeadLayer].rangeFrom > 0;
}

/*
 remove head when it is off screen by height *3 (position off by height*2)
 */
- (BOOL) shouldRemoveHead
{
    return [self getHeadLayer].position.y < -1 * [self getScreenHeight] * 3;
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
        NSLog(@"setting the first layer");
        positionY = [self getScreenHeight] - LETTER_HEIGHT/2 - RULER_LINE_PADDING;
    }
    
    // TODO: calculate initial range and scale
    NSLog(@"currentTailTo = %ld", (long)currentTailTo);
    NSInteger from = currentTailTo + 1;
    NSInteger to = from + MINUITES_PER_LAYER - 1;
    RulerScaleLayer* rsl = [RulerScaleLayer newWithYPosition:positionY WithHeight:TIMER_LAYER_HEIGHT WithWidth:TIMER_LAYER_WIDTH WithRangeFrom: from To: to];
    currentTailTo = to; // update currentTailTo
    rsl.contentsScale = [[UIScreen mainScreen]scale];
    [backgroundLayer addSublayer:rsl];
    [rsl setNeedsDisplay];
    NSLog(@"tail layer added from %ld to %ld", (long)from, (long)to);
}

- (void) removeHeadRulerLayer
{
    [[self getHeadLayer] removeFromSuperlayer];
    currentHeadFrom += MINUITES_PER_LAYER; // increase currentHeadFrom by one layer
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
    NSInteger from = to - MINUITES_PER_LAYER + 1;
    RulerScaleLayer* rsl = [RulerScaleLayer newWithYPosition:positionY WithHeight:TIMER_LAYER_HEIGHT WithWidth:TIMER_LAYER_WIDTH WithRangeFrom:from To:to];
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
    currentTailTo -= MINUITES_PER_LAYER; // decrease currentTailTo by one layer
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
 Barebone scroll with implicit animation.
 Cannot scroll more than one screen within one call. (this may cause bug when speed is too high, b/c new layer won't be alloced in time)
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
 Scroll with implicit animation disabled, with bound checking
 Cannot scroll more than one screen within one call
 */
- (void) scrollByTranslationNotAnimated:(float)translation yScrollSpeed:(float)v
{
    float scale = [self calcScaleWithSpeed:v * VELOCITY_FACTOR];
    
    // disable transactions
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    
    [self checkBoundAndSlowDownOrReverse];
    
    if (translation > 0) {
        [self scrollByTranslation:translation / scale * scrollUpFriction]; // divide by scale to reverse the scalling effect on the translation
    } else {
        [self scrollByTranslation:translation / scale * scrollDownFriction];
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
    NSLog(@"v = %f", v);
    __block float vTemp = v * VELOCITY_FACTOR;
    
    POPCustomAnimation *customAnimation = [POPCustomAnimation animationWithBlock:^BOOL(id obj, POPCustomAnimation *animation) {
        
        // increase friction when out of bound
        if (vTemp > 0) { // scrolling up
            vTemp *= scrollUpFriction;
        } else {
            vTemp *= scrollDownFriction;
        }
        
        float scale = [self calcScaleWithSpeed:vTemp];
        
        for (NSInteger i = 0; i < [self getRulerLayerCount]; i++)
        {
            RulerScaleLayer* rsl = [self getRulerLayerAtIndex:i];
            [rsl setPosition: CGPointMake(rsl.position.x, rsl.position.y + vTemp/scale)]; // divide by scale to reverse the scalling effect on the translation
        }
        
        backgroundLayer.transform = CATransform3DMakeScale(scale, scale, 1);
        
        [self manageLayersOnScreen]; // add and remove layers as needed
 
        vTemp *= 0.95; // EXPONENTIAL DECAY
        
        NSLog(@"velocity = %f", vTemp);
        if (fabsf(vTemp) <= MIN_SCROLL_SPEED) {
            return NO; // animation stop
        } else { // add condition here can interrupt animation
            [self checkBoundAndSlowDownOrReverse];
            return YES; // not there yet
        }
    }];
    
    [customAnimation setCompletionBlock:^(POPAnimation *anim, BOOL finished) {
        [CATransaction begin];
        [CATransaction setCompletionBlock:^(void) {
            [self setTimer];
        }];
        [self checkBoundAndSnapBack];
        [CATransaction commit];

    }];
    
    [self pop_addAnimation:customAnimation forKey:@"momentum_scrolling"];
}

#pragma mark - Scroll Helpers

/*
 returns positive float indicating how much the head layer's center, taking paddings into consideration, is below the screen.
 returns negative float if it is above the bottom of the screen
 */
- (float) headBelowScreenBottomAmount
{
    return ([self getHeadLayer].position.y + LETTER_HEIGHT/2 + RULER_LINE_PADDING) - [self getScreenHeight];
}

/*
 returns positive float indicating how much the tail layer's center, taking paddings into consideration, is above the screen.
 returns negative float if it is below the top of the screen
 */
- (float) tailAboveScreenTopAmount
{
    return 0 - ([self getTailLayer].position.y - LETTER_HEIGHT/2 - RULER_LINE_PADDING);
}

/*
 Check if the 0 min layer or the 10 hour layer is scrolled below or above the center of the screen. Used to activate rubber band effect.
 Returns inBound if there's no ruler layer on the screen
 */
- (CheckBoundResult) checkOutOfBound
{
    if ([self getRulerLayerCount] > 0) {
        if ([self getHeadLayer].rangeFrom < 2 && [self headBelowScreenBottomAmount] > 0) {
            // the head layer is the first layer and is already half out of screen.
            return head;
        } else if ([self getTailLayer].rangeTo > 597 && [self tailAboveScreenTopAmount] > 0) {
            // the tail layer is the last layer and is already half out of screen.
            return tail;
        } else {
            return inBound;
        }
    } else {
        return inBound; // return inBound if there's no layer
    }
}

/*
 Increase the friction applied to scrolling (both manual and animation) 
 by how much the 0 min layer is out of position
 */
- (void) slowDownHeadOutOfBound
{
    // calc the new friction based on how much the position is off
    scrollUpFriction = MAX(powf(0.99, [self headBelowScreenBottomAmount]), 0);
}

- (void) slowDownTailOutOfBound
{
    // calc the new friction based on how much the position is off
    scrollDownFriction = MAX(powf(0.99, [self tailAboveScreenTopAmount]), 0);
}

/*
 Reverse the friction factor to 1.0
 */
- (void) reverseSlowDownBothDirections
{
    scrollUpFriction = 1.0; // no friction
    scrollDownFriction = 1.0;
}

- (void)checkBoundAndSlowDownOrReverse
{
    CheckBoundResult result = [self checkOutOfBound];
    switch (result) {
        case head:
            [self slowDownHeadOutOfBound];
            break;
        case tail:
            [self slowDownTailOutOfBound];
            break;
        case inBound:
            [self reverseSlowDownBothDirections];
            break;
    }
}

- (void) bounceBackResetTransformAndReverseSlowDownWithDirection: (BOOL)isHead
{
    backgroundLayer.transform = CATransform3DMakeScale(1.0, 1.0, 1.0);
    
    if (isHead) {
        [self scrollByTranslation:[self getScreenHeight] - [self getHeadLayer].position.y - LETTER_HEIGHT/2 - RULER_LINE_PADDING];
    } else {
        [self scrollByTranslation:0 - [self getTailLayer].position.y + DISTANCE_PER_MINUTE - LETTER_HEIGHT/2 - RULER_LINE_PADDING];
    }
    
    [self reverseSlowDownBothDirections];
}

- (void) checkBoundAndSnapBack
{
    CheckBoundResult result = [self checkOutOfBound];
    switch (result) {
        case head:
            [self bounceBackResetTransformAndReverseSlowDownWithDirection:YES];
            break;
        case tail:
            [self bounceBackResetTransformAndReverseSlowDownWithDirection:NO];
            break;
        case inBound:
            [self reverseSlowDownBothDirections];
            break;
    }
    
    // TODO: snap to integer minutes
}

/*
 Remove any scrolling animation playing, and reset the transform scale
 */
- (void) interruptAndReset
{
    [self pop_removeAnimationForKey:@"momentum_scrolling"];
    backgroundLayer.transform = CATransform3DMakeScale(1.0, 1.0, 1.0);
}

#pragma mark - Timer
/*
 set the timer using the number currently under the red line
 */
- (void) setTimer
{
    //NSLog(@"setting timer...");
    [self.timerView setTimer:[self getCurrentTime]];
    NSLog(@"Timer Set To: %f", [self getCurrentTime]);
}

/*
 Tick the timer by second
 Intended to be called by timer component in TimerView
 */
- (void) tickByOneSec:(NSTimer*)t
{
    //NSLog(@"Tick");
    // tick animation
    [self scrollByTranslation:DISTANCE_PER_MINUTE/60];
}

#pragma mark - Getters

/*
 Return the time the red line is currently pointing at
 */
- (float) getCurrentTime
{
    RulerScaleLayer* rsl = [self getCurrentLayerOnScreen];
    float distanceFromLayerTop = [self getScreenHeight]/2 - (rsl.position.y - TIMER_LAYER_HEIGHT/2.0);
    
    return rsl.rangeFrom + ((distanceFromLayerTop - LETTER_HEIGHT/2 - RULER_LINE_PADDING) / DISTANCE_PER_MINUTE);
}

/*
 Return the layer currently below the red line
 */
- (RulerScaleLayer*) getCurrentLayerOnScreen
{
    //  return ((RulerScaleLayer*)[backgroundLayer hitTest:CGPointMake([self getScreenWidth]/2, [self getScreenHeight]/2)]);
    // the heisen bug is caused by hitTesting when no ruler layer is on center and as a result the background layer is returned. When debugging, the bug disappear b/c the layer have enough time to snap back.
    
    CGPoint redLineCenter = CGPointMake([self getScreenWidth]/2, [self getScreenHeight]/2);
    RulerScaleLayer* candidate = nil;
    float currentMinDistance = INFINITY;
    
    // return the layer whose centural point is closet to the red line
    for (NSInteger i = 0; i < [self getRulerLayerCount]; i++) {
        RulerScaleLayer* rsl = [self getRulerLayerAtIndex:i];
        float distance = fabs(rsl.position.y - redLineCenter.y);
        if (distance < currentMinDistance) {
            currentMinDistance = distance;
            candidate = rsl;
        }
    }
    
    if (candidate == nil) {
        NSLog(@"getCurrentLayerOnScreen: no ruler layer currently on screen, returning nil");
        return nil;
    } else {
        return candidate;
    }
}

/*
 Calculate the scale factor given the scrolling speed.
 Output: scale factor used in transform matrix
 */

- (float) calcScaleWithSpeed: (float) v
{
    float absV = fabsf(v);
    
    if (scrollDownFriction < 1.0 || scrollUpFriction < 1.0)// || absV < 500)
        return 1.0; // don't scale if out of bound or too slow
    else {
        float a = 1.3;
        float velocityFactor = 0.007;
        return MAX(0.3, 1.0 - (powf(absV*velocityFactor,a)/(powf(absV*velocityFactor, a)+powf((1-absV*velocityFactor),a)))); //2.0 - powf(1.0004, absV));//1.0 - absV * 0.0005); // make sure scale factor is not too small (turn upside down if < 0)
        //http://math.stackexchange.com/questions/121720/ease-in-out-function
    }
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
