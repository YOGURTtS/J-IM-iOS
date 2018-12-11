//
//  EHICustomerServiceModel.h
//  J-IM-Demo
//
//  Created by yogurts on 2018/11/30.
//  Copyright © 2018 yogurts. All rights reserved.
//
//  关于消息cell的model
//

#import "EHISocketMessage.h"

/** 消息来源 */
typedef NS_ENUM(NSInteger, EHIMessageFromType) {
    EHIMessageFromTypeReceiver = 0, /// 接收消息
    EHIMessageFromTypeSender   = 1  /// 发送消息
};

/** 消息状态 */
typedef NS_ENUM(NSInteger, EHIMessageStatus) {
    EHIMessageStatusSending = 0, /// 发送中
    EHIMessageStatusFailed  = 1, /// 发送失败
    EHIMessageStatusSuccess = 2  /// 发送成功
};

/** 语音播放状态 */
typedef NS_ENUM(NSInteger, EHIVoiceMessagePlayStatus) {
    EHIVoiceMessagePlayStatusUnplay    = 0, /// 未播放
    EHIVoiceMessagePlayStatusIsplaying = 1, /// 正在播放
    EHIVoiceMessagePlayStatusPause     = 2, /// 暂停播放
    EHIVoiceMessagePlayStatusFinish    = 3  /// 播放完毕
};

@interface EHICustomerServiceModel : NSObject

/** 是否是匿名信息，未登录为YES，登录为NO */
@property (nonatomic, assign) BOOL isAnonymousMessage;

/** 用户ID */
@property (nonatomic, copy) NSString *userId;

/** 消息来源 */
@property (nonatomic, assign) EHIMessageFromType fromType;

/** 消息状态 */
@property (nonatomic, assign) EHIMessageStatus messageStatus;

/** 消息类型 */
@property (nonatomic, assign) EHIMessageType messageType;

/** 内容 */
@property (nonatomic, copy) NSString *text;

#pragma mark - 语音相关
/** 语音链接 */
@property (nonatomic, copy) NSString *voiceUrl;

/** 语音本地缓存路径 */
@property (nonatomic, copy) NSString *voiceFileUrl;

/** 语音播放状态 */
@property (nonatomic, assign) EHIVoiceMessagePlayStatus playStatus;

/** 语音播放到第几毫秒，单位是毫秒 */
@property (nonatomic, assign) CGFloat millisecondsPlayed;
#pragma mark - 语音相关

/** 图片链接 */
@property (nonatomic, copy) NSString *pictureUrl;

/** 时间 */
@property (nonatomic, copy) NSString *time;

/** 聊天内容视图占用的宽高 */
@property (nonatomic, assign) CGSize chatContentSize;

/** cell的行高 */
@property (nonatomic, assign) CGFloat cellHeight;


///** 获取图片数据 */
//- (void)getPictureData;
//
///** 获取语音数据 */
//- (void)getVoiceData;


@end
