//
//  Scribble.m
//  CrashHandler
//
//  Created by Mani on 4/3/14.
//  Copyright (c) 2014 mani. All rights reserved.
//

#import "Scribble.h"
#import "ScribblePathPoint.h"

@interface Scribble ()

@property (nonatomic) CGPoint currentPoint,previousPoint1,previousPoint2;
@property (nonatomic) BOOL isEmpty;
@property (nonatomic) CGMutablePathRef path;

@property (nonatomic, strong) NSMutableArray *points;

@end

@implementation Scribble

#pragma mark - Scribble Initilization 

- (id)init
{
    if (self = [super init])
    {
        self.points = [[NSMutableArray alloc] init];
        self.strokeColor = [UIColor blackColor] ;
        self.isEraseOn = NO;
        self.path = CGPathCreateMutable();
        self.isEmpty = YES;
    }
    return self;
}

#pragma mark - Scribble points

CGPoint getMidPoint(CGPoint p1, CGPoint p2) {
    return CGPointMake((p1.x + p2.x) * 0.5, (p1.y + p2.y) * 0.5);
}

- (NSMutableArray*)getPoints
{
    return self.points;
}

#pragma mark - Add point to scribble

-(CGRect)updatePointToPath:(CGPoint)point
{
    self.isEmpty = NO;
    if (self.points.count == 1) {
        self.previousPoint2 = self.previousPoint1 = self.currentPoint = [self getPointAtIndex:self.points.count - 1];
    }
    else if(self.points.count == 2){
        self.previousPoint2 = self.previousPoint1 =[self getPointAtIndex:self.points.count - 2];
        self.currentPoint = [self getPointAtIndex:self.points.count - 1];
    }
    else if(self.points.count > 2){
        self.previousPoint2 = [self getPointAtIndex:self.points.count - 3];
        self.previousPoint1 = [self getPointAtIndex:self.points.count - 2];
        self.currentPoint = [self getPointAtIndex:self.points.count - 1];
    }
    
    CGPoint mid1 = getMidPoint(self.previousPoint1, self.previousPoint2);
    CGPoint mid2 = getMidPoint(self.currentPoint,self.previousPoint1);
	CGMutablePathRef subpath = CGPathCreateMutable();
    CGPathMoveToPoint(subpath, NULL, mid1.x, mid1.y);
    CGPathAddQuadCurveToPoint(subpath, NULL, self.previousPoint1.x, self.previousPoint1.y, mid2.x, mid2.y);
    CGRect bounds = CGPathGetBoundingBox(subpath);
	CGPathAddPath(self.path, NULL, subpath);
	CGPathRelease(subpath);
    CGRect drawBox = bounds;
    drawBox.origin.x -= self.lineWidth * 2.0;
    drawBox.origin.y -= self.lineWidth * 2.0;
    drawBox.size.width += self.lineWidth * 4.0;
    drawBox.size.height += self.lineWidth * 4.0;
    return drawBox;
}

- (CGRect)addPoint:(CGPoint)point
{
    ScribblePathPoint *newPoint = [[ScribblePathPoint alloc] init];
    newPoint.point=point;
    [self.points addObject:newPoint];
    return [self updatePointToPath:point];
}

#pragma mark - Get point At touch Index

- (CGPoint) getPointAtIndex:(NSUInteger)index
{
	CGPoint thePoint=CGPointZero;
	@try {
        ScribblePathPoint *point = [self.points objectAtIndex:index];
        thePoint = point.point;
	}
	@catch (NSException * e) {
        @throw e;
	}
	return thePoint;
}

#pragma mark - Scribble Path

- (CGMutablePathRef)drawingPath{
    if (self.isEmpty || !self.path) {
        self.path = CGPathCreateMutable();
        self.isEmpty = NO;
        [self recalculatePath];
    }
    return self.path;
}

#pragma mark - Recalcualte Path

- (void) recalculatePath{
    for (int i = 0; i < self.points.count; i++) {
        if (i == 0) {
            self.previousPoint2 = self.previousPoint1 = self.currentPoint = [self getPointAtIndex:i];
        }
        else if(i == 1){
            self.previousPoint2 = self.previousPoint1 = [self getPointAtIndex:i - 1];
            self.currentPoint = [self getPointAtIndex:i];
        }
        else if(i >= 2){
            self.previousPoint2 = [self getPointAtIndex:i - 2];
            self.previousPoint1 = [self getPointAtIndex:i - 1];
            self.currentPoint = [self getPointAtIndex:i];
        }
        CGPoint mid1 = getMidPoint(self.previousPoint1, self.previousPoint2);
        CGPoint mid2 = getMidPoint(self.currentPoint, self.previousPoint1);
        CGMutablePathRef subpath = CGPathCreateMutable();
        CGPathMoveToPoint(subpath, NULL, mid1.x, mid1.y);
        CGPathAddQuadCurveToPoint(subpath, NULL, self.previousPoint1.x, self.previousPoint1.y, mid2.x, mid2.y);
        CGPathAddPath(self.path, NULL, subpath);
        CGPathRelease(subpath);
    }
}

#pragma mark - Getting top most point of scribble

- (CGRect) enclosingRect {
    return CGPathGetBoundingBox(self.path);
}

- (CGPoint)topMostPoint{
    return [self enclosingRect].origin;
}

@end
