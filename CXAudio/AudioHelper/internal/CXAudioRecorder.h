//
//  CXAudioRecorder.h
//  CXAudio
//
//  Created by xiaoma on 17/5/8.
//  Copyright © 2017年 CX. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

//实时返回当前录音的平均功率，和录制时间
typedef void (^RecordWithMeters)(float meters, NSTimeInterval currentTime);

@interface CXAudioRecorder : NSObject

+(BOOL)isRecording;

// Start recording
+ (void)asyncStartRecordingWithPreparePath:(NSString *)aFilePath
                              updateMeters:(RecordWithMeters)meters
                                completion:(void(^)(NSError *error))completion;
// Stop recording
+(void)asyncStopRecordingWithCompletion:(void(^)(NSString *recordPath))completion;

// Cancel recording
+(void)cancelCurrentRecording;

// Current recorder
+(AVAudioRecorder *)recorder;

//duration
+ (NSTimeInterval)duration;


@end
