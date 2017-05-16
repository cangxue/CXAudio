//
//  CXAudioManger.m
//  CXAudio
//
//  Created by xiaoma on 17/5/9.
//  Copyright © 2017年 CX. All rights reserved.
//

#import "CXAudioManger.h"
#import "CXAudioRecorder.h"
#import "CXAudioPlayer.h"
#import "CXErrorCode.h"
#import "VoiceConverter.h"

typedef NS_ENUM(NSInteger, EMAudioSession){
    EM_DEFAULT = 0,
    EM_AUDIOPLAYER,
    EM_AUDIORECORDER
};

@implementation CXAudioManger
//#pragma mark - AudioPlayer
//// Play the audio
//- (void)asyncPlayingWithPath:(NSString *)aFilePath
//                  completion:(void(^)(NSError *error))completon {
//    
//}
//// Stop playing
//- (void)stopPlaying;
//
//- (void)stopPlayingWithChangeCategory:(BOOL)isChange {
//    
//}
//
//-(BOOL)isPlaying {
//    
//}
//
//#pragma mark - AudioRecorder
//// Start recording
//- (void)asyncStartRecordingWithFileName:(NSString *)fileName
//                             completion:(void(^)(NSError *error))completion {
//    
//}
//
//// Stop recording
//-(void)asyncStopRecordingWithCompletion:(void(^)(NSString *recordPath,
//                                                 NSInteger aDuration,
//                                                 NSError *error))completion {
//    
//}
//// Cancel recording
//-(void)cancelCurrentRecording {
//    
//}
//
//-(BOOL)isRecording {
//    
//}


#pragma mark - Convert

- (BOOL)convertAMR:(NSString *)amrFilePath
             toWAV:(NSString *)wavFilePath
{
    BOOL ret = NO;
    BOOL isFileExists = [[NSFileManager defaultManager] fileExistsAtPath:amrFilePath];
    if (isFileExists) {
        [VoiceConverter amrToWav:amrFilePath wavSavePath:wavFilePath];
        isFileExists = [[NSFileManager defaultManager] fileExistsAtPath:wavFilePath];
        if (isFileExists) {
            ret = YES;
        }
    }
    
    return ret;
}

- (BOOL)convertWAV:(NSString *)wavFilePath
             toAMR:(NSString *)amrFilePath {
    BOOL ret = NO;
    BOOL isFileExists = [[NSFileManager defaultManager] fileExistsAtPath:wavFilePath];
    if (isFileExists) {
        [VoiceConverter wavToAmr:wavFilePath amrSavePath:amrFilePath];
        isFileExists = [[NSFileManager defaultManager] fileExistsAtPath:amrFilePath];
        if (!isFileExists) {
            
        } else {
            ret = YES;
        }
    }
    
    return ret;
}

#pragma mark - dataPath
+ (NSString*)dataPath
{
    NSString *dataPath = [NSString stringWithFormat:@"%@/Library/appdata/chatbuffer", NSHomeDirectory()];
    NSFileManager *fm = [NSFileManager defaultManager];
    if(![fm fileExistsAtPath:dataPath]){
        [fm createDirectoryAtPath:dataPath
      withIntermediateDirectories:YES
                       attributes:nil
                            error:nil];
    }
    return dataPath;
}
@end
