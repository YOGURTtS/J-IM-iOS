//
//  EHINewCustomerServiceDAO.h
//  J-IM-Demo
//
//  Created by yogurts on 2018/12/10.
//  Copyright © 2018 yogurts. All rights reserved.
//

#import "EHIDBBaseDAO.h"
#import "EHICustomerServiceModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface EHINewCustomerServiceDAO : EHIDBBaseDAO

/** 添加消息记录 */
- (BOOL)addMessage:(EHICustomerServiceModel *)message;

/** 查找所有的匿名信息 返回 */
- (void)getAnonymousMessageWithCompletion:(void (^)(NSArray *array))completion;

/** 查找所有的实名信息 返回 */
- (void)getLoginMessageWithCompletion:(void (^)(NSArray *array))completion;

/** 删除所有的匿名信息 */
- (BOOL)deleteAnonymousMessages;

/** 删除所有信息 */
- (BOOL)deleteAllMessages;

/** 将所有的匿名信息更新为实名信息 */
- (BOOL)turnAnonymousMessagesToLoginMessages;

@end

NS_ASSUME_NONNULL_END
