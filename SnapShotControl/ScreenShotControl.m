//
//  ScreenShotControl.m
//  CommonConfirmation
//
//  Created by Mani on 4/4/14.
//
//

#import "ScreenShotControl.h"
#import "SnapshotView.h"
#import "FileManager.h"
#import "ModalVC.h"
#import "FirstVC.h"

#define SquareButtonSize 40

NSString const *kSnapShotImage  = @"ProfileCameraBtn.png";
NSString const *kEmailAddress   = @"jailani.h@npcompete.com";

NSString const *kMimeTypeAudio  = @"audio/aac";
NSString const *kMimeTypeImage  = @"image/png";

NSString const *kAudioPrefix    = @"audio";
NSString const *kImagePrefix    = @"image";

NSString const *kEmailSentResult   = @"Result";
NSString const *kEmailSentMessage  = @"Mail Sent Successfully";
NSString const *kOKButtonTitle     = @"OK";

NSInteger const kMailSuccess    = 1008;

@interface ScreenShotControl () <UIAlertViewDelegate>

@property (nonatomic,strong) UIButton *snapShotBtn;
@property (nonatomic, strong) UIWindow *window;
@property (nonatomic, strong) id presentedVC;

@end

@implementation ScreenShotControl

#pragma mark - Enable Screen shot Control to this Window
-(void)enableScreenshotControlToWindow:(UIWindow*)baseWindow
{
    self.window = baseWindow;
    [baseWindow addSubview:self];
}

#pragma mark - Control Creation and Assign Frame
- (void)assignButtonWithFrame:(CGRect)frame
{
    self.frame = CGRectMake(100,200, frame.size.width, frame.size.height);
    self.snapShotBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.snapShotBtn.frame = frame;
    [self.snapShotBtn setBackgroundImage:[UIImage imageNamed:(NSString*)kSnapShotImage] forState:UIControlStateNormal];
    [self.snapShotBtn addTarget:self action:@selector(snapButtonFired:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.snapShotBtn];
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(panning:)];
    [self addGestureRecognizer:panGesture];
}

+(ScreenShotControl*)sharedHandler
{
    static dispatch_once_t predicate = 0;
    static ScreenShotControl *sharedInstance = nil;
    
    dispatch_once(&predicate, ^{
        sharedInstance = [[self alloc] init];
        [sharedInstance assignButtonWithFrame:CGRectMake(0, 0, SquareButtonSize, SquareButtonSize)];
    });
    return sharedInstance;
}

-(UIImage*)takeSnapForLayer:(CALayer*)layer
{
    [layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return (!image) ? nil : image;
}

-(UIImage*)takeScreenShotImageForView:(UIView *)baseView
{
    UIGraphicsBeginImageContext(baseView.bounds.size);
    return [self takeSnapForLayer:baseView.layer];
}

#pragma mark remove the status bar from screen shot image
-(UIImage *)getScreenShotImageWithOutStatusBar
{
    
    UIWindow *window = [[[UIApplication sharedApplication] delegate] window];

    UIGraphicsBeginImageContext(window.layer.frame.size);
    UIImage *image = [self takeSnapForLayer:window.layer];
    
    CGImageRef tmpImgRef = image.CGImage;
    CGImageRef topImgRef = CGImageCreateWithImageInRect(tmpImgRef, CGRectMake(0, 20, image.size.width, image.size.height));
    UIImage *topImage = [UIImage imageWithCGImage:topImgRef];
    CGImageRelease(topImgRef);
    
    return topImage;
}

#pragma mark - Animation Delegate - only for PopUp

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    [self removeSnapShotView];
    [self.snapShotBtn setHidden:NO];
    [self clearAudiosAndScreenShots];
}

#pragma mark - Popup & Popin animation

