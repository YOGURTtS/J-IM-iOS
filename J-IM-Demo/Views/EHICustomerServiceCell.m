//
//  EHICustomerServiceCell.m
//  J-IM-Demo
//
//  Created by yogurts on 2018/11/30.
//  Copyright © 2018 yogurts. All rights reserved.
//

#import "EHICustomerServiceCell.h"
#import <AVKit/AVKit.h>

@interface EHICustomerServiceCell () {
    UIView *_bgView;
}

/** 头像 */
@property (nonatomic, strong) UIImageView *avatar;

/** 时间 */
@property (nonatomic, strong) UILabel *timeLabel;

/** 显示文字、语音、图片的按钮 */
@property (nonatomic, strong) UIButton *contentButton;

/** 消息状态，目前socket不支持显示状态，仅用于语音消息显示秒数 */
@property (nonatomic, strong) UIButton *statusButton;

/** 音频播放器 */
@property (nonatomic, strong) AVAudioPlayer *audioPlayer;

@end

@implementation EHICustomerServiceCell


- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.backgroundColor = [UIColor clearColor];
        [self setupSubviews];
    }
    return self;
}

- (void)setupSubviews {
    [self.contentView addSubview:self.avatar];
    [self.contentView addSubview:self.timeLabel];
    [self.contentView addSubview:self.contentButton];
    [self.contentView addSubview:self.statusButton];
}

#pragma mark - setter

- (void)setModel:(EHICustomerServiceModel *)model {
    _model = model;
    [self updateUIWithModel:model];
}

#pragma mark - UI

