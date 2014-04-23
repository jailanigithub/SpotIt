//
//  AudioManager.m
//  eMT
//
//  Created by aram on 3/18/14.
//  Copyright (c) 2014 NPCompete. All rights reserved.
//

#import "AudioManager.h"
#import "FileManager.h"
#import "Constants.h"

@interface AudioManager()
{
    float pitch;
}

@end

/*
NSInteger const FORMAT_ID   = kAudioFormatMPEG4AAC;
NSInteger const SAMPLE_RATE = 16000;
NSInteger const BIT_RATE_KEY = 32000;//32,40,48,56,64,80,96,128,160,192,256,320
NSString *const AUDIO_EXTENSION = @".aac";
NSString *const AUDIO_MEDIA_TYPE = @"audio/aac";

NSInteger const BIT_DEPTH_KEY       = 16;

NSInteger const NUMBER_OF_CHANNEL   = 1;
NSInteger const AUDIO_QUALITY       = AVAudioQualityMedium;
*/

@interface AudioManager()

@property(nonatomic, strong) NSMutableDictionary *recordingParamsDicionary;
@property(nonatomic, strong) NSString *recordingFormat;
@property(nonatomic, strong) AVAudioRecorder *recorder;
@property(nonatomic, strong) AVAudioPlayer *player;
@property(nonatomic, strong) NSString *fileName;

@property(nonatomic, strong) NSTimer *playerTimer;
@property(nonatomic, strong) NSTimer *pitchTimer;
@property(nonatomic) BOOL isRecorderPaused, isPlayerPaused;

@end

@implementation AudioManager

