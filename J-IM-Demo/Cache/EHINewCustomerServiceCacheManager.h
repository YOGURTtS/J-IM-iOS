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

@interface EHINewCustomerServiceCacheManager : NSObject

/** 单例 */
+ (instancetype)sharedInstance;

/** 缓存在线语音，返回本地缓存路径 */
- (void)cacheOnlineVoiceWithUrl:(NSString *)url completion:(void (^)(NSString *filePath))completion;

/** 缓存语音，返回语音路径 */
- (void)cacheVoiceWithUrl:(NSString *)url completion:(void (^)(NSString *filePath))completion;

/** 缓存图片，返回图片 */
- (void)cachePictureWithUrl:(NSString *)url completion:(void (^)(UIImage *image))completion;

@end

