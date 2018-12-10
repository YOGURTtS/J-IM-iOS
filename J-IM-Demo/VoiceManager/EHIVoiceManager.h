//
//  EHIVoiceManager.h
//  J-IM-Demo
//
//  Created by 孙星 on 2018/12/8.
//  Copyright © 2018 yogurts. All rights reserved.
//

#import <UIKit/UIKit.h>

///** 语音管理器播放状态 */
//typedef NS_ENUM(NSInteger, EHIVoiceManagerPlayStatus) {
//    EHIVoiceManagerPlayStatusUnplay,    /// 未播放
//    EHIVoiceManagerPlayStatusIsPlaying, /// 正在播放
//    EHIVoiceManagerPlayStatusPause,     /// 暂停
//    EHIVoiceManagerPlayStatusFinish     /// 播放完成
//};

@interface EHIVoiceManager : NSObject

/** 播放音频，播放完会返回finish回调*/
- (void)playVoiceWithUrl:(NSURL *)url finish:(void (^)(void))finish;

/** 暂停播放，回调返回暂停在第几毫秒，单位是毫秒 */
- (void)pausePlayWithUrl:(NSURL *)url completion:(void (^)(CGFloat milliseconds))completion;

/** 继续播放 */
- (void)resumePlayWithUrl:(NSURL *)url time:(CGFloat)seconds;

/** 停止播放 */
- (void)stopPlayWithUrl:(NSURL *)url;

/** 结束播放回调 */
@property (nonatomic, copy) void (^finish)(NSURL *url);

/** 暂停播放回调 */
@property (nonatomic, copy) void (^pause)(NSURL *url, CGFloat milliseconds);

@end

