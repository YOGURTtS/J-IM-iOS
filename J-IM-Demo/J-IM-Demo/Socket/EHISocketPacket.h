//
//  EHIMessage.h
//  J-IM-Demo
//
//  Created by yogurts on 2018/11/13.
//  Copyright © 2018 yogurts. All rights reserved.
//
//  TCP包
//

#import "EHISocketMessageCommand.h"
#import "EHISocketMessage.h"

@interface EHISocketPacket : NSObject

/** 构造函数 */
- (instancetype)initWithMessage:(id<EHISocketMessage>)message command:(EHISocketMessageCommand)command;

/** 当前协议版本号 */
@property (nonatomic, assign) SignedByte version;

/**
 *  命令码
 *  比如聊天请求的消息命令码为 1，登录请求的消息命令码为 2
 */
@property (nonatomic, assign) EHISocketMessageCommand cmd;

/** 用于描述消息是否加密、压缩、同步发送、使用四字节表示消息体的长度 */
@property (nonatomic, assign) SignedByte mask;

/**
 *  同步发送序列号，占用4个字节，存放同步序号
 *  注意：如果消息 非同步发送也就是第二个字节 mask 中的第三位为 0，
 *  那这里这 4 个 byte 是不需要设置的,
 *  为 1 的话才需要设置
 */
@property (nonatomic, assign) int serial;

/** 消息体长度，占用4个字节 */
@property (nonatomic, assign) int bodyLength;

/** 消息体 */
@property (nonatomic, strong) NSData *body;


/** 是否加密 */
- (SignedByte)encodeEncryptWithMask:(SignedByte)mask andIsEncrypt:(BOOL)isEncrypt;

/** 是否压缩 */
- (SignedByte)encodeCompressWithMask:(SignedByte)mask andIsCompress:(BOOL)isCompress;

/** 是否同步发送 */
- (SignedByte)encodeHasSynseqWithMask:(SignedByte)mask andHasSynseq:(BOOL)hasSynseq;

/** 是否用4字节表示消息体长度 */
- (SignedByte)encode4ByteLengthWithMask:(SignedByte)mask andIs4ByteLength:(BOOL)is4ByteLength;

@end
