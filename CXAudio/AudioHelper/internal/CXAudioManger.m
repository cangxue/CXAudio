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

typedef NS_ENUM(NSInteger, CXAudioSession){
    CX_DEFAULT = 0,
    CX_AUDIOPLAYER,
    CX_AUDIORECORDER
};


@interface CXAudioManger() {
    NSDate *_recorderStartDate;
    NSDate *_recorderEndDate;
}

@end


@implementation CXAudioManger
#pragma mark - AudioPlayer
// Play the audio
- (void)asyncPlayingWithPath:(NSString *)aFilePath
                  completion:(void(^)(NSError *error))completon {
    BOOL isNeedSetActive = YES;
    //cancel if it is currently playing
    if ([CXAudioPlayer isPlaying]) {
        [CXAudioPlayer stopCurrentPlaying];
        isNeedSetActive = NO;
    }
    
    if (isNeedSetActive) {
        [self setupAudioSessionCategory:CX_AUDIOPLAYER isActive:YES];
    }
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *wavFilePath = [[aFilePath stringByDeletingPathExtension] stringByAppendingPathExtension:@"wav"];
    if (![fileManager fileExistsAtPath:wavFilePath]) {
        //格式转换
        BOOL covertRet = [self convertAMR:aFilePath toWAV:wavFilePath];
        if (!covertRet) {
            if (completon) {
                NSError *error = [NSError errorWithDomain:@"File format conversion failed" code:EMErrorFileTypeConvertionFailure userInfo:nil];
                completon(error);
            }
            return;
        }
    }

    [CXAudioPlayer asyncPlayingWithPath:wavFilePath completion:^(NSError *error) {
        [self setupAudioSessionCategory:CX_DEFAULT isActive:NO];
        
        if (completon) {
            completon(error);
        }
    }];
}

// Stop playing
- (void)stopPlaying {
    [CXAudioPlayer stopCurrentPlaying];
    [self setupAudioSessionCategory:CX_DEFAULT isActive:NO];
}

-(BOOL)isPlaying {
    return [CXAudioPlayer isPlaying];
}

#pragma mark - AudioRecorder
// Start recording
- (void)asyncStartRecordingWithFileName:(NSString *)fileName
                             completion:(void(^)(NSError *error))completion {
    NSError *error = nil;
    
    if (!fileName || fileName.length  == 0) {
        error = [NSError errorWithDomain:@"File path not exist"
                                    code:-1
                                userInfo:nil];
        completion(error);
        return ;
    }
    
    if ([self isRecording]) {
        [CXAudioRecorder cancelCurrentRecording];
    }
    
    [self setupAudioSessionCategory:CX_AUDIORECORDER isActive:YES];
    
    NSString *recordPath = [NSString stringWithFormat:@"%@/%@",[self dataPath],fileName];
    
    _recorderStartDate = [NSDate date];
    [CXAudioRecorder asyncStartRecordingWithPreparePath:recordPath completion:completion];
    
}

// Stop recording
-(void)asyncStopRecordingWithCompletion:(void(^)(NSString *recordPath,
                                                 NSInteger aDuration,
                                                 NSError *error))completion {
    if (![self isRecording]) {
        if (completion) {
            NSError *error = nil;
            error = [NSError errorWithDomain:@"Recording has not yet begun"
                                        code:EMErrorAudioRecordNotStarted
                                    userInfo:nil];
            completion(nil, 0, error);
        }
        return;
    }
    
    __weak typeof(self) weakSelf = self;
    
    _recorderEndDate = [NSDate date];
    
    [CXAudioRecorder asyncStopRecordingWithCompletion:^(NSString *recordPath) {
        if (completion) {
            if (recordPath) {
                //格式转化
                NSString *amrFilePath = [[recordPath stringByDeletingPathExtension] stringByAppendingPathExtension:@"amr"];
                
                BOOL convertResult = [self convertWAV:recordPath toAMR:amrFilePath];
                
                NSError *error = nil;
                if (convertResult) {
                    //移除
                    NSFileManager *fileManager = [NSFileManager defaultManager];
                    [fileManager removeItemAtPath:recordPath error:nil];
                } else {
                    error = [NSError errorWithDomain:@"File format conversion failed"
                                                code:EMErrorFileTypeConvertionFailure
                                            userInfo:nil];
                }
                
                completion(amrFilePath,(int)[_recorderEndDate timeIntervalSinceDate:_recorderStartDate],error);
            }
            [weakSelf setupAudioSessionCategory:CX_DEFAULT isActive:NO];
        }
    }];
    
}
// Cancel recording
-(void)cancelCurrentRecording {
    [CXAudioRecorder cancelCurrentRecording];
}

-(BOOL)isRecording {
    return [CXAudioRecorder isRecording];
    
}

#pragma mark - Private
//设置音频会话，处理后台播放
- (NSError *)setupAudioSessionCategory:(CXAudioSession)session isActive:(BOOL)isActive {
    NSError *error = nil;
    NSString *audioSessionCategory = nil;
    switch (session) {
        case CX_AUDIOPLAYER:
            //后台播放，也是独占的
            audioSessionCategory = AVAudioSessionCategoryPlayback;
            break;
        case CX_AUDIORECORDER:
            //录音模式，用于录音时使用
            audioSessionCategory = AVAudioSessionCategoryRecord;
            break;
        default:
            // 	混音播放，可以与其他音频应用同时播放
            audioSessionCategory = AVAudioSessionCategoryAmbient;
            break;
    }
    
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    [audioSession setCategory:audioSessionCategory error:nil];
    BOOL success = [audioSession setActive:isActive error:&error];
    
    if (!success) {
        error = [NSError errorWithDomain:@"failed to initialize AVAudioSession"
                                    code:-1
                                userInfo:nil];
    }
    
    return error;
}

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
- (NSString*)dataPath
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
