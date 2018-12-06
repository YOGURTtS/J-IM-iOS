//
//  EHISocketStatusManager.m
//  J-IM-Demo
//
//  Created by yogurts on 2018/12/5.
//  Copyright © 2018 yogurts. All rights reserved.
//

#import "EHISocketStatusManager.h"

@implementation EHISocketStatusManager

- (void)setHeaderData:(NSData *)headerData {
    _headerData = headerData;
    if (headerData == nil) {
        self.readDataStatus = EHISocketReadDataStatusUnGetHeader;
    } else {
        self.readDataStatus = EHISocketReadDataStatusGetHeader;
    }
}

//- (void)setBodyLength:(NSInteger)bodyLength {
//    _bodyLength = bodyLength;
//    if (bodyLength) {
//        self.readDataStatus = EHISocketReadDataStatusGetHeader;
//    } else if (!bodyLength && self.headerData) {
//
//    } else {
//
//    }
//}

@end
