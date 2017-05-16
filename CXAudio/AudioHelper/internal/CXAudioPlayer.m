//
//  CXAudioPlayer.m
//  CXAudio
//
//  Created by xiaoma on 17/5/8.
//  Copyright © 2017年 CX. All rights reserved.
//

#import "CXAudioPlayer.h"
#import <AVFoundation/AVFoundation.h>

@interface CXAudioPlayer () <AVAudioPlayerDelegate> {
    AVAudioPlayer *_player;
    void (^playFinish)(NSError *error);
}

@end

@implementation CXAudioPlayer

#pragma mark - public
+ (BOOL)isPlaying{
    return [[CXAudioPlayer sharedInstance] isPlaying];
}

+ (NSString *)playingFilePath{
    return [[CXAudioPlayer sharedInstance] playingFilePath];
}

+ (void)asyncPlayingWithPath:(NSString *)aFilePath
                  completion:(void(^)(NSError *error))completon{
    [[CXAudioPlayer sharedInstance] asyncPlayingWithPath:aFilePath
                                                  completion:completon];
}

+ (void)stopCurrentPlaying{
    [[CXAudioPlayer sharedInstance] stopCurrentPlaying];
}


#pragma mark - private
+ (CXAudioPlayer *)sharedInstance{
    static CXAudioPlayer *audioPlayer = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        audioPlayer = [[self alloc] init];
    });
    
    return audioPlayer;
}

- (BOOL)isPlaying
{
    return !!_player;
}

// Get the path of what is currently being played
- (NSString *)playingFilePath
{
    NSString *path = nil;
    if (_player && _player.isPlaying) {
        path = _player.url.path;
    }
    
    return path;
}

- (void)asyncPlayingWithPath:(NSString *)aFilePath
                  completion:(void(^)(NSError *error))completon{
    playFinish = completon;
    NSError *error = nil;
    NSFileManager *fm = [NSFileManager defaultManager];
    if (![fm fileExistsAtPath:aFilePath]) {
        error = [NSError errorWithDomain:@"File path not exist"
                                    code:-1
                                userInfo:nil];
        if (playFinish) {
            playFinish(error);
        }
        playFinish = nil;
        
        return;
    }
    
    NSURL *wavUrl = [[NSURL alloc] initFileURLWithPath:aFilePath];
    _player = [[AVAudioPlayer alloc] initWithContentsOfURL:wavUrl error:&error];
    if (error || !_player) {
        _player = nil;
        error = [NSError errorWithDomain: @"Failed to initialize AVAudioPlayer"
                                    code:-1
                                userInfo:nil];
        if (playFinish) {
            playFinish(error);
        }
        playFinish = nil;
        return;
    }
    
    _player.delegate = self;
    [_player prepareToPlay];
    [_player play];
}

- (void)stopCurrentPlaying{
    if(_player){
        _player.delegate = nil;
        [_player stop];
        _player = nil;
    }
    if (playFinish) {
        playFinish = nil;
    }
}

- (void)dealloc{
    if (_player) {
        _player.delegate = nil;
        [_player stop];
        _player = nil;
    }
    playFinish = nil;
}

#pragma mark - AVAudioPlayerDelegate
- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player
                       successfully:(BOOL)flag{
    if (playFinish) {
        playFinish(nil);
    }
    if (_player) {
        _player.delegate = nil;
        _player = nil;
    }
    playFinish = nil;
}

- (void)audioPlayerDecodeErrorDidOccur:(AVAudioPlayer *)player
                                 error:(NSError *)error{
    if (playFinish) {
        NSError *error = [NSError errorWithDomain:@"Play failure"
                                             code:-1
                                         userInfo:nil];
        playFinish(error);
    }
    if (_player) {
        _player.delegate = nil;
        _player = nil;
    }
}



@end
