//
//  ViewController.m
//  TapeTimer
//
//  Created by Jialiang Xiang on 2014-12-25.
//  Copyright (c) 2014 Jialiang Xiang. All rights reserved.
//

#import "ViewController.h"
#import "TimerView.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    TimerView* timerView = [[TimerView alloc] initWithFrame:self.view.frame];
    [self.view addSubview:timerView];
    
    // TODO: add red pointer line subview
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
