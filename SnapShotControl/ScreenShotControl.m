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

#define SquareButtonSize 30

NSString const *snapShotImage  = @"ProfileCameraBtn.png";
NSString const *screenShotName = @"screenShot.png";

@interface ScreenShotControl ()

@property (nonatomic,strong) UIButton *snapShotBtn;
@property (nonatomic, strong) UIWindow *window;
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
    [self.snapShotBtn setBackgroundImage:[UIImage imageNamed:(NSString*)snapShotImage] forState:UIControlStateNormal];
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


-(NSString*)documentsDirectoryAppendedWithPathComponent:(NSString*)append
{

    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0]; // Get documents folder
    NSString *dataPath = [documentsDirectory stringByAppendingPathComponent:@"/ScreenShotControl"];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:dataPath]){
        NSError *error;
        [[NSFileManager defaultManager] createDirectoryAtPath:dataPath withIntermediateDirectories:NO attributes:nil error:&error];
    }
    
    NSString *appendedPath=[dataPath stringByAppendingPathComponent:append];
	return appendedPath;
}

-(UIImage *)getScreenShotImage
{
    UIWindow *window = [[[UIApplication sharedApplication] delegate] window];
    
    UIGraphicsBeginImageContext(window.bounds.size);
    [window.layer renderInContext:UIGraphicsGetCurrentContext()];
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    if(!image)
    {
        NSLog(@"Image is nil");
        return nil;
    }
    NSData *data = UIImagePNGRepresentation(image);
    
    if(!data)
    {
        NSLog(@"Data is nill");
        return nil;
    }
    
    UIImage *pngImage = [UIImage imageWithData:data];
    
    if(!pngImage)
    {
        NSLog(@"image from file path is nill");
    }
    return image;
}

#pragma mark - Snap Shot Button Fired.
-(void)snapButtonFired:(UIButton*)snapButton
{
    [snapButton setHidden:YES];
    [[SnapshotView sharedHandler] assignBackgroundColorWithImage:[self getScreenShotImage]];
    [self.window insertSubview:[SnapshotView sharedHandler] aboveSubview:self];
    [[SnapshotView sharedHandler] addMovableControlToSnapView];
}

#pragma mark - Remove Snap shot view

-(void)closeButtonFired:(UIButton*)closeBtn
{
    [self removeSnapShotView];
    [self.snapShotBtn setHidden:NO];
    [self clearAudiosAndScreenShots];
}

-(void)removeSnapShotView
{
    [[SnapshotView sharedHandler] removeFromWindow];
    [self setNeedsDisplay];
}

#pragma mark - Panning Handle

-(void)panning:(UIPanGestureRecognizer*)gesture
{
    CGPoint translation = [gesture translationInView:self.window];
    gesture.view.center = CGPointMake(gesture.view.center.x + translation.x,
                                      gesture.view.center.y + translation.y);
    [gesture setTranslation:CGPointMake(0, 0) inView:self.window];
    if(gesture.state == UIGestureRecognizerStateBegan)
    {
        NSLog(@"Panning started");
    }
    else if (gesture.state == UIGestureRecognizerStateChanged)
    {
        NSLog(@"Panning continuous");
        
    }
    else if (gesture.state == UIGestureRecognizerStateEnded)
    {
        NSLog(@"Panning Ended");
    }
}

#pragma mark send screen shot
-(void)sendScreenShotView
{
    if(![MFMailComposeViewController canSendMail])
        return;
    
    [self removeSnapShotView];
    
    MFMailComposeViewController *mailComposer = [[MFMailComposeViewController alloc]init];
    [mailComposer setMailComposeDelegate:self];
    
    [mailComposer setToRecipients:[NSArray arrayWithObject:@"jailani.h@npcompete.com"]];
    
    //Attach audios
    NSInteger i = 0;
    NSArray *audios = [[FileManager sharedFileManager] getRecordedAudios];
    
    for (NSString *path  in audios)
    {
        i++;
        [mailComposer addAttachmentData:[NSData dataWithContentsOfFile:path] mimeType:@"audio/aac" fileName:[NSString stringWithFormat:@"audio%d", i]];
    }

    //Attach screen shots
    NSArray *screenShots = [[FileManager sharedFileManager] getScreenShots];
    
    for (NSString *path  in screenShots)
    {
        i++;
        [mailComposer addAttachmentData:[NSData dataWithContentsOfFile:path] mimeType:@"image/png" fileName:[NSString stringWithFormat:@"audio%d", i]];
    }
    
    [self.window.rootViewController presentViewController:mailComposer animated:YES completion:nil];
}

-(void)clearAudiosAndScreenShots
{
    [[FileManager sharedFileManager] clearAllAudios];
    [[FileManager sharedFileManager] clearAllScreenShots];
}

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{
    // Notifies users about errors associated with the interface
    switch (result)
    {
        case MFMailComposeResultCancelled:
            NSLog(@"Result: canceled");
            [self clearAudiosAndScreenShots];
            break;
        
        case MFMailComposeResultSaved:
            NSLog(@"Result: saved");
            [self clearAudiosAndScreenShots];
            break;
        case MFMailComposeResultSent:
        {
            [self clearAudiosAndScreenShots];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Result" message:@"Mail Sent Successfully" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alert show];
        }
            break;
        case MFMailComposeResultFailed:
            //NSLog(@"Result: failed");
            break;
        default:
            [self clearAudiosAndScreenShots];
            //NSLog(@"Result: not sent");
            break;
    }
    
    [self.window.rootViewController dismissViewControllerAnimated:YES completion:^{
        [self.snapShotBtn setHidden:NO];
    }];
}



@end
