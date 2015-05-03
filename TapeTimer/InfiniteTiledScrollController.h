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

/* 
 this is a wrapper for the ruler layers
 */
@interface InfiniteTiledScrollController : NSObject

@property TimerView* timerView;
@property float currentAbsoluteRulerLocation;

- (InfiniteTiledScrollController*) initWithTimerView: (TimerView*) tv;

- (float) getCurrentAbsoluteRulerLocation;
- (void) scrollByTranslationNotAnimated: (float) location yScrollSpeed:(float)v;
- (void) scrollWithFricAndEdgeBounceAtInitialSpeed:(float)v;

@end
