//
//  ScreenShotControl.h
//  CommonConfirmation
//
//  Created by Mani on 4/4/14.
//
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>

@interface ScreenShotControl : UIView <MFMailComposeViewControllerDelegate>

+(ScreenShotControl*)sharedHandler;

-(void)enableScreenshotControlToWindow:(UIWindow*)baseWindow;
-(void)removeSnapShotView;
-(void)closeButtonFired:(UIButton*)closeBtn;

-(void)sendScreenShotView;
-(UIImage*)takeScreenShotImageForView:(UIView *)baseView;

@end
