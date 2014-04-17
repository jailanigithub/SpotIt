//
//  RecordingView.m
//  FinalSnapControl
//
//  Created by aram on 4/8/14.
//  Copyright (c) 2014 mani. All rights reserved.
//

#import "RecordingView.h"

@implementation RecordingView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

-(NSString*)documentsDirectoryAppendedWithPathComponent:(NSString*)append
{
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0]; //Get documents folder
    NSString *dataPath = [documentsDirectory stringByAppendingPathComponent:@"/ScreenShotControl"];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:dataPath])
    {
        NSError *error;
        [[NSFileManager defaultManager] createDirectoryAtPath:dataPath withIntermediateDirectories:NO attributes:nil error:&error];
    }
    
    NSString *appendedPath=[dataPath stringByAppendingPathComponent:append];
	return appendedPath;
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
