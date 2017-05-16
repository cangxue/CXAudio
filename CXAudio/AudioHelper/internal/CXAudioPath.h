//
//  CXAudioPath.h
//  CXAudio
//
//  Created by xiaoma on 17/5/8.
//  Copyright © 2017年 CX. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CXAudioPath : NSObject
//origin
+ (NSString *)recordPathOrigin;
//origin -> amr
+ (NSString *)recordPathOriginToAMR;
//amr -> wav
+ (NSString *)recordPathAMRToWAV;

@end
