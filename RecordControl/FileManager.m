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

static NSInteger kMaxNumberOfAudios     = 3;

@interface FileManager()
@property(nonatomic, strong) NSString *recentFilePathForPlaying;
@end

@implementation FileManager

#pragma mark API methods
#pragma mark sharedFileManager
+(FileManager*)sharedFileManager
{
    //Crearte singleton class
    static dispatch_once_t predicate = 0;
    static FileManager *sharedInstance = nil;
    dispatch_once(&predicate,  ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

#pragma mark Create a directory for given name
-(NSString*)documentsDirectoryAppendedWithPathComponent:(NSString*)append
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0]; // Get documents folder
    NSString *dataPath = [documentsDirectory stringByAppendingPathComponent:SPOT_IT_DIR];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:dataPath])
    {
        NSError *error;
        if(![[NSFileManager defaultManager] createDirectoryAtPath:dataPath withIntermediateDirectories:NO attributes:nil error:&error])
        {
            NSLog(@"Failed to create directory %@", dataPath);
            return nil;
        }
    }
    
    NSString *appendedPath=[dataPath stringByAppendingPathComponent:append];
	return appendedPath;
}

#pragma mark create a directory for audio
-(NSString*)getAudioDirectoryPathWithAudioName:(NSString*)append
{
    NSString *audioDir = [self documentsDirectoryAppendedWithPathComponent:AUDIO_DIR];

    if(!audioDir)
    {
        return nil;
    }
    if (![[NSFileManager defaultManager] fileExistsAtPath:audioDir])
    {
        NSError *error;
        if(![[NSFileManager defaultManager] createDirectoryAtPath:audioDir withIntermediateDirectories:NO attributes:nil error:&error])
        {
            NSLog(@"Failed to create directory %@", audioDir);
            return nil;
        }
    }
    
    NSString *appendedPath=[audioDir stringByAppendingPathComponent:append];
	return appendedPath;
}

#pragma mark create screen name in screen shot directory
-(NSString*)getScreenShotDirectoryPathWithScreenName:(NSString*)append
{
    NSString *screenDir = [self documentsDirectoryAppendedWithPathComponent:SCREEN_SHOT_DIR];
    
    if(!screenDir)
    {
        return nil;
    }
    if (![[NSFileManager defaultManager] fileExistsAtPath:screenDir])
    {
        NSError *error;
        [[NSFileManager defaultManager] createDirectoryAtPath:screenDir withIntermediateDirectories:NO attributes:nil error:&error];
    }
    
    NSString *appendedPath=[screenDir stringByAppendingPathComponent:append];
	return appendedPath;
}

#pragma mark Archieve filepath
-(NSString*)getScreenShotFilePath
{
    
    NSString *fileName = [NSString stringWithFormat:@"%@%@", [NSDate date], IMAGE_EXTENSION];
    NSString *filePath = [self getScreenShotDirectoryPathWithScreenName:fileName];
   
    NSLog(@"Image File path %@", filePath);
    return filePath;
}

#pragma mark Archieve filepath
-(NSString*)getAudioFilePath
{
    NSString *fileName = [NSString stringWithFormat:@"%@%@", [NSDate date], AUDIO_EXTENSION];
    NSString *filePath = [self getAudioDirectoryPathWithAudioName:fileName];
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
-(BOOL)clearFileFromDisk:(NSString*)filePath
{
    NSFileManager *fileMgnr = [NSFileManager defaultManager];
    
    if([fileMgnr fileExistsAtPath:filePath])
    {
        NSError *error = nil;
        return ([fileMgnr removeItemAtPath:filePath error:&error]) ? YES : NO;
        
    }
    else
    {
        NSLog(@"File doesn't exist at path: %@", filePath);
        return NO;
    }    
}

#pragma mark (Private methods)
#pragma mark Check file path exist
-(BOOL)checkFileExistAtPath:(NSString*)fileName
{
    return ([[NSFileManager defaultManager] fileExistsAtPath:fileName]) ? YES : NO;
}

#pragma mark Returns full filepath from directory name
-(NSMutableArray*)getFilePathArrayFromDirectory:(NSString*)archieveDirectoryPath
{
    
    NSError *err = nil;
    NSArray *docContents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:archieveDirectoryPath error:&err];
    
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
    NSArray *screenShots    = [self getFilePathArrayFromDirectory:screenShotDir];
    return screenShots;
}

#pragma mark get file path for recorded audio
-(NSArray*)getRecordedAudios
{
    NSString *audioDir  = [self documentsDirectoryAppendedWithPathComponent:AUDIO_DIR];
    NSArray *audios     = [self getFilePathArrayFromDirectory:audioDir];
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
    NSString *audioDir  = [self documentsDirectoryAppendedWithPathComponent:AUDIO_DIR];
    NSArray *audios     = [self getFilePathArrayFromDirectory:audioDir];
    
    for (NSString *filePath in audios)
        [self clearFileFromDisk:filePath];
}

#pragma mark clear all screen shots
-(void)clearAllScreenShots
{
    NSString *screenShotDir  = [self documentsDirectoryAppendedWithPathComponent:SCREEN_SHOT_DIR];
    NSArray *screenShots     = [self getFilePathArrayFromDirectory:screenShotDir];
    
    for (NSString *filePath in screenShots)
        [self clearFileFromDisk:filePath];
}


#pragma mark sort file names recently created first
-(NSMutableArray*)sortFilePathByDate:(NSArray*)unsortedArray{
    
    NSMutableArray *newSortedrray = [NSMutableArray arrayWithArray:unsortedArray];
    
    for (NSInteger i = 0; i < newSortedrray.count - 1; i++)
    {
        for (NSInteger j = i; j < newSortedrray.count ; j++)
        {
            NSString *filePath1 = [newSortedrray objectAtIndex:i];
            NSString *filePath2 = [newSortedrray objectAtIndex:j];
            
            NSDate* d1 = [[[NSFileManager defaultManager] attributesOfItemAtPath:filePath1 error:nil] objectForKey:@"NSFileCreationDate"];
            NSDate* d2 = [[[NSFileManager defaultManager] attributesOfItemAtPath:filePath2 error:nil] objectForKey:@"NSFileCreationDate"];
            
            NSComparisonResult result = [d1 compare:d2];
            
            if (result == NSOrderedAscending)
                [newSortedrray exchangeObjectAtIndex:i withObjectAtIndex:j];
        }
    }
    return newSortedrray;
}

#pragma Print the creation date of the file from file name
-(void)createdDatesOfFile:(NSArray*)arr
{
    NSInteger i = 0;
    for (NSString *filePath in arr)
    {
        NSDate* d1 = [[[NSFileManager defaultManager] attributesOfItemAtPath:filePath error:nil] objectForKey:@"NSFileCreationDate"];
        NSLog(@"%d - Created Date %@", i++, d1);
    }
}

#pragma Roll back recordedx audios
-(void)rollbackTheRecordedAudios
{
    NSString *audioDir  = [self documentsDirectoryAppendedWithPathComponent:AUDIO_DIR];
    NSArray *audios     = [self getFilePathArrayFromDirectory:audioDir];

    NSMutableArray *sortedArray = [self sortFilePathByDate:audios];

    [self createdDatesOfFile:sortedArray];
    if(sortedArray.count > kMaxNumberOfAudios)
    {
        do
        {
            if([self clearFileFromDisk:[sortedArray lastObject]])
                [sortedArray removeLastObject];
        } while (sortedArray.count > kMaxNumberOfAudios);
        NSLog(@"After roll back");
        [self createdDatesOfFile:sortedArray];
    }
}

@end
