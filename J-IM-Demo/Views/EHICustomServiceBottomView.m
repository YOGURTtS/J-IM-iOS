//
//  EHIBottomInputView.m
//  J-IM-Demo
//
//  Created by yogurts on 2018/11/30.
//  Copyright © 2018 yogurts. All rights reserved.
//

#import "EHICustomServiceBottomView.h"
#import "EHINewCustomerSeerviceTools.h"
#import <AVKit/AVKit.h>
#include "amr_wav_converter.h"

@interface EHICustomServiceBottomView () <UITextViewDelegate, AVAudioRecorderDelegate>

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

/** 音频会话 */
@property (nonatomic, strong) AVAudioSession *audioSession;

/** 音频录音对象 */
@property (nonatomic, strong) AVAudioRecorder *audioRecorder;

/** 取消语音录制 */
@property (nonatomic, assign) BOOL isCancelSendAudioMessage;

@end

@implementation EHICustomServiceBottomView


- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.isCancelSendAudioMessage = NO;
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
    
    CGFloat buttonHeight = 37.f;
    
    self.switchToVoiceOrTextButton.frame = CGRectMake(6, CGRectGetHeight(self.frame) - buttonHeight - 7 - [EHINewCustomerSeerviceTools getBottomDistance], buttonHeight, buttonHeight);
    self.sendPictureButton.frame = CGRectMake(CGRectGetWidth(self.frame) - buttonHeight - 16,
                                              CGRectGetHeight(self.frame) - buttonHeight - 7 - [EHINewCustomerSeerviceTools getBottomDistance],
                                              buttonHeight,
                                              buttonHeight);
    self.textOrSendVoiceView.frame = CGRectMake(CGRectGetMaxX(self.switchToVoiceOrTextButton.frame) + 4,
                                                CGRectGetMinY(self.switchToVoiceOrTextButton.frame),
                                                CGRectGetMinX(self.sendPictureButton.frame) -
                                                CGRectGetMaxX(self.switchToVoiceOrTextButton.frame) - 18,
                                                buttonHeight);
    
    self.textView.frame = self.textOrSendVoiceView.bounds;
    self.voiceButton.frame = self.textOrSendVoiceView.bounds;
}

/** 快捷入口视图布局 */
- (void)setupQuickEntrancesView {
    CGFloat x = 0;
    for (NSInteger i = 0; i < self.quickEntrances.count; ++i) {
        UIButton *quickEntrance = [UIButton buttonWithType:UIButtonTypeCustom];
        quickEntrance.backgroundColor = [UIColor whiteColor];
        [quickEntrance setTitle:[self.quickEntrances objectAtIndex:i] forState:UIControlStateNormal];
        [quickEntrance setTitleColor:[UIColor colorWithRed:41/255.0 green:183/255.0 blue:183/255.0 alpha:1.0] forState:UIControlStateNormal];
        quickEntrance.titleLabel.font = [UIFont systemFontOfSize:12];
        quickEntrance.frame = CGRectMake(x + 12, 10, 70, 24);
        quickEntrance.layer.cornerRadius = 12.f;
        quickEntrance.clipsToBounds = YES;
        quickEntrance.layer.borderColor = [UIColor colorWithRed:41/255.0 green:183/255.0 blue:183/255.0 alpha:1.0].CGColor;
        quickEntrance.layer.borderWidth = 1.f;
        quickEntrance.tag = i;
        [quickEntrance addTarget:self action:@selector(quickEntrancebuttonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:quickEntrance];
        x = CGRectGetMaxX(quickEntrance.frame);
    }
}

#pragma mark - text view delegate

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if ([text isEqualToString:@"\n"]) {
        // TODO: 发送文字
        if (self.sendTextCallBack) {
            self.sendTextCallBack(textView.text);
        }
       
        textView.text = @"";
        [textView resignFirstResponder];
        return NO;
    }
    return YES;
}

#pragma mark - button click action

