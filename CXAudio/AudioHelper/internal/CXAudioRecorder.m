//
//  CXAudioRecorder.m
//  CXAudio
//
//  Created by xiaoma on 17/5/8.
//  Copyright © 2017年 CX. All rights reserved.
//

#import "CXAudioRecorder.h"

//#include "amrFileCodec.h"
//#import "CXAudioPath.h"
//
//#import "VoiceConverter.h"

@interface CXAudioRecorder () <AVAudioRecorderDelegate> {
    
    NSDate *_startDate;
    NSDate *_endDate;
    
    void (^recordFinish)(NSString *recordPath);
    
}

@property (nonatomic, strong) AVAudioRecorder *recorder;
@property (nonatomic, strong) NSDictionary *recordSetting;

@property (nonatomic, copy) RecordWithMeters recordMeters;
@property (nonatomic) dispatch_source_t recordTimer;

@end

@implementation CXAudioRecorder

+ (BOOL)isRecording {
    return [[CXAudioRecorder sharedInstance] isRecording];
}

// Start recording
+ (void)asyncStartRecordingWithPreparePath:(NSString *)aFilePath
                              updateMeters:(RecordWithMeters)meters
                                completion:(void(^)(NSError *error))completion {
    [[CXAudioRecorder sharedInstance] asyncStartRecordingWithPreparePath:aFilePath
                                                            updateMeters:meters
                                                              completion:completion];
}

// Stop recording
+ (void)asyncStopRecordingWithCompletion:(void(^)(NSString *recordPath))completion {
    [[CXAudioRecorder sharedInstance] asyncStopRecordingWithCompletion:completion];
}

// pause recording
+ (void)asyncPauseRecording {
    [[CXAudioRecorder sharedInstance] asyncPauseRecording];
}

// goon recording
+ (void)asyncGoonRecording {
    [[CXAudioRecorder sharedInstance] asyncGoonRecording];
}


// Cancel recording
+ (void)cancelCurrentRecording {
    [[CXAudioRecorder sharedInstance] cancelCurrentRecording];
}

+ (AVAudioRecorder *)recorder {
    return [CXAudioRecorder sharedInstance].recorder;
}

//duration
+ (NSTimeInterval)duration {
    return [CXAudioRecorder sharedInstance].recorder.currentTime;
}

#pragma mark - getter
- (NSDictionary *)recordSetting
{
    if (!_recordSetting) {
        _recordSetting = [[NSDictionary alloc] initWithObjectsAndKeys:
                          [NSNumber numberWithFloat: 8000.0],AVSampleRateKey, //采样率
                          [NSNumber numberWithInt: kAudioFormatLinearPCM],AVFormatIDKey,
                          [NSNumber numberWithInt:16],AVLinearPCMBitDepthKey,//采样位数 默认 16
                          [NSNumber numberWithInt: 1], AVNumberOfChannelsKey,//通道的数目
                          nil];
    }
    
    return _recordSetting;
}

#pragma mark - Private
+(CXAudioRecorder *)sharedInstance{
    static CXAudioRecorder *audioRecorder = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        audioRecorder = [[self alloc] init];
    });
    
    return audioRecorder;
}

-(instancetype)init{
    if (self = [super init]) {
        
    }
    
    return self;
}

-(void)dealloc{
    if (_recorder) {
        _recorder.delegate = nil;
        [_recorder stop];
        [_recorder deleteRecording];
        _recorder = nil;
    }
    recordFinish = nil;
}

-(BOOL)isRecording{
    return !!_recorder;
}

// Start recording，save the audio file to the path
- (void)asyncStartRecordingWithPreparePath:(NSString *)aFilePath
                              updateMeters:(RecordWithMeters)meters
                                completion:(void(^)(NSError *error))completion
{
    self.recordMeters = meters;
    NSError *error = nil;
    NSString *wavFilePath = [[aFilePath stringByDeletingPathExtension]
                             stringByAppendingPathExtension:@"wav"];
    NSURL *wavUrl = [[NSURL alloc] initFileURLWithPath:wavFilePath];
    _recorder = [[AVAudioRecorder alloc] initWithURL:wavUrl
                                            settings:self.recordSetting
                                               error:&error];
    if(!_recorder || error)
    {
        _recorder = nil;
        if (completion) {
            error = [NSError errorWithDomain:@"Failed to initialize AVAudioRecorder"
                                        code:-1
                                    userInfo:nil];
            completion(error);
        }
        return ;
    }
    _startDate = [NSDate date];
    _recorder.meteringEnabled = YES;
    _recorder.delegate = self;
    
    if ([_recorder record]) {
        [self startTimer];
    }
    
    
    if (completion) {
        completion(error);
    }
}

// Stop recording
-(void)asyncStopRecordingWithCompletion:(void(^)(NSString *recordPath))completion{
    recordFinish = completion;
    [self stopTimer];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self->_recorder stop];
    });
}

// Cancel recording
- (void)cancelCurrentRecording
{
    _recorder.delegate = nil;
    if (_recorder.recording) {
        [_recorder stop];
    }
    _recorder = nil;
    recordFinish = nil;
    
    [self stopTimer];
}

// pause recording
- (void)asyncPauseRecording {
    if (_recorder.recording) {
        [_recorder pause];
        [self stopTimer];
    }
}

// goon recording
- (void)asyncGoonRecording {
    if (_recorder) {
        if ([_recorder record]) {
            [self startTimer];
        }
    }
}


#pragma mark - AVAudioRecorderDelegate
- (void)audioRecorderDidFinishRecording:(AVAudioRecorder *)recorder
                           successfully:(BOOL)flag
{
    NSString *recordPath = [[_recorder url] path];
    if (recordFinish) {
        if (!flag) {
            recordPath = nil;
        }
        recordFinish(recordPath);
    }
    _recorder = nil;
    recordFinish = nil;
    [self stopTimer];
}

- (void)audioRecorderEncodeErrorDidOccur:(AVAudioRecorder *)recorder
                                   error:(NSError *)error{
    [self stopTimer];
    NSLog(@"audioRecorderEncodeErrorDidOccur");
}

#pragma mark - dispatch_source_create
- (void)stopTimer {
    if (self.recordTimer) {
        dispatch_source_cancel(self.recordTimer);
    }
    self.recordTimer = NULL;
}

- (void)startTimer {
    self.recordTimer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_main_queue());
    dispatch_source_set_timer(self.recordTimer, DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC, 0 *NSEC_PER_SEC);
    dispatch_source_set_event_handler(self.recordTimer, ^{
        [self.recorder updateMeters];
        self.recordMeters([self.recorder averagePowerForChannel:0], self.recorder.currentTime);
    });
    dispatch_resume(self.recordTimer);
}

@end
