//
//  EHICustomerServiceCell.m
//  J-IM-Demo
//
//  Created by yogurts on 2018/11/30.
//  Copyright © 2018 yogurts. All rights reserved.
//

#import "EHICustomerServiceCell.h"

@interface EHICustomerServiceCell ()

/** 时间 */
@property (nonatomic, strong) UILabel *timeLabel;

/** 文字内容 */
@property (nonatomic, strong) UILabel *contentLabel;

/** 图片 */
@property (nonatomic, strong) UIImageView *picture;

/** 语音 */
@property (nonatomic, strong) UIButton *voiceButton;

@end

@implementation EHICustomerServiceCell


- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self setupSubviews];
    }
    return self;
}

- (void)setupSubviews {
    [self.contentView addSubview:self.timeLabel];
    [self.contentView addSubview:self.contentLabel];
    [self.contentView addSubview:self.picture];
    [self.contentView addSubview:self.voiceButton];
}






#pragma mark - lazy load

- (UILabel *)timeLabel {
    if (!_timeLabel) {
        _timeLabel = [[UILabel alloc] init];
    }
    return _timeLabel;
}

- (UILabel *)contentLabel {
    if (!_contentLabel) {
        _contentLabel = [[UILabel alloc] init];
    }
    return _contentLabel;
}

- (UIImageView *)picture {
    if (!_picture) {
        _picture = [[UIImageView alloc] init];
    }
    return _picture;
}

- (UIButton *)voiceButton {
    if (!_voiceButton) {
        _voiceButton = [[UIButton alloc] init];
    }
    return _voiceButton;
}


@end
