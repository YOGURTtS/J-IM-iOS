//
//  EHINewCustomerServiceControllerViewController.m
//  J-IM-Demo
//
//  Created by yogurts on 2018/11/28.
//  Copyright © 2018 yogurts. All rights reserved.
//

#import "EHINewCustomerServiceControllerViewController.h"
#import "EHICustomServiceBottomView.h"
#import "EHICustomerServiceCell.h"
#import "EHINewCustomerSeerviceTools.h"
#import "EHISocketManager.h"
#import "EHICustomerServiceModel.h"
#import "EHINewCustomerServiceVoiceManager.h"
#import <TZImagePickerController.h>
#import "EHINewCustomerServiceCacheManager.h"


@interface EHINewCustomerServiceControllerViewController () <UITableViewDelegate, UITableViewDataSource, EHISocketManagerProcotol>

/** 顶部提示视图 */
@property (nonatomic, strong) UILabel *topLabel;

/** tableView */
@property (nonatomic, strong) UITableView *tableView;

/** 底部视图，包括快捷入口和输入部分 */
@property (nonatomic, strong) EHICustomServiceBottomView *bottomView;

/** 录音提示弹窗 */
@property (nonatomic, strong) UIImageView *recordTipImgView;

/** socket管理器 */
@property (nonatomic, strong) EHISocketManager *socketManager;

/** 消息数组 */
@property (nonatomic, strong) NSMutableArray<EHICustomerServiceModel *> *messageArrayM;

/** 语音管理器 */
@property (nonatomic, strong) EHINewCustomerServiceVoiceManager *voiceManager;

/** 语音缓存管理器 */
@property (nonatomic, strong) EHINewCustomerServiceCacheManager *voiceCacheManager;

@end

@implementation EHINewCustomerServiceControllerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationItem.title = @"在线客服";
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"连接" style:UIBarButtonItemStylePlain target:self action:@selector(connectSocket)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"断开" style:UIBarButtonItemStylePlain target:self action:@selector(disconnectSocket)];
    
    [self setupUI];
}

- (void)setupUI {
    [self.view addSubview:self.bottomView];
    [self.view addSubview:self.tableView];
    [self.view addSubview:self.recordTipImgView];
    
    CGFloat bottomViewHeight = 87.f;
    self.bottomView.frame = CGRectMake(0, [UIScreen mainScreen].bounds.size.height - bottomViewHeight - [EHINewCustomerSeerviceTools getBottomDistance], [UIScreen mainScreen].bounds.size.width, bottomViewHeight + [EHINewCustomerSeerviceTools getBottomDistance]);
    self.tableView.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height - CGRectGetHeight(self.bottomView.frame));
}

#pragma mark - about socket

/** 连接socket */
- (void)connectSocket {
    [self.socketManager connect];
}

/** 断开连接socket */
- (void)disconnectSocket {
    [self.socketManager disconnect];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.messageArrayM.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"EHICustomerServiceCell";
    EHICustomerServiceCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    cell.model = [self.messageArrayM objectAtIndex:indexPath.row];
    
    __weak typeof(self) weakSelf = self;
    cell.voicePlay = ^{
        __strong typeof(weakSelf) self = weakSelf;
        [self voicePlayWithIndex:indexPath.row];
    };
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    EHICustomerServiceModel *model = [self.messageArrayM objectAtIndex:indexPath.row];
    CGFloat cellHeight = model.cellHeight;
    return cellHeight;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:true];
}


#pragma mark - about voice

/** 调整录音提示视图 */
- (void)recordTipImgViewChangedWithStatus:(EHIAudioRecordStatus)status {
    switch (status) {
        case EHIAudioRecordStatusStart:
            self.recordTipImgView.hidden = NO;
            break;
        case EHIAudioRecordStatusFinish:
            self.recordTipImgView.hidden = YES;
            break;
        case EHIAudioRecordStatusRecording:
            self.recordTipImgView.image = [UIImage imageNamed:@"new_customer_service_record"];
            break;
        case EHIAudioRecordStatusRecordingButMayCancel:
            self.recordTipImgView.image = [UIImage imageNamed:@"new_customer_service_cancel_record"];
            break;
            
        default:
            break;
    }
}

