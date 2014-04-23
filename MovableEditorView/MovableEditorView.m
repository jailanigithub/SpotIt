//
//  MovableEditorView.m
//  FinalSnapControl
//
//  Created by aram on 4/7/14.
//  Copyright (c) 2014 mani. All rights reserved.
//

#import "MovableEditorView.h"
#import "SnapshotView.h"
#import "AudioManager.h"
#import "FileManager.h"
#import "ScreenShotControl.h"

NSString *const SCRIBBLE_UNSELECTED_IMAGE   = @"scribble_unselected.png";
NSString *const SCRIBBLE_SELECTED_IMAGE     = @"scribble_selected.png";

NSString *const ERASE_SELECTED_IMAGE        = @"eraser_selected.png";
NSString *const ERASE_UNSELECTED_IMAGE      = @"eraser_unselected.png";

NSString *const TEXT_SELECTED_IMAGE         = @"text_selected";
NSString *const TEXT_UNSELECTED_IMAGE       = @"text_unselected.png";

NSString *const AUDIO_SELECTED_IMAGE        = @"audio_selected.png";
NSString *const AUDIO_UNSELECTED_IMAGE      = @"audio_unselected.png";

NSString *const COLOR_PICKER_SELECTED_IMAGE        = @"color_picker.png";
NSString *const COLOR_PICKER_UNSELECTED_IMAGE      = @"color_picker.png";

NSString *const EMAIL_SELECTED_IMAGE        = @"email_selected.png";
NSString *const EMAIL_UNSELECTED_IMAGE      = @"email_Unselected.png";

NSString *const RECORD_IMAGE    = @"record.png";
NSString *const STOP_IMAGE      = @"stop.png";
NSString *const PLAY_IMAGE      = @"play.png";

NSInteger const kMaxRecordingTime = 3; //in minutes

enum{
    SCRIBBLE_BTN_ID         = 100,
    ERASE_BTN_ID,
    TEXT_BTN_ID ,
    AUDIO_BTN_ID,
    COLOR_PICKER_BTN_ID,
    EMAIL_BTN_ID
};
typedef enum NSInteger MovableControlButtonId;


@interface MovableEditorView()

@property(nonatomic, weak) IBOutlet UIButton *scribbleBtn, *eraseBtn, *textBtn, *audioBtn, *colorPickerBtn, *emailBtn;

@property(nonatomic) NSInteger selectedBtnId, previouslySelectedBtnId;
@property(nonatomic) BOOL isRecordedAudioAvailable;

-(IBAction)scribblePressed:(id)sender;
-(IBAction)textPressed:(id)sender;

-(IBAction)erasePressed:(id)sender;
-(IBAction)audioPressed:(id)sender;

-(IBAction)colorPickerPressed:(id)sender;
-(IBAction)emailPressed:(id)sender;

@end

@implementation MovableEditorView

#pragma mark - Shared Control

+(MovableEditorView*)customView
{
    static dispatch_once_t predicate = 0;
    static MovableEditorView *sharedInstance = nil;
    
    dispatch_once(&predicate, ^{
        sharedInstance = [[[NSBundle mainBundle] loadNibNamed:@"MovableEditorView" owner:nil options:nil] lastObject];
        CGRect frame = [[UIScreen mainScreen] bounds];
        [sharedInstance setFrame:CGRectMake(frame.origin.x, frame.size.height/2, sharedInstance.frame.size.width, sharedInstance.frame.size.height)];
        
        [sharedInstance.layer setCornerRadius:5.0];
        [sharedInstance addPanGestureRecognizerToContainerView];
        
        [[AudioManager sharedAudioManager] assignTempFileName:[[FileManager sharedFileManager] getAudioFilePath]];
        [sharedInstance assignCompletionBlocksForAudioManager];
        [sharedInstance assignColorSelectedCompletionBlock];
    });
    return sharedInstance;
}

#pragma mark default scribble selection
-(void)defaultSelection
{
    [self scribblePressed:self.scribbleBtn];
}

