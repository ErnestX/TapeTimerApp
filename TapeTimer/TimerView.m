//
//  TimerView.m
//  TapeTimer
//
//  Created by Jialiang Xiang on 2014-12-25.
//  Copyright (c) 2014 Jialiang Xiang. All rights reserved.
//

#import "TimerView.h"
#import "RulerScaleLayer.h"

@implementation TimerView
{
    float previousTranslation;
    CGPoint lastScrollSpeed;
    NSTimer* timer;
    NSTimer* ticker;
}

- (void)myInit
{
    if (self)
    {
        self.backgroundColor = [UIColor whiteColor];
        self.rulerScrollController = [[InfiniteTiledScrollController alloc] initWithTimerView:self];
        
        self.userInteractionEnabled = YES;
        
        UIPanGestureRecognizer* panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
        panRecognizer.cancelsTouchesInView = NO; // so that touch event won't be cancelled
        [self addGestureRecognizer:panRecognizer];
    }
}

- (id) initWithCoder:(NSCoder *)aDecoder // designated initializer
{
    NSLog(@"initWithCoderCalled");
    self = [super initWithCoder:aDecoder];
    [self myInit];
    return self;
}

- (id) initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    [self myInit];
    return self;
}

#pragma mark - Touch Events

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSLog(@"touch began");
    [super touchesBegan:touches withEvent:event];
    
    [self.rulerScrollController interruptAndReset]; // interrupt any animation when touched
}

- (void) handlePan: (UIPanGestureRecognizer*) uigr
{
    switch (uigr.state) {
        case UIGestureRecognizerStateBegan:
        {
            NSLog(@"pan began");
            // translation is 0 at the beginning
            previousTranslation = 0.0;
            break;
        }
        
        case UIGestureRecognizerStateChanged:
        {
            lastScrollSpeed = [uigr velocityInView:self];
            CGPoint translation = [uigr translationInView:self]; // pan up or scroll down = negative
            
            [self.rulerScrollController scrollByTranslationNotAnimated:(translation.y - previousTranslation) yScrollSpeed:lastScrollSpeed.y]; // substract the translation already done = the new translation amount
            previousTranslation = translation.y; // translation.y = the distance already translated
            break;
        }
        
        case UIGestureRecognizerStateEnded:
        {
            NSLog(@"pan ended");
            // start animation with lastScrollSpeed as initial speed
            [self.rulerScrollController scrollWithFricAndEdgeBounceAtInitialSpeed:lastScrollSpeed.y];
            break;
        }
    }
}

#pragma mark - Timer
- (void) setTimer: (float) min
{
    // remove previous timer
    [timer invalidate];
    [ticker invalidate];
    // set new timer
    timer = [NSTimer scheduledTimerWithTimeInterval:min * 60 target:self selector:@selector(timesUp:) userInfo:nil repeats:NO];
    // set ticker
    ticker = [NSTimer scheduledTimerWithTimeInterval:1 target:self.rulerScrollController selector:@selector(tickByOneSec:) userInfo:nil repeats:YES];
}

- (void)timesUp:(NSTimer *)t
    {
        NSLog(@"time's up!");
        // play sound, etc
        [ticker invalidate];
    }
             
@end