/** 播放、暂停音频 */
- (void)voicePlayWithIndex:(NSInteger)index {
    EHICustomerServiceModel *model = [self.messageArrayM objectAtIndex:index];
    // 未播放过或播放完成
    if (model.playStatus == EHIVoiceMessagePlayStatusUnplay ||
        model.playStatus == EHIVoiceMessagePlayStatusFinish) {
        model.playStatus = EHIVoiceMessagePlayStatusIsplaying;
        [self.voiceManager playVoiceWithUrl:[NSURL URLWithString:model.voiceUrl] finish:nil];
    } else if (model.playStatus == EHIVoiceMessagePlayStatusPause) { // 暂停播放
        model.playStatus = EHIVoiceMessagePlayStatusIsplaying;
        [self.voiceManager resumePlayWithUrl:[NSURL URLWithString:model.voiceUrl] time:model.millisecondsPlayed];
    } else { // 正在播放
        model.playStatus = EHIVoiceMessagePlayStatusPause;
        [self.voiceManager pausePlayWithUrl:[NSURL URLWithString:model.voiceUrl] completion:^(CGFloat seconds) {
            model.millisecondsPlayed = seconds;
        }];
    }
    [self.tableView reloadData];
}

/** 修改播放状态为暂停 */
- (void)voicePauseWithUrl:(NSURL *)url milliseconds:(CGFloat)milliseconds {
    for (EHICustomerServiceModel *model in self.messageArrayM) {
        if ([model.voiceUrl isEqualToString:[url absoluteString]]) {
            model.millisecondsPlayed = milliseconds;
            model.playStatus = EHIVoiceMessagePlayStatusPause;
        }
    }
    [self.tableView reloadData];
}

/** 修改播放状态为播放完 */
- (void)voiceFinishWithUrl:(NSURL *)url {
    for (EHICustomerServiceModel *model in self.messageArrayM) {
        NSLog(@"model.voiceUrl = %@, url = %@", model.voiceUrl, url);
        if ([model.voiceUrl isEqualToString:[url absoluteString]]) {
            model.millisecondsPlayed = 0.0f;
            model.playStatus = EHIVoiceMessagePlayStatusFinish;
        }
    }
    [self.tableView reloadData];
}

#pragma mark - send message

- (void)sendtextMessage:(NSString *)text {
    EHICustomerServiceModel *model = [[EHICustomerServiceModel alloc] init];
    model.isAnonymousMessage = YES;
    model.fromType = EHIMessageFromTypeSender;
    model.messageStatus = EHIMessageStatusSuccess;
    model.messageType = EHIMessageTypeText;
    model.text = text;
    model.time = [self currentDateStr];
    [self.messageArrayM addObject:model];
    [self.tableView reloadData];
    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.messageArrayM.count - 1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    [self.socketManager sendText:text success:^{
        
    } failure:^(NSError *error) {
        
    }];
}

- (void)sendVoiceMessage:(NSData *)data wavFilePath:(NSString *)filePath {
    // TODO: 上传音频
    
    EHICustomerServiceModel *model = [[EHICustomerServiceModel alloc] init];
    model.isAnonymousMessage = YES;
    model.fromType = EHIMessageFromTypeSender;
    model.messageStatus = EHIMessageStatusSuccess;
    model.messageType = EHIMessageTypeVoice;
    model.voiceUrl = @"https://raw.githubusercontent.com/YOGURTtS/YGRecorder/master/myRecord.amr";
    model.time = [self currentDateStr];
    
    __weak typeof(self) weakSelf = self;
    [self.voiceCacheManager cacheSendVoiceWithUrl:model.voiceUrl completion:^(NSString *filePath, NSInteger duration) {
        __strong typeof(weakSelf) self = weakSelf;
        NSLog(@"voice cache file path = %@", filePath);
        model.voiceDuration = duration;
        [self.messageArrayM addObject:model];
        [self.tableView reloadData];
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.messageArrayM.count - 1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    }];
    
    
//    [self.socketManager sendVoice:nil success:^{
//        
//    } failure:^(NSError * error) {
//        
//    }];
}

