//
//  EHISocketPacketHandler.m
//  J-IM-Demo
//
//  Created by yogurts on 2018/11/13.
//  Copyright © 2018 yogurts. All rights reserved.
//
//  socket接收、发送、处理消息
//

#import "EHISocketManager.h"
#import "EHISocketPacket.h"
#import "EHISocketMessage.h"
#import "EHISocketEncoder.h"
#import "EHISocketDecoder.h"

typedef enum : NSUInteger {
    EHISocketStatusUnLogin = 0,
    EHISocketStatusDidLogin,
} EHISocketStatus;

typedef enum : NSUInteger {
    EHISocketTagDefault = 10001,
    EHISocketTagInit,
    EHISocketTagHeartbeat,
    EHISocketTagLogin,
    EHISocketTagCloseChat,
} EHISocketTag;

static const NSTimeInterval kSocketTimeout = -1;

@interface EHISocketManager ()

/** 编码器 */
@property (nonatomic, strong) EHISocketEncoder *encoder;

/** 解码器 */
@property (nonatomic, strong) EHISocketDecoder *decoder;

@end

@implementation EHISocketManager

/** singleton */
+ (instancetype)sharedInstance {
    static EHISocketManager *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[EHISocketManager alloc] init];
    });
    return instance;
}


#pragma mark - GCDAsyncSocketDelegate

/** 当socket连接正准备读和写的时候调用，host属性是一个IP地址，而不是一个DNS 名称 */
- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port {
    
    NSLog(@"Socket连接成功");
    // TODO:登录
    [self sendLoginMessage];
}

/** 当socket已完成所要求的数据读入内存时调用，如果有错误则不调用 */
- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag {
    
}

/** 当一个socket已完成请求数据的写入时候调用 */
- (void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag {
    
}

/** 发生错误，socket关闭，可以在call- back过程调用"unreadData"去取得socket的最后的数据字节 */
- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err {
    
}


#pragma mark - 发送各种包

/** 发送消息 */
- (void)sendMessage {
    EHISocketMessage *message = [[EHISocketMessage alloc] init];
    message.cmd = 11;
    message.from = @"111";
    message.to = @"2";
    long timeStamp = 0;
    timeStamp = (long)[[NSDate dateWithTimeIntervalSinceNow:0] timeIntervalSince1970] * 1000;
    message.createTime = timeStamp;
    message.msgType = 1;
    message.chatType = 2;
    EHISocketPacket *packet = [[EHISocketPacket alloc] initWithMessage:message command:COMMAND_CHAT_REQ];
    NSData *data = [self.encoder encode:packet];
    [self.socket writeData:data withTimeout:kSocketTimeout tag:EHISocketTagLogin];
}

/** 发送登录信息 */
- (void)sendLoginMessage {
    EHISocketLoginMessage *message = [[EHISocketLoginMessage alloc] init];
    message.cmd = 5;
    message.token = @"111";
    message.loginname = @"111";
    message.password = @"111";
    EHISocketPacket *packet = [[EHISocketPacket alloc] initWithMessage:message command:COMMAND_LOGIN_REQ];
    NSData *data = [self.encoder encode:packet];
    [self.socket writeData:data withTimeout:kSocketTimeout tag:EHISocketTagLogin];
}

/** 发送心跳包 */
- (void)sendHeartbeatMessage {
    EHISocketHeartbeatMessage *message = [[EHISocketHeartbeatMessage alloc] init];
    message.cmd = 13;
    message.hbyte = 1;
    EHISocketPacket *packet = [[EHISocketPacket alloc] initWithMessage:message command:COMMAND_HEARTBEAT_REQ];
    NSData *data = [self.encoder encode:packet];
    [self.socket writeData:data withTimeout:kSocketTimeout tag:EHISocketTagHeartbeat];
}

/** 关闭聊天 */
- (void)closeChat {
    EHISocketCloseChatMessage *message = [[EHISocketCloseChatMessage alloc] init];
    message.cmd = 14;
    message.from = @"111";
    message.to = @"2";
    long timeStamp = 0;
    timeStamp = (long)[[NSDate dateWithTimeIntervalSinceNow:0] timeIntervalSince1970] * 1000;
    message.optTime = timeStamp;
    message.optType = @"1";
    EHISocketPacket *packet = [[EHISocketPacket alloc] initWithMessage:message command:COMMAND_CLOSE_REQ];
    NSData *data = [self.encoder encode:packet];
    [self.socket writeData:data withTimeout:kSocketTimeout tag:EHISocketTagLogin];
}

/** 发送确认消息 */




#pragma mark - lazy load

- (GCDAsyncSocket *)socket {
    if (!_socket) {
        _socket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_global_queue(0, 0)];
    }
    return _socket;
}

- (EHISocketEncoder *)encoder {
    if (!_encoder) {
        _encoder = [[EHISocketEncoder alloc] init];
    }
    return _encoder;
}

- (EHISocketDecoder *)decoder {
    if (!_decoder) {
        _decoder = [[EHISocketDecoder alloc] init];
    }
    return _decoder;
}

@end
