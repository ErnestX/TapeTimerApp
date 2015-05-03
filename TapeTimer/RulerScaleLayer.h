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

@property NSInteger rangeFrom;
@property NSInteger rangeTo;
//@property float scaleFactor;

+ (id) newWithYPosition:(float)py WithHeight:(float)h WithWidth:(float)w WithRangeFrom:(NSInteger)f To:(NSInteger)t;// WithScaleFactor:(float)s;

@end
