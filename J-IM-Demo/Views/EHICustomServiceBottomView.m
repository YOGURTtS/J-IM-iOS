//
//  EHIBottomInputView.m
//  J-IM-Demo
//
//  Created by yogurts on 2018/11/30.
//  Copyright © 2018 yogurts. All rights reserved.
//

#import "EHICustomServiceBottomView.h"

@interface EHICustomServiceBottomView ()

/** 文字输入或按住录音视图 */
@property (nonatomic, strong) UIView *textOrSendVoiceView;

/** 传图片按钮 */
@property (nonatomic, strong) UIButton *sendPictureButton;

/** 切换语音或者文字按钮 */
@property (nonatomic, strong) UIButton *switchToVoiceOrTextButton;

/** 输入框 */
@property (nonatomic, strong) UITextView *textView;

/** 录音按钮 */
@property (nonatomic, strong) UIButton *voiceButton;

@end

@implementation EHICustomServiceBottomView


- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupSubviews];
    }
    return self;
}

- (void)setupSubviews {
    [self addSubview:self.textOrSendVoiceView];
    [self addSubview:self.sendPictureButton];
    [self addSubview:self.switchToVoiceOrTextButton];
    
    [self.textOrSendVoiceView addSubview:self.textView];
    [self.textOrSendVoiceView addSubview:self.voiceButton];
    
    [self setupQuickEntrancesView];
    
    self.inputType = EHICustomServiceInputTypeText;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.switchToVoiceOrTextButton.frame = CGRectMake(4, CGRectGetHeight(self.frame) - 30 - 4, 30, 30);
    self.sendPictureButton.frame = CGRectMake(CGRectGetWidth(self.frame) - 30 - 4,
                                              CGRectGetHeight(self.frame) - 30 - 4,
                                              30,
                                              30);
    self.textOrSendVoiceView.frame = CGRectMake(CGRectGetMaxX(self.switchToVoiceOrTextButton.frame) + 4,
                                                CGRectGetMinY(self.switchToVoiceOrTextButton.frame),
                                                CGRectGetMinX(self.sendPictureButton.frame) -
                                                CGRectGetMaxX(self.switchToVoiceOrTextButton.frame) - 8,
                                                30);
    
    self.textView.frame = self.textOrSendVoiceView.bounds;
    self.voiceButton.frame = self.textOrSendVoiceView.bounds;
}

/** 快捷入口视图布局 */
- (void)setupQuickEntrancesView {
    CGFloat x = 0;
    for (NSInteger i = 0; i < self.quickEntrances.count; ++i) {
        UIButton *quickEntrance = [UIButton buttonWithType:UIButtonTypeCustom];
        [quickEntrance setTitle:[self.quickEntrances objectAtIndex:i] forState:UIControlStateNormal];
        quickEntrance.titleLabel.font = [UIFont systemFontOfSize:14];
        quickEntrance.frame = CGRectMake(x + 4, 8, 70, 22);
        quickEntrance.tag = i;
        [quickEntrance addTarget:self action:@selector(quickEntrancebuttonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:quickEntrance];
        x = CGRectGetMaxX(quickEntrance.frame);
    }
}

#pragma mark - button click action

/** 快接入口按钮点击 */
- (void)quickEntrancebuttonClicked:(UIButton *)button {
    if (self.quickEntranceSelected) {
        self.quickEntranceSelected(button, button.tag);
    }
}

#pragma mark - setter

- (void)setInputType:(EHICustomServiceInputType)inputType {
    _inputType = inputType;
    if (inputType == EHICustomServiceInputTypeText) {
        self.textView.hidden = NO;
        self.voiceButton.hidden = YES;
    } else {
        self.textView.hidden = YES;
        self.voiceButton.hidden = NO;
    }
}

#pragma mark - button action

- (void)switchTovoiceOrText {
    if (self.inputType == EHICustomServiceInputTypeText) {
        self.inputType = EHICustomServiceInputTypeVoice;
    } else {
        self.inputType = EHICustomServiceInputTypeText;
    }
}

- (void)longPress:(UILongPressGestureRecognizer *)gestureRecognizer {
    CGPoint point = [gestureRecognizer locationInView:self];
    
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
        [self.voiceButton setTitle:@"松开 结束" forState:UIControlStateNormal];
//        [self audioStart];
    } else if (gestureRecognizer.state == UIGestureRecognizerStateEnded) {
        [self.voiceButton setTitle:@"按住 说话" forState:UIControlStateNormal];
//        [self audioStop];
    } else if (gestureRecognizer.state == UIGestureRecognizerStateChanged) {
        if ([self.voiceButton.layer containsPoint:point]) {
            [self.voiceButton setTitle:@"松开 结束" forState:UIControlStateNormal];
//            isCancelSendAudioMessage = NO;
        } else {
            [self.voiceButton setTitle:@"松开 取消" forState:UIControlStateNormal];
//            isCancelSendAudioMessage = YES;
        }
    } else if (gestureRecognizer.state == UIGestureRecognizerStateFailed) {
        NSLog(@"失败");
    } else if (gestureRecognizer.state == UIGestureRecognizerStateCancelled) {
        NSLog(@"取消");
    }
}

#pragma mark - lazy load

- (UIView *)textOrSendVoiceView {
    if (!_textOrSendVoiceView) {
        _textOrSendVoiceView = [[UIView alloc] init];
    }
    return _textOrSendVoiceView;
}

- (UIButton *)sendPictureButton {
    if (!_sendPictureButton) {
        _sendPictureButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_sendPictureButton setTitle:@"图片" forState:UIControlStateNormal];
    }
    return _sendPictureButton;
}

- (UIButton *)switchToVoiceOrTextButton {
    if (!_switchToVoiceOrTextButton) {
        _switchToVoiceOrTextButton = [UIButton buttonWithType:UIButtonTypeCustom];
        
        [_switchToVoiceOrTextButton setTitle:@"录音" forState:UIControlStateNormal];
        _switchToVoiceOrTextButton.backgroundColor = [UIColor orangeColor];
        [_switchToVoiceOrTextButton addTarget:self action:@selector(switchTovoiceOrText) forControlEvents:UIControlEventTouchUpInside];
    }
    return _switchToVoiceOrTextButton;
}

- (UITextView *)textView {
    if (!_textView) {
        _textView = [[UITextView alloc] init];
        _textView.backgroundColor = [UIColor blackColor];
    }
    return _textView;
}

- (UIButton *)voiceButton {
    if (!_voiceButton) {
        _voiceButton = [UIButton buttonWithType:UIButtonTypeCustom];
        
        [_voiceButton setTitle:@"按住 说话" forState:UIControlStateNormal];
        _voiceButton.backgroundColor = [UIColor whiteColor];
        //增加长按手势
        UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPress:)];
        longPress.minimumPressDuration = 0;
        [_voiceButton addGestureRecognizer:longPress];
        
    }
    return _voiceButton;
}

- (NSArray *)quickEntrances {
    if (!_quickEntrances) {
        _quickEntrances = @[@"领券中心", @"违章处理", @"开票管理"];
    }
    return _quickEntrances;
}

@end
