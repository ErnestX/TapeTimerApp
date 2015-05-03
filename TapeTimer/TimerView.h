//
//  TimerView.h
//  TapeTimer
//
//  Created by Jialiang Xiang on 2014-12-25.
//  Copyright (c) 2014 Jialiang Xiang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "InfiniteTiledScrollController.h"

@class InfiniteTiledScrollController;

@interface TimerView : UIView

@property InfiniteTiledScrollController* rulerScrollController;
- (void) setTimer: (float) min;

@end
