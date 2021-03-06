//
//  ScribCapControl.m
//  CrashHandler
//
//  Created by Mani on 4/7/14.
//  Copyright (c) 2014 mani. All rights reserved.
//

#import "ScribCapControl.h"

@interface ScribCapControl ()

@end

@implementation ScribCapControl

#pragma mark - Shared Control

+(ScribCapControl*)sharedControl
{
    static dispatch_once_t predicate = 0;
    static ScribCapControl *sharedInstance = nil;
    
    dispatch_once(&predicate, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}
#pragma mark - Pass touch event to View

-(void)sendEvent:(UIEvent*)event withTouch:(UITouch*)touch
{
    NSSet *touches = [event allTouches];
    for (UITouch *aTouch in touches) {
        if ((UITouchPhaseBegan == aTouch.phase) || (UITouchPhaseEnded == aTouch.phase)) {
            break;
        }
    }
	if (!self.scribTarget || !self.controller)
        return ;
	for (UITouch *touch in touches) {
        if (UITouchPhaseBegan == touch.phase) {
            CGPoint pt = [touch locationInView:self.scribTarget];
            if (CGRectContainsPoint([self.scribTarget bounds], pt)) {
                [self.controller didPassOnTouch:touch withEvent:event];
            }
        } else {
            [self.controller didPassOnTouch:touch withEvent:event];
        }
        
	}
}

#pragma mark - Handle Touch with Event

- (BOOL)beginTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
    if (!(UIEventTypeTouches == event.type))
        return NO;
    [self sendEvent:event withTouch:touch];
    return YES;
}

- (BOOL)continueTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
    if (!(UIEventTypeTouches == event.type))
        return NO;
    [self sendEvent:event withTouch:touch];
    return YES;
}

- (void)endTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
    if (!(UIEventTypeTouches == event.type))
        return ;
    [self sendEvent:event withTouch:touch];
}

@end
