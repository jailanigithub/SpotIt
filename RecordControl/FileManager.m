//
//  FileManager.m
//  eMT
//
//  Created by aram on 3/18/14.
//  Copyright (c) 2014 NPCompete. All rights reserved.
//

#import "FileManager.h"


static  NSString *SPOT_IT_DIR           = @"/SpotIt";

static  NSString *SCREEN_SHOT_DIR       = @"/ScreenShots";
static  NSString *AUDIO_DIR             = @"/Audios";


static  NSString *IMAGE_EXTENSION       = @".png";
static  NSString *AUDIO_EXTENSION       = @".aac";


@interface FileManager()

@end

@implementation FileManager

#pragma mark API methods
#pragma mark sharedFileManager
+(FileManager*)sharedFileManager{ //Crearte singleton class
    
    static dispatch_once_t predicate = 0;
    static FileManager *sharedInstance = nil;
    dispatch_once(&predicate,  ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

-(NSString*)documentsDirectoryAppendedWithPathComponent:(NSString*)append
{
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0]; // Get documents folder
    NSString *dataPath = [documentsDirectory stringByAppendingPathComponent:SPOT_IT_DIR];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:dataPath]){
        NSError *error;
        [[NSFileManager defaultManager] createDirectoryAtPath:dataPath withIntermediateDirectories:NO attributes:nil error:&error];
    }
    
    NSString *appendedPath=[dataPath stringByAppendingPathComponent:append];
	return appendedPath;
}

-(NSString*)getAudioDirectoryWithAudioName:(NSString*)append
{
    NSString *audioDir = [self documentsDirectoryAppendedWithPathComponent:AUDIO_DIR];

    if (![[NSFileManager defaultManager] fileExistsAtPath:audioDir]){
        NSError *error;
        [[NSFileManager defaultManager] createDirectoryAtPath:audioDir withIntermediateDirectories:NO attributes:nil error:&error];
    }
    
    NSString *appendedPath=[audioDir stringByAppendingPathComponent:append];
	return appendedPath;

}

#pragma mark create screen name in screen shot directory
-(NSString*)getScreenShotDirectoryWithScreenName:(NSString*)append
{
    NSString *audioDir = [self documentsDirectoryAppendedWithPathComponent:SCREEN_SHOT_DIR];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:audioDir]){
        NSError *error;
        [[NSFileManager defaultManager] createDirectoryAtPath:audioDir withIntermediateDirectories:NO attributes:nil error:&error];
    }
    
    NSString *appendedPath=[audioDir stringByAppendingPathComponent:append];
	return appendedPath;
    
}

#pragma mark Archieve filepath
-(NSString*)getScreenShotFilePath
{
    
    NSString *fileName = [NSString stringWithFormat:@"%@%@", [NSDate date], IMAGE_EXTENSION];
    NSString *filePath = [self getScreenShotDirectoryWithScreenName:fileName];
   
    NSLog(@"Image File path %@", filePath);
    return filePath;
}

#pragma mark Archieve filepath
-(NSString*)getAudioFilePath
{
    
    NSString *fileName = [NSString stringWithFormat:@"%@%@", [NSDate date], AUDIO_EXTENSION];
    NSString *filePath = [self getAudioDirectoryWithAudioName:fileName];
    
    NSLog(@"Audio File path %@", filePath);
    [self setRecentFilePathForPlaying:filePath];
    return filePath;
}

#pragma mark get recently recorded file path
-(NSString*)getRecentlyRecordedAudioFilePath
{
    return (self.recentFilePathForPlaying) ? self.recentFilePathForPlaying : nil;
}

#pragma mark clearFilefromDiskPath
-(BOOL)clearFileFromDisk:(NSString*)filePath{
    
    NSFileManager *fileMgnr = [NSFileManager defaultManager];
    
    if([fileMgnr fileExistsAtPath:filePath]){
    
        NSError *error = nil;
        return ([fileMgnr removeItemAtPath:filePath error:&error]) ? YES : NO;
        
    }else{
        NSLog(@"File doesn't exist at path: %@", filePath);
        return NO;
    }    
}

#pragma mark getFileSizeForFivenFilePath
-(NSNumber*)getFileSize:(NSString*)filePath{
    
    NSNumber *fileSize = nil;
    if([self checkFileExistAtPath:filePath])
    {
        NSData *data = [NSData dataWithContentsOfFile:filePath];
        fileSize = [NSNumber numberWithUnsignedInt:data.length];
    }
    else{
        NSLog(@"File doesn't exist at path: %@", filePath);
    }
    return fileSize;
}

#pragma mark (Private methods)

#pragma mark Check file path exist
-(BOOL)checkFileExistAtPath:(NSString*)fileName{

    NSFileManager *fileMngr = [NSFileManager defaultManager];
    if([fileMngr fileExistsAtPath:fileName]){
        return YES;
    }
    return NO;
}

#pragma mark Returns full filepath from directory name
-(NSMutableArray*)getFilePathArrayFromDirectory:(NSString*)archieveDirectoryPath
{
    
    NSError *err = nil;
    NSArray *docContents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:archieveDirectoryPath error:&err];
    NSLog(@"Doc Contents %@", docContents);
    
    if(!(docContents && docContents.count > 0))
    {
        NSLog(@"Error: Directory is empty!");
        return nil;
    }
    
    NSMutableArray *filePathArray = [NSMutableArray arrayWithCapacity:docContents.count];
    
    for (NSString *fileName in docContents)
    {
        NSString *filePath = [archieveDirectoryPath stringByAppendingPathComponent:fileName];
        [filePathArray addObject:filePath];
    }
    return filePathArray;
}

#pragma mark get file path for screen shots
-(NSArray*)getScreenShots
{
    NSString *screenShotDir = [self documentsDirectoryAppendedWithPathComponent:SCREEN_SHOT_DIR];
    NSArray *screenShots = [self getFilePathArrayFromDirectory:screenShotDir];
    NSLog(@"Screen shot paths %@", screenShotDir);
    return screenShots;
}

#pragma mark get file path for recorded audio
-(NSArray*)getRecordedAudios
{
    NSString *audioDir = [self documentsDirectoryAppendedWithPathComponent:AUDIO_DIR];
    NSArray *audios = [self getFilePathArrayFromDirectory:audioDir];
    NSLog(@"Audios shot paths %@", audioDir);
    return audios;
}

#pragma mark save screen shot image
-(BOOL)saveImage:(UIImage*)image
{
    NSData *imageData = UIImagePNGRepresentation(image);
    if(!imageData)
        return NO;
    
    return [imageData writeToFile:[[FileManager sharedFileManager]getScreenShotFilePath] atomically:YES];
}

#pragma mark clear all recorded
-(void)clearAllAudios
{
    NSString *audioDir = [self documentsDirectoryAppendedWithPathComponent:AUDIO_DIR];
    NSArray *audios = [self getFilePathArrayFromDirectory:audioDir];
    
    for (NSString *filePath in audios)
    {
        [self clearFileFromDisk:filePath];
    }
}

#pragma mark clear all screen shots
-(void)clearAllScreenShots
{
    NSString *screenShotDir  = [self documentsDirectoryAppendedWithPathComponent:SCREEN_SHOT_DIR];
    NSArray *screenShots     = [self getFilePathArrayFromDirectory:screenShotDir];
    
    for (NSString *filePath in screenShots)
    {
        [self clearFileFromDisk:filePath];
    }
}
@end



















