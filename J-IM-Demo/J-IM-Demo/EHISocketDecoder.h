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

@class EHISocketPacket;
@interface EHISocketDecoder : NSObject

/** 解码 */
- (EHISocketPacket *)decode:(NSData *)data;

@end
