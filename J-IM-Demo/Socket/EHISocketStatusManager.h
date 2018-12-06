//
//  EHISocketStatusManager.h
//  J-IM-Demo
//
//  Created by yogurts on 2018/12/5.
//  Copyright © 2018 yogurts. All rights reserved.
//
//  socket过程中的一些状态的控制
//

#import <Foundation/Foundation.h>

/** 超时时间 */
static const NSInteger kSocketTimeout = -1;
/** 心跳包发送间隔 */
static const NSInteger kHeartbeatTimeInterval = 5;

/** socket读数据的状态 */
typedef NS_ENUM(NSInteger, EHISocketReadDataStatus) {
    EHISocketReadDataStatusUnGetHeader, /// 未获取到头
    EHISocketReadDataStatusGetHeader    /// 已经获取到头
};

/** 在线客服登录状态 */
typedef NS_ENUM(NSInteger, EHISocketLoginStatus) {
    EHISocketLoginStatusUnLogin = 0,
    EHISocketLoginStatusDidLogin,
};

typedef NS_ENUM(NSInteger, EHISocketTag) {
    EHISocketTagDefault
};

@interface EHISocketStatusManager : NSObject

/** 是否是第一次发送 */
@property (nonatomic, assign) BOOL isFirstSend;

/**
 *  消息头数据
 *  作为临时数据
 *  当获取到消息体数据时拼接成完整的消息数据
 */
@property (nonatomic, strong) NSData *headerData;

/**
 *  消息体长度，
 *  作为临时值避免重复读取消息头
 *  当消息体长度为0时读取消息头
 *  否则读取消息体
 */
@property (nonatomic, assign) NSInteger bodyLength;

/** 解码状态 */
@property (nonatomic, assign) EHISocketReadDataStatus readDataStatus;



@end