- (void) attachPopUpAnimationToView:(UIView*)view isPopIn:(BOOL)popIn
{
    CAKeyframeAnimation *animation = [CAKeyframeAnimation
                                      animationWithKeyPath:@"transform"];
    CATransform3D scale1 = CATransform3DMakeScale(0.2, 0.2, 1);
    CATransform3D scale11 = CATransform3DMakeScale(0.5, 0.5, 1);
    CATransform3D scale2 = CATransform3DMakeScale(1.2, 1.2, 1);
    CATransform3D scale3 = CATransform3DMakeScale(0.9, 0.9, 1);
    CATransform3D scale4 = CATransform3DMakeScale(1.0, 1.0, 1);
    
    NSArray *frameValues = [NSArray arrayWithObjects:
                            [NSValue valueWithCATransform3D:scale1],
                            [NSValue valueWithCATransform3D:scale11],
                            [NSValue valueWithCATransform3D:scale2],
                            [NSValue valueWithCATransform3D:scale3],
                            [NSValue valueWithCATransform3D:scale4],
                            nil];
    NSArray *frameTimes = [NSArray arrayWithObjects:
                           [NSNumber numberWithFloat:0.1],
                           [NSNumber numberWithFloat:0.2],
                           [NSNumber numberWithFloat:0.5],
                           [NSNumber numberWithFloat:0.9],
                           [NSNumber numberWithFloat:1.0],
                           nil];
    animation.duration = 0.8;
    if (popIn)
    {
        [animation setValues:frameValues];
        [animation setKeyTimes:frameTimes];
        animation.fillMode = kCAFillModeForwards;
    }
    else
    {
        [animation setValues:[[frameValues reverseObjectEnumerator] allObjects]];
        [animation setKeyTimes:frameTimes];
        animation.fillMode = kCAFillModeRemoved;
        animation.delegate = self;
    }
    [view.layer addAnimation:animation forKey:@"popup"];
}

#pragma mark - Snap Shot Button Fired.
-(void)snapButtonFired:(UIButton*)snapButton
{
    [snapButton setHidden:YES];
    [[SnapshotView sharedHandler] assignBackgroundColorWithImage:[self getScreenShotImageWithOutStatusBar]];
    [self.window insertSubview:[[SnapshotView sharedHandler] getBaseView] aboveSubview:self];
    [[SnapshotView sharedHandler] addMovableControlToSnapView];
    [self attachPopUpAnimationToView:[SnapshotView sharedHandler] isPopIn:YES];
}

#pragma mark - Remove Snap shot view

-(void)closeButtonFired:(UIButton*)closeBtn
{
    [self attachPopUpAnimationToView:[SnapshotView sharedHandler] isPopIn:NO];
}

-(void)removeSnapShotView
{
    [[SnapshotView sharedHandler] removeFromWindow];
}

#pragma mark - Panning Handle

-(BOOL)isTouchEventHappenedInsideBase:(CGPoint)currentTouchPoint
{
    if (currentTouchPoint.x > self.window.frame.origin.x + self.window.frame.size.width - self.snapShotBtn.frame.size.width/2)
        return NO;
    else if (currentTouchPoint.x <= self.window.frame.origin.x + self.snapShotBtn.frame.size.width/2)
        return NO;
    if (currentTouchPoint.y >= self.window.frame.origin.y + self.window.frame.size.height - self.snapShotBtn.frame.size.height/2)
        return NO;
    else if (currentTouchPoint.y <= self.window.frame.origin.y + self.snapShotBtn.frame.size.height/2)
        return NO;
    return YES;
}

-(void)panning:(UIPanGestureRecognizer*)gesture
{
    CGPoint currentTouchPoint = [gesture locationInView:self.window];
    if (![self isTouchEventHappenedInsideBase:currentTouchPoint])
        return;
    CGPoint translation = [gesture translationInView:self.window];
    gesture.view.center = CGPointMake(gesture.view.center.x + translation.x,
                                      gesture.view.center.y + translation.y);
    [gesture setTranslation:CGPointMake(0, 0) inView:self.window];
}

