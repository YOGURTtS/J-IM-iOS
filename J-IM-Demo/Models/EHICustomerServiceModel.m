//
//  EHICustomerServiceModel.m
//  J-IM-Demo
//
//  Created by yogurts on 2018/11/30.
//  Copyright © 2018 yogurts. All rights reserved.
//

#import "EHICustomerServiceModel.h"

@implementation EHICustomerServiceModel

- (void)handleMediaDataWithMessageType:(EHIMessageType)type {
    switch (type) {
        case EHIMessageTypePicture: // 图片
            [self getPictureData];
            break;
        case EHIMessageTypeVoice: // 语音
            [self getVoiceData];
            break;
            
        default:
            break;
    }
}

/** 获取图片数据 */
- (void)getPictureData {
    
    NSData *pictureData = [NSData dataWithContentsOfURL:[NSURL URLWithString:self.content]];
    CGFloat pictureWidth = [UIScreen mainScreen].bounds.size.width / 3.0;
    self.size = CGSizeMake(pictureWidth, pictureWidth * 1.5);
    self.pictureData = pictureData;
}

/** 获取语音数据 */
- (void)getVoiceData {
    
    NSData *voiceData = [NSData dataWithContentsOfURL:[NSURL URLWithString:self.content]];
    
    self.voiceData = voiceData;
}

@end
