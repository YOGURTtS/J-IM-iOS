//
//  EHIVoiceCacheManager.h
//  J-IM-Demo
//
//  Created by yogurts on 2018/12/11.
//  Copyright © 2018 yogurts. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface EHIVoiceCacheManager : NSObject

/** 缓存在线语音，返回本地缓存路径 */
- (void)cacheOnlineVoiceWithUrl:(NSString *)url completion:(void (^)(NSString *filePath))completion;

@end

