//
//  EHIMessage.m
//  J-IM-Demo
//
//  Created by yogurts on 2018/11/13.
//  Copyright © 2018 yogurts. All rights reserved.
//

#import "EHISocketPacket.h"
#import "EHIMessageConfig.h"

@interface EHISocketPacket ()

/** 当前协议版本号 */
@property (nonatomic, assign) SignedByte version;

/** 用于描述消息是否加密、压缩、同步发送、使用四字节表示消息体的长度 */
@property (nonatomic, assign) SignedByte mask;

/**
 *  同步发送序列号，占用4个字节，存放同步序号
 *  注意：如果消息 非同步发送也就是第二个字节 mask 中的第三位为 0，
 *  那这里这 4 个 byte 是不需要设置的,
 *  为 1 的话才需要设置
 */
@property (nonatomic, assign) SignedByte *serial;

/** 消息体长度，占用4个字节 */
@property (nonatomic, assign) SignedByte *bodyLength;

@end


@implementation EHISocketPacket

/** 是否加密 */
- (SignedByte)encodeEncryptWithMask:(SignedByte)mask andIsEncrypt:(BOOL)isEncrypt {
    if (isEncrypt) {
        return (SignedByte)(mask | FIRST_BYTE_MASK_ENCRYPT);
    } else {
        return (SignedByte)(FIRST_BYTE_MASK_ENCRYPT & 0B01111111);
    }
}

/** 是否压缩 */
- (SignedByte)encodeCompressWithMask:(SignedByte)mask andIsCompress:(BOOL)isCompress {
    if (isCompress) {
        return (SignedByte)(mask | FIRST_BYTE_MASK_COMPRESS);
    } else {
        return (SignedByte)(mask & (FIRST_BYTE_MASK_COMPRESS ^ 0B01111111));
    }
}

/** 是否同步发送 */
- (SignedByte)encodeHasSynseqWithMask:(SignedByte)mask andHasSynseq:(BOOL)hasSynseq {
    if (hasSynseq) {
        return (SignedByte)(mask | FIRST_BYTE_MASK_HAS_SYNSEQ);
    } else {
        return (SignedByte)(mask & (FIRST_BYTE_MASK_HAS_SYNSEQ ^ 0B01111111));
    }
}

/** 是否用4字节表示消息体长度 */
- (SignedByte)encode4ByteLengthWithMask:(SignedByte)mask andIs4ByteLength:(BOOL)is4ByteLength {
    if (is4ByteLength) {
        return (SignedByte)(mask | FIRST_BYTE_MASK_4_BYTE_LENGTH);
    } else {
        return (SignedByte)(mask & (FIRST_BYTE_MASK_4_BYTE_LENGTH ^ 0B01111111));
    }
}

/** 计算消息头长度 */
- (int)calculateHeaderLength:(BOOL)is4ByteLength {
    
    int len = 4;
    if (is4ByteLength) {
        len += 2;
    }
    // TODO: 判断是否同步发送
    if (0) {
        len += 4;
    }
    
    return len;
}

/** 获取命令码 */
- (NSData *)getCommandWithCommand:(EHISocketMessageCommand)command {
    SignedByte byte[1] = {};
    byte[0] = (SignedByte) (command & 0xFF);
    return [NSData dataWithBytes:byte length:1];
}



@end
