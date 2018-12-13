//
//  EHINewCustomerServiceCommentView.h
//  J-IM-Demo
//
//  Created by yogurts on 2018/12/13.
//  Copyright © 2018 yogurts. All rights reserved.
//
//  聊天结束的评价视图
//

#import <UIKit/UIKit.h>

/** 客户评价类型 */
typedef NS_ENUM(NSInteger, EHINewCustomerServiceCommentType) {
    EHINewCustomerServiceCommentTypeBad,    // 差评
    EHINewCustomerServiceCommentTypeNormal, // 一般
    EHINewCustomerServiceCommentTypeGood    // 好评
};

@interface EHINewCustomerServiceCommentView : UIView

/** 客户f点击评价按钮回调 */
@property (nonatomic, copy) void (^commentCallback)(EHINewCustomerServiceCommentType type);

@end

