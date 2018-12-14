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
#import "EHISocketMessageFactory.h"


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
        
    }
    return self;
}

/** 连接 */
- (void)connectWithCustomerId:(NSString *)customerId {
    
    NSDictionary *dict = @{
                           @"carNo": @"111",
                           @"customerEntrance": @"111",
                           @"customerId": customerId,
                           @"customerName": @"111",
                           @"customerPhone": @"111",
                           @"lastCustomerServiceId": @"10100",
                           @"orderNo": @"111"
                           };
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/plain",@"application/json", @"text/json", @"text/javascript",nil];
    
    [[manager POST:@"http://devb.1hai.cn/online-service/customer/inline" parameters:dict progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"success, responseObject = %@", [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding]);
        
        // 连接socket
        NSError *error;
        BOOL connectSuccess = [self.socket connectToHost:@"devb.1hai.cn" onPort:56789 error:&error];
        if (connectSuccess == NO) {
            NSLog(@"error = %@", error);
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"failure, error = %@", [error description]);
    }] resume];
}

/** 连接socket */
- (void)connectSocketWithHost:(NSString *)host
                         port:(uint16_t)port
                      success:(void(^)(void))success
                      failure:(void(^)(NSError *error))failure {
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
    [self.socket disconnect];
}


#pragma mark - GCDAsyncSocketDelegate

/** 当socket连接正准备读和写的时候调用 */
- (void)socket:(GCDAsyncSocket *)sock didConnectToUrl:(NSURL *)url {
    
    // 重置读取数据状态
    self.statusManager.readDataStatus = EHISocketReadDataStatusUnGetHeader;
    NSLog(@"Socket连接成功");
}

- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port {
    NSLog(@"Socket连接成功");
    
    // 重置socket状态
    [self resetSocketStatus];
    [self sendHeartbeatMessage];
    
    // 代理方法
    if ([self.delegate respondsToSelector:@selector(socketManeger:didConnectToHost:port:)]) {
        [self.delegate socketManeger:self didConnectToHost:host port:port];
    }
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
    
    if (self.statusManager.readDataStatus == EHISocketReadDataStatusUnGetHeader) {
        
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
    // 根据消息体中的"command"字段生产message对象
    [self getVarietyOfMessagesWithPacket:packet];
    
    // 更改读取数据状态
    self.statusManager.readDataStatus = EHISocketReadDataStatusUnGetHeader;
    self.statusManager.headerData = nil;
    self.statusManager.bodyLength = 0;
    
    // 读数据
    [self.socket readDataToLength:HEADER_LENGHT withTimeout:kSocketTimeout tag:tag];
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
    [self resetSocketStatus];
    [self suspendTimer];
    if ([self.delegate respondsToSelector:@selector(socketManeger:socketDidDisconnectWithError:)]) {
        [self.delegate socketManeger:self socketDidDisconnectWithError:err];
    }
}

#pragma mark - 发送各种包

- (void)sendText:(NSString *)text
            from:(NSString *)from
              to:(NSString *)to
          extras:(NSDictionary *)extras
         success:(void (^)(void))success
         failure:(void (^)(NSError *error))failure {
    EHISocketNormalMessage *message = [[EHISocketNormalMessage alloc] init];
    message.cmd = COMMAND_CHAT_REQ;
    message.from = from;
    message.to = to;
    long timeStamp = 0;
    timeStamp = (long)[[NSDate dateWithTimeIntervalSinceNow:0] timeIntervalSince1970] * 1000;
    message.createTime = timeStamp;
    message.msgType = EHIMessageTypeText;
    message.chatType = EHIChatTypePrivate;
    message.content = text;
    message.extras = extras;
    EHISocketPacket *packet = [[EHISocketPacket alloc] initWithMessage:message command:COMMAND_CHAT_REQ];
    NSData *data = [self.encoder encode:packet];
    [self.socket writeData:data withTimeout:kSocketTimeout tag:EHISocketTagDefault];
}

- (void)sendVoice:(NSString *)voice
             from:(NSString *)from
               to:(NSString *)to
           extras:(NSDictionary *)extras
          success:(void (^)(void))success
          failure:(void (^)(NSError *error))failure {
    EHISocketNormalMessage *message = [[EHISocketNormalMessage alloc] init];
    message.cmd = COMMAND_CHAT_REQ;
    message.from = from;
    message.to = to;
    long timeStamp = 0;
    timeStamp = (long)[[NSDate dateWithTimeIntervalSinceNow:0] timeIntervalSince1970] * 1000;
    message.createTime = timeStamp;
    message.msgType = EHIMessageTypeVoice;
    message.chatType = EHIChatTypePrivate;
    message.content = voice;
    message.extras = extras;
    EHISocketPacket *packet = [[EHISocketPacket alloc] initWithMessage:message command:COMMAND_CHAT_REQ];
    NSData *data = [self.encoder encode:packet];
    [self.socket writeData:data withTimeout:kSocketTimeout tag:EHISocketTagDefault];
}

- (void)sendPicture:(NSString *)picture
               from:(NSString *)from
                 to:(NSString *)to
             extras:(NSDictionary *)extras
            success:(void (^)(void))success
            failure:(void (^)(NSError *error))failure {
    EHISocketNormalMessage *message = [[EHISocketNormalMessage alloc] init];
    message.cmd = COMMAND_CHAT_REQ;
    message.from = from;
    message.to = to;
    long timeStamp = 0;
    timeStamp = (long)[[NSDate dateWithTimeIntervalSinceNow:0] timeIntervalSince1970] * 1000;
    message.createTime = timeStamp;
    message.msgType = EHIMessageTypePicture;
    message.chatType = EHIChatTypePrivate;
    message.content = picture;
    message.extras = extras;
    EHISocketPacket *packet = [[EHISocketPacket alloc] initWithMessage:message command:COMMAND_CHAT_REQ];
    NSData *data = [self.encoder encode:packet];
    [self.socket writeData:data withTimeout:kSocketTimeout tag:EHISocketTagDefault];
}

- (void)sendVideo:(NSString *)video
             from:(NSString *)from
               to:(NSString *)to
          success:(void (^)(void))success
          failure:(void (^)(NSError *error))failure {
    EHISocketNormalMessage *message = [[EHISocketNormalMessage alloc] init];
    message.cmd = COMMAND_CHAT_REQ;
    message.from = from;
    message.to = to;
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

/** 登录 */
- (void)sendLoginMessagaWithLoginName:(NSString *)loginName
                             password:(NSString *)password
                                token:(NSString *)token success:(void(^)(void))success
                              failure:(void(^)(NSError *error))failure {
    EHISocketLoginMessage *message = [[EHISocketLoginMessage alloc] init];
    message.cmd = 5;
    message.loginname = loginName;
    message.password = password;
    message.token = token;
    EHISocketPacket *packet = [[EHISocketPacket alloc] initWithMessage:message command:COMMAND_LOGIN_REQ];
    NSData *data = [self.encoder encode:packet];
    [self.socket writeData:data withTimeout:kSocketTimeout tag:EHISocketTagDefault];
}

/** 发送心跳包 */
- (void)sendHeartbeatMessage {
    EHISocketHeartbeatMessage *message = [[EHISocketHeartbeatMessage alloc] init];
    message.cmd = 13;
    message.hbyte = 1;
    EHISocketPacket *packet = [[EHISocketPacket alloc] initWithMessage:message command:COMMAND_HEARTBEAT_REQ];
    NSData *data = [self.encoder encode:packet];
    
    // 每10秒发送一次心跳包
    dispatch_source_set_timer(self.timer,dispatch_walltime(NULL, 0),kHeartbeatTimeInterval * NSEC_PER_SEC, 0);
    __weak typeof(self) weakSelf = self;
    dispatch_source_set_event_handler(_timer, ^{
        __strong typeof(weakSelf) self = weakSelf;
        NSLog(@"发送心跳包");
        [self.socket writeData:data withTimeout:kSocketTimeout tag:EHISocketTagDefault];

    });
    
    dispatch_resume(self.timer);
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

#pragma mark - 获取各种包

/** 获取各种消息 */
- (void)getVarietyOfMessagesWithPacket:(EHISocketPacket *)packet {
    switch ([EHISocketMessageFactory getPacketTypeWithPacket:packet]) {
        case EHIPacketTypeNormalMessage:
            if ([self.delegate respondsToSelector:@selector(socketManeger:didReceiveMessage:)]) {
                [self.delegate socketManeger:self didReceiveMessage:[EHISocketMessageFactory getMessageWithPacket:packet]];
            }
            break;
            
        default:
            break;
    }
}

#pragma mark - about timer

/** 停止计时器 */
- (void)suspendTimer {
    dispatch_suspend(self.timer);
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

#pragma mark - deinit

- (void)dealloc {
    dispatch_source_cancel(self.timer);
}

@end
