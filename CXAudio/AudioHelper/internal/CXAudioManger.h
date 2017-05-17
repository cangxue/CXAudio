//
//  CXAudioManger.h
//  CXAudio
//
//  Created by xiaoma on 17/5/9.
//  Copyright © 2017年 CX. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface CXAudioManger : NSObject

#pragma mark - AudioPlayer
// Play the audio
- (void)asyncPlayingWithPath:(NSString *)aFilePath
                  completion:(void(^)(NSError *error))completon;
// Stop playing
- (void)stopPlaying;

-(BOOL)isPlaying;

#pragma mark - AudioRecorder
// Start recording
- (void)asyncStartRecordingWithFileName:(NSString *)fileName
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
