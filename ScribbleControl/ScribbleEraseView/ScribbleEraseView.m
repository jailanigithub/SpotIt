//
//  ScribbleEraseView.m
//  CrashHandler
//
//  Created by Mani on 4/3/14.
//  Copyright (c) 2014 mani. All rights reserved.
//

#import "ScribbleEraseView.h"
#import "Scribble.h"
#import "ScribCapControl.h"

#define kEraseWidthAmplifyFactor    (4.0)

@interface ScribbleEraseView ()<ScribProcessor,ScribbleViewDelegate>

@property (nonatomic,strong) NSMutableDictionary* scribbles;
@property (nonatomic, strong) NSMutableArray    *finishedScribbles;

@end

@implementation ScribbleEraseView

#pragma mark - Scribble Erase view Initilization

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        ScribCapControl *scribbleControl = [ScribCapControl sharedControl];
        scribbleControl.frame =  CGRectMake(0, 0, self.frame.size.width, self.frame.size.height) ;
        scribbleControl.controller = self;
        scribbleControl.scribTarget = self;
        self.scribbleDelegate = self;
        [self addSubview:scribbleControl];
        
        self.scribbles = [NSMutableDictionary dictionary];
        self.lineWidth = self.eraseWidth = 4.0f;
        self.finishedScribbles = [NSMutableArray array];
        self.currentScribbleStrokeColor = [UIColor blackColor];
    }
    return self;
}

#pragma mark - Draw Scribbles in context

- (void)drawScribble:(Scribble *)scribble inContext:(CGContextRef)context{
    
	CGColorRef colorRef = [scribble.strokeColor CGColor];
	CGContextAddPath(context, scribble.drawingPath);
    CGContextSetLineCap(context, kCGLineCapRound);
    CGContextSetLineWidth(context, self.lineWidth);
    CGContextSetStrokeColorWithColor(context, colorRef);
	CGContextStrokePath(context);
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    CGContextRef context = UIGraphicsGetCurrentContext();
    for (Scribble *scribble in self.finishedScribbles) {
        if (!scribble.isEraseOn) {
            [self drawScribble:scribble inContext:context];
        }
    }
    for (NSString *key in self.scribbles){
        Scribble *scribble = [self.scribbles valueForKey:key];
        [self drawScribble:scribble inContext:context];
    }
}

#pragma mark - Clear all scribbles

- (void)resetView{
    [self.scribbles removeAllObjects];
	[self.finishedScribbles removeAllObjects];
    
	[self setNeedsDisplay];
}

#pragma mark - Scribble manipulation - Helping methods

- (void) initScribble:(Scribble*) scribble WithPoint : (CGPoint) point{
	[scribble setStrokeColor:self.currentScribbleStrokeColor];
    [scribble setIsEraseOn:self.isEraseOn];
    
    if (scribble.isEraseOn) {
        [scribble setLineWidth:(self.eraseWidth * kEraseWidthAmplifyFactor)];
    }
    else {
        [scribble setLineWidth:self.lineWidth];
        [scribble addPoint:point];
    }
}

- (void) eraseScribbleInRect:(CGRect)eraseRect{
    BOOL eraseScribble = NO;
    for (Scribble *finishedScribble in self.finishedScribbles)
    {
        for (int pointIndex = 0; pointIndex < [finishedScribble getPoints].count;  pointIndex++) {
            CGPoint currentPoint = [finishedScribble getPointAtIndex:pointIndex];
            
            if (CGRectContainsPoint(eraseRect, currentPoint)){
                eraseScribble = YES;
                finishedScribble.isEraseOn = YES;
                break;
            }
        }
    }
}


#pragma mark - Scribble manipulation depending on touch event

