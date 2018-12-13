//
//  EHINewCustomerServiceCommentView.m
//  J-IM-Demo
//
//  Created by yogurts on 2018/12/13.
//  Copyright © 2018 yogurts. All rights reserved.
//

#import "EHINewCustomerServiceCommentView.h"

@interface EHINewCustomerServiceCommentView ()

/** 提示语 */
@property (nonatomic, strong) UILabel *tipLabel;

/** 提示语左边的灰线 */
@property (nonatomic, strong) UIView *leftLine;

/** 提示语右边的灰线 */
@property (nonatomic, strong) UIView *rightLine;

/** 差评 */
@property (nonatomic, strong) UIButton *badCommentButton;

/** 中评 */
@property (nonatomic, strong) UIButton *normalCommentButton;

/** 好评 */
@property (nonatomic, strong) UIButton *goodCommentButton;

@end

@implementation EHINewCustomerServiceCommentView

- (instancetype)init {
    self = [super init];
    if (self) {
        [self setupSubviews];
    }
    return self;
}

- (void)setupSubviews {
    [self addSubview:self.tipLabel];
    [self addSubview:self.leftLine];
    [self addSubview:self.rightLine];
    [self addSubview:self.badCommentButton];
    [self addSubview:self.normalCommentButton];
    [self addSubview:self.goodCommentButton];
}

- (void)willMoveToSuperview:(UIView *)newSuperview {
    [super willMoveToSuperview:newSuperview];
    
    self.tipLabel.bounds = CGRectMake(0, 0, CGRectGetWidth(self.tipLabel.frame), CGRectGetHeight(self.tipLabel.frame));
    self.leftLine.frame = CGRectMake(41, CGRectGetMidY(self.tipLabel.frame), 20, 1);
    
}

#pragma mark - lazy load

- (UILabel *)tipLabel {
    if (!_tipLabel) {
        // 提示语
        _tipLabel = [[UILabel alloc] init];
        _tipLabel.text = @"请对本次服务作出评价";
        _tipLabel.textColor = [UIColor colorWithRed:123/255.0 green:123/255.0 blue:123/255.0 alpha:1.0];
        _tipLabel.font = [UIFont systemFontOfSize:12 weight:UIFontWeightRegular];
    }
    return _tipLabel;
}

- (UIView *)leftLine {
    if (!_leftLine) {
        _leftLine = [[UIView alloc] init];
        _leftLine.backgroundColor = [UIColor colorWithRed:234.0 / 255.0 green:234.0 / 255.0 blue:234.0 / 255.0 alpha:1];
    }
    return _leftLine;
}

- (UIView *)rightLine {
    if (!_rightLine) {
        _rightLine = [[UIView alloc] init];
        _rightLine.backgroundColor = [UIColor colorWithRed:234.0 / 255.0 green:234.0 / 255.0 blue:234.0 / 255.0 alpha:1];
    }
    return _rightLine;
}

- (UIButton *)badCommentButton {
    if (!_badCommentButton) {
        _badCommentButton = [UIButton buttonWithType:UIButtonTypeCustom];
    }
    return _badCommentButton;
}

- (UIButton *)normalCommentButton {
    if (!_normalCommentButton) {
        _normalCommentButton = [UIButton buttonWithType:UIButtonTypeCustom];
    }
    return _normalCommentButton;
}

- (UIButton *)goodCommentButton {
    if (!_goodCommentButton) {
        _goodCommentButton = [UIButton buttonWithType:UIButtonTypeCustom];
    }
    return _goodCommentButton;
}

@end
