//
//  EHISocketMessageConverter.m
//  J-IM-Demo
//
//  Created by yogurts on 2018/11/27.
//  Copyright © 2018 yogurts. All rights reserved.
//

#import "EHISocketMessageFactory.h"
#import <YYModel.h>

@implementation EHISocketMessageFactory



/** 获取消息类型 */
+ (EHIPacketType)getPacketTypeWithPacket:(EHISocketPacket *)packet {
    
    switch (packet.cmd) {
        case COMMAND_CHAT_REQ:  // 普通聊天
            return EHIPacketTypeNormalMessage;
        case COMMAND_HEARTBEAT_REQ: // 心跳
            return EHIPacketTypeHeartbeatMessage;
            // TODO: ACK确认
//        case COMMAND_CHAT_RESP:  // 信息ACK
//        case COMMAND_LOGIN_RESP: // 登录ACK
         
            
        default:
            return 0;
           
    }
    
}

/** 将包转换为消息对象 */
+ (id<EHISocketMessage>)getMessageWithPacket:(EHISocketPacket *)packet {
    
//    id<EHISocketMessage> message;
    
    // 获取消息类型
    EHIPacketType type = [EHISocketMessageFactory getPacketTypeWithPacket:packet];
    switch (type) {
        case EHIPacketTypeNormalMessage: // 普通聊天
        {
            EHISocketNormalMessage *message = [EHISocketNormalMessage yy_modelWithJSON:packet.body];
            
            return message;
        }
            
        case EHIPacketTypeHeartbeatMessage: // 心跳
        {
            EHISocketHeartbeatMessage *message = [EHISocketHeartbeatMessage yy_modelWithJSON:packet.body];
            
            return message;
        }
            break;
        case EHIPacketTypeLoginMessage: // 登录
        {
            EHISocketLoginMessage *message = [EHISocketLoginMessage yy_modelWithJSON:packet.body];
            
            return message;
        }
            break;
        
        default:
            break;
    }
    
    return nil;
}



@end
