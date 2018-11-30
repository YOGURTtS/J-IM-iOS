//
//  EHISocketPacketHandler.h
//  J-IM-Demo
//
//  Created by yogurts on 2018/11/13.
//  Copyright © 2018 yogurts. All rights reserved.
//
//  socket单例管理类
//

#import "EHISocketMessage.h"
#import "GCDAsyncSocket.h"

@class EHISocketManager;
@protocol EHISocketManagerProcotol <NSObject>

/** 接收到文字、语音、视频信息 */
- (void)socketManeger:(EHISocketManager *)socketManager didReceiveMessage:(EHISocketNormalMessage *)message;

- (void)socketManeger:(EHISocketManager *)socketManager didReceiveData:(NSData *)data;

@end

@interface EHISocketManager : NSObject <GCDAsyncSocketDelegate>

/** singleton */
+ (instancetype)sharedInstance;

/** socket */
@property (nonatomic, strong) GCDAsyncSocket *socket;

/** 代理 */
@property(nonatomic, weak) id<EHISocketManagerProcotol> delegate;

/** 发送文字消息 */
- (void)sendText:(NSString *)text
         success:(void(^)(void))success
         failure:(void(^)(NSError *))failure;

/** 发送语音消息 */
- (void)sendVoice:(NSString *)voice
          success:(void(^)(void))success
          failure:(void(^)(NSError *))failure;

/** 发送视频消息 */
- (void)sendVideo:(NSString *)video
          success:(void(^)(void))success
          failure:(void(^)(NSError *))failure;

- (void)sendMessage;

/** 连接 */
- (void)connect;

/** 连接socket */
- (void)connectSocketWithHost:(NSString *)host
                         port:(uint16_t)port
                      success:(void(^)(void))success
                      failure:(void(^)(NSError *))failure;

/** 断开连接 */
- (void)disconnect;

@end