#pragma mark reset recording and buttons
-(void)resetRecordingControl
{
    //Change reset recorder image if it is ready to play state
    [self resetRecorderImage];
    
    [self stopPlaying];
    [self stopRecording];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

#pragma Pan Gesture related function
-(void)addPanGestureRecognizerToContainerView
{
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(panningContainerView:)];
    [self addGestureRecognizer:panGesture];
}

-(BOOL)isInsideOfFrame:(UIPanGestureRecognizer*)gesture
{
    CGPoint translation = [gesture translationInView:self];
    
    CGRect gestureFrame = gesture.view.frame;
    CGRect movableFrame = self.frame;
    CGRect superFrame   = self.superview.frame;
    
    return ((gestureFrame.origin.y + movableFrame.size.height + translation.y >= superFrame.size.height) || (gestureFrame.origin.x + movableFrame.size.width + translation.x >= superFrame.size.width) || (gestureFrame.origin.x + translation.x <= 0) || (gestureFrame.origin.y + translation.y <= 0)) ? NO : YES;
    
    if(gestureFrame.origin.x + translation.x <= 0)
        return NO;

    if(gestureFrame.origin.y + translation.y <= 0)
        return NO;

    
    if(gestureFrame.origin.x + movableFrame.size.width + translation.x >= superFrame.size.width)
        return NO;

    if(gestureFrame.origin.y + movableFrame.size.height + translation.y >= superFrame.size.height)
        return NO;

    return YES;
}

-(void)panningContainerView:(UIPanGestureRecognizer*)gesture
{
    if(![self isInsideOfFrame:gesture])
        return;
    
    CGPoint translation = [gesture translationInView:self.superview];
    gesture.view.center = CGPointMake(gesture.view.center.x + translation.x,
                                      gesture.view.center.y + translation.y);
    [gesture setTranslation:CGPointMake(0, 0) inView:self.superview];
    
}

#pragma Save currently selected btn id to maintain state
-(void)setSelectedBtnId:(NSInteger)selectedBtnId
{

    _selectedBtnId = selectedBtnId;
    
    if(selectedBtnId == AUDIO_BTN_ID)
    {
        [self addNoButtonSelectedView];
    }
    else
    {
        [self stopRecording];
        [self stopPlaying];
        
        if (selectedBtnId == SCRIBBLE_BTN_ID)
        {
            [self addScribbleControllToView];
            [self setScribbleBtnSelectedImage];
        }
        
        else if (selectedBtnId == ERASE_BTN_ID)
        {
            [self addEraserToControl];
            [self setEraseBtnSelectedImage];
        }
        
        else if(selectedBtnId == TEXT_BTN_ID)
        {
            [self addtextViewControl];
            [self setTextBtnSelectedImage];
        }
        
        else if(selectedBtnId == COLOR_PICKER_BTN_ID)
        {
            [self addColorPickerToControl];
        }
        
        else if(selectedBtnId == EMAIL_BTN_ID)
        {
            [self setHidden:YES];
            [[SnapshotView sharedHandler] closeButtonState:YES];
            UIImage *image = [[ScreenShotControl sharedHandler] takeScreenShotImageForView:[SnapshotView sharedHandler]];
            [[SnapshotView sharedHandler] closeButtonState:NO];
            [self setHidden:NO];
            if(image)
            {
                if([[FileManager sharedFileManager] saveImage:image])
                    [self sendScreenShotAndAudio];
            }
            else
            {
                NSLog(@"Error: Failed to get screen shot ");
            }
        }
    }
}

#pragma send screen shot
-(void)sendScreenShotAndAudio
{
    [[ScreenShotControl sharedHandler] sendScreenShotView];
}

#pragma mark - No button seleted view to base view
-(void)addNoButtonSelectedView
{
    [[SnapshotView sharedHandler] addNoSelectionView];
}

#pragma mark - Add Color picker control to base view
-(void)addColorPickerToControl
{
    [[SnapshotView sharedHandler] colorPickerToSnapView];
}

#pragma mark - Add Scribble Control to Base View
-(void)addScribbleControllToView
{
    [[SnapshotView sharedHandler] addScribbleControllToSnapView];
}

