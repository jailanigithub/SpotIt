//
//  TextView.m
//  FinalSnapControl
//
//  Created by aram on 4/8/14.
//  Copyright (c) 2014 mani. All rights reserved.
//

#import "TextView.h"

static const NSInteger kDeleteControlHeight = 30;
static const NSInteger kDeleteControlWidth  = 200;

static const NSInteger kCommendLabelWidth     = 300;
static const NSInteger kCommendlabelHeight    = 15;
static const NSInteger kCommendlabelFontSize  = 12;

static const NSInteger kAccessoryLabelWidth     = 180;
static const NSInteger kAccessoryLabelHeight    = 30;

static const NSString* kDeleteControlTitle    = @"Remove X";

@interface TextView()

@property(nonatomic, strong) UITextField *textField;
@property(nonatomic, strong) UILabel *deleteControl, *accessoryLabel;
@property(nonatomic) CGPoint textFieldTouchPoint;
@end

@implementation TextView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        //Initialization code
        [self setBackgroundColor:[UIColor clearColor]];
        [self addTapgestureRecognizerToBackgrndView];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(handleTextFieldChanged:)
                                                     name:UITextFieldTextDidChangeNotification
                                                   object:nil];
    }
    return self;
}

#pragma mark tapgesture recognizer
-(void)addTapgestureRecognizerToBackgrndView
{
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(backgrndViewTapped:)];
    [tapGesture setNumberOfTapsRequired:1];
    [self addGestureRecognizer:tapGesture];
}

-(void)backgrndViewTapped:(UIGestureRecognizer*)gesture
{
    NSLog(@"back ground view tapped");
    CGPoint touchPoint = [gesture  locationInView:gesture.view];
    self.textFieldTouchPoint = touchPoint;
    [self addTextFieldToPoint:touchPoint withText:@""];
    [self resetAccessoryTextField];
}

#pragma mark reset accessory textfield
-(void)resetAccessoryTextField
{
    [self.accessoryLabel setText:@"|"];
    [self.textField setText:@""];
}

#pragma Command labels related methods
-(void)addTapGesture:(UILabel*)label
{
    UITapGestureRecognizer *tapGes = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(commandLabelTapped:)];
    [tapGes setNumberOfTapsRequired:1];
    [label addGestureRecognizer:tapGes];
}

-(void)commandLabelTapped:(UITapGestureRecognizer*)tapGes
{
    UILabel *label = (UILabel*)tapGes.view;
    NSLog(@"Command label tapped %@", label.text);
    CGPoint touchPoint = [tapGes locationInView:self];
    self.textFieldTouchPoint = touchPoint;
    [tapGes.view removeFromSuperview];
    [self addTextFieldToPoint:touchPoint withText:label.text];
}

#pragma add textControl
-(void)addTextFieldToPoint:(CGPoint)point withText:(NSString*)text
{
    CGRect frame = self.textField.frame;
    [self.textField setText:text];
    [self.accessoryLabel setText:[NSString stringWithFormat:@"%@|", text]];
    [self addSubview:self.textField];
    [self.textField setFrame:CGRectMake(point.x, point.y, frame.size.width, frame.size.height)];
    [self.textField becomeFirstResponder];
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    return YES;
}

#pragma mark create textControl
-(UITextField*)textField
{
    if(!_textField)
    {
        _textField = [[UITextField alloc]init];
        
        [_textField setFrame:CGRectMake(10, 150, 150, 25)];
        [_textField setBackgroundColor:[UIColor whiteColor]];
        [_textField setFont:[UIFont systemFontOfSize:11.0]];
        
        [_textField setBorderStyle:UITextBorderStyleBezel];
        [_textField setDelegate:self];
        [self.textField setHidden:YES];
        
        [_textField setAutocorrectionType:UITextAutocorrectionTypeNo];
        
        [self addInputAccessoryView:_textField];
    }
    return _textField;
}

#pragma mark accessory textfield
-(UILabel*)accessoryLabel
{
    if(!_accessoryLabel)
    {
        _accessoryLabel = [[UILabel alloc]initWithFrame:CGRectMake(50, 5, kAccessoryLabelWidth, kAccessoryLabelHeight)];
        [_accessoryLabel setBackgroundColor:[UIColor whiteColor]];
        [_accessoryLabel.layer setCornerRadius:4.0];
        [_accessoryLabel setText:@"|"];
    }
    return _accessoryLabel;
}

#pragma Resign responders
-(void)removeFirstResponders
{
    [self.textField resignFirstResponder];
}

#pragma mark Pan gesture related functions
-(void)addPanGestureRecognizer:(UILabel*)label
{
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(panning:)];
    [label addGestureRecognizer:panGesture];
}

