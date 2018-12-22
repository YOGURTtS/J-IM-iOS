//
//  EHIVoiceManager.m
//  J-IM-Demo
//
//  Created by 孙星 on 2018/12/8.
//  Copyright © 2018 yogurts. All rights reserved.
//

#import "EHINewCustomerServiceVoiceManager.h"
#import <AVKit/AVKit.h>
#import "EHINewCustomerServiceCacheManager.h"

@interface EHINewCustomerServiceVoiceManager () <AVAudioRecorderDelegate>

/** 音频会话 */
@property (nonatomic, strong) AVAudioSession *audioSession;

/** 音频录音对象 */
@property (nonatomic, strong) AVAudioRecorder *audioRecorder;

/** 播放器 */
@property (nonatomic, strong) AVPlayer *audioPlayer;

/** 正在播放语音的url */
@property (nonatomic, strong) NSURL *currentUrl;

/** 缓存管理类 */
@property (nonatomic, strong) EHINewCustomerServiceCacheManager *cacheManager;

@end

@implementation EHINewCustomerServiceVoiceManager

/** 单例 */
static EHINewCustomerServiceVoiceManager *instance;
+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[EHINewCustomerServiceVoiceManager alloc] init];
    });
    return instance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(playbackFinished:)
                                                     name:AVPlayerItemDidPlayToEndTimeNotification
                                                   object:self.audioPlayer.currentItem];
    }
    return self;
}

#pragma mark - about audio record

/** 开始录音 */
- (void)audioRecordStart {
    if (!self.audioRecorder.isRecording) {
        [self.audioSession setCategory:AVAudioSessionCategoryRecord error:nil];
        [self.audioSession setActive:YES error:nil];
        [self.audioRecorder prepareToRecord];
        [self.audioRecorder peakPowerForChannel:0.0];
        [self.audioRecorder record];
    }
}

/** 结束录音 */
- (void)audioRecordStop {
    if (self.audioRecorder.isRecording) {
        [self.audioRecorder stop];
        [self.audioSession setActive:NO error:nil];
    }
}

- (BOOL)isRecording {
    return self.audioRecorder.isRecording;
}

#pragma mark - sudio recorder delegate

- (void)audioRecorderDidFinishRecording:(AVAudioRecorder *)recorder successfully:(BOOL)flag {
    
    // 暂存录音文件路径
    NSString *cachepath = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).lastObject;
    NSString *wavRecordFilePath = [cachepath stringByAppendingString:@"/new_cs/send_voice/myRecord.wav"];
    NSString *amrRecordFilePath = [cachepath stringByAppendingString:[NSString stringWithFormat:@"/new_cs/send_voice/%@.amr", [NSUUID UUID].UUIDString]];
    
    // 重点:把wav录音文件转换成amr文件,用于网络传输.amr文件大小是wav文件的十分之一左右
    wave_file_to_amr_file([wavRecordFilePath cStringUsingEncoding:NSUTF8StringEncoding],[amrRecordFilePath cStringUsingEncoding:NSUTF8StringEncoding], 1, 16);
    
    // 返回amr音频文件Data,用于传输或存储
    NSData *cacheAudioData = [NSData dataWithContentsOfFile:amrRecordFilePath];
    
    // 获取录音时长
    AVURLAsset* audioAsset =[AVURLAsset URLAssetWithURL:[NSURL fileURLWithPath:wavRecordFilePath] options:nil];
    CMTime audioDuration = audioAsset.duration;
    float audioDurationSeconds = CMTimeGetSeconds(audioDuration);
    
    if (audioDurationSeconds < 1.0) {
        NSLog(@"录音未满一秒，放弃");
        return;
    }
    
    /** 录制完成并且用户没有取消发送 */
    if (self.finishRecord && !self.isCancelSendAudioMessage) {
        self.finishRecord(cacheAudioData, [NSURL fileURLWithPath:amrRecordFilePath].absoluteString, (NSInteger)audioDurationSeconds);
    }
}


#pragma mark - about audio play

