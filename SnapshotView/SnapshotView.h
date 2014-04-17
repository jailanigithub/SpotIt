//
//  SnapshotView.h
//  CommonConfirmation
//
//  Created by Mani on 4/4/14.
//
//

#import <UIKit/UIKit.h>

typedef void (^ColorSelectedCompletionBlock)();

@interface SnapshotView : UIView

@property(nonatomic, copy) ColorSelectedCompletionBlock colorSelectedCompletionBlock;

+(SnapshotView*)sharedHandler;

-(void)removeFromWindow;

-(void)assignBackgroundColorWithImage:(UIImage*)image;

-(void)addMovableControlToSnapView;
-(void)removeMovableControlFromSnapView;

-(void)addScribbleControllToSnapView;
-(void)removeScribbleControllFromSnapView;

-(void)addEraseControlToSnapView;
-(void)removeEraserFromSnapView;

-(void)colorPickerToSnapView;

-(void)addTextViewControlToSnapView;
-(void)removeTextViewFromSnapView;

-(void)addNoSelectionView;
-(void)removeNoSelectionView;

-(void)closeButtonState:(BOOL)hidden;

@end