/** 获取图片并发送 */
- (void)getPictures {
    TZImagePickerController *imagePickerVc = [[TZImagePickerController alloc] initWithMaxImagesCount:9 delegate:nil];
    imagePickerVc.allowPickingGif = NO;
    imagePickerVc.allowPickingVideo = NO;
    __weak typeof(self) weakSelf = self;
    [imagePickerVc setDidFinishPickingPhotosHandle:^(NSArray<UIImage *> *photos, NSArray *assets, BOOL isSelectOriginalPhoto) {
        __strong typeof(weakSelf) self = weakSelf;
        [self sendPictureWithPhotos:photos];
    }];
    [self presentViewController:imagePickerVc animated:YES completion:nil];
}

/** 发送图片 */
- (void)sendPictureWithPhotos:(NSArray<UIImage *> *)photos {
    for (UIImage *image in photos) {
        EHICustomerServiceModel *model = [[EHICustomerServiceModel alloc] init];
        model.isAnonymousMessage = YES;
        model.fromType = EHIMessageFromTypeSender;
        model.messageStatus = EHIMessageStatusSuccess;
        model.messageType = EHIMessageTypePicture;
        model.picture = image;
        model.ratio = image.size.width / image.size.height;
        model.time = [self currentDateStr];
        [self.messageArrayM addObject:model];
        
    }
    [self.tableView reloadData];
    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.messageArrayM.count - 1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
}

/** 获取当前时间 */
- (NSString *)currentDateStr {
    NSDate *currentDate = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"YYYY/MM/dd hh:mm:ss SS "];
    NSString *dateString = [dateFormatter stringFromDate:currentDate];
    return dateString;
}

#pragma mark - http request

/** 获取未读消息 */
- (void)getHistoryMessages {
    
    // TODO: 获取最后一条消息的时间
    
    // 当前时间
    NSString *currentTime = [self currentDateStr];
    
    // TODO: 调接口获取消息列表
    
    // TODO: 数据添加到数据库中
}

/** 消息插入数据表 */
- (void)addMessagesToDatabase {
    for (EHICustomerServiceModel *model in self.messageArrayM) {
        // TODO: 将消息逐条插入数据表
        
    }
}

#pragma mark - cache voice and picture

/** 缓存语音 */
- (void)cacheVoiceMessages {
    
    for (EHICustomerServiceModel *model in self.messageArrayM) {
        // 语音类型
        if (model.messageType == EHIMessageTypeVoice) {
            __weak typeof(self) weakSelf = self;
            [self.voiceCacheManager cacheVoiceWithUrl:model.voiceUrl completion:^(NSString *filePath, NSInteger duration) {
                __strong typeof(weakSelf) self = weakSelf;
                // TODO: 更新数据库
                model.voiceDuration = duration;
                // 更新tableView当前行
                NSInteger index = [self.messageArrayM indexOfObject:model];
                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
                if ([self.tableView.indexPathsForVisibleRows containsObject:indexPath]) {
                    [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:(UITableViewRowAnimationAutomatic)];
                }
            }];
        }
    }
}

/** 缓存图片 */
- (void)cachePictureMessages {
    for (EHICustomerServiceModel *model in self.messageArrayM) {
        if (model.messageType == EHIMessageTypePicture) {
            NSURL *picUrl = [NSURL URLWithString:model.pictureUrl];
            
            
        }
    }
}

#pragma mark - lazy load

