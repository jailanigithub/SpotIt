//
//  UILabel+UILabelDynamicHeight.m
//  SpotIt
//
//  Created by aram on 4/22/14.
//  Copyright (c) 2014 mani. All rights reserved.
//

#import "UILabel+UILabelDynamicHeight.h"
#import "CommonMacro.h"

@implementation UILabel (UILabelDynamicHeight)

-(CGSize)sizeOfMultiLineLabel
{
    
    NSAssert(self, @"UILabel was nil");

    NSString *aLabelTextString = [self text];
    UIFont *aLabelFont = [self font];
    CGFloat aLabelSizeWidth = self.frame.size.width;

    if (SYSTEM_VERSION_LESS_THAN(iOS7_0))
    {
        return [aLabelTextString sizeWithFont:aLabelFont
                            constrainedToSize:CGSizeMake(aLabelSizeWidth, MAXFLOAT)
                                lineBreakMode:NSLineBreakByWordWrapping];
    }
    else if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(iOS7_0))
    {
        return [aLabelTextString boundingRectWithSize:CGSizeMake(aLabelSizeWidth, MAXFLOAT)
                                              options:NSStringDrawingUsesLineFragmentOrigin
                                           attributes:@{
                                                        NSFontAttributeName : aLabelFont
                                                        }
                                              context:nil].size;
        
    }
    
    return [self bounds].size;
}

-(void)adjustFrameSize
{
    CGSize labelSize = [self sizeOfMultiLineLabel];
    [self setNumberOfLines:labelSize.height/self.font.pointSize];
    [self setFrame:CGRectMake(self.frame.origin.x, self.frame.origin.y, labelSize.width, labelSize.height)];
}

@end
