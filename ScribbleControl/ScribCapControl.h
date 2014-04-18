//
//  ScribCapControl.h
//  CrashHandler
//
//  Created by Mani on 4/7/14.
//  Copyright (c) 2014 mani. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ScribProcessor

- (void) didPassOnTouch:(UITouch *) touch withEvent:(UIEvent *) event;

@end

@interface ScribCapControl : UIControl

@property (nonatomic, weak) UIView *scribTarget;
@property (nonatomic, weak) id <ScribProcessor> controller;
+(ScribCapControl*)sharedControl;

@end