- (UILabel *)topLabel {
    if (!_topLabel) {
        _topLabel = [[UILabel alloc] init];
        
        _topLabel.backgroundColor = [UIColor colorWithRed:234.0 / 255.0 green:234.0 / 255.0 blue:234.0 / 255.0 alpha:1];
        _topLabel.font = [UIFont systemFontOfSize:12.f weight:UIFontWeightRegular];
        _topLabel.textColor = [UIColor colorWithRed:123/255.0 green:123/255.0 blue:123/255.0 alpha:1.0];
        _topLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _topLabel;
}

- (EHICustomServiceBottomView *)bottomView {
    if (!_bottomView) {
        _bottomView = [[EHICustomServiceBottomView alloc] initWithFrame:CGRectZero];
        _bottomView.backgroundColor = [UIColor colorWithRed:234.0 / 255.0 green:234.0 / 255.0 blue:234.0 / 255.0 alpha:1];
        __weak typeof(self)weakSelf = self;
        _bottomView.quickEntranceSelected = ^(UIButton *button, NSInteger index) {
            __strong typeof(weakSelf)self = weakSelf;
            NSLog(@"button = %@, index = %zd", button, index);
        };
        
        // 发送文字消息
        _bottomView.sendTextCallback = ^(NSString *text) {
            __strong typeof(weakSelf)self = weakSelf;
            NSLog(@"text = %@", text);
            [self sendtextMessage:text];
        };
        
        // 发送语音消息
        _bottomView.sendVoiceCallback = ^(NSData *amrdData, NSString *wavFilePath) {
            __strong typeof(weakSelf)self = weakSelf;
            NSLog(@"voice wavFilePath = %@", wavFilePath);
            [self sendVoiceMessage:amrdData wavFilePath:wavFilePath];
        };
        
        
        // 发送图片消息
        _bottomView.sendPictureCallback = ^(UIImage *image) {
            __strong typeof(weakSelf)self = weakSelf;
            [self getPictures];
        };
        
        // 调整录音弹窗效果
        _bottomView.recordStatusChangedCallback = ^(EHIAudioRecordStatus status) {
            __strong typeof(weakSelf) self = weakSelf;
            [self recordTipImgViewChangedWithStatus:status];
        };
        
    }
    return _bottomView;
}

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        
        _tableView.backgroundColor = [UIColor colorWithRed:242.0 / 255.0 green:242.0 / 255.0 blue:242.0 / 255.0 alpha:1];
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.tableFooterView = [UIView new];
        _tableView.dataSource = self;
        _tableView.delegate = self;
        [_tableView registerClass:[EHICustomerServiceCell class] forCellReuseIdentifier:@"EHICustomerServiceCell"];
    }
    return _tableView;
}

- (UIImageView *)recordTipImgView {
    if (!_recordTipImgView) {
        _recordTipImgView = [[UIImageView alloc] init];
        
        _recordTipImgView.image = [UIImage imageNamed:@"new_customer_service_record"];
        _recordTipImgView.center = self.view.center;
        _recordTipImgView.bounds = CGRectMake(0, 0, _recordTipImgView.image.size.width, _recordTipImgView.image.size.height);
        _recordTipImgView.hidden = YES;
    }
    return _recordTipImgView;
}

- (EHISocketManager *)socketManager {
    if (!_socketManager) {
        _socketManager = [EHISocketManager sharedInstance];
        _socketManager.delegate = self;
    }
    return _socketManager;
}

- (NSMutableArray<EHICustomerServiceModel *> *)messageArrayM {
    if (!_messageArrayM) {
        _messageArrayM = [NSMutableArray array];
    }
    return _messageArrayM;
}

- (EHINewCustomerServiceVoiceManager *)voiceManager {
    if (!_voiceManager) {
        _voiceManager = [EHINewCustomerServiceVoiceManager sharedInstance];
        
        __weak typeof(self) weakSelf = self;
        // 播放完成回调
        _voiceManager.finishPlay = ^(NSURL *url) {
            __strong typeof(weakSelf) self = weakSelf;
            [self voiceFinishWithUrl:url];
        };
        
        // 播放暂停回调
        _voiceManager.pause = ^(NSURL *url, CGFloat milliseconds) {
            __strong typeof(weakSelf) self = weakSelf;
            [self voicePauseWithUrl:url milliseconds:milliseconds];
        };
    }
    return _voiceManager;
}

- (EHINewCustomerServiceCacheManager *)voiceCacheManager {
    if (!_voiceCacheManager) {
        _voiceCacheManager = [EHINewCustomerServiceCacheManager sharedInstance];
    }
    return _voiceCacheManager;
}

@end
