//
//  EHIVoiceManager.m
//  J-IM-Demo
//
//  Created by 孙星 on 2018/12/8.
//  Copyright © 2018 yogurts. All rights reserved.
//

#import "EHIVoiceManager.h"
#import <AVKit/AVKit.h>
#import "amr_wav_converter.h"

@interface EHIVoiceManager ()

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

/** 如果继续播放的url正式当前url，可以直接使用playerItem */
//@property (nonatomic, strong) AVPlayerItem *playerItem;

@end

@implementation EHIVoiceManager

- (instancetype)init
{
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
    if (self.finish) {
        self.finish(self.currentUrl);
    }
}

#pragma mark - about audio

- (void)playVoiceWithUrl:(NSURL *)url finish:(void (^)(void))finish {
    
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
    
    // 如果是amr文件，需要进行格式转换
    if ([url.lastPathComponent hasSuffix:@"amr"]) {
        
        //            NSURL *localUrl = [self handleAmrFileWithUrl:url];
        __block NSURL *localUrl;
        __weak typeof(self) weakSelf = self;
        [[[NSURLSession sharedSession] dataTaskWithURL:url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            __strong typeof(weakSelf) self = weakSelf;

            // 暂存录音文件路径
            NSString *wavRecordFilePath = [NSTemporaryDirectory() stringByAppendingPathComponent:@"downloadRecord.wav"];
            NSString *amrRecordFilePath = [NSTemporaryDirectory() stringByAppendingPathComponent:@"downloadRecord.amr"];
            
            if ([data writeToFile:amrRecordFilePath atomically:YES]) {
                // amr文件转成wav文件
                amr_file_to_wave_file([amrRecordFilePath cStringUsingEncoding:NSUTF8StringEncoding],
                                      [wavRecordFilePath cStringUsingEncoding:NSUTF8StringEncoding]);
                
                localUrl = [NSURL fileURLWithPath:wavRecordFilePath];
                
                if (localUrl) {
                    AVPlayerItem *playerItem = [AVPlayerItem playerItemWithURL:localUrl];
                    [self.audioPlayer replaceCurrentItemWithPlayerItem:playerItem];
                    [self.audioPlayer play];
                }
            }
        }] resume];
        
    } else {
        AVPlayerItem *playerItem = [AVPlayerItem playerItemWithURL:url];
        [self.audioPlayer replaceCurrentItemWithPlayerItem:playerItem];
        [self.audioPlayer play];
    }
    
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

#pragma mark - deinit

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


@end