/** 快捷入口按钮点击 */
- (void)quickEntrancebuttonClicked:(UIButton *)button {
    if (self.quickEntranceSelected) {
        self.quickEntranceSelected(button, button.tag);
    }
}

- (void)switchToVoiceOrText {
    if (self.inputType == EHICustomServiceInputTypeText) {
        self.inputType = EHICustomServiceInputTypeVoice;
    } else {
        self.inputType = EHICustomServiceInputTypeText;
    }
}

- (void)sendPicture {
    if (self.sendPictureCallBack) {
        self.sendPictureCallBack(nil);
    }
    
    
}

#pragma mark - gesture

- (void)longPress:(UILongPressGestureRecognizer *)gestureRecognizer {
    CGPoint point = [gestureRecognizer locationInView:self];
    
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
        [self.voiceButton setTitle:@"松开结束" forState:UIControlStateNormal];
        // TODO: 开始录音
        [self audioStart];
    } else if (gestureRecognizer.state == UIGestureRecognizerStateEnded) {
        [self.voiceButton setTitle:@"按住说话" forState:UIControlStateNormal];
        // TODO: 结束录音
        if (!self.isCancelSendAudioMessage) {
            [self audioStop];
        }
    } else if (gestureRecognizer.state == UIGestureRecognizerStateChanged) {
        CGPoint aPoint = [self convertPoint:point toView:self.voiceButton];
        if ([self.voiceButton.layer containsPoint:aPoint]) {
            [self.voiceButton setTitle:@"松开结束" forState:UIControlStateNormal];
            // TODO:
            self.isCancelSendAudioMessage = NO;
        } else {
            [self.voiceButton setTitle:@"松开取消" forState:UIControlStateNormal];
            self.isCancelSendAudioMessage = YES;
        }
    } else if (gestureRecognizer.state == UIGestureRecognizerStateFailed) {
        NSLog(@"失败");
    } else if (gestureRecognizer.state == UIGestureRecognizerStateCancelled) {
        NSLog(@"取消");
    }
}

#pragma mark - setter

- (void)setInputType:(EHICustomServiceInputType)inputType {
    _inputType = inputType;
    if (inputType == EHICustomServiceInputTypeText) {
        self.textView.hidden = NO;
        self.voiceButton.hidden = YES;
        [self.switchToVoiceOrTextButton setImage:[UIImage imageNamed:@"new_customer_service_send_voice"] forState:UIControlStateNormal];
    } else {
        self.textView.hidden = YES;
        self.voiceButton.hidden = NO;
        [self.switchToVoiceOrTextButton setImage:[UIImage imageNamed:@"new_customer_service_send_text"] forState:UIControlStateNormal];
    }
}

#pragma mark - record audio

/** 开始录音 */
- (void)audioStart {
    if (!self.audioRecorder.isRecording) {
        [self.audioSession setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
        [self.audioSession setActive:YES error:nil];
        [self.audioRecorder prepareToRecord];
        [self.audioRecorder peakPowerForChannel:0.0];
        [self.audioRecorder record];
    }
}

/** 结束录音 */
- (void)audioStop {
    if (self.audioRecorder.isRecording) {
        [self.audioRecorder stop];
        [self.audioSession setActive:NO error:nil];
    }
}

#pragma mark - sudio recorder delegate

- (void)audioRecorderDidFinishRecording:(AVAudioRecorder *)recorder successfully:(BOOL)flag {
    // 暂存录音文件路径
    NSString *wavRecordFilePath = [NSTemporaryDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"wav/%@.wav", [NSUUID UUID].UUIDString]];
    NSString *amrRecordFilePath = [NSTemporaryDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"amr/%@.amr", [NSUUID UUID].UUIDString]];
    
    // 重点:把wav录音文件转换成amr文件,用于网络传输.amr文件大小是wav文件的十分之一左右
    wave_file_to_amr_file([wavRecordFilePath cStringUsingEncoding:NSUTF8StringEncoding],[amrRecordFilePath cStringUsingEncoding:NSUTF8StringEncoding], 1, 16);
    
    // 返回amr音频文件Data,用于传输或存储
    NSData *cacheAudioData = [NSData dataWithContentsOfFile:amrRecordFilePath];
    
    if (self.sendVoiceCallBack) {
        self.sendVoiceCallBack(cacheAudioData, wavRecordFilePath);
    }
}

