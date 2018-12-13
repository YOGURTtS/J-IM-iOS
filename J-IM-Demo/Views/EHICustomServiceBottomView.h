//
//  EHIBottomInputView.h
//  J-IM-Demo
//
//  Created by yogurts on 2018/11/30.
//  Copyright © 2018 yogurts. All rights reserved.
//
//  在线客服底部视图，包括快捷入口和输入区域
//

#import <UIKit/UIKit.h>

/** 输入状态 */
typedef NS_ENUM(NSInteger, EHICustomServiceInputType) {
    EHICustomServiceInputTypeText,  // 文字
    EHICustomServiceInputTypeVoice  // 语音
};

/** 录音状态 */
typedef NS_ENUM(NSInteger, EHIAudioRecordStatus) {
    EHIAudioRecordStatusStart,                  /// 开始录音
    EHIAudioRecordStatusRecording,              /// 正在录音
    EHIAudioRecordStatusFinish,                 /// 结束录音
    EHIAudioRecordStatusRecordingButMayCancel,  /// 正在录音但是可能取消，对应“松开手指取消发送”
};

@interface EHICustomServiceBottomView : UIView

/** 输入类型 */
@property (nonatomic, assign) EHICustomServiceInputType inputType;

/** 快捷入口 */
@property (nonatomic, strong) NSArray *quickEntrances;

/** 快捷入口按钮点击回调 */
@property (nonatomic, copy) void (^quickEntranceSelected)(UIButton *button, NSInteger index);

/** 发送文字消息回调 */
@property (nonatomic, copy) void (^sendTextCallback)(NSString *text);

/** 发送语音消息回调 */
@property (nonatomic, copy) void (^sendVoiceCallback)(NSData *amrdData, NSString *wavFilePath);

/** 发送图片消息回调 */
@property (nonatomic, copy) void (^sendPictureCallback)(UIImage *image);

/**
 *  录音状态改变回调
 *  用于进行录音时显示在屏幕中间的视图调整
 */
@property (nonatomic, copy) void (^recordStatusChangedCallback)(EHIAudioRecordStatus status);

@end
