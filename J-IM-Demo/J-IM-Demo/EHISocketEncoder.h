//
//  EHISocketEncoder.h
//  J-IM-Demo
//
//  Created by 孙星 on 2018/11/13.
//  Copyright © 2018 yogurts. All rights reserved.
//

#import <Foundation/Foundation.h>

@class EHISocketMessage;
@interface EHISocketEncoder : NSObject

/** 编码 */
- (NSData *)encodeMessage:(EHISocketMessage *)message;

@end