-(void)panning:(UIPanGestureRecognizer*)gesture
{
    CGPoint translation = [gesture translationInView:self];
    gesture.view.center = CGPointMake(gesture.view.center.x + translation.x,
                                      gesture.view.center.y + translation.y);
    [gesture setTranslation:CGPointMake(0, 0) inView:self];
    
    if(gesture.state == UIGestureRecognizerStateBegan)
    {
        NSLog(@"Panning started");
        [self addTextFieldDeleteTool];
        [self removeFirstResponders];
    }
    else if (gesture.state == UIGestureRecognizerStateChanged)
    {
        //        NSLog(@"Panning continuous");
    }
    else if (gesture.state == UIGestureRecognizerStateEnded)
    {
        NSLog(@"Panning ended");
        if(CGRectIntersectsRect(self.deleteControl.frame, gesture.view.frame))
        {
            NSLog(@"Command label Intersects delete control");
            [gesture.view removeFromSuperview];
        }
        else
        {
            NSLog(@"Command label doesn't intersects delete control");
        }
        [self removeDeleteControlFromSuperView];
    }
}

#pragma mark add inputAccessory view
-(void)addInputAccessoryView:(UITextField*)textField
{
    UIToolbar *keyboardToolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width, 44)];
    keyboardToolbar.barStyle = UIBarStyleBlackTranslucent;
    keyboardToolbar.tintColor = [UIColor darkGrayColor];
    
    UIBarButtonItem* previousButton = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStyleBordered target:self action:@selector(textFieldCancelled:)];
    [previousButton setTintColor:[UIColor blackColor]];
    
    UIBarButtonItem* doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(donePressed:)];
    [doneButton setTintColor:[UIColor blackColor]];
    
    UIBarButtonItem *textFieldItem = [[UIBarButtonItem alloc] initWithCustomView:self.accessoryLabel];
                                      
    [keyboardToolbar setItems:[NSArray arrayWithObjects: previousButton, textFieldItem, doneButton, nil] animated:NO];
    
    [textField setInputAccessoryView:keyboardToolbar];
}

-(void)textFieldCancelled:(id)sender
{
    [self removeFirstResponders];
    [self removetextFieldFromSuperView];
}

-(void)donePressed:(id)sender
{
    [self removeFirstResponders];
    [self addCommandLabel];
}

#pragma mark command label related function
-(void)addCommandLabel
{
    if(!self.textField.text || [@"" isEqualToString:self.textField.text])
        return;
    
    UILabel *commandLabel = [[UILabel alloc]initWithFrame:CGRectMake(self.textFieldTouchPoint.x, self.textFieldTouchPoint.y, kCommendLabelWidth, kCommendlabelHeight)];
    
    [self addTapGesture:commandLabel];
    [self addPanGestureRecognizer:commandLabel];
    [self setAttributeCommendlabel:commandLabel];

    [commandLabel setUserInteractionEnabled:YES];
    [commandLabel setText:self.textField.text];

    [self removetextFieldFromSuperView];
    [self addSubview:commandLabel];
}

-(void)setAttributeCommendlabel:(UILabel*)label
{
    [label setFont: [UIFont systemFontOfSize:kCommendlabelFontSize]];
    [label setTextColor:(self.textColor) ? self.textColor : [UIColor redColor]];
    [label setBackgroundColor:[UIColor clearColor]];
    [label setTextAlignment:NSTextAlignmentLeft];
}

-(void)resetCommandlabel
{
    for (UIView *subView in self.subviews)
    {
        if([subView isKindOfClass:[UILabel class]])
        {
            [subView removeFromSuperview];
        }
    }
}

#pragma remove textControl
-(void)removetextFieldFromSuperView
{
    [self resetAccessoryTextField];
    [self.textField removeFromSuperview];
}

#pragma mark create deleteControl
-(UILabel*)deleteControl
{
    if(!_deleteControl)
    {
        _deleteControl = [[UILabel alloc]initWithFrame:CGRectMake(self.frame.size.width/2 - (kDeleteControlWidth/2), self.frame.size.height - kDeleteControlHeight + 5, kDeleteControlWidth, kDeleteControlHeight)];
        [_deleteControl.layer setCornerRadius:5.0];
        [_deleteControl setBackgroundColor:[UIColor redColor]];
        [_deleteControl setAlpha:0.3];
        [_deleteControl setTextColor:[UIColor whiteColor]];
        [_deleteControl setTextAlignment:NSTextAlignmentCenter];
        [_deleteControl setText:(NSString*)kDeleteControlTitle];
    }
    return _deleteControl;
}

#pragma mark add delete control
-(void)addTextFieldDeleteTool
{
    [self addSubview:self.deleteControl];
}

#pragma mark remove delete control
-(void)removeDeleteControlFromSuperView
{
    [self.deleteControl removeFromSuperview];
}

#pragma mark text field delegate
-(void)handleTextFieldChanged:(NSNotification*)notification
{
//    NSLog(@"+++Did text field change notification called %@+++", self.textField.text);
   [self.accessoryLabel setText:[NSString stringWithFormat:@"%@|", self.textField.text]];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
