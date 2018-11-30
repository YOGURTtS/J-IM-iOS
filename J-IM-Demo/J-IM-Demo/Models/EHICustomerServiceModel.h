//
//  EHICustomerServiceModel.h
//  J-IM-Demo
//
//  Created by yogurts on 2018/11/30.
//  Copyright © 2018 yogurts. All rights reserved.
//
//
//

#import "EHISocketMessage.h"

/** 消息来源 */
typedef NS_ENUM(NSInteger, EHIMessageFromType) {
    EHIMessageFromTypeReceiver, /// 接收消息
    EHIMessageFromTypeSender    /// 发送消息
};

/** 消息状态 */
typedef NS_ENUM(NSInteger, EHIMessageStatus) {
    EHIMessageStatusSending, /// 发送中
    EHIMessageStatusFailed   /// 发送失败
};

@interface EHICustomerServiceModel : NSObject

/** 消息来源 */
@property (nonatomic, assign) EHIMessageFromType fromType;

/** 消息状态 */
@property (nonatomic, assign) EHIMessageStatus messageStatus;

/** 消息类型 */
@property (nonatomic, assign) EHIMessageType messageType;

/** 内容 */
@property (nonatomic, copy) NSString *content;

/** 时间 */
@property (nonatomic, copy) NSString *time;

@end
