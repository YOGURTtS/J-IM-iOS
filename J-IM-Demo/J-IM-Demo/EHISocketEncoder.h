//
//  EHISocketEncoder.h
//  J-IM-Demo
//
//  Created by 孙星 on 2018/11/13.
//  Copyright © 2018 yogurts. All rights reserved.
//
//  编码
//

#import <Foundation/Foundation.h>

@class EHISocketPacket;
@interface EHISocketEncoder : NSObject

/** 编码 */
- (NSData *)encode:(EHISocketPacket *)packet;

@end

