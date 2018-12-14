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

/** socket连接 */
- (void)socketManeger:(EHISocketManager *)socketManager didConnectToHost:(NSString *)host port:(uint16_t)port;

/** socket断开 */
- (void)socketManeger:(EHISocketManager *)socketManager socketDidDisconnectWithError:(NSError *)error;

@end

@interface EHISocketManager : NSObject <GCDAsyncSocketDelegate>

/** singleton */
+ (instancetype)sharedInstance;

/** socket */
@property (nonatomic, strong) GCDAsyncSocket *socket;

/** 代理 */
@property(nonatomic, weak) id<EHISocketManagerProcotol> delegate;

/** 连接 */
- (void)connectWithCustomerId:(NSString *)customerId;

/** 连接socket */
- (void)connectSocketWithHost:(NSString *)host
                         port:(uint16_t)port
                      success:(void(^)(void))success
                      failure:(void(^)(NSError *))failure;

/** 发送文字消息 */
- (void)sendText:(NSString *)text
            from:(NSString *)from
              to:(NSString *)to
          extras:(NSDictionary *)extras
         success:(void(^)(void))success
         failure:(void(^)(NSError *error))failure;

/** 发送语音消息 */
- (void)sendVoice:(NSString *)voice
             from:(NSString *)from
               to:(NSString *)to
           extras:(NSDictionary *)extras
          success:(void (^)(void))success
          failure:(void (^)(NSError *error))failure;

/** 发送图片消息 */
- (void)sendPicture:(NSString *)picture
             from:(NSString *)from
               to:(NSString *)to
             extras:(NSDictionary *)extras
          success:(void(^)(void))success
          failure:(void(^)(NSError *error))failure;

/** 发送视频消息 */
- (void)sendVideo:(NSString *)video
             from:(NSString *)from
               to:(NSString *)to
          success:(void(^)(void))success
          failure:(void(^)(NSError *error))failure;

/** 发送登录socket消息 */
- (void)sendLoginMessagaWithLoginName:(NSString *)loginName
                             password:(NSString *)password
                                token:(NSString *)token success:(void(^)(void))success
                              failure:(void(^)(NSError *error))failure;

/** 断开连接 */
- (void)disconnect;

@end
