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

/** 获取cell高度 */
- (CGFloat)cellHeight {
    CGFloat chatContentHeight = self.chatContentSize.height;
    chatContentHeight = chatContentHeight + 12 >= minimumHeight ? chatContentHeight + 12 : minimumHeight;
    return chatContentHeight;
}

/** 获取聊天内容的宽高 */
- (CGSize)chatContentSize {
    return [self getChatContentSize];
}

/** 获取聊天内容按钮的size */
- (CGSize)getChatContentSize {
    switch (self.messageType) {
        case EHIMessageTypeText:
        {
            CGSize textSize = [self getSizeOfString:self.text fontSize:14];
            CGFloat height = textSize.height + 12;
            return CGSizeMake(textSize.width + 18, height);
        }
        case EHIMessageTypePicture:
        {
            CGSize picSize = [self getSizeOfPicture];
            return picSize;
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
    return CGSizeMake([UIScreen mainScreen].bounds.size.width / 3.5, 39);
}

/** 获取图片消息的size */
- (CGSize)getSizeOfPicture {
    if (self.ratio) {
        CGFloat picWidth = [UIScreen mainScreen].bounds.size.width / 2.0;
        CGFloat picHeight = picWidth / self.ratio;
        return CGSizeMake(picWidth, picHeight);
    }
    return CGSizeMake(50, 50);
}

@end
