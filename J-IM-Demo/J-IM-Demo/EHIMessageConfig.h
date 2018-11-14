//
//  EHIMessageConfig.h
//  J-IM-Demo
//
//  Created by 孙星 on 2018/11/13.
//  Copyright © 2018 yogurts. All rights reserved.
//
//  一些需要用到的参数
//

#import <Foundation/Foundation.h>

/** 心跳字节 */
static const SignedByte HEARTBEAT_BYTE = -128;

/** 握手字节 */
static const SignedByte HANDSHAKE_BYTE = -127;

/** 协议版本号 */
static const SignedByte VERSION = 0x01;
static const NSString *WEBSOCKET = @"ws";
static const NSString *HTTP = @"http";
static const NSString *TCP = @"tcp";
static const NSString *COOKIE_NAME_FOR_SESSION = @"jim-s";

/** 消息体最多为多少 */
static const int MAX_LENGTH_OF_BODY = (int) (1024 * 1024 * 2.1);

/** 消息头最少为多少字节 */
static const int LEAST_HEADER_LENGHT = 4; // 1（协议版本号） + 1(mask) + 2(消息体长度) + (2(4字节表示消息体长度)+4(同步发送消息))

/** 消息头字节数 */
static const int HEADER_LENGHT = 7; // 1（协议版本号） + 1(mask) + 1(命令码) + 4(消息体长度)

/** 加密标识位mask，1为加密，否则不加密 */
static const SignedByte FIRST_BYTE_MASK_ENCRYPT = -128;

/** 压缩标识位mask，1为压缩，否则不压缩 */
static const SignedByte FIRST_BYTE_MASK_COMPRESS = 0B01000000;

/** 是否有同步序列号标识位mask，如果有同步序列号，消息头会带有同步序列号，否则不带 */
static const SignedByte FIRST_BYTE_MASK_HAS_SYNSEQ = 0B00100000;

/** 是否用4字节来表示消息体的长度 */
static const SignedByte FIRST_BYTE_MASK_4_BYTE_LENGTH = 0B00010000;

/** 版本号mask */
static const SignedByte FIRST_BYTE_MASK_VERSION = 0B00001111;

@interface EHIMessageConfig : NSObject

@end

