//
//  EHIMessage.m
//  J-IM-Demo
//
//  Created by yogurts on 2018/11/13.
//  Copyright © 2018 yogurts. All rights reserved.
//

#import "EHISocketMessage.h"
#import "EHIMessageConfig.h"


@implementation EHISocketMessage

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



@end