-(void)removeScribbleControllToView
{
    [[SnapshotView sharedHandler] removeEraserFromSnapView];
}

#pragma mark - Add Eraser Control to Base View
-(void)addEraserToControl
{
    [[SnapshotView sharedHandler] addEraseControlToSnapView];
}

#pragma mark - Add Text view Control to Base View
-(void)addtextViewControl
{
    [[SnapshotView sharedHandler] addTextViewControlToSnapView];
}

#pragma mark scribble button related functions
-(void)setScribbleBtnSelectedImage
{
    [self.scribbleBtn setBackgroundImage:[UIImage imageNamed:SCRIBBLE_SELECTED_IMAGE] forState:UIControlStateNormal];
}

-(void)setScribbleBtnUnselectedImage
{
    [self.scribbleBtn setBackgroundImage:[UIImage imageNamed:SCRIBBLE_UNSELECTED_IMAGE] forState:UIControlStateNormal];
}

#pragma mark erase button related functions
-(void)setEraseBtnSelectedImage
{
    [self.eraseBtn setBackgroundImage:[UIImage imageNamed:ERASE_SELECTED_IMAGE] forState:UIControlStateNormal];
}

-(void)setEraseBtnUnselectedImage
{
    [self.eraseBtn setBackgroundImage:[UIImage imageNamed:ERASE_UNSELECTED_IMAGE] forState:UIControlStateNormal];
}

#pragma mark text button related functions
-(void)setTextBtnSelectedImage
{
    [self.textBtn setBackgroundImage:[UIImage imageNamed:TEXT_SELECTED_IMAGE] forState:UIControlStateNormal];
}

-(void)setTextBtnUnselectedImage
{
    [self.textBtn setBackgroundImage:[UIImage imageNamed:TEXT_UNSELECTED_IMAGE] forState:UIControlStateNormal];
}

#pragma assigning completion and progress block
-(void)assignCompletionBlocksForAudioManager
{
    
    [[AudioManager sharedAudioManager] setPlayingCompletionBlock:^{

        self.isRecordedAudioAvailable = NO;
        [self changeAudioButtonImageToStartRecodring];
    }];

    [[AudioManager sharedAudioManager] setRecordingProgressBlock:^(NSString* recordingTime, CGFloat seconds, float pitchLevel){
        
        if(seconds > (60 * kMaxRecordingTime))
            [self audioPressed:self.audioBtn];
    }];

}

-(void)assignColorSelectedCompletionBlock
{
    [[SnapshotView sharedHandler] setColorSelectedCompletionBlock:^{
        [self setSelectedBtnId:self.previouslySelectedBtnId];
    }];
}

#pragma mark change audio button image to start recording
-(void)changeAudioButtonImageToStartRecodring
{
    [self.audioBtn setBackgroundImage:[UIImage imageNamed:RECORD_IMAGE] forState:UIControlStateNormal];
}

#pragma mark change audio button image to stop
-(void)changeAudioButtonImageToStop
{
    [self.audioBtn setBackgroundImage:[UIImage imageNamed:STOP_IMAGE] forState:UIControlStateNormal];
}

-(void)changeAudioButtonImageToStartPlaying
{
    [self.audioBtn setBackgroundImage:[UIImage imageNamed:PLAY_IMAGE] forState:UIControlStateNormal];
}

#pragma mark change audio button image to start playing
-(void)stopRecording
{
    if([[AudioManager sharedAudioManager] getRecorderStatus] == RecorderStatusRecording)
    {
        [[AudioManager sharedAudioManager] stopRecording];
        [self changeAudioButtonImageToStartRecodring];
    }
}

-(void)stopPlaying
{
    if([[AudioManager sharedAudioManager] getPlayerStatus] == PlayerStatusPlaying)
    {
        [[AudioManager sharedAudioManager] stopPlaying];
        [self changeAudioButtonImageToStartRecodring];
    }
}

