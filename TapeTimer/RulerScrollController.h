//
//  RulerScrollController.h
//  TapeTimer
//
//  Created by Jialiang Xiang on 2014-12-31.
//  Copyright (c) 2014 Jialiang Xiang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TimerView.h"

@class TimerView;

// this is a wrapper for the ruler layers
@interface RulerScrollController : NSObject

@property TimerView* timerView;
@property float currentAbsoluteRulerLocation;

- (void) createNewTailRulerLayer;
- (void) removeHeadRulerLayer;

- (float) getCurrentAbsoluteRulerLocation;
- (void) scrollToAbsoluteRulerLocation: (float) location;
- (RulerScrollController*) initWithTimerView: (TimerView*) tv;

@end
