//
//  ColorPickerView.h
//  CrashHandler
//
//  Created by Mani on 4/5/14.
//  Copyright (c) 2014 mani. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ColorPickerView : UIView

@property (nonatomic,weak) IBOutlet UIView *baseColorView,*pickerKnob;
@property (nonatomic,weak) IBOutlet UIButton *doneBtn;
@property (nonatomic,weak) IBOutlet UILabel *redValue,*greenValue,*blackValue;
@property (nonatomic,weak) IBOutlet UIView *pickedColor;

-(UIColor*)getCurrentSelectedColor;

@end
