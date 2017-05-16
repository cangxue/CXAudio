//
//  CXAudioRecorder.h
//  CXAudio
//
//  Created by xiaoma on 17/5/8.
//  Copyright © 2017年 CX. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

//失败回调
typedef void(^RecordFailedBlock)(NSError *error);

//成功回调
typedef void(^RecordSuccessBlock)(NSData *recordData);

@interface CXAudioRecorder : NSObject

+(BOOL)isRecording;

// Start recording
+ (void)asyncStartRecordingWithPreparePath:(NSString *)aFilePath
                                completion:(void(^)(NSError *error))completion;
// Stop recording
+(void)asyncStopRecordingWithCompletion:(void(^)(NSString *recordPath))completion;

// Cancel recording
+(void)cancelCurrentRecording;

// Current recorder
+(AVAudioRecorder *)recorder;


@end
