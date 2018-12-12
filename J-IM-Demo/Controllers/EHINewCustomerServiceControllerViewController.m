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
#import "EHIVoiceManager.h"
#import <TZImagePickerController.h>
#import "EHINewCustomerServiceCacheManager.h"


@interface EHINewCustomerServiceControllerViewController () <UITableViewDelegate, UITableViewDataSource>

/** tableView */
@property (nonatomic, strong) UITableView *tableView;

/** 底部视图，包括快捷入口和输入部分 */
@property (nonatomic, strong) EHICustomServiceBottomView *bottomView;

/** socket管理器 */
@property (nonatomic, strong) EHISocketManager *socketManager;

/** 消息数组 */
@property (nonatomic, strong) NSMutableArray<EHICustomerServiceModel *> *messageArrayM;

/** 语音管理器 */
@property (nonatomic, strong) EHIVoiceManager *voiceManager;

/** 语音缓存管理器 */
@property (nonatomic, strong) EHINewCustomerServiceCacheManager *voiceCacheManager;

@end

@implementation EHINewCustomerServiceControllerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationItem.title = @"在线客服";
    
    [self setupUI];
}

- (void)setupUI {
    [self.view addSubview:self.bottomView];
    [self.view addSubview:self.tableView];
    
    CGFloat bottomViewHeight = 87.f;
    self.bottomView.frame = CGRectMake(0, [UIScreen mainScreen].bounds.size.height - bottomViewHeight - [EHINewCustomerSeerviceTools getBottomDistance], [UIScreen mainScreen].bounds.size.width, bottomViewHeight + [EHINewCustomerSeerviceTools getBottomDistance]);
    self.tableView.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height - CGRectGetHeight(self.bottomView.frame));
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

/** 播放、暂停音频 */
- (void)voicePlayWithIndex:(NSInteger)index {
    EHICustomerServiceModel *model = [self.messageArrayM objectAtIndex:index];
    // 未播放过或播放完成
    if (model.playStatus == EHIVoiceMessagePlayStatusUnplay ||
        model.playStatus == EHIVoiceMessagePlayStatusFinish) {
        model.playStatus = EHIVoiceMessagePlayStatusIsplaying;
        [self.voiceManager playVoiceWithUrl:[NSURL fileURLWithPath:model.voiceFileUrl] finish:nil];
    } else if (model.playStatus == EHIVoiceMessagePlayStatusPause) { // 暂停播放
        model.playStatus = EHIVoiceMessagePlayStatusIsplaying;
        [self.voiceManager resumePlayWithUrl:[NSURL fileURLWithPath:model.voiceFileUrl] time:model.millisecondsPlayed];
    } else { // 正在播放
        model.playStatus = EHIVoiceMessagePlayStatusPause;
        [self.voiceManager pausePlayWithUrl:[NSURL fileURLWithPath:model.voiceFileUrl] completion:^(CGFloat seconds) {
            model.millisecondsPlayed = seconds;
        }];
    }
    [self.tableView reloadData];
}

/** 修改播放状态为暂停 */
- (void)voicePauseWithUrl:(NSURL *)url milliseconds:(CGFloat)milliseconds {
    for (EHICustomerServiceModel *model in self.messageArrayM) {
        if ([model.voiceUrl isEqual:url]) {
            model.millisecondsPlayed = milliseconds;
            model.playStatus = EHIVoiceMessagePlayStatusPause;
        }
    }
}

/** 修改播放状态为播放完 */
- (void)voiceFinishWithUrl:(NSURL *)url {
    for (EHICustomerServiceModel *model in self.messageArrayM) {
        if ([model.voiceUrl isEqual:url]) {
            model.millisecondsPlayed = 0.0f;
            model.playStatus = EHIVoiceMessagePlayStatusFinish;
        }
    }
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
    
    //    [self.socketManager sendText:text success:^{
    //
    //    } failure:^(NSError *error) {
    //
    //    }];
}

- (void)sendVoiceMessage:(NSData *)data wavFilePath:(NSString *)filePath {
    // TODO: 上传音频
    
    EHICustomerServiceModel *model = [[EHICustomerServiceModel alloc] init];
    model.isAnonymousMessage = YES;
    model.fromType = EHIMessageFromTypeSender;
    model.messageStatus = EHIMessageStatusSuccess;
    model.messageType = EHIMessageTypeVoice;
    model.voiceUrl = @"https://raw.githubusercontent.com/YOGURTtS/YGRecorder/master/myRecord.amr";
    model.voiceFileUrl = filePath;
    model.time = [self currentDateStr];
    [self.messageArrayM addObject:model];
    [self.tableView reloadData];
    
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
        model.pictureUrl = 
        model.time = [self currentDateStr];
        [self.messageArrayM addObject:model];
        [self.tableView reloadData];
    }
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
        // 如果是在线语音就缓存下来
        if (model.messageType == EHIMessageTypeVoice && model.voiceFileUrl.length == 0 &&
            [model.voiceUrl hasPrefix:@"http"]) {
            __weak typeof(self) weakSelf = self;
            [self.voiceCacheManager cacheOnlineVoiceWithUrl:model.voiceUrl completion:^(NSString *filePath) {
                __strong typeof(weakSelf) self = weakSelf;
                model.voiceFileUrl = filePath;
                // TODO: 更新数据库
                
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

#pragma mark - lazy laod

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
        _bottomView.sendTextCallBack = ^(NSString *text) {
            __strong typeof(weakSelf)self = weakSelf;
            NSLog(@"text = %@", text);
            [self sendtextMessage:text];
        };
        
        // 发送语音消息
        _bottomView.sendVoiceCallBack = ^(NSData *amrdData, NSString *wavFilePath) {
            __strong typeof(weakSelf)self = weakSelf;
            NSLog(@"voice wavFilePath = %@", wavFilePath);
            [self sendVoiceMessage:amrdData wavFilePath:wavFilePath];
        };
        
        
        // 发送图片消息
        _bottomView.sendPictureCallBack = ^(UIImage *image) {
            __strong typeof(weakSelf)self = weakSelf;
            [self getPictures];
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

- (NSMutableArray<EHICustomerServiceModel *> *)messageArrayM {
    if (!_messageArrayM) {
        _messageArrayM = [NSMutableArray array];
    }
    return _messageArrayM;
}

- (EHIVoiceManager *)voiceManager {
    if (!_voiceManager) {
        _voiceManager = [[EHIVoiceManager alloc] init];
        
        __weak typeof(self) weakSelf = self;
        // 播放完成回调
        _voiceManager.finish = ^(NSURL *url) {
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
        _voiceCacheManager = [[EHINewCustomerServiceCacheManager alloc] init];
    }
    return _voiceCacheManager;
}

@end
