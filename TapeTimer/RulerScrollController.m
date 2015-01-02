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
    }
    return self;
}

//- (void) scrollToAbsoluteLocationMockUp:(float)location
//{
//    // use CATransaction to disable transactions
//    [CATransaction begin];
//    [CATransaction setDisableActions:YES];
//    
//    // TODO: below is a stub merely to test one-layer setup.
//    ((CALayer*)[[self getRulerLayers] objectAtIndex:0]).position = CGPointMake(((CALayer*)[[self getRulerLayers] objectAtIndex:0]).position.x, location);
//    
//    [CATransaction commit];
//    
//    // update absolute location
//    self.currentAbsoluteRulerLocation = location;
//}

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
