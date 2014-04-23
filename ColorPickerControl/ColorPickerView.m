//
//  ColorPickerView.m
//  CrashHandler
//
//  Created by Mani on 4/5/14.
//  Copyright (c) 2014 mani. All rights reserved.
//

#import "ColorPickerView.h"
NSString const *ColorPickerPanel = @"colorPicker.png";

typedef void(^RGBCompletionBlcok)(CGFloat rValue,CGFloat gValue,CGFloat bValue,UIColor *currentColor);

@interface ColorPickerView()

@property (nonatomic,copy) RGBCompletionBlcok completionBlock;
@property (nonatomic,strong) UIColor *currentSelectedColor;

@end

@implementation ColorPickerView

#pragma mark - Hide Done button (iPad only)

-(void)hideDoneButton
{
    self.doneBtn.hidden = YES;
}

#pragma mark - Get Selected Color

-(UIColor*)getCurrentSelectedColor
{
    return self.currentSelectedColor;
}

#pragma mark - Initial Color Selection

- (void)awakeFromNib
{
    self.baseColorView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:(NSString*)ColorPickerPanel]];
    self.pickerKnob.layer.cornerRadius =  self.pickerKnob.frame.size.width/2;
    self.pickerKnob.layer.borderColor = [UIColor whiteColor].CGColor;
    self.pickerKnob.layer.borderWidth = 2.0f;
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(panning:)];
    [self.pickerKnob addGestureRecognizer:panGesture];
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestureFired:)];
    [self.baseColorView addGestureRecognizer:tapGesture];
    
    __weak typeof(self) weak_self = self;
    self.completionBlock = ^(CGFloat rValue,CGFloat gValue,CGFloat bValue,UIColor *currentColor){
        weak_self.redValue.text = [NSString stringWithFormat:@"%d",(NSInteger)(rValue * 255)];
        weak_self.greenValue.text = [NSString stringWithFormat:@"%d",(NSInteger)(gValue * 255)];
        weak_self.blackValue.text = [NSString stringWithFormat:@"%d",(NSInteger)(bValue * 255)];
        weak_self.pickedColor.backgroundColor = currentColor;
        weak_self.currentSelectedColor = currentColor;
    };
    [self getRGBAsFromImage:[UIImage imageNamed:(NSString*)ColorPickerPanel] atX:self.pickerKnob.center.x andY:self.pickerKnob.center.y withCompletionBlock:self.completionBlock];
}

#pragma mark - Panning handle method

-(void)panning:(UIPanGestureRecognizer*)gesture
{
    CGPoint currentTouchPoint = [gesture locationInView:self];
    if (![self isTouchEventHappenedInsideBase:currentTouchPoint])
        return;
    CGPoint translation = [gesture translationInView:self];
    gesture.view.center = CGPointMake(gesture.view.center.x + translation.x,
                                      gesture.view.center.y + translation.y);
    [gesture setTranslation:CGPointMake(self.frame.origin.x, self.frame.origin.y) inView:self];
    [self getRGBAsFromImage:[UIImage imageNamed:(NSString*)ColorPickerPanel] atX:currentTouchPoint.x-self.baseColorView.frame.origin.x andY:currentTouchPoint.y-self.baseColorView.frame.origin.y withCompletionBlock:self.completionBlock];
}

#pragma mark - Tapping handle method

-(void)tapGestureFired:(UITapGestureRecognizer*)gesture
{
    CGPoint touchPoint = [gesture locationInView:self.baseColorView];
    self.pickerKnob.center = touchPoint;
    [self getRGBAsFromImage:[UIImage imageNamed:(NSString*)ColorPickerPanel] atX:touchPoint.x andY:touchPoint.y withCompletionBlock:self.completionBlock];
}

#pragma mark - Check Panning happen Inside Color picker panel

-(BOOL)isTouchEventHappenedInsideBase:(CGPoint)currentTouchPoint
{
    if (currentTouchPoint.x > self.baseColorView.frame.origin.x + self.baseColorView.frame.size.width)
        return NO;
    else if (currentTouchPoint.x <= self.baseColorView.frame.origin.x)
        return NO;
    if (currentTouchPoint.y >= self.baseColorView.frame.origin.y + self.baseColorView.frame.size.height)
        return NO;
    else if (currentTouchPoint.y <= self.baseColorView.frame.origin.y)
        return NO;
    return YES;
}

#pragma mark Getting RGB From corresponding pixel point

- (void)getRGBAsFromImage:(UIImage*)image atX:(int)xx andY:(int)yy withCompletionBlock:(RGBCompletionBlcok)completionBlock
{
    CGImageRef imageRef = [image CGImage];
    NSUInteger width = CGImageGetWidth(imageRef);
    NSUInteger height = CGImageGetHeight(imageRef);
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    unsigned char *rawData = (unsigned char*) calloc(height * width * 4, sizeof(unsigned char));
    NSUInteger bytesPerPixel = 4;
    NSUInteger bytesPerRow = bytesPerPixel * width;
    NSUInteger bitsPerComponent = 8;
    CGContextRef context = CGBitmapContextCreate(rawData, width, height,
                                                 bitsPerComponent, bytesPerRow, colorSpace,
                                                 kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    CGColorSpaceRelease(colorSpace);
    CGContextDrawImage(context, CGRectMake(0, 0, width, height), imageRef);
    CGContextRelease(context);
    int byteIndex = (bytesPerRow * yy) + xx * bytesPerPixel;
    CGFloat red   = (rawData[byteIndex]     * 1.0) / 255.0;
    CGFloat green = (rawData[byteIndex + 1] * 1.0) / 255.0;
    CGFloat blue  = (rawData[byteIndex + 2] * 1.0) / 255.0;
    CGFloat alpha = (rawData[byteIndex + 3] * 1.0) / 255.0;
    byteIndex += 4;
    UIColor *acolor = [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
    free(rawData);
    if (completionBlock)
        completionBlock(red,green,blue,acolor);
}


@end
