//
//  EHICustomerServiceCell.m
//  J-IM-Demo
//
//  Created by yogurts on 2018/11/30.
//  Copyright © 2018 yogurts. All rights reserved.
//

#import "EHICustomerServiceCell.h"

@interface EHICustomerServiceCell ()

/** 头像 */
@property (nonatomic, strong) UIImageView *avatar;

/** 时间 */
@property (nonatomic, strong) UILabel *timeLabel;

/** 聊天内容视图，contentLabel、picture、voiceButton的父视图 */
@property (nonatomic, strong) UIView *chatView;

/** 文字内容 */
@property (nonatomic, strong) UILabel *contentLabel;

/** 图片 */
@property (nonatomic, strong) UIImageView *picture;

/** 语音 */
@property (nonatomic, strong) UIButton *voiceButton;

/** 消息状态 */
@property (nonatomic, strong) UIButton *statusButton;

@end

@implementation EHICustomerServiceCell


- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self setupSubviews];
    }
    return self;
}

- (void)setupSubviews {
    [self.contentView addSubview:self.avatar];
    [self.contentView addSubview:self.timeLabel];
    [self.contentView addSubview:self.chatView];
    [self.chatView addSubview:self.contentLabel];
    [self.chatView addSubview:self.picture];
    [self.chatView addSubview:self.voiceButton];
}


#pragma mark - setter

- (void)setModel:(EHICustomerServiceModel *)model {
    _model = model;
    
    [self updateUIWithModel:model];
   
}

/** 更新UI布局 */
- (void)updateUIWithModel:(EHICustomerServiceModel *)model {
    
    [self switchMessageWidgetVisualWithModel:model];
    
    // 头像宽高
    CGFloat avatarWidth = 30;
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    
    // 获取聊天内容视图的size
    CGSize chatViewSize = [self getChatViewSizeWithModel:model];
    
    if (model.fromType == EHIMessageFromTypeSender) {
        self.avatar.frame = CGRectMake(screenWidth - avatarWidth - 16, 0, avatarWidth, avatarWidth);
        self.chatView.frame = CGRectMake(CGRectGetMinX(self.avatar.frame) - chatViewSize.width - 8, 0, chatViewSize.width, chatViewSize.height);
    } else {
        self.avatar.frame = CGRectMake(screenWidth - avatarWidth - 16, 0, avatarWidth, avatarWidth);
        self.chatView.frame = CGRectMake(CGRectGetMaxX(self.avatar.frame) + 8, 0, chatViewSize.width, chatViewSize.height);
    }
}

/** 切换聊天文字、语音、图片相关控件的显示隐藏 */
- (void)switchMessageWidgetVisualWithModel:(EHICustomerServiceModel *)model {
    switch (model.messageType) {
        case EHIMessageTypeText:
            self.contentLabel.hidden = NO;
            self.picture.hidden = YES;
            self.voiceButton.hidden = YES;
            break;
        case EHIMessageTypePicture:
            self.contentLabel.hidden = YES;
            self.picture.hidden = NO;
            self.voiceButton.hidden = YES;
            break;
        case EHIMessageTypeVoice:
            self.contentLabel.hidden = YES;
            self.picture.hidden = YES;
            self.voiceButton.hidden = NO;
            break;
            
        default:
            self.contentLabel.hidden = YES;
            self.picture.hidden = YES;
            self.voiceButton.hidden = YES;
            break;
    }
}

/** 获取聊天内容视图的高度 */
- (CGSize)getChatViewSizeWithModel:(EHICustomerServiceModel *)model {
    switch (model.messageType) {
        case EHIMessageTypeText:
            
            return CGSizeZero;
        case EHIMessageTypePicture:
        {
            CGFloat pictureWidth = [UIScreen mainScreen].bounds.size.width / 3.0;
            return CGSizeMake(pictureWidth, pictureWidth * 1.5);
        }
        case EHIMessageTypeVoice:
            
            return CGSizeZero;
            
        default:
            
            return CGSizeZero;
    }
}


#pragma mark - lazy load

- (UIImageView *)avatar {
    if (!_avatar) {
        _avatar = [[UIImageView alloc] init];
    }
    return _avatar;
}

- (UILabel *)timeLabel {
    if (!_timeLabel) {
        _timeLabel = [[UILabel alloc] init];
    }
    return _timeLabel;
}

- (UIView *)chatView {
    if (!_chatView) {
        _chatView = [[UIView alloc] init];
    }
    return _chatView;
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
        _voiceButton = [UIButton buttonWithType:UIButtonTypeCustom];
    }
    return _voiceButton;
}

- (UIButton *)statusButton {
    if (!_statusButton) {
        _statusButton = [UIButton buttonWithType:UIButtonTypeCustom];
    }
    return _statusButton;
}


@end
