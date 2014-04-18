//
//  AudioManager.h
//  eMT
//
//  Created by aram on 3/18/14.
//  Copyright (c) 2014 NPCompete. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>


typedef enum RecordingStatus{
    
    RecordingStarted,
    RecordingAlreadyInProgress,
    RecordingPaused,
    RecordingAlreadyPaused,
    RecordingStopped,
    RecordingNotStarted,
    RecordingResumed,
    RecordingFailedToStart,
    RecordingFailedToStartAudioSession,
    RecordingUnkownState
}RecordingStatus;

typedef enum RecorderStatus{
    
    RecorderStatusIdle,
    RecorderStatusRecording,
    RecorderStatusPaused,
    RecorderStatusUnkown
}RecorderStatus;

typedef enum PlayerStatus{
    PlayerStatusIdle,
    PlayerStatusPlaying,
    PlayerStatusPaused
}PlayerStatus;

typedef enum PlayingStatus{
    
    PlayingAlreadyinProgress,
    PlayingStarted,
    PlayingAlreadyPaused,
    PlayingPaused,
    PlayingStopped,
    PlayingNotStarted,
    PlayingResumed,
    PlayingFailedToStart,
    PlayingFailedToStartAudioSession,
    PlayingUnknownState
    
}PlayingStatus;

//Blocks for audio recorder and player
typedef void (^RecordingProgressBlock) (NSString* recordingTime, float pitchLevel);
typedef void (^PlayingProgressBlock) (NSString* currentPlayinTime);
typedef void (^PlayingCompletionBlock) ();
typedef void (^AudioPlayerDecoreErrorBlock) (NSError *decodeError);


@interface AudioManager : NSObject <AVAudioPlayerDelegate>

@property(nonatomic, copy) RecordingProgressBlock recordingProgressBlock;
@property(nonatomic, copy) PlayingProgressBlock playingProgressBlock;
@property(nonatomic, copy) PlayingCompletionBlock playingCompletionBlock;
@property(nonatomic, copy) AudioPlayerDecoreErrorBlock audioPlayerErrorBlock;


+(AudioManager*)sharedAudioManager;

//Recorder related mehtods
-(RecordingStatus)startRecording:(NSString*)fileName;
-(RecordingStatus)toggleRecording;
-(RecordingStatus)stopRecording;

//Player related methods
-(PlayingStatus)startPlaying:(NSString*)fileName;
-(PlayingStatus)togglePlaying;
-(PlayingStatus)stopPlaying;

//Getting status of the recorde and player
-(RecorderStatus)getRecorderStatus;
-(PlayerStatus)getPlayerStatus;

//Set player seek time, blocks, file name 
-(void)setCurrentPlayingTime:(double)secs;
-(void)invalidateAllProgressBlock;

-(void)assignTempFileName:(NSString*)fileName;
@end
