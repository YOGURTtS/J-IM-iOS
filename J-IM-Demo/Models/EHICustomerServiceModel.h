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
    EHIMessageFromTypeReceiver, /// 接收消息
    EHIMessageFromTypeSender    /// 发送消息
};

/** 消息状态 */
typedef NS_ENUM(NSInteger, EHIMessageStatus) {
    EHIMessageStatusSending, /// 发送中
    EHIMessageStatusFailed,  /// 发送失败
    EHIMessageStatusSuccess  /// 发送成功
};

@interface EHICustomerServiceModel : NSObject

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
@property (nonatomic, strong) NSURL *voiceUrl;

/** 语音是否正在播放 */
@property (nonatomic, assign) BOOL isVoicePlaying;

/** 语音播放进度 */
@property (nonatomic, assign) CGFloat voicePlayProgress;
#pragma mark - 语音相关

/** 图片链接 */
@property (nonatomic, strong) NSURL *pictureUrl;

/** 时间 */
@property (nonatomic, copy) NSString *time;

/** 聊天内容视图占用的宽高 */
@property (nonatomic, assign) CGSize chatContentSize;


///** 获取图片数据 */
//- (void)getPictureData;
//
///** 获取语音数据 */
//- (void)getVoiceData;


@end
