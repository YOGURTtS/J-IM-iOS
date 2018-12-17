//
//  EHIMessageCommand.h
//  J-IM-Demo
//
//  Created by yogurts on 2018/11/13.
//  Copyright © 2018 yogurts. All rights reserved.
//
//  命令码类型
//

#import <Foundation/Foundation.h>

/** 消息头中命令码类型 */
typedef enum : int {
    /// 未知
    COMMAND_UNKNOW = 0,
    /// 握手请求，含http的websocket握手请求
    COMMAND_HANDSHAKE_REQ,
    /// 握手响应，含http的websocket握手响应
    COMMAND_HANDSHAKE_RESP,
    /// 鉴权请求
    COMMAND_AUTH_REQ,
    /// 鉴权响应
    COMMAND_AUTH_RESP,
    /// 登录请求
    COMMAND_LOGIN_REQ,
    /// 登录响应
    COMMAND_LOGIN_RESP,
    /// 申请进入群组
    COMMAND_JOIN_GROUP_REQ,
    /// 申请进入群组响应
    COMMAND_JOIN_GROUP_RESP,
    /// 进入群组通知
    COMMAND_JOIN_GROUP_NOTIFY_RESP,
    /// 退出群组通知
    COMMAND_EXIT_GROUP_NOTIFY_RESP,
    /// 聊天请求
    COMMAND_CHAT_REQ,
    /// 聊天响应
    COMMAND_CHAT_RESP,
    /// 心跳请求
    COMMAND_HEARTBEAT_REQ,
    /// 关闭请求
    COMMAND_CLOSE_REQ,
    /// 发出撤消消息指令(管理员可以撤消所有人的消息，自己可以撤消自己的消息)
    COMMAND_CANCEL_MSG_REQ,
    /// 收到撤消消息指令
    COMMAND_CANCEL_MSG_RESP,
    /// 获取用户信息
    COMMAND_GET_USER_REQ,
    /// 获取用户信息响应
    COMMAND_GET_USER_RESP,
    /// 获取聊天消息
    COMMAND_GET_MESSAGE_REQ,
    /// 获取聊天消息响应
    COMMAND_GET_MESSAGE_RESP
    
} EHISocketMessageCommand;





