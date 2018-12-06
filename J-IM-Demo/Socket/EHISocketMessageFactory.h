//
//  EHISocketMessageConverter.h
//  J-IM-Demo
//
//  Created by yogurts on 2018/11/27.
//  Copyright © 2018 yogurts. All rights reserved.
//
//  消息和包的转换
//

#import "EHISocketMessage.h"
#import "EHISocketPacket.h"

@interface EHISocketMessageFactory : NSObject

/** 获取消息类型 */
+ (EHIPacketType)getPacketTypeWithPacket:(EHISocketPacket *)packet;

/** 将包转换为消息对象 */
+ (id<EHISocketMessage>)getMessageWithPacket:(EHISocketPacket *)packet;


@end