- (void) addTouchPoint:(CGPoint)point forTouch:(UITouch *)touch AndEvent:(UIEvent *) event{
    
    Scribble *scribble = [[Scribble alloc] init];
    [self initScribble:scribble  WithPoint:point];
    if (scribble.isEraseOn) {
        if ([self.scribbleDelegate respondsToSelector:@selector(logEraseStart)])
            [self.scribbleDelegate logEraseStart];
    } else {
        if ([self.scribbleDelegate respondsToSelector:@selector(logScribbleStart)])
            [self.scribbleDelegate logScribbleStart];
    }
    
    NSValue *touchValue = [NSValue valueWithPointer:(__bridge const void *)(touch)];
    NSString *key = [NSString stringWithFormat:@"%@", touchValue];
    
    BOOL touchShouldBeCancelled;
    NSSet *keysOfScribblesToBeRemoved=[self.scribbles keysOfEntriesPassingTest:^BOOL(id key, id obj, BOOL *stop) {
        Scribble *scrib=(Scribble*)obj;
        CGPoint topPoint = scrib.topMostPoint;
        return (topPoint.y > point.y);
    }];
    if ([keysOfScribblesToBeRemoved anyObject]) {
        [self.scribbles removeObjectsForKeys:[keysOfScribblesToBeRemoved allObjects]];
    }
    touchShouldBeCancelled=([[self.scribbles allValues] count]>0)?YES:NO;
    if (!touchShouldBeCancelled) {
        [self.scribbles setValue:scribble forKey:key];
    }
}

- (void) appendTouchPoint:(CGPoint)point forTouch:(UITouch *)touch AndEvent:(UIEvent *) event{
    
    NSValue *touchValue = [NSValue valueWithPointer:(__bridge const void *)(touch)];
    Scribble *scribble = [self.scribbles valueForKey:
                          [NSString stringWithFormat:@"%@", touchValue]];
    
    if (scribble.isEraseOn) {
        CGRect eraseRect =  CGRectMake(point.x, point.y, scribble.lineWidth, scribble.lineWidth);
        [self eraseScribbleInRect:eraseRect];
        [self setNeedsDisplay];
    }
    else {
        CGRect drawRect = [scribble addPoint:point];
        [self setNeedsDisplayInRect:drawRect];
    }
}

- (void) endTouchPoint:(CGPoint)point forTouch:(UITouch *)touch AndEvent:(UIEvent *) event; {
    
    NSValue *touchValue = [NSValue valueWithPointer:(__bridge const void *)(touch)];
    NSString *key = [NSString stringWithFormat:@"%@", touchValue];
    
    Scribble *scribble = [self.scribbles valueForKey:key];
	
    if (scribble) {
        if (scribble.isEraseOn) {
            if ([self.scribbleDelegate respondsToSelector:@selector(logEraseEnd)])
                [self.scribbleDelegate logEraseEnd];
        } else {
            if ([self.scribbleDelegate respondsToSelector:@selector(logScribbleEnd)])
                [self.scribbleDelegate logScribbleEnd];
        }
        if (!scribble.isEraseOn) {
            [self.finishedScribbles addObject:scribble];
        }        
        [self.scribbles removeObjectForKey:key];
        
        if ([self.finishedScribbles count] == 1) {
            if ([self.scribbleDelegate respondsToSelector:@selector(scribbleDidStart)])
                [self.scribbleDelegate scribbleDidStart];
        }
    }
    else {
        NSLog(@"ended scribb, object not found in scrib show view!\n");
    }
    [self setNeedsDisplay];
}

- (void) cancelTouchPoint:(CGPoint)point forTouch:(UITouch *)touch AndEvent:(UIEvent *) event {
	NSLog(@"Cancelled touch with point X=%.2f and y=%.2f \n", point.x, point.y);
}

#pragma mark - Get Finished Scribbles

-(NSArray*) getFinishedScribbles {
    return [NSArray arrayWithArray:self.finishedScribbles];
}

-(void) changeColorOfScribbleTo:(UIColor*)someColor {
    if (!someColor) {
        someColor=[UIColor lightGrayColor];
    }
    [self setNeedsDisplay];
}

#pragma mark - Scribble Processor Delegate

- (void) didPassOnTouch:(UITouch *) touch withEvent:(UIEvent *) event
{
    if(!self) return;
    CGPoint tPt = [touch locationInView: self];
    if (!(CGRectContainsPoint(self.bounds, tPt))) { return; }
    
    if (UITouchPhaseBegan == touch.phase) {
        [self addTouchPoint:tPt forTouch:touch AndEvent:event];
    }
    if (UITouchPhaseMoved == touch.phase) {
        [self appendTouchPoint:tPt forTouch:touch AndEvent:event];
    }
    if (UITouchPhaseEnded == touch.phase) {
        [self endTouchPoint:tPt forTouch:touch AndEvent:event];
    }
    if (UITouchPhaseCancelled == touch.phase) {
        [self cancelTouchPoint:tPt forTouch:touch AndEvent:event];
    }
}

@end
