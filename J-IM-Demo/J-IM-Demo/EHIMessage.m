//
//  EHIMessage.m
//  J-IM-Demo
//
//  Created by yogurts on 2018/11/13.
//  Copyright © 2018 yogurts. All rights reserved.
//

#import "EHIMessage.h"

/** 加密标识位mask，1为加密，否则不加密 */
static const Byte FIRST_BYTE_MASK_ENCRYPT = -128;

/** 压缩标识位mask，1为压缩，否则不压缩 */
static const Byte FIRST_BYTE_MASK_COMPRESS = 0B01000000;

/** 是否有同步序列号标识位mask，如果有同步序列号，消息头会带有同步序列号，否则不带 */
static const Byte FIRST_BYTE_MASK_HAS_SYNSEQ = 0B00100000;

/** 是否用4字节来表示消息体的长度 */
static const Byte FIRST_BYTE_MASK_4_BYTE_LENGTH = 0B00010000;


@implementation EHIMessage

/** 是否加密 */
- (Byte)encodeEncryptWithMask:(Byte)mask andIsEncrypt:(BOOL)isEncrypt {
    if (isEncrypt) {
        return (Byte)(mask | FIRST_BYTE_MASK_ENCRYPT);
    } else {
        return (Byte)(FIRST_BYTE_MASK_ENCRYPT & 0B01111111);
    }
}

/** 是否压缩 */
- (Byte)encodeCompressWithMask:(Byte)mask andIsCompress:(BOOL)isCompress {
    if (isCompress) {
        return (Byte)(mask | FIRST_BYTE_MASK_COMPRESS);
    } else {
        return (Byte)(mask & (FIRST_BYTE_MASK_COMPRESS ^ 0B01111111));
    }
}

/** 是否同步发送 */
- (Byte)encodeHasSynseqWithMask:(Byte)mask andHasSynseq:(BOOL)hasSynseq {
    if (hasSynseq) {
        return (Byte)(mask | FIRST_BYTE_MASK_HAS_SYNSEQ);
    } else {
        return (Byte)(mask & (FIRST_BYTE_MASK_HAS_SYNSEQ ^ 0B01111111));
    }
}

/** 是否用4字节表示消息体长度 */
- (Byte)encode4ByteLengthWithMask:(Byte)mask andIs4ByteLength:(BOOL)is4ByteLength {
    if (is4ByteLength) {
        return (Byte)(mask | FIRST_BYTE_MASK_4_BYTE_LENGTH);
    } else {
        return (Byte)(mask & (FIRST_BYTE_MASK_4_BYTE_LENGTH ^ 0B01111111));
    }
}



@end
