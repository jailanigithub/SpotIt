//
//  SnapshotView.m
//  CommonConfirmation
//
//  Created by Mani on 4/4/14.
//
//

#import "SnapshotView.h"
#import "ScribCapControl.h"
#import "ScribbleEraseView.h"
#import "ColorPickerView.h"
#import "MovableEditorView.h"
#import "MovableTextView.h"
#import "ScreenShotControl.h"
#import "CommonMacro.h"

enum{
    eBorderEdgeInsetTop = 40,
    eBorderEdgeInsetBottom = 10,
    eBorderEdgeInsetLeftRight = 20
}BorderEdgeInset;

CGFloat const CloseButtonSize = 30;
CGFloat const TitleLabelOriginY = 20;
CGFloat const TitleLabelHeight = 20;

@interface SnapshotView ()<UIPopoverControllerDelegate>

@property (nonatomic,strong) ScribbleEraseView *scribbleView;
@property (nonatomic,strong) ColorPickerView *colorPickerView;
@property (nonatomic, strong) MovableTextView *textView;
@property (nonatomic, strong) UIView *noSelectionView;
@property (nonatomic, strong) UIButton *closeBtn;
@property (nonatomic, strong) UIView *baseView;
@property (nonatomic,strong) UIPopoverController *colorPickerPopover;

@end

@implementation SnapshotView

#pragma mark - Shared Handle.

-(void)addCloseButton
{
    self.closeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.closeBtn.frame = CGRectMake(self.baseView.frame.origin.x + self.baseView.frame.size.width - (2*eBorderEdgeInsetLeftRight), eBorderEdgeInsetTop/2, CloseButtonSize, CloseButtonSize);
    [self.closeBtn addTarget:[ScreenShotControl sharedHandler] action:@selector(closeButtonFired:) forControlEvents:UIControlEventTouchUpInside];
    [self.closeBtn setImage:[UIImage imageNamed:@"close.png"] forState:UIControlStateNormal];
    [self.baseView addSubview:self.closeBtn];
}

#pragma mark - Close Button Handle - Front & Back

-(void)getCloseButtonToFront
{
    [self bringSubviewToFront:self.closeBtn];
}

#pragma mark - Base View Frame Design

-(UIView*)getBaseView
{
    return self.baseView;
}

-(void)designBaseViewFrame
{
    self.layer.borderWidth = 0.8f;
    self.layer.borderColor = [UIColor blackColor].CGColor;
    self.clipsToBounds = YES;
    self.baseView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bg_transparent.png"]];
    UILabel *titleLbl = [[UILabel alloc] initWithFrame:CGRectMake(0, TitleLabelOriginY, self.baseView.frame.size.width, TitleLabelHeight)];
    titleLbl.text = @"Spotit";
    titleLbl.backgroundColor = [UIColor clearColor];
    titleLbl.textAlignment = NSTextAlignmentCenter;
    [self.baseView addSubview:titleLbl];
}

#pragma mark - Shared Handler

+(SnapshotView*)sharedHandler
{
    static dispatch_once_t predicate = 0;
    static SnapshotView *sharedInstance = nil;
    
    dispatch_once(&predicate, ^{
        sharedInstance = [[self alloc] init];
        sharedInstance.baseView = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
        sharedInstance.frame = CGRectMake(sharedInstance.baseView.frame.origin.x +eBorderEdgeInsetLeftRight, sharedInstance.baseView.frame.origin.y +eBorderEdgeInsetTop, sharedInstance.baseView.frame.size.width - (2*eBorderEdgeInsetLeftRight) , sharedInstance.baseView.frame.size.height - (eBorderEdgeInsetTop+eBorderEdgeInsetBottom) );
        [sharedInstance.baseView addSubview:sharedInstance];
        [sharedInstance designBaseViewFrame];
        [sharedInstance addCloseButton];
    });
    return sharedInstance;
}

#pragma mark - Assign Image to snap button