#pragma mark unselect previously selected image
-(void)unSelectPreviouslySelectedBtn:(NSInteger)selectedBtnId
{
    switch (self.selectedBtnId)
    {
        case SCRIBBLE_BTN_ID:
            [self setScribbleBtnUnselectedImage];
            break;

        case ERASE_BTN_ID:
            [self setEraseBtnUnselectedImage];
            break;

        case TEXT_BTN_ID:
            [self setTextBtnUnselectedImage];
            break;

        default:
            break;
    }
}

#pragma Control mark IBAction containers action
-(IBAction)scribblePressed:(id)sender
{
    if(self.selectedBtnId == SCRIBBLE_BTN_ID)
        return;

    [self unSelectPreviouslySelectedBtn:SCRIBBLE_BTN_ID];
    [self setSelectedBtnId:SCRIBBLE_BTN_ID];
}

-(IBAction)erasePressed:(id)sender
{
    [self unSelectPreviouslySelectedBtn:ERASE_BTN_ID];
    [self setSelectedBtnId:ERASE_BTN_ID];
}

-(IBAction)textPressed:(id)sender
{
    [self unSelectPreviouslySelectedBtn:TEXT_BTN_ID];
    [self setSelectedBtnId:TEXT_BTN_ID];
}

-(IBAction)audioPressed:(id)sender
{
    [self unSelectPreviouslySelectedBtn:AUDIO_BTN_ID];
    [self controlRecorderAndPlayer];
}

-(IBAction)colorPickerPressed:(id)sender
{
    self.previouslySelectedBtnId = self.selectedBtnId;
    [self setSelectedBtnId:COLOR_PICKER_BTN_ID];
}

-(IBAction)emailPressed:(id)sender
{
    [self unSelectPreviouslySelectedBtn:EMAIL_BTN_ID];
    [self setSelectedBtnId:EMAIL_BTN_ID];
}

#pragma mark audio button fuctionality
-(void)controlRecorderAndPlayer{
    
    if([[AudioManager sharedAudioManager] getRecorderStatus] == RecorderStatusIdle || [[AudioManager sharedAudioManager] getRecorderStatus] == RecorderStatusUnkown)//Recorder status idle, unknown
    {
        
        if(self.isRecordedAudioAvailable == YES)
        {
            if([[AudioManager sharedAudioManager] getPlayerStatus] == PlayerStatusIdle)
            {
                NSString *recentlyRecordedFilePath = [[FileManager sharedFileManager] getRecentlyRecordedAudioFilePath];

                if(recentlyRecordedFilePath)
                {
                    if([[AudioManager sharedAudioManager] startPlaying:recentlyRecordedFilePath] != PlayingStarted)
                    {
                        [self changeAudioButtonImageToStartRecodring];
                        return;
                    }
                    [self changeAudioButtonImageToStop];
                }
                else
                {
                    NSLog(@"Error: No recorded audio file found");
                }
                
            }
            else if([[AudioManager sharedAudioManager] getPlayerStatus] == PlayerStatusPlaying)
            {
                [[AudioManager sharedAudioManager] stopPlaying];
                [self resetRecorderImage];
            }
        }
        else
        {
            if([[AudioManager sharedAudioManager] startRecording:[[FileManager sharedFileManager] getAudioFilePath]] != RecordingStarted)
            {
                return;
            }
            
            self.previouslySelectedBtnId = self.selectedBtnId;
            [self setSelectedBtnId:AUDIO_BTN_ID];
            //Change to stop button image
            [self changeAudioButtonImageToStop];
        }
    }
    else if([[AudioManager sharedAudioManager] getRecorderStatus] == RecorderStatusRecording)//Recorder status recording
    {
        [[AudioManager sharedAudioManager] stopRecording];
        
        //Change to start playing
        [self changeAudioButtonImageToStartPlaying];
        
        //set IsRecordedAudioAvailable == YES
        self.isRecordedAudioAvailable = YES;
    }
}

-(void)resetRecorderImage
{
    [self.audioBtn setBackgroundImage:[UIImage imageNamed:RECORD_IMAGE] forState:UIControlStateNormal];
    self.isRecordedAudioAvailable = NO;
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
