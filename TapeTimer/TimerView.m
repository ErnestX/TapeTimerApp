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
    float lastScrollSpeed;
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

/* why we need to remember previous location: the translation is calculated from the 
 position the pan begins. So the value gets larger and larger as moving further and
 further from the beginning position. 
 */
- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSLog(@"touch began");
    [super touchesBegan:touches withEvent:event];
    // Remember original location
    previousLocation = self.rulerScrollController.getCurrentAbsoluteRulerLocation;
}

- (void) handlePan: (UIPanGestureRecognizer*) uigr
{
    lastScrollSpeed = [uigr velocityInView:self].y;
    CGPoint translation = [uigr translationInView:self]; // pan up or scroll down = negative
    [self.rulerScrollController scrollToAbsoluteRulerLocationNotAnimated:(translation.y + previousLocation)];
}

- (void) touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesCancelled:touches withEvent:event];
    NSLog(@"touch cancelled");
}

- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesEnded:touches withEvent:event];
    NSLog(@"touch ended");
    // start animation with lastScrollSpeed as initial speed
    [self.rulerScrollController scrollWithFricAndEdgeBounceAtInitialSpeed:lastScrollSpeed];
}

@end
