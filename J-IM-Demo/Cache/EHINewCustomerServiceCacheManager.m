//
//  EHIVoiceCacheManager.m
//  J-IM-Demo
//
//  Created by yogurts on 2018/12/11.
//  Copyright © 2018 yogurts. All rights reserved.
//

#import "EHINewCustomerServiceCacheManager.h"

@interface EHINewCustomerServiceCacheManager ()


@end

@implementation EHINewCustomerServiceCacheManager

/** 单例 */
static dispatch_once_t onceToken;
+ (instancetype)sharedInstance {
    static EHINewCustomerServiceCacheManager *instance;
    dispatch_once(&onceToken, ^{
        instance = [[EHINewCustomerServiceCacheManager alloc] init];
    });
    return instance;
}

#pragma mark - about voice cache

/** 缓存自己发送的语音，返回本地语音路径 */
- (void)cacheSendVoiceWithUrl:(NSString *)url completion:(void (^)(NSString *filePath))completion {
    NSString *cachepath = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).lastObject;
    NSString *wavRecordFilePath = [cachepath stringByAppendingString:@"/new_cs/send_voice/myRecord.wav"];
    NSData *data = [NSData dataWithContentsOfFile:wavRecordFilePath];
    NSString *wavUrl = [url stringByReplacingOccurrencesOfString:@".amr" withString:@".wav"];
    NSString *wavFilePath = [self voiceFilePath:wavUrl];
    if ([data writeToFile:wavFilePath atomically:YES]) {
        completion(wavFilePath);
    }
}

/** 缓存语音，返回语音路径 */
- (void)cacheVoiceWithUrl:(NSString *)url completion:(void (^)(NSString *filePath))completion {
    // 先判断本地沙盒是否已经存在图像，存在直接获取，不存在再下载，下载后保存
    // 存在沙盒的Caches的子文件夹DownloadImages中
    NSString *voiceFilePath = [self loadLocalVoiceFilePath:url];
    NSData *voiceData = [NSData dataWithContentsOfFile:voiceFilePath];
    
    // 沙盒中没有，下载
    if (voiceData == nil) {
        __block NSString *filePath;
        __weak typeof(self) weakSelf = self;
        [[[NSURLSession sharedSession] dataTaskWithURL:[NSURL URLWithString:url] completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            __strong typeof(weakSelf) self = weakSelf;
            // amr文件需要转码成wav文件才能正常播放
            if ([url hasSuffix:@"amr"]) {
                
                NSString *wavUrl = [url stringByReplacingOccurrencesOfString:@".amr" withString:@".wav"];
                NSString *wavRecordFilePath = [self voiceFilePath:wavUrl];
                
                // 临时缓存文件路径
                NSString *cachepath = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).lastObject;
                NSString *amrRecordFilePath = [cachepath stringByAppendingString:[NSString stringWithFormat:@"/new_cs/DownloadVoices/%@.amr", [NSUUID UUID].UUIDString]];
                if ([data writeToFile:amrRecordFilePath atomically:YES]) {
                    // amr文件转成wav文件
                    amr_file_to_wave_file([amrRecordFilePath cStringUsingEncoding:NSUTF8StringEncoding],
                                          [wavRecordFilePath cStringUsingEncoding:NSUTF8StringEncoding]);
                }
                
                // 删除临时缓存的amr文件
                [[NSFileManager defaultManager] removeItemAtPath:amrRecordFilePath error:nil];
                filePath = wavRecordFilePath;
                
            } else { // 不需要转码，直接缓存
//                NSURL *voiceUrl = [NSURL URLWithString:url];
//                NSString *recordFilePath = [NSTemporaryDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"%@/%@.%@", voiceUrl.pathExtension, [NSUUID UUID].UUIDString, voiceUrl.pathExtension]];
                NSString *recordFilePath = [self voiceFilePath:url];
                [data writeToFile:recordFilePath atomically:YES];
                filePath = recordFilePath;
            }
            
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                // UI更新代码
                NSLog(@"current thread = %@", [NSThread currentThread]);
                // TODO: 更新数据库
                completion(filePath);
            }];

            
        }] resume];
    } else {
        completion(voiceFilePath);
    }
}

/** 加载本地语音路径 */
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
    NSString *downloadVoicesPath = [[cachesPath stringByAppendingPathComponent:@"new_cs"] stringByAppendingPathComponent:@"DownloadVoices"];
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
    NSString *downloadImagesPath = [[cachesPath stringByAppendingPathComponent:@"new_cs"] stringByAppendingPathComponent:@"DownloadImages"];
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
