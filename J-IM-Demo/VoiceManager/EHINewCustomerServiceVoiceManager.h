//
//  EHIVoiceManager.h
//  J-IM-Demo
//
//  Created by 孙星 on 2018/12/8.
//  Copyright © 2018 yogurts. All rights reserved.
//
//  语音管理类
//

#import <UIKit/UIKit.h>


@interface EHINewCustomerServiceVoiceManager : NSObject

/** 单例 */
+ (instancetype)sharedInstance;

#pragma mark - 录音相关
/** 取消语音录制 */
@property (nonatomic, assign) BOOL isCancelSendAudioMessage;

/** 开始录音 */
- (void)audioRecordStart;

/** 结束录音 */
- (void)audioRecordStop;

/** 结束录音回调 */
@property (nonatomic, copy) void (^finishRecord)(NSData *amrdData, NSString *amrFilePath, NSInteger duration);

/** 判断是否正在录音 */
- (BOOL)isRecording;
#pragma mark - 录音相关

#pragma mark - 播放录音相关
/** 播放音频，播放完会返回finish回调 */
- (void)playVoiceWithUrl:(NSURL *)url finish:(void (^)(void))finish;

/** 暂停播放，回调返回暂停在第几毫秒，单位是毫秒 */
- (void)pausePlayWithUrl:(NSURL *)url completion:(void (^)(CGFloat milliseconds))completion;

/** 继续播放 */
- (void)resumePlayWithUrl:(NSURL *)url time:(CGFloat)seconds;

/** 停止播放 */
- (void)stopPlayWithUrl:(NSURL *)url;

/** 结束播放回调 */
@property (nonatomic, copy) void (^finishPlay)(NSURL *url);

/** 暂停播放回调 */
@property (nonatomic, copy) void (^pause)(NSURL *url, CGFloat milliseconds);
#pragma mark - 播放录音相关

@end

