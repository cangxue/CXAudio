//
//  CXAudioManger.h
//  CXAudio
//
//  Created by xiaoma on 17/5/9.
//  Copyright © 2017年 CX. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface CXAudioManger : NSObject

+ (CXAudioManger *)sharedInstance;

#pragma mark - AudioPlayer
// Play the audio
- (void)asyncPlayingWithPath:(NSString *)aFilePath
                updateMeters:(void(^)(float meters, NSTimeInterval currentTime))palyMeter
                  completion:(void(^)(NSError *error))completion;
// Stop playing
- (void)stopPlaying;

-(BOOL)isPlaying;

#pragma mark - AudioRecorder
// Start recording
- (void)asyncStartRecordingWithFileName:(NSString *)fileName
                            updateMeters:(void(^)(float meters, NSTimeInterval currentTime))updateMeter
                             completion:(void(^)(NSError *error))completion;

// Stop recording
-(void)asyncStopRecordingWithCompletion:(void(^)(NSString *recordPath,
                                                 NSInteger aDuration,
                                                 NSError *error))completion;
// Cancel recording
-(void)cancelCurrentRecording;

-(BOOL)isRecording;

// Get the saved data path
+ (NSString*)dataPath;

@end
