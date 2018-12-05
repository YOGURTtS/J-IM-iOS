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
#import "EHIMessageConfig.h"
#import "EHISocketStatusManager.h"
#import <YYModel.h>
#import <netinet/in.h>
#import <AFNetworking.h>


@interface EHISocketManager ()

/** 状态管理器 */
@property (nonatomic, strong) EHISocketStatusManager *statusManager;

/** 编码器 */
@property (nonatomic, strong) EHISocketEncoder *encoder;

/** 解码器 */
@property (nonatomic, strong) EHISocketDecoder *decoder;

/** 心跳包计时器 */
@property (nonatomic, strong) dispatch_source_t timer;

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

- (instancetype)init {
    self = [super init];
    if (self) {
        //        [self connect];
    }
    return self;
}

/** 连接 */
- (void)connect {
    NSError *error;
    
    BOOL connectSuccess = [self.socket connectToHost:@"demob.1hai.cn" onPort:56789 error:&error];
    if (connectSuccess == NO) {
        NSLog(@"error = %@", error);
    }
}

/** 连接socket */
- (void)connectSocketWithHost:(NSString *)host
                         port:(uint16_t)port
                      success:(void(^)(void))success
                      failure:(void(^)(NSError *))failure {
    NSError *error;
    BOOL connectSuccess = [self.socket connectToHost:host onPort:port error:&error];
    if (connectSuccess == NO) {
        failure(error);
    } else {
        success();
    }
}


/** 断开连接 */
- (void)disconnect {
    dispatch_cancel(self.timer);
    [self.socket disconnect];
}


#pragma mark - GCDAsyncSocketDelegate

/** 当socket连接正准备读和写的时候调用 */
- (void)socket:(GCDAsyncSocket *)sock didConnectToUrl:(NSURL *)url {
    
    // 重置读取数据状态
    self.statusManager.readDataStatus = EHISocketReadDataStatusUnGetHeader;
    NSLog(@"Socket连接成功");
    // TODO:登录
    [self login];
    
}

- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port {
    NSLog(@"Socket连接成功");
    
    // 重置socket状态
    [self resetSocketStatus];
    [self sendHeartbeatMessage];
    
    // TODO:登录
    [self login];
    
}

/** 重置socket状态 */
- (void)resetSocketStatus {
    self.statusManager.isFirstSend = true;
    self.statusManager.readDataStatus = EHISocketReadDataStatusUnGetHeader;
    self.statusManager.bodyLength = 0;
}

/** 当socket已完成所要求的数据读入内存时调用，如果有错误则不调用 */
- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag {
    
    NSLog(@"读取到消息:%@", data);
    
    if (self.statusManager.bodyLength) {
        self.statusManager.readDataStatus = EHISocketReadDataStatusGetHeader;
    } else {
        self.statusManager.readDataStatus = EHISocketReadDataStatusUnGetHeader;
    }
    
    if (self.statusManager.readDataStatus == EHISocketReadDataStatusUnGetHeader) {
        
//        // 没有消息体数据，读取消息头
//        if (self.statusManager.bodyLength == 0) {
//            [self.socket readDataToLength:HEADER_LENGHT withTimeout:kSocketTimeout tag:tag];
//            return;
//        }
        
        // 获取消息头出错
        if (![self.decoder isHeaderLengthValid:data]) {
            [self.socket readDataToLength:HEADER_LENGHT withTimeout:kSocketTimeout tag:tag];
            return;
        }
        self.statusManager.readDataStatus = EHISocketReadDataStatusGetHeader;
        self.statusManager.headerData = data;
        // 获取消息头
        EHISocketPacket *header = [self.decoder getPacketHeader:data];
        self.statusManager.bodyLength = header.bodyLength;
        [self.socket readDataToLength:header.bodyLength withTimeout:kSocketTimeout tag:tag];
        return;
    }
    
    // 拼接完整的data
    NSMutableData *completeData = [[NSMutableData alloc] initWithData:self.statusManager.headerData];
    [completeData appendData:data];
    
    // 解码
    EHISocketPacket *packet = [self.decoder decode:completeData];
    self.statusManager.readDataStatus = EHISocketReadDataStatusUnGetHeader;
    self.statusManager.headerData = nil;
    self.statusManager.bodyLength = 0;
    
//    [self.socket readDataToLength:HEADER_LENGHT withTimeout:kSocketTimeout tag:tag];
//    [self sendACKMessageWithPacket:packet];
}

