//
//  EHINewCustomerSeerviceTools.h
//  J-IM-Demo
//
//  Created by yogurts on 2018/12/7.
//  Copyright © 2018 yogurts. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EHINewCustomerSeerviceTools : NSObject

/** 是否有刘海 */
+ (BOOL)isIphoneX;

/** 获取tabbar底部多余高度 */
+ (CGFloat)getBottomDistance;

@end
