//
//  MovableEditorView.h
//  FinalSnapControl
//
//  Created by aram on 4/7/14.
//  Copyright (c) 2014 mani. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface MovableEditorView : UIView 

+(MovableEditorView*)customView;

-(void)resetRecordingControl;
-(void)defaultSelection;

@end
