//
//  ViewController.m
//  CXAudio
//
//  Created by xiaoma on 17/5/8.
//  Copyright © 2017年 CX. All rights reserved.
//

#import "ViewController.h"
#import "CXAudioManger.h"

#define kRecorderFileName @"CXAudioRecordFileName"

@interface ViewController ()

@property (weak, nonatomic) IBOutlet UILabel *filePathLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

#pragma mark - recorder
- (IBAction)startRecorderClickBtn:(id)sender {
    [[CXAudioManger sharedInstance] asyncStartRecordingWithFileName:kRecorderFileName updateMeters:^(float meters, NSTimeInterval currentTime) {
        self.timeLabel.text = [NSString stringWithFormat:@"时间：%@\n频率：%.2f",[self timeFormatted:currentTime], meters + 60];
    } completion:^(NSError *error) {
        if (error) {
            NSLog(@"录音失败");
        }
    }];
}

- (IBAction)pauseRecorderClickBtn:(id)sender {
    [[CXAudioManger sharedInstance] asyncPauseRecording];
}

- (IBAction)goonRecorderClickBtn:(id)sender {
    [[CXAudioManger sharedInstance] asyncGoonRecording];
}

- (IBAction)endRecorderClickBtn:(id)sender {
    if ([CXAudioManger sharedInstance].isRecording) {
        [[CXAudioManger sharedInstance] asyncStopRecordingWithCompletion:^(NSString *recordPath, NSInteger aDuration, NSError *error) {
            if (!error) {
                self.filePathLabel.text = recordPath;
                NSLog(@"录音总时长：%ld",(long)aDuration);
            } else {
                NSLog(@"%@",error.description);
            }
        }];
    }
    
}

#pragma mark - palyer
- (IBAction)startPlayerClickBtn:(id)sender {
    [[CXAudioManger sharedInstance] asyncPlayingWithPath:kRecorderFileName updateMeters:^(float meters, NSTimeInterval currentTime) {
        self.timeLabel.text = [NSString stringWithFormat:@"时间：%@\n频率：%.2f",[self timeFormatted:currentTime], meters + 60];
    } completion:^(NSError *error) {
        if (error) {
            NSLog(@"%@",error.description);
        }
    }];
}

- (IBAction)pausePlayerClickBtn:(id)sender {
    [[CXAudioManger sharedInstance] asyncPausePlaying];
}

- (IBAction)goonPlayerClickBtn:(id)sender {
    [[CXAudioManger sharedInstance] asyncGoonPlaying];
}

- (IBAction)endPlayerClickBtn:(id)sender {
    if ([CXAudioManger sharedInstance].isPlaying) {
        [[CXAudioManger sharedInstance] stopPlaying];
    }
}

#pragma mark - 时间转换
- (NSString *)timeFormatted:(int)totalSeconds
{
    
    int seconds = totalSeconds % 60;
    int minutes = (totalSeconds / 60) % 60;
    int hours = totalSeconds / 3600;
    if (hours > 0) {
        return [NSString stringWithFormat:@"%02d:%02d:%02d",hours, minutes, seconds];
    } else {
        return [NSString stringWithFormat:@"%02d:%02d",minutes, seconds];
    }
    
}

@end
