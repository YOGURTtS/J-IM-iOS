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


@protocol EHISocketMessage <NSObject>

@end

/**
 普通消息
 */
@interface EHISocketNormalMessage : NSObject <EHISocketMessage>

/** 来源ID */
@property (nonatomic, copy) NSString *from;

/** 目标ID */
@property (nonatomic, copy) NSString *to;

/**
 命令码
 请求:COMMAND_CHAT_REQ(11)
 响应:COMMAND_CHAT_RESP(12)
 */
@property (nonatomic, assign) EHISocketMessageCommand cmd;

/** 消息创建时间 */
@property (nonatomic, assign) long createTime;

/** 消息类型 */
@property (nonatomic, assign) int msgType;

/** 聊天类型 */
@property (nonatomic, assign) int chatType;

/** 内容 */
@property (nonatomic, copy) NSString *content;

@end



/**
 登录消息
 */
@interface EHISocketLoginMessage : NSObject <EHISocketMessage>

/**
 命令码
 请求:COMMAND_LOGIN_REQ(5)
 响应:COMMAND_LOGIN_RESP(6)
 */
@property (nonatomic, assign) EHISocketMessageCommand cmd;

/** 用户名 */
@property (nonatomic, copy) NSString *loginname;

/** 密码 */
@property (nonatomic, copy) NSString *password;

/** token */
@property (nonatomic, copy) NSString *token;

@end



/**
 心跳信息
 */
@interface EHISocketHeartbeatMessage : NSObject <EHISocketMessage>

/**
 命令码
 请求:COMMAND_HEARTBEAT_REQ(13)
 响应:COMMAND_HEARTBEAT_REQ(13)
 */
@property (nonatomic, assign) EHISocketMessageCommand cmd;

/** 设置为1 */
@property (nonatomic, assign) int hbyte;

@end



/**
 关闭聊天信息
 */
@interface EHISocketCloseChatMessage : NSObject <EHISocketMessage>

/** 来源ID */
@property (nonatomic, copy) NSString *from;

/** 目标ID */
@property (nonatomic, copy) NSString *to;

/**
 命令码
 请求:COMMAND_CLOSE_REQ(14)
 响应:COMMAND_CLOSE_REQ(14)
 */
@property (nonatomic, assign) EHISocketMessageCommand cmd;

/** 操作时间 */
@property (nonatomic, assign) long optTime;

/** 类型 1 客户关闭 2 客服关闭 */
@property (nonatomic, copy) NSString *optType;

@end



/**
 客服接受、拒绝、设置状态、最大接入人数、连接方式
 */
@interface EHISocketCustomerServiceMessage : NSObject <EHISocketMessage>

/** 来源ID */
@property (nonatomic, copy) NSString *from;

/** 目标ID */
@property (nonatomic, copy) NSString *to;

/**
 命令码
 一嗨自定义10+两位标示
 */
@property (nonatomic, assign) int cmd;

/** 操作时间 */
@property (nonatomic, assign) long optTime;

/** 类型 1 接受 2 拒绝 3设置状态为闲 4 设置状态为忙 5 设置最大接入数 6 设置连接方式为手动 7 设置为自动 */
@property (nonatomic, copy) NSString *optType;

/** 最大连接人数 */
@property (nonatomic, assign) int connectAmount;

@end



