//
//  EHIMessage.h
//  MobileSales
//
//  Created by dengwx on 17/2/19.
//  Copyright © 2017年 wxdeng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EHIMessageFrame.h"

#define     MAX_MESSAGE_WIDTH               SCREEN_WIDTH * 0.58
#define     MAX_MESSAGE_IMAGE_WIDTH         WIDTH_SCREEN * 0.45
#define     MIN_MESSAGE_IMAGE_WIDTH         WIDTH_SCREEN * 0.25

/** 消息类型 */
typedef NS_ENUM(NSInteger, EHIMessageType) {
    EHIMessageTypeUnknown,
    EHIMessageTypeText,          /// 文字
    EHIMessageTypePicture,         /// 图片
    EHIMessageTypeExpression,    /// 表情
    EHIMessageTypeVoice,         /// 语音
    EHIMessageTypeOther,
};

/** 消息拥有者 */
typedef NS_ENUM(NSInteger, EHIMessageOwnerType){
    EHIMessageOwnerTypeUnknown,  /// 未知的消息拥有者
    EHIMessageOwnerTypeSelf,     /// 自己发送的消息
    EHIMessageOwnerTypeFriend,   /// 接收到的他人消息
};

/** 消息发送状态 */
typedef NS_ENUM(NSInteger, EHIMessageSendState){
    EHIMessageSending,
    EHIMessageSendSuccess,       /// 消息发送成功
    EHIMessageSendFail,          /// 消息发送失败
};

/** 消息读取状态 */
typedef NS_ENUM(NSInteger, EHIMessageReadState) {
    EHIMessageUnRead,            /// 消息未读
    EHIMessageReaded,            /// 消息已读
};

@interface EHIMessage : NSObject {
    
    EHIMessageFrame *kMessageFrame;
}

/** 消息ID */
@property (nonatomic, strong) NSString *messageID;

/** 发送者ID */
@property (nonatomic, strong) NSString *sendID;

/** 发送者Name */
@property (nonatomic, strong) NSString *sendName;

/** 接收者ID */
@property (nonatomic, strong) NSString *receivedID;

/** 接收者Name */
@property (nonatomic, strong) NSString *receivedName;

/** 组ID */
@property (nonatomic, strong) NSString *nodeID;

/** 发送时间 */
@property (nonatomic, strong) NSDate *date;

@property (nonatomic, assign) BOOL showTime;
@property (nonatomic, assign) BOOL showName;

/** 消息类型 */
@property (nonatomic, assign) EHIMessageType messageType;

/** 发送者类型 */
@property (nonatomic, assign) EHIMessageOwnerType ownerTyper;

/** 读取状态 */
@property (nonatomic, assign) EHIMessageReadState readState;

/** 发送状态 */
@property (nonatomic, assign) EHIMessageSendState sendState;

@property (nonatomic, strong) NSMutableDictionary *content;

/** 消息frame */
@property (nonatomic, strong, readonly) EHIMessageFrame *messageFrame;


+ (EHIMessage *)createMessageByType:(EHIMessageType)type;

- (void)resetMessageFrame;

@end
