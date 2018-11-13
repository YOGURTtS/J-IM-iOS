//
//  EHIMessage.h
//  J-IM-Demo
//
//  Created by yogurts on 2018/11/13.
//  Copyright © 2018 yogurts. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EHIMessage : NSObject

/** 当前协议版本号 */
@property (nonatomic, assign) Byte version;

/** 用于描述消息是否加密、压缩、同步发送、使用四字节表示消息体的长度 */
@property (nonatomic, assign) Byte mask;

/**
 *  同步发送序列号，占用4个字节，存放同步序号
 *  注意：如果消息 非同步发送也就是第二个字节 mask 中的第三位为 0，
 *  那这里这 4 个 byte 是不需要设置的,
 *  为 1 的话才需要设置
 */
@property (nonatomic, assign) Byte *serial;

/**
 *  命令码
 *  比如聊天请求的消息命令码为 1，登录请求的消息命令码为 2
 */
@property (nonatomic, assign) Byte cmd;

/** 消息体长度，占用4个字节 */
@property (nonatomic, assign) Byte *bodyLength;

/** 消息体 */
@property (nonatomic, strong) NSMutableDictionary *body;

@end
