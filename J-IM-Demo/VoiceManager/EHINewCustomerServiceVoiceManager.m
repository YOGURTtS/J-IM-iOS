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

/** 进度计时器 */
@property (nonatomic, strong) dispatch_source_t timer;

/** 播放进度 单位：毫秒 */
@property (nonatomic, assign) CGFloat milliseconds;

/** 上一个url */
@property (nonatomic, strong) NSURL *lastUrl;

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

- (void)playbackFinished:(NSNotification *)noti {
    if (self.finishPlay) {
        self.finishPlay(self.currentUrl);
    }
}


#pragma mark - about audio record

/** 开始录音 */
- (void)audioStart {
    if (!self.audioRecorder.isRecording) {
        [self.audioSession setCategory:AVAudioSessionCategoryRecord error:nil];
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
    NSString *cachepath = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).lastObject;
    NSString *wavRecordFilePath = [cachepath stringByAppendingString:@"/new_cs/send_voice/myRecord.wav"];
    NSString *amrRecordFilePath = [cachepath stringByAppendingString:[NSString stringWithFormat:@"/new_cs/send_voice/%@.amr", [NSUUID UUID].UUIDString]];
    
    // 重点:把wav录音文件转换成amr文件,用于网络传输.amr文件大小是wav文件的十分之一左右
    wave_file_to_amr_file([wavRecordFilePath cStringUsingEncoding:NSUTF8StringEncoding],[amrRecordFilePath cStringUsingEncoding:NSUTF8StringEncoding], 1, 16);
    
    // 返回amr音频文件Data,用于传输或存储
    NSData *cacheAudioData = [NSData dataWithContentsOfFile:amrRecordFilePath];
    
    if (self.finishRecord) {
        self.finishRecord(cacheAudioData, wavRecordFilePath);
    }
}


#pragma mark - about audio play

- (void)playVoiceWithUrl:(NSURL *)url finish:(void (^)(void))finish {
    
    NSLog(@"voice play url = %@", url);
    
    NSError *error = nil;
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:&error];
    
    if (self.currentUrl) {
        self.lastUrl = self.currentUrl;
    }
    self.currentUrl = url;
    
    if (self.lastUrl) {
        AVPlayerItem *playerItem = [AVPlayerItem playerItemWithURL:self.lastUrl];
        [self.audioPlayer replaceCurrentItemWithPlayerItem:playerItem];
        if (self.pause) {
            self.pause(self.lastUrl, self.milliseconds);
        }
    }
    
    [self resetAudioPlayerStatus];
    
    if (!url.path.length) {
        return;
    }
    
#pragma mark - 本地音频
    
    if ([url.scheme hasPrefix:@"file"]) {
        AVPlayerItem *playerItem = [AVPlayerItem playerItemWithURL:url];
        [self.audioPlayer replaceCurrentItemWithPlayerItem:playerItem];
        [self.audioPlayer play];

        self.currentUrl = url;
        return;
    }
    
#pragma mark - 在线音频
    __weak typeof(self) weakSelf = self;
    [self.cacheManager cacheVoiceWithUrl:[url absoluteString] completion:^(NSString *filePath) {
        __strong typeof(weakSelf) self = weakSelf;
        
        AVPlayerItem *playerItem = [AVPlayerItem playerItemWithURL:[NSURL fileURLWithPath:filePath]];
        [self.audioPlayer replaceCurrentItemWithPlayerItem:playerItem];
        [self.audioPlayer play];
        
        self.currentUrl = url;
    }];
    
    [self startTimer];
}

- (void)pausePlayWithUrl:(NSURL *)url completion:(void (^)(CGFloat seconds))completion {
    [self.audioPlayer pause];
    [self stopTimer];
    completion(self.milliseconds);
}

- (void)resumePlayWithUrl:(NSURL *)url time:(CGFloat)milliseconds {
    
    if (self.currentUrl) {
        self.lastUrl = self.currentUrl;
    }
    self.currentUrl = url;
    
    if (self.lastUrl) {
        AVPlayerItem *playerItem = [AVPlayerItem playerItemWithURL:self.lastUrl];
        [self.audioPlayer replaceCurrentItemWithPlayerItem:playerItem];
        if (self.pause) {
            self.pause(self.lastUrl, self.milliseconds);
        }
    }
    
    [self resetAudioPlayerStatus];
    if (!url.path.length) {
        return;
    }
    
    self.milliseconds = milliseconds;
    CMTime time = CMTimeMakeWithSeconds(milliseconds, 600);
    __weak typeof(self) weakSelf = self;
    [self.audioPlayer seekToTime:time completionHandler:^(BOOL finished) {
        __strong typeof(weakSelf) self = weakSelf;
        [self.audioPlayer play];
    }];
    
    [self startTimer];
}

- (void)stopPlayWithUrl:(NSURL *)url {
    [self stopTimer];
    [self.audioPlayer pause];
}

/** 重置语音播放器状态 */
- (void)resetAudioPlayerStatus {
    if (self.audioPlayer) {
        [self stopTimer];
        [self.audioPlayer pause];
        self.audioPlayer = nil;
        self.milliseconds = .0f;
    }
}

#pragma mark - about timer 用来记录播放进度

/** 开始计时器 */
- (void)startTimer {
    __weak typeof(self) weakSelf = self;
    dispatch_source_set_timer(self.timer, dispatch_walltime(NULL, 0), 0.001 * NSEC_PER_SEC, 0); // 每毫秒执行
        dispatch_source_set_event_handler(_timer, ^{
            __strong typeof(weakSelf) self = weakSelf;
            self.milliseconds += 0.001;
        });
    
        dispatch_resume(self.timer);
}

/** 停止计时器 */
- (void)stopTimer {
    if (_timer) {
        dispatch_cancel(_timer);
        _timer = nil;
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

- (dispatch_source_t)timer {
    if (!_timer) {
        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        _timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
    }
    return _timer;
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
