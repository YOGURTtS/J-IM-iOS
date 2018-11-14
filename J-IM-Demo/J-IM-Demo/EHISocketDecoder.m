//
//  EHISocketDecoder.m
//  J-IM-Demo
//
//  Created by yogurts on 2018/11/14.
//  Copyright © 2018 yogurts. All rights reserved.
//

#import "EHISocketDecoder.h"
#import "EHIMessageConfig.h"
#import "EHISocketPacket.h"

@implementation EHISocketDecoder

/** 解码 */
- (EHISocketPacket *)decode:(NSData *)data {
    
    if (![self isHeaderLengthValid:data]) {
        return nil;
    }
    
    EHISocketPacket *packet = [EHISocketPacket new];
    
    // 获取版本号
    SignedByte version;
    [data getBytes:&version range:NSMakeRange(0, 1)];
    packet.version = version;
    
    // 获取mask
    SignedByte mask;
    [data getBytes:&mask range:NSMakeRange(1, 1)];
    packet.mask = mask;
    
    // 获取命令码
    SignedByte cmd;
    [data getBytes:&cmd range:NSMakeRange(2, 1)];
    packet.cmd = cmd;
    
    // 获取消息体长度
    int bodyLength;
    [data getBytes:&bodyLength range:NSMakeRange(3, 4)];
    if (bodyLength < 0) { // 获取消息体长度出错
        return nil;
    } else {
        packet.bodyLength = bodyLength;
    }
    
    
    
    
    
    
    return packet;
}

/** 判断消息头长度是否合法 */
- (BOOL)isHeaderLengthValid:(NSData *)data {
    if (data.length < HEADER_LENGHT) {
        return NO;
    }
    
    // 判断版本号是否正确
    SignedByte version;
    [data getBytes:&version range:NSMakeRange(0, 1)];
    if (version != VERSION) {
        return NO;
    }
    
    // 判断mask是否正确
    SignedByte mask;
    [data getBytes:&mask range:NSMakeRange(1, 1)];
    if (mask != 0B00010000) { // 0B000100001代表只有4字节表示消息体长度为true，其他为false
        return NO;
    }
    
    return YES;
}

@end