#pragma mark send screen shot
-(void)sendScreenShotView
{
    if(![MFMailComposeViewController canSendMail])
        return;
    
    [self removeSnapShotView];
    
    MFMailComposeViewController *mailComposer = [[MFMailComposeViewController alloc]init];
    [mailComposer setMailComposeDelegate:self];
    
    //Attach audios
    NSInteger i = 0;
    NSArray *audios = [[FileManager sharedFileManager] getRecordedAudios];
    
    for (NSString *path  in audios)
    {
        i++;
        [mailComposer addAttachmentData:[NSData dataWithContentsOfFile:path] mimeType:(NSString*)kMimeTypeAudio fileName:[NSString stringWithFormat:@"%@%d", kAudioPrefix, i]];
    }

    //Attach screen shots
    NSArray *screenShots = [[FileManager sharedFileManager] getScreenShots];
    
    for (NSString *path  in screenShots)
    {
        i++;
        [mailComposer addAttachmentData:[NSData dataWithContentsOfFile:path] mimeType:(NSString*)kMimeTypeImage fileName:[NSString stringWithFormat:@"%@%d", kImagePrefix, i]];
    }
    
    self.presentedVC = [self getVisibleViewControllerFrom:self.window.rootViewController];
    
    if(self.presentedVC)
    {
        //Hold already presented vc and present it once mailcomposer vc is dismissed
        [self.window.rootViewController dismissViewControllerAnimated:NO completion:^{
            [self.window.rootViewController presentViewController:mailComposer animated:YES completion:nil];
        }];
    }
    else
    {
        NSLog(@"Else part called");
        [self.window.rootViewController presentViewController:mailComposer animated:YES completion:nil];
    }
}

#pragma mark get PresentedView controller
-(UIViewController*)getVisibleViewControllerFrom:(UIViewController *) vc
{
    return ([vc presentedViewController]) ? [vc presentedViewController]: nil;
}

#pragma mark dismiss mail composer vc and present the presented vc if the root vc already had presented vc
-(void)dismissMailVCAndPresentAlreadyPresnetedVC
{
    if(self.presentedVC)
    {
        [self.window.rootViewController dismissViewControllerAnimated:NO completion:^{
            [self.window.rootViewController presentViewController:self.presentedVC animated:NO completion:^{
                [self.snapShotBtn setHidden:NO];
                self.presentedVC = nil;
            }];
        }];
    }
    else
    {
        [self.window.rootViewController dismissViewControllerAnimated:YES completion:^{
            [self.snapShotBtn setHidden:NO];
        }];
    }
}

#pragma mark mail composer delegate
- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{
    // Notifies users about errors associated with the interface
    switch (result)
    {
        case MFMailComposeResultCancelled:
            [self clearAudiosAndScreenShots];
            break;
            
        case MFMailComposeResultSaved:
            [self clearAudiosAndScreenShots];
            break;
        case MFMailComposeResultSent:
        {
            [self clearAudiosAndScreenShots];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:(NSString*)kEmailSentResult message:(NSString*)kEmailSentMessage delegate:self cancelButtonTitle:(NSString*)kOKButtonTitle otherButtonTitles:nil, nil];
            [alert setTag:kMailSuccess];
            [alert show];
            return;
        }
            break;
        case MFMailComposeResultFailed:
            break;
        default:
            [self clearAudiosAndScreenShots];
            break;
    }
    
    [self dismissMailVCAndPresentAlreadyPresnetedVC];
}

#pragma mark clear audios and screen shots
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(alertView.tag == kMailSuccess)
    {
        [self dismissMailVCAndPresentAlreadyPresnetedVC];
    }
}

#pragma mark clear audios and screen shots
-(void)clearAudiosAndScreenShots
{
    [[FileManager sharedFileManager] clearAllAudios];
    [[FileManager sharedFileManager] clearAllScreenShots];
}

@end
