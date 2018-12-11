//
//  EHIVoiceCacheManager.m
//  J-IM-Demo
//
//  Created by yogurts on 2018/12/11.
//  Copyright © 2018 yogurts. All rights reserved.
//

#import "EHIVoiceCacheManager.h"
#import "amr_wav_converter.h"

@interface EHIVoiceCacheManager ()


@end

@implementation EHIVoiceCacheManager

/** 缓存在线语音，返回本地缓存路径 */
- (void)cacheOnlineVoiceWithUrl:(NSString *)url completion:(void (^)(NSString *filePath))completion {
    
    if ([url hasPrefix:@"http"]) {
        __block NSString *filePath;
        [[[NSURLSession sharedSession] dataTaskWithURL:[NSURL URLWithString:url] completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            // amr文件需要转码成wav文件才能正常播放
            if ([url hasSuffix:@"amr"]) {
                NSString *wavRecordFilePath = [NSTemporaryDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"wav/%@.wav", [NSUUID UUID].UUIDString]];
                NSString *amrRecordFilePath = [NSTemporaryDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"amr/%@.amr", [NSUUID UUID].UUIDString]];
                if ([data writeToFile:amrRecordFilePath atomically:YES]) {
                    // amr文件转成wav文件
                    amr_file_to_wave_file([amrRecordFilePath cStringUsingEncoding:NSUTF8StringEncoding],
                                          [wavRecordFilePath cStringUsingEncoding:NSUTF8StringEncoding]);
                }
                filePath = wavRecordFilePath;
                
            } else { // 不需要转码，直接缓存
                NSURL *voiceUrl = [NSURL URLWithString:url];
                NSString *recordFilePath = [NSTemporaryDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"%@/%@.%@", voiceUrl.pathExtension, [NSUUID UUID].UUIDString, voiceUrl.pathExtension]];
                [data writeToFile:recordFilePath atomically:YES];
                filePath = recordFilePath;
            }
            
            // TODO: 更新数据库
            
        }] resume];
        completion(filePath);
    } else {
        completion(url);
    }
}

@end
