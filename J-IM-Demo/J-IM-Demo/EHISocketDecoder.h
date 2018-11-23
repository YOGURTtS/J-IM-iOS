//
//  EHISocketDecoder.h
//  J-IM-Demo
//
//  Created by yogurts on 2018/11/14.
//  Copyright © 2018 yogurts. All rights reserved.
//
//  解码
//

#import <Foundation/Foundation.h>

@class EHISocketPacket;
@interface EHISocketDecoder : NSObject

/** 判断消息头长度是否合法 */
- (BOOL)isHeaderLengthValid:(NSData *)data;

/** 获取消息头，此时packet的消息体为空 */
- (EHISocketPacket *)getPacketHeader:(NSData *)data;

/** 解码，获取完整的packet */
- (EHISocketPacket *)decode:(NSData *)data;

@end