/** 播放语音 */
- (void)playVoiceWithUrl:(NSURL *)url finish:(void (^)(void))finish {
    
    NSLog(@"voice play url = %@", url);
    
    // 当前播放器正在播放其他语音
    if (self.audioPlayer.rate && self.audioPlayer.error == nil) {
        if (self.pause) {
            // 获取当前播放时间
            CGFloat currentTime = CMTimeGetSeconds(self.audioPlayer.currentTime) / 1000.0;
            [self.audioPlayer pause];
            // 暂停回调，用于更新状态
            self.pause(self.currentUrl, currentTime);
        }
    }
    
    NSError *error = nil;
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:&error];
    
    // 播放前重置播放器相关状态
    [self resetAudioPlayerStatus];
    
    if (url == nil) {
        return;
    }
    
    self.currentUrl = url;
    
    
    AVPlayerItem *playerItem = [AVPlayerItem playerItemWithURL:url];
    [self.audioPlayer replaceCurrentItemWithPlayerItem:playerItem];
    [self.audioPlayer play];
    
    self.currentUrl = url;
    return;
}

/** 暂停播放 */
- (void)pausePlayWithUrl:(NSURL *)url completion:(void (^)(CGFloat seconds))completion {
    [self.audioPlayer pause];
    CGFloat current = CMTimeGetSeconds(self.audioPlayer.currentTime) / 1000.0;
    completion(current);
}

/** 继续播放 */
- (void)resumePlayWithUrl:(NSURL *)url time:(CGFloat)milliseconds {
    
    // 当前播放器正在播放其他语音
    if (self.audioPlayer.rate && self.audioPlayer.error == nil) {
        if (self.pause) {
            // 获取当前播放时间
            CGFloat currentTime = CMTimeGetSeconds(self.audioPlayer.currentTime) / 1000.0;
            [self.audioPlayer pause];
            // 暂停回调，用于更新状态
            self.pause(self.currentUrl, currentTime);
        }
    }
    
    NSError *error = nil;
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:&error];
    
    [self resetAudioPlayerStatus];
    
    if (url == nil) {
        return;
    }
    
    self.currentUrl = url;
    
    // 获取model的播放进度
    CMTime time = CMTimeMakeWithSeconds(milliseconds, 600);
    __weak typeof(self) weakSelf = self;
    [self.audioPlayer seekToTime:time completionHandler:^(BOOL finished) {
        __strong typeof(weakSelf) self = weakSelf;
        [self.audioPlayer play];
    }];
    
}

/** 停止播放 */
- (void)stopPlayWithUrl:(NSURL *)url {
    [self.audioPlayer pause];
}

/** 播放完成回调 */
- (void)playbackFinished:(NSNotification *)noti {
    if (self.finishPlay) {
        self.finishPlay(self.currentUrl);
    }
}

/** 重置语音播放器状态 */
- (void)resetAudioPlayerStatus {
    if (self.audioPlayer) {
        [self.audioPlayer pause];
    }
}


#pragma mark - lazy load

- (AVAudioSession *)audioSession {
    if (!_audioSession) {
        _audioSession = [AVAudioSession sharedInstance];
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
        NSString *cachepath = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).lastObject;
        NSString *recordingUrl = [cachepath stringByAppendingString:@"/new_cs/send_voice/myRecord.wav"];
        // 先创建子目录
        NSFileManager *fileManager = [NSFileManager defaultManager];
        if (![fileManager fileExistsAtPath:recordingUrl]) {
            NSString *recordPath = [[cachepath stringByAppendingPathComponent:@"new_cs"] stringByAppendingPathComponent:@"send_voice"];
            [fileManager createDirectoryAtPath:recordPath withIntermediateDirectories:YES attributes:nil error:nil];
        }
        _audioRecorder = [[AVAudioRecorder alloc] initWithURL:[NSURL fileURLWithPath:recordingUrl] settings:recordSettings error:nil];
        // 对录音开启音量检测
        _audioRecorder.meteringEnabled = YES;
        // 设置代理
        _audioRecorder.delegate = self;
    }
    return _audioRecorder;
}

- (AVPlayer *)audioPlayer {
    if (!_audioPlayer) {
        _audioPlayer = [[AVPlayer alloc] init];
        _audioPlayer.volume = 1.0;
    }
    return _audioPlayer;
}

- (EHINewCustomerServiceCacheManager *)cacheManager {
    if (!_cacheManager) {
        _cacheManager = [EHINewCustomerServiceCacheManager sharedInstance];
    }
    return _cacheManager;
}

#pragma mark - deinit

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


@end
