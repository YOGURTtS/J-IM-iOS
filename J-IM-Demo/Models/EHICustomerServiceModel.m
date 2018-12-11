//
//  EHICustomerServiceModel.m
//  J-IM-Demo
//
//  Created by yogurts on 2018/11/30.
//  Copyright © 2018 yogurts. All rights reserved.
//

#import "EHICustomerServiceModel.h"

/** 最小行高 */
static NSInteger minimumHeight = 52;

@implementation EHICustomerServiceModel

//- (void)handleMediaDataWithMessageType:(EHIMessageType)type {
//    switch (type) {
//        case EHIMessageTypePicture: // 图片
//            [self getPictureData];
//            break;
//        case EHIMessageTypeVoice: // 语音
//            [self getVoiceData];
//            break;
//            
//        default:
//            break;
//    }
//}

///** 获取图片数据 */
//- (void)getPictureData {
//
//    NSData *pictureData = [NSData dataWithContentsOfURL:[NSURL URLWithString:self.content]];
//    CGFloat pictureWidth = [UIScreen mainScreen].bounds.size.width / 3.0;
//    self.size = CGSizeMake(pictureWidth, pictureWidth * 1.5);
//    self.pictureUrl = pictureData;
//}
//
///** 获取语音数据 */
//- (void)getVoiceData {
//
//    NSData *voiceData = [NSData dataWithContentsOfURL:[NSURL URLWithString:self.content]];
//
//    self.voiceData = voiceData;
//}

#pragma mark - get

/** 获取聊天内容的宽高 */
- (CGSize)chatContentSize {
    return [self getChatContentSize];
}

/** 获取聊天内容按钮的size */
- (CGSize)getChatContentSize {
    switch (self.messageType) {
        case EHIMessageTypeText:
        {
            CGSize textSize = [self getSizeOfString:self.text fontSize:15];
            CGFloat height = textSize.height >= minimumHeight ? textSize.height : minimumHeight;
            return CGSizeMake(textSize.width + 6, height + 6);
        }
        case EHIMessageTypePicture:
        {
            CGFloat pictureWidth = [UIScreen mainScreen].bounds.size.width / 3.0;
            CGFloat height = pictureWidth >= minimumHeight ? pictureWidth : minimumHeight;
            return CGSizeMake(pictureWidth + 6, height + 6);
        }
        case EHIMessageTypeVoice:
        {
            CGSize voiceSize = [self getSizeOfVoice];
            return voiceSize;
        }
        default:
            
            return CGSizeZero;
    }
}

/** 获取文字的size */
- (CGSize)getSizeOfString:(NSString *)string fontSize:(CGFloat)fontSize {
    return [string boundingRectWithSize:CGSizeMake([UIScreen mainScreen].bounds.size.width / 2.0, [UIScreen mainScreen].bounds.size.height) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:fontSize]} context:nil].size;
}

/** 获取语音消息的size */
- (CGSize)getSizeOfVoice {
    
    return CGSizeMake(123, 40);
}

@end