/** 更新UI布局 */
- (void)updateUIWithModel:(EHICustomerServiceModel *)model {
    
    // 重置UI
    [self resetUI];
    
    // 头像宽高
    CGFloat avatarWidth = 30;
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    
    // 获取聊天内容视图的size
    CGSize chatViewSize = model.chatContentSize;
    
    if (model.fromType == EHIMessageFromTypeSender) {
        // 头像
        self.avatar.image = [UIImage imageNamed:@"new_customer_service_default_avatar"];
        self.avatar.frame = CGRectMake(screenWidth - avatarWidth - 16, 12, avatarWidth, avatarWidth);
        // 内容
        self.contentButton.frame = CGRectMake(CGRectGetMinX(self.avatar.frame) - chatViewSize.width - 5,
                                              12,
                                              chatViewSize.width,
                                              chatViewSize.height);
        [self.contentButton setBackgroundImage:[UIImage imageNamed:@"new_customer_service_send_bubble"] forState:UIControlStateNormal];
        [self.contentButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        self.contentButton.titleEdgeInsets = model.messageType == EHIMessageTypeText ? UIEdgeInsetsMake(6, 6, 6, 12) : UIEdgeInsetsZero;
        // 状态按钮
        self.statusButton.frame = CGRectMake(CGRectGetMinX(self.contentButton.frame) - 37, 22, 30, 18);
        
    } else {
        // 头像
        self.avatar.image = [UIImage imageNamed:@"new_customer_service_staff_avatar"];
        self.avatar.frame = CGRectMake(16, 12, avatarWidth, avatarWidth);
        // 内容
        self.contentButton.frame = CGRectMake(CGRectGetMaxX(self.avatar.frame) + 5,
                                              12,
                                              chatViewSize.width,
                                              chatViewSize.height);
        [self.contentButton setBackgroundImage:[UIImage imageNamed:@"new_customer_service_receive_bubble"] forState:UIControlStateNormal];
        [self.contentButton setTitleColor:[UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1.0] forState:UIControlStateNormal];
        self.contentButton.titleEdgeInsets = model.messageType == EHIMessageTypeText ? UIEdgeInsetsMake(6, 12, 6, 6) : UIEdgeInsetsZero;
        // 状态按钮
        self.statusButton.frame = CGRectMake(CGRectGetMaxX(self.contentButton.frame) + 7, 22, 30, 18);
    }
    [self setupChatContentWithModel:model];
    [self setupStatusButtonWithModel:model];
}

/** 设置聊天内容 */
- (void)setupChatContentWithModel:(EHICustomerServiceModel *)model {
    
    switch (model.messageType) {
        case EHIMessageTypeText:
        {
            [self.contentButton setTitle:model.text forState:UIControlStateNormal];
        }
            break;
        case EHIMessageTypeVoice:
            [self.contentButton setImage:[UIImage imageNamed:@"new_customer_service_voice"] forState:UIControlStateNormal];
            if (model.fromType == EHIMessageFromTypeSender) {
                self.contentButton.imageEdgeInsets = UIEdgeInsetsMake(0, 30, 0, -30);
            } else {
                self.contentButton.imageEdgeInsets = UIEdgeInsetsMake(0, -30, 0, 30);
            }
            switch (model.playStatus) {
                case EHIVoiceMessagePlayStatusIsplaying:
//                    [self.contentButton setTitle:@"播放中" forState:UIControlStateNormal];
                    break;
                case EHIVoiceMessagePlayStatusPause:
//                    [self.contentButton setTitle:@"播放暂停" forState:UIControlStateNormal];
                    break;
                case EHIVoiceMessagePlayStatusFinish:
//                    [self.contentButton setTitle:@"播放完成" forState:UIControlStateNormal];
                    break;
                    
                default:
//                    [self.contentButton setTitle:@"录音" forState:UIControlStateNormal];
                    [self.contentButton setImage:[UIImage imageNamed:@"new_customer_service_voice"] forState:UIControlStateNormal];
                    break;
            }
            
            break;
        case EHIMessageTypePicture:
        {
            // 设置聊天内容按钮样式
            self.contentButton.layer.cornerRadius = 4;
            self.contentButton.clipsToBounds = YES;
            self.contentButton.layer.borderColor = model.fromType == EHIMessageFromTypeSender ? [UIColor colorWithRed:41 / 255.0 green:183 / 255.0 blue:183 / 255.0 alpha:1.0].CGColor : [UIColor whiteColor].CGColor;
            self.contentButton.layer.borderWidth = 1;
            
            [self.contentButton setBackgroundImage:nil forState:UIControlStateNormal];
            [self.contentButton setImage:model.picture forState:UIControlStateNormal];
            self.contentButton.imageView.contentMode = UIViewContentModeScaleAspectFill;
        }
            break;
            
        default:
            break;
    }
}

/** 设置状态按钮 */
- (void)setupStatusButtonWithModel:(EHICustomerServiceModel *)model {
    if (model.messageType == EHIMessageTypeVoice) {
        self.statusButton.hidden = NO;
        [self.statusButton setTitle:[NSString stringWithFormat:@"%@″", [NSNumber numberWithInteger:model.voiceDuration]] forState:UIControlStateNormal];
    } else {
        self.statusButton.hidden = YES;
        [self.statusButton setTitle:@"" forState:UIControlStateNormal];
    }
}

/** 重置UI */
- (void)resetUI {
    // 重置聊天内容按钮样式
    self.contentButton.layer.cornerRadius = 0;
    self.contentButton.clipsToBounds = NO;
    self.contentButton.layer.borderColor = nil;
    self.contentButton.layer.borderWidth = 0;
    [self.contentButton setTitle:@"" forState:UIControlStateNormal];
    [self.contentButton setImage:nil forState:UIControlStateNormal];
    [self.contentButton setBackgroundImage:nil forState:UIControlStateNormal];
    self.contentButton.imageEdgeInsets = UIEdgeInsetsZero;
}

#pragma mark - button click action

/** 聊天内容按钮点击 */
- (void)contentButtonClicked:(UIButton *)button {
    switch (self.model.messageType) {
        case EHIMessageTypeText:    // 文字，什么也不做
            
            break;
        case EHIMessageTypeVoice:   // 语音，播放语音
            [self playVoice];
            break;
        case EHIMessageTypePicture: // 图片，缩放图片
            [self seeFullScreenPicture];
            break;
            
        default:
            break;
    }
}

/** 播放音频 */
- (void)playVoice {
    if (self.voicePlay) {
        self.voicePlay();
    }
}

/** 查看大图 */
- (void)seeFullScreenPicture {
    // 初始化一个用来当做背景的view
    _bgView = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    _bgView.backgroundColor = [UIColor blackColor];
    UIWindow *keyWindow = [[[UIApplication sharedApplication] delegate] window];
    [keyWindow addSubview:_bgView];
    
    UIImageView *imgView = [[UIImageView alloc] initWithFrame:(CGRectMake(0,
                                                                          0,
                                                                          [UIScreen mainScreen].bounds.size.width,
                                                                          [UIScreen mainScreen].bounds.size.height))];
    imgView.contentMode = UIViewContentModeScaleAspectFit;
    imgView.center = CGPointMake([UIScreen mainScreen].bounds.size.width / 2.0, [UIScreen mainScreen].bounds.size.height / 2.0);
    // TODO: 加载网络图片
    imgView.image = self.model.picture;
    [_bgView addSubview:imgView];
    imgView.userInteractionEnabled = YES;
    
    // 添加点击手势（点击图片后退出全屏)
    UITapGestureRecognizer *tapGest = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(closeView)];
    [_bgView addGestureRecognizer:tapGest];
    // 放大过程中的动画
    [self shakeToShow:_bgView];
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
}

