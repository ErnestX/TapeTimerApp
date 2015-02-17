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
    float previousLocation;
    CGPoint lastScrollSpeed;
}

- (void)myInit
{
    if (self)
    {
        self.backgroundColor = [UIColor whiteColor];
        self.rulerScrollController = [[InfiniteTiledScrollController alloc] initWithTimerView:self];
        
        self.userInteractionEnabled = YES;
        
        UIPanGestureRecognizer* panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
        //panRecognizer.cancelsTouchesInView = NO; // so that touch event won't be cancelled (no longer needed after switched to gesturerecognizer's built-in states)
        [self addGestureRecognizer:panRecognizer];
    }
}

- (id) initWithCoder:(NSCoder *)aDecoder
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

- (void) handlePan: (UIPanGestureRecognizer*) uigr
{
    switch (uigr.state) {
        case UIGestureRecognizerStateBegan:
        {
            NSLog(@"touch began");
            //[super touchesBegan:touches withEvent:event];
            // Remember original location
            previousLocation = self.rulerScrollController.getCurrentAbsoluteRulerLocation;
        }
        
        case UIGestureRecognizerStateChanged:
        {
            lastScrollSpeed = [uigr velocityInView:self];
            CGPoint translation = [uigr translationInView:self]; // pan up or scroll down = negative
            [self.rulerScrollController scrollToAbsoluteRulerLocationNotAnimated:(translation.y + previousLocation)];
        }
        break;
        
        case UIGestureRecognizerStateEnded:
        {
            NSLog(@"touch ended");
            // start animation with lastScrollSpeed as initial speed
            [self.rulerScrollController scrollWithFricAndEdgeBounceAtInitialSpeed:lastScrollSpeed.y];
        }
    }
    
}

@end
