//
//  Scribble.h
//  CrashHandler
//
//  Created by Mani on 4/3/14.
//  Copyright (c) 2014 mani. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Scribble : NSObject

@property (nonatomic,strong) UIColor* strokeColor;
@property (assign) float lineWidth;
@property (assign) BOOL isEraseOn;
@property (readonly) CGPoint topMostPoint;

-(CGMutablePathRef)drawingPath;
- (CGRect) addPoint:(CGPoint)point; 
- (CGPoint) getPointAtIndex:(NSUInteger)index;

- (NSMutableArray*)getPoints;

@end
