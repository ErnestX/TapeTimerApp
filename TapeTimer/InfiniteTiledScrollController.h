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

- (InfiniteTiledScrollController*) initWithTimerView: (TimerView*) tv;

- (void) scrollByTranslationNotAnimated: (float) location yScrollSpeed:(float)v;
- (void) scrollWithFricAndEdgeBounceAtInitialSpeed:(float)v;
- (void) interruptAndReset;
- (void) checkBoundAndSnapBack;
- (float) getCurrentTime;
- (void) tickByOneSec:(NSTimer*)t;

@end
