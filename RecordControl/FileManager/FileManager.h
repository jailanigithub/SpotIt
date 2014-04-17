//
//  FileManager.h
//  eMT
//
//  Created by aram on 3/18/14.
//  Copyright (c) 2014 NPCompete. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FileManager : NSObject

@property(nonatomic, strong) NSString *recentFilePathForPlaying;

+(FileManager*)sharedFileManager;

//File information and file path
-(NSString*)getAudioFilePath;
-(NSString*)getRecentlyRecordedAudioFilePath;

//Recorded audio and screen shots
-(NSArray*)getScreenShots;
-(NSArray*)getRecordedAudios;

//Save screen shot image
-(BOOL)saveImage:(UIImage*)image;

//Clear scren shots and audios
-(void)clearAllAudios;
-(void)clearAllScreenShots;


@end
