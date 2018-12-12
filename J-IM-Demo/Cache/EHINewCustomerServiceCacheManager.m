//
//  EHIVoiceCacheManager.m
//  J-IM-Demo
//
//  Created by yogurts on 2018/12/11.
//  Copyright © 2018 yogurts. All rights reserved.
//

#import "EHINewCustomerServiceCacheManager.h"
#import "amr_wav_converter.h"

@interface EHINewCustomerServiceCacheManager ()


@end

@implementation EHINewCustomerServiceCacheManager

#pragma mark - about voice cache

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

/** 缓存语音，返回语音路径 */
- (void)cacheVoiceWithUrl:(NSString *)url completion:(void (^)(NSString *filePath))completion {
    // 先判断本地沙盒是否已经存在图像，存在直接获取，不存在再下载，下载后保存
    // 存在沙盒的Caches的子文件夹DownloadImages中
    NSString *voiceFilePath = [self loadLocalVoiceFilePath:url];
    
    // 沙盒中没有，下载
    if (voiceFilePath.length == 0) {
        __block NSString *filePath;
        [[[NSURLSession sharedSession] dataTaskWithURL:[NSURL URLWithString:url] completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            // amr文件需要转码成wav文件才能正常播放
            if ([url hasSuffix:@"amr"]) {
//                NSString *wavRecordFilePath = [NSTemporaryDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"wav/%@.wav", [NSUUID UUID].UUIDString]];
                NSString *wavUrl = [url stringByReplacingOccurrencesOfString:@".amr" withString:@".wav"];
                NSString *wavRecordFilePath = [self voiceFilePath:wavUrl];
                NSString *amrRecordFilePath = [NSTemporaryDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"amr/%@.amr", [NSUUID UUID].UUIDString]];
                if ([data writeToFile:amrRecordFilePath atomically:YES]) {
                    // amr文件转成wav文件
                    amr_file_to_wave_file([amrRecordFilePath cStringUsingEncoding:NSUTF8StringEncoding],
                                          [wavRecordFilePath cStringUsingEncoding:NSUTF8StringEncoding]);
                }
                filePath = wavRecordFilePath;
                
            } else { // 不需要转码，直接缓存
//                NSURL *voiceUrl = [NSURL URLWithString:url];
//                NSString *recordFilePath = [NSTemporaryDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"%@/%@.%@", voiceUrl.pathExtension, [NSUUID UUID].UUIDString, voiceUrl.pathExtension]];
                NSString *recordFilePath = [self voiceFilePath:url];
                [data writeToFile:recordFilePath atomically:YES];
                filePath = recordFilePath;
            }
            
            // TODO: 更新数据库
            
            
        }] resume];
    }
}

/** 加载本地图片 */
- (NSString *)loadLocalVoiceFilePath:(NSString *)voiceUrl {
    // 转换成wav
    NSString *wavUrl = [voiceUrl stringByReplacingOccurrencesOfString:@".amr" withString:@".wav"];
    // 获取语音路径
    NSString *filePath = [self voiceFilePath:wavUrl];
    
    if (filePath.length) {
        return filePath;
    }
    return nil;
}

/** 获取语音路径 */
- (NSString *)voiceFilePath:(NSString *)voiceUrl {
    // 获取caches文件夹路径
    NSString *cachesPath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
    
    // 创建DownloadVoices文件夹
    NSString *downloadVoicesPath = [cachesPath stringByAppendingPathComponent:@"DownloadVoices"];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:downloadVoicesPath]) {
        
        [fileManager createDirectoryAtPath:downloadVoicesPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
#pragma mark 拼接u语音文件在沙盒中的路径,因为语音URL有"/",要在存入前替换掉,随意用"_"代替
    NSString *voiceName = [voiceUrl stringByReplacingOccurrencesOfString:@"/" withString:@"_"];
    NSString *voiceFilePath = [downloadVoicesPath stringByAppendingPathComponent:voiceName];
    
    return voiceFilePath;
}


#pragma mark - about picture cache

/** 缓存图片，返回图片 */
- (void)cachePictureWithUrl:(NSString *)url completion:(void (^)(UIImage *image))completion {
    // 先判断本地沙盒是否已经存在图像，存在直接获取，不存在再下载，下载后保存
    // 存在沙盒的Caches的子文件夹DownloadImages中
    UIImage * image = [self loadLocalImage:url];
    
    // 沙盒中没有，下载
    if (image == nil) {
        // 异步下载,分配在程序进程缺省产生的并发队列
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            // 多线程中下载图像--->方便简洁写法
            NSData * imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:url]];
            // 缓存图片
            [imageData writeToFile:[self imageFilePath:url] atomically:YES];
            // 回到主线程完成UI设置
            dispatch_async(dispatch_get_main_queue(), ^{
                UIImage * image = [UIImage imageWithData:imageData];
                // 回调
                completion(image);
            });
        });
    }
}

/** 加载本地图片 */
- (UIImage *)loadLocalImage:(NSString *)imageUrl {
    // 获取图像路径
    NSString *filePath = [self imageFilePath:imageUrl];
    // 获取图像
    UIImage *image = [UIImage imageWithContentsOfFile:filePath];
    
    if (image) {
        return image;
    }
    return nil;
}

/** 获取图片路径 */
- (NSString *)imageFilePath:(NSString *)imageUrl {
    // 获取caches文件夹路径
    NSString *cachesPath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
    
    // 创建DownloadImages文件夹
    NSString *downloadImagesPath = [cachesPath stringByAppendingPathComponent:@"DownloadImages"];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:downloadImagesPath]) {
        
        [fileManager createDirectoryAtPath:downloadImagesPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
#pragma mark 拼接图像文件在沙盒中的路径,因为图像URL有"/",要在存入前替换掉,随意用"_"代替
    NSString *imageName = [imageUrl stringByReplacingOccurrencesOfString:@"/" withString:@"_"];
    NSString *imageFilePath = [downloadImagesPath stringByAppendingPathComponent:imageName];
    
    return imageFilePath;
}

@end
