//
//  TextView.h
//  FinalSnapControl
//
//  Created by aram on 4/8/14.
//  Copyright (c) 2014 mani. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TextView : UIView <UITextFieldDelegate>

@property(nonatomic, strong) UIColor *textColor;

-(void)resetCommandlabel;
-(void)removeFirstResponders;
@end
