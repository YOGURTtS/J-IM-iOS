//
//  EHIVoiceManager.h
//  J-IM-Demo
//
//  Created by 孙星 on 2018/12/8.
//  Copyright © 2018 yogurts. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EHIVoiceManager : NSObject

/** 播放音频，播放完会返回finish回调*/
- (void)playVoiceWithUrl:(NSURL *)url finish:(void (^)(void))finish;

/** 暂停播放，回调返回暂停在第几秒 */
- (void)pausePlayWithUrl:(NSURL *)url completion:(void (^)(CGFloat seconds))completion;

/** 继续播放 */
- (void)resumePlayWithUrl:(NSURL *)url time:(CGFloat)seconds;

/** 停止播放 */
- (void)stopPlayWithUrl:(NSURL *)url;

@end

