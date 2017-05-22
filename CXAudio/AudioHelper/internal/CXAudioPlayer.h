//
//  CXAudioPlayer.h
//  CXAudio
//
//  Created by xiaoma on 17/5/8.
//  Copyright © 2017年 CX. All rights reserved.
//

#import <Foundation/Foundation.h>

//实时返回当前录音的平均功率，和录制时间
typedef void (^PlayWithMeters)(float meters, NSTimeInterval currentTime);

@interface CXAudioPlayer : NSObject

+ (BOOL)isPlaying;

// Get the path of what is currently being played
+ (NSString *)playingFilePath;

// Play the audio（wav）from the path
+ (void)asyncPlayingWithPath:(NSString *)aFilePath
                updateMeters:(PlayWithMeters)meters
                  completion:(void(^)(NSError *error))completon;

+ (void)stopCurrentPlaying;

@end
