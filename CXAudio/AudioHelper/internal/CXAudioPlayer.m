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

@property (nonatomic, copy) PlayWithMeters playMeters;
@property (nonatomic) dispatch_source_t playTimer;

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
                updateMeters:(PlayWithMeters)meters
                  completion:(void(^)(NSError *error))completon {
    [[CXAudioPlayer sharedInstance] asyncPlayingWithPath:aFilePath
                                            updateMeters:meters
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
                updateMeters:(PlayWithMeters)meters
                  completion:(void(^)(NSError *error))completon{
    _playMeters = meters;
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
    _player.meteringEnabled = YES;
    [_player prepareToPlay];
    if ([_player play]) {
        self.playTimer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_main_queue());
        dispatch_source_set_timer(self.playTimer, DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC, 0 * NSEC_PER_SEC);
        dispatch_source_set_event_handler(self.playTimer, ^{
            [_player updateMeters];
            self.playMeters([_player averagePowerForChannel:0], _player.currentTime);
        });
        dispatch_resume(self.playTimer);
    }
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
    
    if (_playTimer) {
        [self stopTimer];
    }
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
    if (_playTimer) {
        [self stopTimer];
    }
}

#pragma mark - dispatch_source_create
- (void)stopTimer {
    if (self.playTimer) {
        dispatch_source_cancel(self.playTimer);
    }
    self.playTimer = NULL;
}

@end
