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

/** socket解码状态 */
typedef NS_ENUM(NSInteger, EHIDecodeStatus) {
    EHIDecodeStatusUnGetHeader, /// 未获取到头
    EHIDecodeStatusGetHeader    /// 已经获取到头
};

@class EHISocketPacket;
@interface EHISocketDecoder : NSObject

/** 解码状态 */
@property (nonatomic, assign) EHIDecodeStatus decodeStatus;

/** 判断消息头长度是否合法 */
- (BOOL)isHeaderLengthValid:(NSData *)data;

/** 获取消息头，此时packet的消息体为空 */
- (EHISocketPacket *)getPacketHeader:(NSData *)data;

/** 解码，获取完整的packet */
- (EHISocketPacket *)decode:(NSData *)data;


@end
