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
#import "TextView.h"
#import "ScreenShotControl.h"

@interface SnapshotView ()

@property (nonatomic,strong) ScribbleEraseView *scribbleView;
@property (nonatomic,strong) ColorPickerView *colorPickerView;
@property (nonatomic, strong) TextView *textView;
@property (nonatomic, strong) UIView *noSelectionView;
@property (nonatomic, strong) UIButton *closeBtn;

@end

@implementation SnapshotView

#pragma mark - Shared Handle.

-(void)addCloseButton
{
    self.closeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.closeBtn.frame = CGRectMake(280, 20, 25, 25);
    [self.closeBtn addTarget:[ScreenShotControl sharedHandler] action:@selector(closeButtonFired:) forControlEvents:UIControlEventTouchUpInside];
    self.closeBtn.backgroundColor = [UIColor lightGrayColor];
    [self.closeBtn setTitle:@"X" forState:UIControlStateNormal];
    [self.closeBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.closeBtn.layer.cornerRadius = self.closeBtn.frame.size.width/2;
    self.closeBtn.layer.borderWidth = 0.8f;
    self.closeBtn.layer.borderColor = [UIColor blackColor].CGColor;
    [self addSubview:self.closeBtn];
}

-(void)getCloseButtonToFront
{
    [self bringSubviewToFront:self.closeBtn];
}

-(void)sendCloseButtonToBack
{
    [self sendSubviewToBack:self.closeBtn];
}

+(SnapshotView*)sharedHandler
{
    static dispatch_once_t predicate = 0;
    static SnapshotView *sharedInstance = nil;
    
    dispatch_once(&predicate, ^{
        sharedInstance = [[self alloc] init];
        sharedInstance.frame = [[UIScreen mainScreen] bounds];
        [sharedInstance addCloseButton];
    });
    return sharedInstance;
}

#pragma mark - Assign Image to snap button

-(void)assignBackgroundColorWithImage:(UIImage*)image
{
    self.backgroundColor = [UIColor colorWithPatternImage:image];
}

#pragma mark - Add Scribble Control to Base View

-(BOOL)isScribbleViewCreated
{
    if (!self.scribbleView)
    {
        self.scribbleView = [[ScribbleEraseView alloc] initWithFrame:self.frame];
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
    [self removeColorPickerFromSnapView];
    [self insertSubview:self.colorPickerView aboveSubview:[MovableEditorView customView]];
    [self getCloseButtonToFront];
    [self setNeedsDisplay];
}

-(void)doneButtonFired:(UIButton*)doneBtn
{
    [self.colorPickerView removeFromSuperview];
    self.scribbleView.currentScribbleStrokeColor = [self.colorPickerView getCurrentSelectedColor];
    self.textView.textColor = [self.colorPickerView getCurrentSelectedColor];
    [self bringSubviewToFront:[MovableEditorView customView]];
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
-(TextView*)textView
{
    if(!_textView)
    {
        CGRect frame = [[UIScreen mainScreen] bounds];
        _textView = [[TextView alloc]initWithFrame:CGRectMake(frame.origin.x, frame.origin.y, frame.size.width, frame.size.height)];
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

-(void)removeFromWindow
{
    [self removeFromSuperview];
    [self.scribbleView resetView];
    [self.textView resetCommandlabel];
    [self removeTextViewFromSnapView];
    [self removeColorPickerFromSnapView];
    [[MovableEditorView customView] resetRecordingControl];
}
@end
