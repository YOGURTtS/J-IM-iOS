//
//  EHISocketEncoder.m
//  J-IM-Demo
//
//  Created by 孙星 on 2018/11/13.
//  Copyright © 2018 yogurts. All rights reserved.
//

#import "EHISocketEncoder.h"
#import "EHISocketPacket.h"
#import "EHIMessageConfig.h"

@implementation EHISocketEncoder

/** 编码 */
- (NSData *)encode:(EHISocketPacket *)packet {
    
    // 消息体长度
    int bodyLength = 0;
    NSData *bodyData = packet.body;
    if (bodyData.length) {
        bodyLength = (int)bodyData.length;
    }
    
    // 协议版本号
    SignedByte version = VERSION;
    
    // 协议标识位mask
    BOOL isEncrypt = NO;
    BOOL isCompress = NO;
    BOOL isHasSynSeq = NO;
    BOOL is4ByteLength = YES;
    
    SignedByte mask = [packet encodeEncryptWithMask:0x01 andIsEncrypt:isEncrypt];
    mask = [packet encodeCompressWithMask:mask andIsCompress:isCompress];
    mask = [packet encodeHasSynseqWithMask:mask andHasSynseq:isHasSynSeq];
    mask = [packet encode4ByteLengthWithMask:mask andIs4ByteLength:is4ByteLength];
    
    // 命令码
    SignedByte cmdByte = 0x00;
    if (packet.cmd > 0) {
        cmdByte = (SignedByte)(cmdByte | packet.cmd);
    }
    
    packet.version = version;
    packet.mask = mask;
    
    // 总长度是 = 1byte协议版本号+1byte消息标志位+4byte同步序列号(如果是同步发送则都4byte同步序列号,否则无4byte序列号)+1byte命令码+4byte消息的长度+消息体
    int packetLength = 1 + 1;
    if (isHasSynSeq) {
        packetLength += 4;
    }
    packetLength += 1 + 4 + bodyLength;
    
    NSMutableData *packetData = [NSMutableData dataWithLength:packetLength];
    [packetData appendBytes:&version length:1];
    [packetData appendBytes:&mask length:1];
    if (isHasSynSeq) {
        int serial = packet.serial;
        [packetData appendBytes:&serial length:4];
    }
    [packetData appendBytes:&cmdByte length:1];
    [packetData appendBytes:&bodyLength length:4];
    [packetData appendData:bodyData];
    
    return packetData;
}

@end
