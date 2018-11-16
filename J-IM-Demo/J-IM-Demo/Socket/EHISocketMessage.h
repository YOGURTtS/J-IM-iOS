//
//  EHISocketMessage.h
//  J-IM-Demo
//
//  Created by yogurts on 2018/11/14.
//  Copyright © 2018 yogurts. All rights reserved.
//
//  各种类型的消息
//

#import <Foundation/Foundation.h>
#import "EHISocketMessageCommand.h"



#pragma mark - 普通信息


/**
 消息类型
 */
typedef NS_ENUM(int, EHISocketMessageType) {
    EHISocketMessageTypeText    = 0,    /// 文字
    EHISocketMessageTypeImage   = 1,    /// 图片
    EHISocketMessageTypeVoice   = 2,    /// 语音
    EHISocketMessageTypeVideo   = 3,    /// 视频
    EHISocketMessageTypeMusic   = 4,    /// 音乐
    EHISocketMessageTypeNews    = 5     /// 新闻
};


/**
 聊天类型
 */
typedef NS_ENUM(int, EHISocketChatType) {
    EHISocketChatTypeUnknown    = 0,    /// 未知
    EHISocketChatTypePublic     = 1,    /// 公聊
    EHISocketChatTypePrivate    = 2,    /// 私聊
};

/**
 客服状态
 */
typedef NS_ENUM(NSUInteger, EHISocketCustomServiceOptType) {
    EHISocketCustomServiceOptTypeAccept             = 1,    /// 接受
    EHISocketCustomServiceOptTypeRefuse             = 2,    /// 拒绝
    EHISocketCustomServiceOptTypeIdle               = 3,    /// 设置状态为空闲
    EHISocketCustomServiceOptTypeBusy               = 4,    /// 设置状态为忙
    EHISocketCustomServiceOptTypeMaxConnectNumber   = 5,    /// 设置最大接入数
    EHISocketCustomServiceOptTypeConnectManual      = 6,    /// 设置连接方式为手动
    EHISocketCustomServiceOptTypeAuto               = 7     /// 设置为自动
};


@interface EHISocketMessage : NSObject

/** 来源ID */
@property (nonatomic, copy) NSString *from;

/** 目标ID */
@property (nonatomic, copy) NSString *to;

/** 命令码 */
@property (nonatomic, assign) EHISocketMessageCommand cmd;

/** 消息创建时间 */
@property (nonatomic, assign) long createTime;

/** 消息类型 (0:text、1:image、2:voice、3:vedio、4:music、5:news) */
@property (nonatomic, assign) EHISocketMessageType msgType;

/** 聊天类型 (0:未知,1:公聊,2:私聊) */
@property (nonatomic, assign) EHISocketChatType chatType;

/** 内容 */
@property (nonatomic, copy) NSString *content;

/** 用户名 */
@property (nonatomic, copy) NSString *loginname;

/** 密码 */
@property (nonatomic, copy) NSString *password;

/** token */
@property (nonatomic, copy) NSString *token;

/** 设置为1 */
@property (nonatomic, assign) int hbyte;

/** 操作时间 */
@property (nonatomic, assign) long optTime;

/** 类型 */
@property (nonatomic, assign) int optType;

/** 最大连接人数 */
@property (nonatomic, assign) int connectAmount;

@end