/** 当一个socket已完成请求数据的写入时候调用 */
- (void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag {
   
    NSLog(@"写消息成功");
    
    // 读取头部长度的数据
    if (self.statusManager.isFirstSend) {
        [self.socket readDataToLength:HEADER_LENGHT withTimeout:kSocketTimeout tag:tag];
        self.statusManager.isFirstSend = false;
    }
}

/** 发生错误，socket关闭，可以在call- back过程调用"unreadData"去取得socket的最后的数据字节 */
- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err {
    dispatch_cancel(self.timer);
    NSLog(@"SocketDidDisconnectWithError:%@", err);
}


#pragma mark - 发送各种包

- (void)sendText:(NSString *)text success:(void (^)(void))success failure:(void (^)(NSError *))failure {
    EHISocketNormalMessage *message = [[EHISocketNormalMessage alloc] init];
    message.cmd = COMMAND_CHAT_REQ;
    message.from = @"111";
    message.to = @"10100";
    long timeStamp = 0;
    timeStamp = (long)[[NSDate dateWithTimeIntervalSinceNow:0] timeIntervalSince1970] * 1000;
    message.createTime = timeStamp;
    message.msgType = EHIMessageTypeText;
    message.chatType = EHIChatTypePrivate;
    message.content = text;
    EHISocketPacket *packet = [[EHISocketPacket alloc] initWithMessage:message command:COMMAND_CHAT_REQ];
    NSData *data = [self.encoder encode:packet];
    [self.socket writeData:data withTimeout:kSocketTimeout tag:EHISocketTagDefault];
}

- (void)sendVoice:(NSString *)voice success:(void (^)(void))success failure:(void (^)(NSError *))failure {
    EHISocketNormalMessage *message = [[EHISocketNormalMessage alloc] init];
    message.cmd = COMMAND_CHAT_REQ;
    message.from = @"111";
    message.to = @"2";
    long timeStamp = 0;
    timeStamp = (long)[[NSDate dateWithTimeIntervalSinceNow:0] timeIntervalSince1970] * 1000;
    message.createTime = timeStamp;
    message.msgType = EHIMessageTypeVoice;
    message.chatType = EHIChatTypePrivate;
    message.content = voice;
    EHISocketPacket *packet = [[EHISocketPacket alloc] initWithMessage:message command:COMMAND_CHAT_REQ];
    NSData *data = [self.encoder encode:packet];
    [self.socket writeData:data withTimeout:kSocketTimeout tag:EHISocketTagDefault];
}

- (void)sendVideo:(NSString *)video success:(void (^)(void))success failure:(void (^)(NSError *))failure {
    EHISocketNormalMessage *message = [[EHISocketNormalMessage alloc] init];
    message.cmd = COMMAND_CHAT_REQ;
    message.from = @"111";
    message.to = @"2";
    long timeStamp = 0;
    timeStamp = (long)[[NSDate dateWithTimeIntervalSinceNow:0] timeIntervalSince1970] * 1000;
    message.createTime = timeStamp;
    message.msgType = EHIMessageTypeVideo;
    message.chatType = EHIChatTypePrivate;
    message.content = video;
    EHISocketPacket *packet = [[EHISocketPacket alloc] initWithMessage:message command:COMMAND_CHAT_REQ];
    NSData *data = [self.encoder encode:packet];
    [self.socket writeData:data withTimeout:kSocketTimeout tag:EHISocketTagDefault];
}

/** 发送消息 */
- (void)sendMessage {
    EHISocketNormalMessage *message = [[EHISocketNormalMessage alloc] init];
    message.cmd = 11;
    message.from = @"114";
    message.to = @"10100";
    long timeStamp = 0;
    timeStamp = (long)[[NSDate dateWithTimeIntervalSinceNow:0] timeIntervalSince1970] * 1000;
    message.createTime = timeStamp;
    message.msgType = 1;
    message.chatType = 2;
    message.content = @"测试";
    EHISocketPacket *packet = [[EHISocketPacket alloc] initWithMessage:message command:COMMAND_CHAT_REQ];
    NSData *data = [self.encoder encode:packet];
    
//    [self.socket writeData:data withTimeout:kSocketTimeout tag:EHISocketTagDefault];
    [self.socket readDataToLength:self.statusManager.bodyLength withTimeout:kSocketTimeout tag:EHISocketTagDefault];
}

/** 发送登录信息 */
- (void)sendLoginMessage {
    EHISocketLoginMessage *message = [[EHISocketLoginMessage alloc] init];
    message.cmd = 5;
    message.token = @"111";
    message.loginname = @"114";
    message.password = @"111";
    EHISocketPacket *packet = [[EHISocketPacket alloc] initWithMessage:message command:COMMAND_LOGIN_REQ];
    NSData *data = [self.encoder encode:packet];
    
    [self.socket writeData:data withTimeout:kSocketTimeout tag:EHISocketTagDefault];
}

- (void)login {
    
    NSDictionary *dict = @{
                           @"carNo": @"111",
                           @"customerEntrance": @"111",
                           @"customerId": @"114",
                           @"customerName": @"111",
                           @"customerPhone": @"111",
                           @"lastCustomerServiceId": @"10100",
                           @"orderNo": @"111"
                           };
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [[manager POST:@"http://demob.1hai.cn/online-service/customer/inline" parameters:dict progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"task = %@", task.currentRequest.allHTTPHeaderFields);
        NSLog(@"success, message = %@", [responseObject objectForKey:@"message"]);
        [self.socket readDataToLength:self.statusManager.bodyLength withTimeout:kSocketTimeout tag:EHISocketTagDefault];
//        self.decoder.decodeStatus = EHIDecodeStatusGetHeader;
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
         NSLog(@"failure, error = %@", [error description]);
    }] resume];
}

