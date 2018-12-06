//
//  EHIBottomInputView.h
//  J-IM-Demo
//
//  Created by yogurts on 2018/11/30.
//  Copyright © 2018 yogurts. All rights reserved.
//
//  在线客服底部视图，包括快捷入口和输入区域
//

#import <UIKit/UIKit.h>

/** 输入状态 */
typedef NS_ENUM(NSInteger, EHICustomServiceInputType) {
    EHICustomServiceInputTypeText,  // 文字
    EHICustomServiceInputTypeVoice  // 语音
};

@interface EHICustomServiceBottomView : UIView

/** 输入类型 */
@property (nonatomic, assign) EHICustomServiceInputType inputType;

/** 快捷入口 */
@property (nonatomic, strong) NSArray *quickEntrances;

/** 快捷入口按钮点击回调 */
@property (nonatomic, copy) void (^quickEntranceSelected)(UIButton *button, NSInteger index);

@end
