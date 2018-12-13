//
//  EHIVoiceCacheManager.h
//  J-IM-Demo
//
//  Created by yogurts on 2018/12/11.
//  Copyright © 2018 yogurts. All rights reserved.
//
//  缓存语音和图片管理类
//

#import <UIKit/UIKit.h>
#import "amr_wav_converter.h"
#import <AVFoundation/AVFoundation.h>

@interface EHINewCustomerServiceCacheManager : NSObject

/** 单例 */
+ (instancetype)sharedInstance;

/**
 缓存 <*自己录制*> 的语音，返回本地语音路径和录音时长

 @param url 上传语音文件后返回的lurl
 @param completion 返回缓存的本地语音路径和录音时长
 */
- (void)cacheSendVoiceWithUrl:(NSString *)url completion:(void (^)(NSString *filePath, NSInteger duration))completion;

/**
 缓存语音，返回语音路径和录音时长

 @param url 上传语音文件后返回的lurl
 @param completion 返回缓存的本地语音路径和录音时长
 */
- (void)cacheVoiceWithUrl:(NSString *)url completion:(void (^)(NSString *filePath, NSInteger duration))completion;

/** 缓存图片，返回图片 */
- (void)cachePictureWithUrl:(NSString *)url completion:(void (^)(UIImage *image))completion;

@end

