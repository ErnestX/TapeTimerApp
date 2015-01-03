//
//  RulerScale.h
//  TapeTimer
//
//  Created by Jialiang Xiang on 2014-12-25.
//  Copyright (c) 2014 Jialiang Xiang. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "TimerView.h"

@interface RulerScaleLayer : CALayer

@property float absoluteRulerLocation;
@property NSInteger rangeFrom;
@property NSInteger rangeTo;
@property float scaleFactor;

//+ (id) newTailForTimerView: (TimerView*) tv WithRangeFrom:(NSInteger)f to:(NSInteger)t withScaleFactor:(float)s;
+ (id) newWithYPosition:(float)py WithHeight:(float)h WithWidth:(float)w WithRangeFrom:(NSInteger)f To:(NSInteger)t WithScaleFactor:(float)s;

@end