/** 发送心跳包 */
- (void)sendHeartbeatMessage {
    EHISocketHeartbeatMessage *message = [[EHISocketHeartbeatMessage alloc] init];
    message.cmd = 13;
    message.hbyte = 1;
    EHISocketPacket *packet = [[EHISocketPacket alloc] initWithMessage:message command:COMMAND_HEARTBEAT_REQ];
    NSData *data = [self.encoder encode:packet];
    
    dispatch_source_set_timer(self.timer,dispatch_walltime(NULL, 0),kHeartbeatTimeInterval * NSEC_PER_SEC, 0); // 每5秒发送一次心跳包
    dispatch_source_set_event_handler(_timer, ^{
        NSLog(@"发送心跳包");
        [self.socket writeData:data withTimeout:kSocketTimeout tag:EHISocketTagDefault];
    });
    
    dispatch_resume(self.timer);
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
    message.optType = 1;
    EHISocketPacket *packet = [[EHISocketPacket alloc] initWithMessage:message command:COMMAND_CLOSE_REQ];
    NSData *data = [self.encoder encode:packet];
    [self.socket writeData:data withTimeout:kSocketTimeout tag:EHISocketTagDefault];
}

/**
 *  发送确认消息
 *  根据接收的包来判断发送
 */
- (void)sendACKMessageWithPacket:(EHISocketPacket *)packet {
    EHISocketMessageCommand ACKCmd;
    id socketMessage;
    switch (packet.cmd) {
        case COMMAND_CHAT_REQ:  // 普通聊天
            ACKCmd = COMMAND_CHAT_RESP;
            socketMessage = (EHISocketNormalMessage *)[EHISocketNormalMessage yy_modelWithJSON:packet.body];
            [socketMessage setCmd:ACKCmd];
            break;
        case COMMAND_HEARTBEAT_REQ: // 心跳
            ACKCmd = COMMAND_HEARTBEAT_REQ;
            socketMessage = [EHISocketHeartbeatMessage yy_modelWithJSON:packet.body];
            [socketMessage setCmd:ACKCmd];
            break;
        case COMMAND_LOGIN_REQ: // 登录（应该收不到登录请求）
            NSLog(@"socket收到了登录请求！！！！这是不应该发生的");
            ACKCmd = COMMAND_LOGIN_RESP;
            socketMessage = [EHISocketLoginMessage yy_modelWithJSON:packet.body];
            [socketMessage setCmd:ACKCmd];
            break;
            //        case COMMAND_HEARTBEAT_REQ: // 客服接受、拒绝、设置状态、最大接入人数、连接方式
            //            ACKCmd = COMMAND_HEARTBEAT_REQ; // 心跳
            //            break;
            
        default:
            
            NSLog(@"packet.cmd = %d", packet.cmd);
            [self.socket disconnect];
            return;
            break;
    }
    
    packet.cmd = ACKCmd;
    packet.body = [socketMessage yy_modelToJSONData];
    NSData *data = [self.encoder encode:packet];
    [self.socket writeData:data withTimeout:kSocketTimeout tag:EHISocketTagDefault];
    
}




#pragma mark - lazy load

- (GCDAsyncSocket *)socket {
    if (!_socket) {
        _socket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_global_queue(0, 0)];
        // 优先使用IPv6
        _socket.IPv4PreferredOverIPv6 = NO;
    }
    return _socket;
}

- (EHISocketStatusManager *)statusManager {
    if (!_statusManager) {
        _statusManager = [[EHISocketStatusManager alloc] init];
    }
    return _statusManager;
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

- (dispatch_source_t)timer {
    if (!_timer) {
        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        _timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
    }
    return _timer;
}

@end
