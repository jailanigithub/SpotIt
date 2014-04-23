//
//  Constants.m
//  eMT
//
//  Created by aram on 3/14/14.
//  Copyright (c) 2014 NPCompete. All rights reserved.
//

#import "Constants.h"
#import <AVFoundation/AVFoundation.h>

#if (EncodingFormat == ILPC_FORMAT)

    NSInteger const FORMAT_ID   = kAudioFormatiLBC;
    NSInteger const SAMPLE_RATE = 8000;
    NSInteger const BIT_RATE_KEY = 15200;//13.2K
    NSString *const AUDIO_EXTENSION = @".lbc";
    NSString *const AUDIO_MEDIA_TYPE = @"audio/iLBC";

#elif (EncodingFormat == AMR_FORMAT)
    NSInteger const FORMAT_ID   = kAudioFormatAMR;
    NSInteger const SAMPLE_RATE = 8000;
    NSInteger const BIT_RATE_KEY = 12200;//4.75, 5.15, 5.90, 6.70, 7.40, 7.95, 10.2, or 12.2 (kbit/s,)
    NSString *const AUDIO_EXTENSION = @".amr";
    NSString *const AUDIO_MEDIA_TYPE = @"audio/amr";

#elif (EncodingFormat == M4A_FORMAT)
    NSInteger const FORMAT_ID   = kAudioFormatMPEG4AAC;
    NSInteger const SAMPLE_RATE = 16000;
    NSInteger const BIT_RATE_KEY = 32000;//7.4K,10.2K, 12.2K
    NSString *const AUDIO_EXTENSION = @".m4a";
    NSString *const AUDIO_MEDIA_TYPE = @"audio/aac";

#elif (EncodingFormat == AAC_FORMAT)
    NSInteger const FORMAT_ID   = kAudioFormatMPEG4AAC;
    NSInteger const SAMPLE_RATE = 16000;
    NSInteger const BIT_RATE_KEY = 32000;//32,40,48,56,64,80,96,128,160,192,256,320
    NSString *const AUDIO_EXTENSION = @".aac";
    NSString *const AUDIO_MEDIA_TYPE = @"audio/aac";

#endif


NSInteger const BIT_DEPTH_KEY       = 16;

NSInteger const NUMBER_OF_CHANNEL   = 1;
NSInteger const AUDIO_QUALITY       = AVAudioQualityMedium;