+(AudioManager*)sharedAudioManager{
    
    static dispatch_once_t predicate = 0;
    static AudioManager *sharedInstance = nil;
    dispatch_once(&predicate,  ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

-(void)assignTempFileName:(NSString*)fileName
{
    self.fileName = fileName;
}

#pragma amrk Recorder related functions
#pragma mark getRecorderStatus
-(RecorderStatus)getRecorderStatus
{
    if (self.recorder.isRecording)
        return RecorderStatusRecording;
    
    else if (self.isRecorderPaused)
        return RecorderStatusPaused;
    else
        return RecorderStatusIdle;
}

-(NSMutableDictionary*)recordingParamsDicionary
{
    if(!_recordingParamsDicionary)
    {
        _recordingParamsDicionary = [[NSMutableDictionary alloc]init];
        
        [_recordingParamsDicionary setObject:[NSNumber numberWithInt:FORMAT_ID] forKey: AVFormatIDKey];
        [_recordingParamsDicionary setObject:[NSNumber numberWithInt:SAMPLE_RATE] forKey: AVSampleRateKey];
        [_recordingParamsDicionary setObject:[NSNumber numberWithInt:NUMBER_OF_CHANNEL] forKey:AVNumberOfChannelsKey];
        
        [_recordingParamsDicionary setObject:[NSNumber numberWithInt:BIT_RATE_KEY] forKey:AVEncoderBitRateKey];
        [_recordingParamsDicionary setObject:[NSNumber numberWithInt:BIT_DEPTH_KEY] forKey:AVLinearPCMBitDepthKey];
        [_recordingParamsDicionary setObject:[NSNumber numberWithInt:AUDIO_QUALITY] forKey: AVEncoderAudioQualityKey];
        
    }
    return _recordingParamsDicionary;
}

-(AVAudioRecorder*)recorder{
    
    if(!_recorder)
    {
        self.fileName = (self.fileName) ? self.fileName : [[FileManager sharedFileManager] getAudioFilePath];

        NSError *recordingError = nil;
        _recorder = [[ AVAudioRecorder alloc] initWithURL:[NSURL fileURLWithPath:self.fileName] settings:self.recordingParamsDicionary error:&recordingError];
        _recorder.meteringEnabled = YES;
        
        if (recordingError)
        {
            NSLog(@"Recodring error: %@", recordingError.description);
        }
    }
    return _recorder;
}

#pragma mark StartRecorder and timer
-(void)startRecorderAndTimer
{
    self.recorder.meteringEnabled = YES;
    [self.recorder record];
    self.isRecorderPaused = NO;
    [self enableRecordingPitchTimer];
}

#pragma mark StopRecorder and timer
-(void)stopRecorderAndInvalidateTimer
{
    self.isRecorderPaused = NO;
    [self.recorder stop];
    [self invalidateRecorderAndTimer];
}

#pragma mark EnableRecordingPitchTimer
-(void)enableRecordingPitchTimer
{
    self.pitchTimer = [NSTimer scheduledTimerWithTimeInterval: 0.1 target: self selector: @selector(pitchTimerCallBack:) userInfo: nil repeats: YES];
}

#pragma mark DisableRecorderAndPitchTimer
-(void)invalidateRecorderAndTimer
{
    self.recorder = nil;
    [self.pitchTimer invalidate];
}

#pragma mark Start Recording
-(RecordingStatus)startRecording:(NSString*)fileName
{
    if(![self.fileName isEqualToString:fileName])
    {
        self.fileName = fileName;
        self.recorder = nil;
    }
    
    if(self.recorder.isRecording || self.isRecorderPaused)
    {
        return [self toggleRecording];
    }
    else
    {
        //Activate audio session
        if(![self activateAudioSession])
            return RecordingFailedToStartAudioSession;
        
        if ([self.recorder prepareToRecord] == YES)
        {
            [self startRecorderAndTimer];
            [[FileManager sharedFileManager]rollbackTheRecordedAudios];
            return RecordingStarted;
        }
        else
        {
            NSLog(@"Error: Recorder not ready:");
            return RecordingFailedToStart;
        }
    }
}

#pragma mark Toggle recording
-(RecordingStatus)toggleRecording
{
    if(self.recorder.recording)
    {
        [self pauseRecording];
        return RecordingPaused;
    }
    else
    {
        [self resumeRecording];
        return RecordingResumed;
    }
}

#pragma mark PauseRecording
-(RecordingStatus)pauseRecording
{
    [self.recorder pause];
    self.isRecorderPaused = YES;
    [self.pitchTimer invalidate];
    return RecordingPaused;
}

#pragma mark resumeRecording
-(RecordingStatus)resumeRecording
{
    [self startRecorderAndTimer];
    return RecordingResumed;
}

#pragma mark PauseRecording
-(RecordingStatus)stopRecording
{
    RecorderStatus recorderStatus = [self getRecorderStatus];

    if(recorderStatus == RecorderStatusPaused || recorderStatus == RecorderStatusRecording)
    {
        [self stopRecorderAndInvalidateTimer];
        return RecordingStopped;
    }
    return RecordingUnkownState;
}

#pragma mark PitchTimerCallback
-(void)pitchTimerCallBack:(NSTimer*)timer
{
    [self.recorder updateMeters];
    float linear1 = pow (10, [self.recorder averagePowerForChannel:0] / 20);
    
    if (linear1>0.03)
        pitch = linear1+.20;
    else
        pitch = 0.0;
    
    pitch =linear1;
    
    float minutes = floor(self.recorder.currentTime/60);
    float seconds = self.recorder.currentTime - (minutes * 60);
    
    NSString *time = [NSString stringWithFormat:@"%0.0f.%0.0f",minutes, seconds];
    if(self.recordingProgressBlock)
        self.recordingProgressBlock(time, self.recorder.currentTime,pitch);
}

#pragma mark audioplayer related functions
#pragma mark Enable Player Timer
-(void)enablePlayerTimer
{
    self.playerTimer = [NSTimer scheduledTimerWithTimeInterval: 0.5 target: self selector: @selector(playerTimerCallBack:) userInfo: nil repeats: YES];
}

#pragma mark InvalidatePlayeranTimer
-(void)invalidatePlayerAndTimer
{
    self.player = nil;
    [self.playerTimer invalidate];
}

#pragma mark startPlayerAndTimer
-(void)startplayerAndTimer
{
    [self.player play];
    self.isPlayerPaused = NO;
    [self enablePlayerTimer];
}

#pragma mark stopPayerAndInvalidateTimer
-(void)stopPlayerAndInvalidateTimer
{
    self.isPlayerPaused = NO;
    [self.player stop];
    [self invalidatePlayerAndTimer];
}

#pragma mark getPlayerStatus
-(PlayerStatus)getPlayerStatus
{
    if(self.player.isPlaying)
        return PlayerStatusPlaying;

    else if(self.isPlayerPaused)
        return PlayerStatusPaused;
    
    else
        return PlayerStatusIdle;
}

#pragma mark
#pragma mark playerTimerCallback
-(void)playerTimerCallBack:(NSTimer*)timer{
    
    if(self.playingProgressBlock)
    {
        float minutes = floor(self.player.currentTime/60);
        float seconds = self.player.currentTime - (minutes * 60);
        
        NSString *time = [NSString stringWithFormat:@"%0.0f.%0.0f",minutes, seconds];
//        NSLog(@"Playing timer %@", time);
        self.playingProgressBlock((time));
    }
}

#pragma mark activateAudioSession
-(BOOL)activateAudioSession{

    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    NSError *err = nil;
    
    if(![audioSession setCategory:AVAudioSessionCategoryPlayAndRecord error:&err])
    {
        NSLog(@"Error: failed to set category for audio session+++ description %@", err.description);
        return NO;
    }
    
    if(![audioSession setCategory:AVAudioSessionCategoryMultiRoute error:&err])
    {
        NSLog(@"Error: failed to set category for audio session+++ description %@", err.description);
        return NO;
    }
    
    BOOL active = [audioSession setActive: YES error: &err];
    if (!active)
        NSLog(@"Failed to set category on AVAudioSession+++ Description %@", err.description);
    
    return YES;
}

#pragma mark AVAudiopayer delegates
- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag{

    if(self.playingCompletionBlock)
        self.playingCompletionBlock();
        
    [self stopPlaying];
}

- (void)audioPlayerDecodeErrorDidOccur:(AVAudioPlayer *)player error:(NSError *)error{
    
    NSLog(@"Error: AudioPlayer DecodeError Occured %@", error.description);
    if(self.audioPlayerErrorBlock)
        self.audioPlayerErrorBlock(error);
}

#pragma mark startplaying
-(PlayingStatus)startPlaying:(NSString*)fileName{
    
    if(self.player.isPlaying || self.isPlayerPaused)
    {
        PlayingStatus status = [self togglePlaying];
        return status;
    }
    else
    {
        //Activate audio session
        if(![self activateAudioSession])
            return PlayingFailedToStartAudioSession;
        
        //Load audio url
        NSURL *url = [NSURL fileURLWithPath:fileName];
        NSError *error;

        //create audio player with url
        self.player = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&error];
        self.player.numberOfLoops = 0;
        [self.player setDelegate: self];

        //Check the player is ready for play
        if(![self.player prepareToPlay]){
            NSLog(@"Failed to start player %@", error.description);
            return PlayingFailedToStart;
        }
        
        [self startplayerAndTimer];
        return PlayingStarted;
    }
}

#pragma mark togglePlaying
-(PlayingStatus)togglePlaying
{
    if(self.player.isPlaying)
    {
        return  [self pausePlayer];
    }

    else if(self.isPlayerPaused)
    {
        return  [self resumePlayer];
    }
    
    return PlayingUnknownState;
}

#pragma mark resumePlaying
-(PlayingStatus)resumePlayer
{
    [self.player play];
    [self enablePlayerTimer];
    return PlayingResumed;
}

#pragma mark pausePlaying
-(PlayingStatus)pausePlayer
{
    [self.player pause];
    self.isPlayerPaused = YES;
    [self.playerTimer invalidate];
    return PlayingPaused;
}

#pragma mark setCurrentPlaying time
-(void)setCurrentPlayingTime:(double)secs
{
    if (self.player.isPlaying || self.isPlayerPaused)
    {
        [self.player setCurrentTime:secs];
    }
    else
    {
        NSLog(@"Error: Can't set current time. Audio  player not started yet");
    }
}

#pragma invalidateCompletionBlock
-(void)invalidateAllProgressBlock
{
    self.playingProgressBlock = nil;
    self.playingCompletionBlock = nil;
    
    self.recordingProgressBlock = nil;
    self.audioPlayerErrorBlock = nil;
}

#pragma mark stopPlaying
-(PlayingStatus)stopPlaying
{
    [self.player stop];
    [self invalidatePlayerAndTimer];
    self.isPlayerPaused = NO;
    return PlayingStopped;
}

@end