/** 关闭大图 */
- (void)closeView {
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    [_bgView removeFromSuperview];
}

/** 放大过程中出现的缓慢动画 */
- (void)shakeToShow:(UIView *)aView {
    CAKeyframeAnimation* animation = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
    animation.duration = 0.2;
    NSMutableArray *values = [NSMutableArray array];
    [values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeScale(0.1, 0.1, 1.0)]];
    [values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeScale(1.0, 1.0, 1.0)]];
    animation.values = values;
    [aView.layer addAnimation:animation forKey:nil];
}

#pragma mark - lazy load

- (UIImageView *)avatar {
    if (!_avatar) {
        UIImage *image = [UIImage imageNamed:@"new_customer_service_default_avatar"];
        _avatar = [[UIImageView alloc] initWithImage:image];
    }
    return _avatar;
}

- (UILabel *)timeLabel {
    if (!_timeLabel) {
        _timeLabel = [[UILabel alloc] init];
    }
    return _timeLabel;
}

- (UIButton *)contentButton {
    if (!_contentButton) {
        _contentButton = [UIButton buttonWithType:UIButtonTypeCustom];
        
        _contentButton.titleLabel.numberOfLines = 0;
        _contentButton.titleLabel.font = [UIFont systemFontOfSize:14];
        [_contentButton setTitleColor:[UIColor blackColor]
                             forState:UIControlStateNormal];
        
        [_contentButton addTarget:self action:@selector(contentButtonClicked:)
                 forControlEvents:UIControlEventTouchUpInside];
    }
    return _contentButton;
}

- (UIButton *)statusButton {
    if (!_statusButton) {
        _statusButton = [UIButton buttonWithType:UIButtonTypeCustom];
        
        _statusButton.titleLabel.font = [UIFont systemFontOfSize:18.f weight:UIFontWeightRegular];
        [_statusButton setTitleColor:[UIColor colorWithRed:123/255.0 green:123/255.0 blue:123/255.0 alpha:1.0] forState:UIControlStateNormal];
        _statusButton.hidden = YES;
    }
    return _statusButton;
}

- (AVAudioPlayer *)audioPlayer {
    if (!_audioPlayer) {
        _audioPlayer = [[AVAudioPlayer alloc] init];
    }
    return _audioPlayer;
}

@end