#pragma mark - lazy load

- (UIView *)textOrSendVoiceView {
    if (!_textOrSendVoiceView) {
        _textOrSendVoiceView = [[UIView alloc] init];
        _textOrSendVoiceView.layer.cornerRadius = 4.0;
        _textOrSendVoiceView.clipsToBounds = YES;
    }
    return _textOrSendVoiceView;
}

- (UIButton *)sendPictureButton {
    if (!_sendPictureButton) {
        _sendPictureButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_sendPictureButton setImage:[UIImage imageNamed:@"new_customer_service_picture"] forState:UIControlStateNormal];
        [_sendPictureButton addTarget:self action:@selector(sendPicture) forControlEvents:UIControlEventTouchUpInside];
    }
    return _sendPictureButton;
}

- (UIButton *)switchToVoiceOrTextButton {
    if (!_switchToVoiceOrTextButton) {
        _switchToVoiceOrTextButton = [UIButton buttonWithType:UIButtonTypeCustom];
        
        [_switchToVoiceOrTextButton addTarget:self action:@selector(switchToVoiceOrText) forControlEvents:UIControlEventTouchUpInside];
    }
    return _switchToVoiceOrTextButton;
}

- (UITextView *)textView {
    if (!_textView) {
        _textView = [[UITextView alloc] init];
        
        _textView.backgroundColor = [UIColor whiteColor];
        _textView.returnKeyType = UIReturnKeySend;
        _textView.delegate = self;
    }
    return _textView;
}

- (UIButton *)voiceButton {
    if (!_voiceButton) {
        _voiceButton = [UIButton buttonWithType:UIButtonTypeCustom];
        
        _voiceButton.backgroundColor = [UIColor whiteColor];
        _voiceButton.titleLabel.font = [UIFont systemFontOfSize:16.f weight:UIFontWeightSemibold];
        [_voiceButton setTitle:@"按住说话" forState:UIControlStateNormal];
        [_voiceButton setTitleColor:[UIColor colorWithRed:123/255.0 green:123/255.0 blue:123/255.0 alpha:1.0] forState:UIControlStateNormal];
        
        // 增加长按手势
        UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPress:)];
        longPress.minimumPressDuration = 0.1;
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

- (AVAudioSession *)audioSession {
    if (!_audioSession) {
        _audioSession = [AVAudioSession sharedInstance];
        [_audioSession setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
    }
    return _audioSession;
}

- (AVAudioRecorder *)audioRecorder {
    if (!_audioRecorder) {
        // 对AVAudioRecorder进行一些设置
        NSDictionary *recordSettings = [[NSDictionary alloc] initWithObjectsAndKeys:
                                        [NSNumber numberWithFloat:8000], AVSampleRateKey,
                                        [NSNumber numberWithInt:kAudioFormatLinearPCM], AVFormatIDKey,
                                        [NSNumber numberWithInt:16], AVLinearPCMBitDepthKey,
                                        [NSNumber numberWithInt:1], AVNumberOfChannelsKey,
                                        [NSNumber numberWithInt:AVAudioQualityHigh], AVEncoderAudioQualityKey,
                                        nil];
        
        // 录音存放的地址文件
        NSURL *recordingUrl = [NSURL URLWithString:[NSTemporaryDirectory() stringByAppendingString:@"myRecord.wav"]];
        _audioRecorder = [[AVAudioRecorder alloc] initWithURL:recordingUrl settings:recordSettings error:nil];
        // 对录音开启音量检测
        _audioRecorder.meteringEnabled = YES;
        // 设置代理
        _audioRecorder.delegate = self;
    }
    return _audioRecorder;
}

@end
