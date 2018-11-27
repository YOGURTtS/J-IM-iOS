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

@protocol EHISocketManagerProcotol <NSObject>



@end

@interface EHISocketManager : NSObject <GCDAsyncSocketDelegate>

+ (instancetype)sharedInstance;

/** socket */
@property (nonatomic, strong) GCDAsyncSocket *socket;

/** 发送文字消息 */
- (void)sendTextMessage:(EHISocketNormalMessage *)message;

/** 发送语音消息 */
- (void)sendVoiceMessage:(EHISocketNormalMessage *)message;

/** 发送视频消息 */
- (void)sendVideoMessage:(EHISocketNormalMessage *)message;

- (void)sendMessage;

/** 连接 */
- (void)connect;

/** 断开连接 */
- (void)disconnect;

@end
