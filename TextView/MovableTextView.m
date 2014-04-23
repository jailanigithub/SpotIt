//
//  TextView.m
//  FinalSnapControl
//
//  Created by aram on 4/8/14.
//  Copyright (c) 2014 mani. All rights reserved.
//

#import "MovableTextView.h"
#import "UILabel+UILabelDynamicHeight.h"
#import "CommonMacro.h"
#import "SnapshotView.h"

static const NSInteger kDeleteControlHeight = 50;
static const NSInteger kDeleteControlWidth  = 200;

static const NSInteger kCommendLabelWidth     = 200;
static const NSInteger kCommendlabelHeight    = 15;
static const NSInteger kCommendlabelFontSize  = 15;

static const NSInteger kAccessoryLabelHeight    = 30;

static const NSString* kTrashIconImage    = @"trash_icon";
static const NSString* kCursor            = @"|";

@interface MovableTextView()

@property(nonatomic, strong) UITextField *textField;
@property(nonatomic, strong) UILabel *deleteControl, *accessoryLabel;
@property(nonatomic) CGPoint textFieldTouchPoint;
@end

@implementation MovableTextView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        //Initialization code
        [self setBackgroundColor:[UIColor clearColor]];
        [self setUserInteractionEnabled:YES];
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

#pragma mark reset accessory textfield(Label)
-(void)resetAccessoryTextField
{
    [self.accessoryLabel setText:(NSString*)kCursor];
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

-(CGRect)getFrame:(UIToolbar*)myToolbar forbarbutton:(UIBarButtonItem*)itemToExclude
{
    
    CGFloat totalItemsWidth = 0.0;
    for (UIBarButtonItem *barButtonItem in myToolbar.items) {
        if (barButtonItem != itemToExclude)
        {
            // Get width of bar button item (hack from other SO question)
            UIView *view = [barButtonItem valueForKey:@"view"];
            CGFloat width = view ? [view frame].size.width : (CGFloat)0.0;
            
            totalItemsWidth += width;
        }
    }
    
    return CGRectMake(0, 5, (myToolbar.frame.size.width - totalItemsWidth), kAccessoryLabelHeight);
}

-(UILabel*)accessoryLabel
{
    if(!_accessoryLabel)
    {
        _accessoryLabel = [[UILabel alloc]init];
        [_accessoryLabel setBackgroundColor:[UIColor whiteColor]];
        
        [_accessoryLabel setLineBreakMode:NSLineBreakByTruncatingHead];
        [_accessoryLabel.layer setCornerRadius:4.0];
        [_accessoryLabel setText:(NSString*)kCursor];
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

-(BOOL)isInsideOfFrame:(UIPanGestureRecognizer*)gesture
{
    CGPoint translation = [gesture translationInView:self];
    
    if(gesture.view.frame.origin.x + translation.x <= 0)
        return NO;

    if(gesture.view.frame.origin.y + translation.y <= 0)
        return NO;

    if(gesture.view.frame.origin.x + gesture.view.frame.size.width + translation.x >= self.frame.size.width)
        return NO;
    
    if(gesture.view.frame.origin.y + gesture.view.frame.size.height + translation.y >= self.frame.size.height)
        return NO;
    
    return YES;
}

-(void)panning:(UIPanGestureRecognizer*)gesture
{
    if (![self isInsideOfFrame:gesture])
    {
        if(CGRectIntersectsRect(self.deleteControl.frame, gesture.view.frame))
            [gesture.view removeFromSuperview];
        [self removeDeleteControlFromSuperView];
        return;
    }
    
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
    else if (gesture.state == UIGestureRecognizerStateEnded)
    {
        if(CGRectIntersectsRect(self.deleteControl.frame, gesture.view.frame))
            [gesture.view removeFromSuperview];
        [self removeDeleteControlFromSuperView];
    }
}

#pragma mark add inputAccessory view
-(void)addInputAccessoryView:(UITextField*)textField
{
    UIToolbar *keyboardToolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width, 44)];
    keyboardToolbar.barStyle = UIBarStyleBlackTranslucent;

    
    if(SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0"))
    {
        [keyboardToolbar setBarTintColor:[UIColor darkGrayColor]];
    }
    else
    {
        [keyboardToolbar setTintColor:[UIColor darkGrayColor]];
    }
    
    UIBarButtonItem* previousButton = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStyleBordered target:self action:@selector(textFieldCancelled:)];
    [previousButton setTintColor:[UIColor blackColor]];
    
    UIBarButtonItem* doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(donePressed:)];
    [doneButton setTintColor:[UIColor blackColor]];
    
    UIBarButtonItem *textFieldItem = [[UIBarButtonItem alloc] initWithCustomView:self.accessoryLabel];
    
    [keyboardToolbar setItems:[NSArray arrayWithObjects: previousButton, textFieldItem, doneButton, nil] animated:NO];
    
    self.accessoryLabel.frame =  [self getFrame:keyboardToolbar forbarbutton:textFieldItem];
    
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
-(CGFloat)getCommandLabelWidth
{
    NSLog(@"Command label width %f", self.frame.size.width*75/100);
    return self.frame.size.width*75/100;
}

-(void)addCommandLabel
{
    if(!self.textField.text || [@"" isEqualToString:self.textField.text])
        return;
    
    UILabel *commandLabel = [[UILabel alloc]initWithFrame:CGRectMake(self.textFieldTouchPoint.x, self.textFieldTouchPoint.y, [self getCommandLabelWidth], kCommendlabelHeight)];

    [commandLabel setUserInteractionEnabled:YES];
    [commandLabel setText:self.textField.text];
    [commandLabel adjustFrameSize];
    
    [self addTapGesture:commandLabel];
    [self addPanGestureRecognizer:commandLabel];
    [self setAttributeCommendlabel:commandLabel];

    [self removetextFieldFromSuperView];
    [commandLabel setCenter:CGPointMake(self.textFieldTouchPoint.x, self.textFieldTouchPoint.y)];
    [self addSubview:commandLabel];
}

-(void)setAttributeCommendlabel:(UILabel*)label
{
    [label setFont: [UIFont systemFontOfSize:kCommendlabelFontSize]];
    [label setTextColor:(self.textColor) ? self.textColor : [UIColor redColor]];
    [label setBackgroundColor:[UIColor clearColor]];
    [label setTextAlignment:NSTextAlignmentCenter];
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

-(CGFloat)getDeleteControlWidth
{
    return [SnapshotView sharedHandler].frame.size.width;
}

-(UILabel*)deleteControl
{
    if(!_deleteControl)
    {
        _deleteControl = [[UILabel alloc]initWithFrame:CGRectMake(self.frame.size.width/2 - [self getDeleteControlWidth]/2, self.frame.size.height - (kDeleteControlHeight*1.0),  [self getDeleteControlWidth], kDeleteControlHeight)];
        [_deleteControl.layer setCornerRadius:5.0];
        [_deleteControl setBackgroundColor:[UIColor redColor]];
        [_deleteControl setAlpha:0.6];
         UIImageView *trashIcon = [[UIImageView alloc]initWithImage:[UIImage imageNamed:(NSString*)kTrashIconImage]];
        [trashIcon setCenter:CGPointMake( _deleteControl.frame.size.width/2, _deleteControl.frame.size.height/2)];
        [_deleteControl addSubview:trashIcon];
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
   [self.accessoryLabel setText:[NSString stringWithFormat:@"%@|", self.textField.text]];
}

@end
