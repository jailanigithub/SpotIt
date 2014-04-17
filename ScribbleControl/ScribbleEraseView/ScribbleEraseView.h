//
//  ScribbleEraseView.h
//  CrashHandler
//
//  Created by Mani on 4/3/14.
//  Copyright (c) 2014 mani. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Scribble;
@protocol ScribbleViewDelegate
@optional
-(BOOL) isValidScribble:(Scribble*)scribble;
-(void) scribbleDidStart;

//Logging Activity
-(void) logEraseStart;
-(void) logScribbleStart;
-(void) logEraseEnd;
-(void) logScribbleEnd;

@end

@interface ScribbleEraseView : UIView

@property (nonatomic) float lineWidth, eraseWidth;
@property (nonatomic) BOOL isEraseOn;
@property (nonatomic,strong) UIColor *currentScribbleStrokeColor;
@property (nonatomic, weak) id <ScribbleViewDelegate,NSObject> scribbleDelegate;

- (id)initWithFrame:(CGRect)frame;
- (void)resetView;

- (void) addTouchPoint:(CGPoint)point forTouch:(UITouch *)touch AndEvent:(UIEvent *) event;
- (void) appendTouchPoint:(CGPoint) point forTouch:(UITouch *)touch AndEvent:(UIEvent *) event;
- (void) endTouchPoint:(CGPoint) point forTouch:(UITouch *)touch AndEvent:(UIEvent *) event;
- (void) cancelTouchPoint:(CGPoint) point forTouch:(UITouch *)touch AndEvent:(UIEvent *) event;

-(void) changeColorOfScribbleTo:(UIColor*)someColor;

@end