+ (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize {
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

-(void)assignBackgroundColorWithImage:(UIImage*)fillingImage
{
    UIImage *newImage = [SnapshotView imageWithImage:fillingImage scaledToSize:self.frame.size];
    self.backgroundColor = [UIColor colorWithPatternImage:newImage];
}

#pragma mark - Scribble Control to Base View

-(BOOL)isScribbleViewCreated
{
    if (!self.scribbleView)
    {
        self.scribbleView = [[ScribbleEraseView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
        self.scribbleView.backgroundColor = [UIColor clearColor];
    }
    return YES;
}

-(void)addScribbleControllToSnapView
{
    [self.textView removeFirstResponders];
    if (![self isScribbleViewCreated])
        return;
    [self removeScribbleControllFromSnapView];
    self.scribbleView.isEraseOn = NO;
    [self insertSubview:self.scribbleView belowSubview:[MovableEditorView customView]];
    [self getCloseButtonToFront];
    [self setNeedsDisplay];
}

-(void)removeScribbleControllFromSnapView
{
    [self.scribbleView removeFromSuperview];
}

#pragma mark - Eraser Control in Base View

-(void)addEraseControlToSnapView
{
    [self.textView removeFirstResponders];
    if (![self isScribbleViewCreated])
        return;
    [self removeEraserFromSnapView];
    self.scribbleView.isEraseOn = YES;
    [self insertSubview:self.scribbleView belowSubview:[MovableEditorView customView]];
    [self getCloseButtonToFront];
    [self setNeedsDisplay];
}

-(void)removeEraserFromSnapView
{
    [self.scribbleView removeFromSuperview];
}

#pragma mark - Color Picker Control in Snap View

-(void)removeColorPickerFromSnapView
{
    [self.colorPickerView removeFromSuperview];
}

-(void)colorPickerToSnapView
{
    NSLog(@"Adding Color picker Triggered");
    [self.textView removeFirstResponders];
    if (!self.colorPickerView)
    {
        NSArray* lcellArray = [[NSBundle mainBundle] loadNibNamed:@"ColorPickerView" owner:self options:nil];
        self.colorPickerView = (ColorPickerView *)[lcellArray objectAtIndex:0];
        [self.colorPickerView.doneBtn addTarget:self action:@selector(doneButtonFired:) forControlEvents:UIControlEventTouchUpInside];
    }
    if (IS_IPAD)
    {
        if (!self.colorPickerPopover)
        {
            [self.colorPickerView hideDoneButton];
            UIViewController *vC = [[UIViewController alloc]init];
            vC.view = self.colorPickerView;
            vC.view.frame = self.colorPickerView.frame;
            self.colorPickerPopover = [[UIPopoverController alloc]initWithContentViewController:vC];
            self.colorPickerPopover.delegate = self;
        }
        [self.colorPickerPopover presentPopoverFromRect:[MovableEditorView customView].frame inView:self permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    }
    else
    {
        [self removeColorPickerFromSnapView];
        [self insertSubview:self.colorPickerView aboveSubview:[MovableEditorView customView]];
        [self getCloseButtonToFront];
        [self setNeedsDisplay];
    }
}

#pragma mark - Popover Delegate

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{
    [self doneButtonFired:nil];
}

#pragma mark - Done Button Handle

-(void)doneButtonFired:(UIButton*)doneBtn
{
    if (IS_IPAD)
    {
        [self.colorPickerPopover dismissPopoverAnimated:YES];
    }
    else{
        [self.colorPickerView removeFromSuperview];
    }
    self.scribbleView.currentScribbleStrokeColor = [self.colorPickerView getCurrentSelectedColor];
    self.textView.textColor = [self.colorPickerView getCurrentSelectedColor];
    
    if (self.colorSelectedCompletionBlock)
        self.colorSelectedCompletionBlock();
}

#pragma mark - Movable Control Actions
-(void)addMovableControlToSnapView
{
    [self removeMovableControlFromSnapView];
    [self addSubview:[MovableEditorView customView]];
    [[MovableEditorView customView] defaultSelection];
}

-(void)removeMovableControlFromSnapView
{
    [[MovableEditorView customView] removeFromSuperview];
}

#pragma mark add TextView and remove
-(MovableTextView*)textView
{
    if(!_textView)
    {
        CGRect frame = self.frame;

        _textView = [[MovableTextView alloc]initWithFrame:CGRectMake(0.0, 0.0, frame.size.width, frame.size.height)];
    }
    return _textView;
}

-(void)addTextViewControlToSnapView
{
    [self.textView removeFirstResponders];
    [self removeTextViewFromSnapView];
    [self insertSubview:self.textView belowSubview:[MovableEditorView customView]];
    [self getCloseButtonToFront];
    [self setNeedsDisplay];
}

-(void)removeTextViewFromSnapView
{
    [self.textView removeFirstResponders];
    [self.textView removeFromSuperview];
}

#pragma mark add no selection view
-(UIView*)noSelectionView
{
    if(!_noSelectionView)
    {
        _noSelectionView = [[UIView alloc]initWithFrame:[[UIScreen mainScreen] bounds]];
        [_noSelectionView setBackgroundColor:[UIColor clearColor]];
    }
    return _noSelectionView;
}

-(void)addNoSelectionView
{
    [self.textView removeFirstResponders];
    [self insertSubview:self.noSelectionView belowSubview:[MovableEditorView customView]];
    [self getCloseButtonToFront];
}

-(void)removeNoSelectionView
{
    [self.noSelectionView removeFromSuperview];
}

-(void)closeButtonState:(BOOL)hidden
{
    [self.closeBtn setHidden:hidden];
}

#pragma mark - Remove Snap View from window

-(void)removeFromWindow
{
    [self.baseView removeFromSuperview];
    [self.scribbleView resetView];
    [self.textView resetCommandlabel];
    [self removeTextViewFromSnapView];
    [self removeColorPickerFromSnapView];
    [[MovableEditorView customView] resetRecordingControl];
}
@end
