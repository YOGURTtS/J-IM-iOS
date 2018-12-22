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
#import "EHINewCustomerServiceDAO.h"
#import "EHICustomerServiceModel.h"
#import "EHINewCustomerServiceVoiceManager.h"
#import "EHINewCustomerServiceCacheManager.h"
#import <TZImagePickerController.h>
#import <IQKeyboardManager.h>


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

/** 数据库对象 */
@property (nonatomic, strong) EHINewCustomerServiceDAO *dao;

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
    [self loadHistoryMessages];
}

- (void)viewWillAppear:(BOOL)animated {
    //TODO: 页面appear 禁用
    [[IQKeyboardManager sharedManager] setEnableAutoToolbar:NO];
    [[IQKeyboardManager sharedManager] setEnable:NO];
    //启用监听
    [self registerForKeyboardNotifications];
}

- (void)viewWillDisappear:(BOOL)animated {
    //TODO: 页面Disappear 启用
    [[IQKeyboardManager sharedManager] setEnableAutoToolbar:YES];
    //TODO: 页面Disappear 启用
    [[IQKeyboardManager sharedManager] setEnable:YES];
    //关闭监听
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

/** 注册键盘监听的通知 */
- (void)registerForKeyboardNotifications {
    // 使用NSNotificationCenter 键盘出现时
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillChangeFrameNotification object:nil];
    // 使用NSNotificationCenter 键盘隐藏时
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

/** 键盘显示的时候 */
- (void)keyboardWillShow:(NSNotification*)aNotification {
    NSDictionary *info = [aNotification userInfo];
    CGFloat duration = [[info objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    NSValue *value = [info objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGSize keyboardSize = [value CGRectValue].size;
    // 输入框位置动画加载
    [UIView animateWithDuration:duration animations:^{
        // 将输入框位置提高
        self.tableView.transform = CGAffineTransformMakeTranslation(0, -keyboardSize.height);
        self.bottomView.transform = CGAffineTransformMakeTranslation(0, -keyboardSize.height);
    }];
}

/** 当键盘隐藏的时候 */
- (void)keyboardWillHide:(NSNotification*)aNotification {
    // 将输入框位置还原
    self.tableView.transform = CGAffineTransformIdentity;
    self.bottomView.transform = CGAffineTransformIdentity;
}

- (void)setupUI {
    
    self.view.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.topLabel];
    [self.view addSubview:self.bottomView];
    [self.view addSubview:self.tableView];
    [self.view addSubview:self.recordTipImgView];
    [self.view bringSubviewToFront:self.topLabel];
    
    self.topLabel.frame = CGRectMake(0, CGRectGetHeight(self.navigationController.navigationBar.frame) + CGRectGetHeight([UIApplication sharedApplication].statusBarFrame), [UIScreen mainScreen].bounds.size.width, 25);
    
    CGFloat bottomViewHeight = 87.f;
    self.bottomView.frame = CGRectMake(0, [UIScreen mainScreen].bounds.size.height - bottomViewHeight - [EHINewCustomerSeerviceTools getBottomDistance], [UIScreen mainScreen].bounds.size.width, bottomViewHeight + [EHINewCustomerSeerviceTools getBottomDistance]);
    
    self.tableView.frame = CGRectMake(0, CGRectGetMaxY(self.topLabel.frame), [UIScreen mainScreen].bounds.size.width, CGRectGetHeight(self.view.frame) - CGRectGetHeight(self.navigationController.navigationBar.frame) - CGRectGetHeight([UIApplication sharedApplication].statusBarFrame) - CGRectGetHeight(self.topLabel.frame) - CGRectGetHeight(self.bottomView.frame));
}

#pragma mark - about socket

/** 连接socket */
- (void)connectSocket {
    [self.socketManager connectWithCustomerId:@"101"];
}

/** 断开连接socket */
- (void)disconnectSocket {
    [self.socketManager disconnect];
    [self.messageArrayM removeAllObjects];
    [self.tableView reloadData];
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

/** 滚动到最后一行 */
- (void)scrollToLastCell {
    if (self.messageArrayM.count) {
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.messageArrayM.count - 1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    }
}

#pragma mark - socket manager delegate

/** 接收到聊天消息 */
- (void)socketManeger:(EHISocketManager *)socketManager didReceiveMessage:(EHISocketServiceMessage *)message {
    NSLog(@"message content = %@", message.data.content);
    
    // 切换到主线程
    __weak typeof(self) weakSelf = self;
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        __strong typeof(weakSelf) self = weakSelf;
        [self handleMessageFromService:message];
    }];
    
}

/** 接收关闭socket请求 */
- (void)socketManeger:(EHISocketManager *)socketManager didReceiveCloseChatMessage:(EHISocketCloseChatMessage *)message {
    NSLog(@"message command = %d", message.cmd);
}

/** 处理收到的客服消息 */
- (void)handleMessageFromService:(EHISocketServiceMessage *)message {
    EHICustomerServiceModel *model = [[EHICustomerServiceModel alloc] init];
    model.isAnonymousMessage = YES;
    model.time = [NSString stringWithFormat:@"%zd", message.data.createTime];
    model.fromType = EHIMessageFromTypeReceiver;
    model.messageType = message.data.msgType;
    model.messageStatus = EHIMessageStatusReceived;
    switch (message.data.msgType) {
        case EHIMessageTypeText:
            model.text = message.data.content;
            [self.messageArrayM addObject:model];
            [self.tableView reloadData];
            [self scrollToLastCell];
            [self.dao addMessage:model];
            break;
        case EHIMessageTypePicture:
        {
            model.pictureUrl = message.data.content;
        }
            break;
        case EHIMessageTypeVoice:
        {
            model.voiceUrl = message.data.content;
            // 缓存
            __weak typeof(self) weakSelf = self;
            [self.voiceCacheManager cacheVoiceWithUrl:model.pictureUrl completion:^(NSString *filePath, NSInteger duration) {
                __strong typeof(weakSelf) self = weakSelf;
                model.voiceDuration = duration;
                [self.messageArrayM addObject:model];
                [self.tableView reloadData];
                [self scrollToLastCell];
                [self.dao addMessage:model];
            }];
        }
            break;
            
        default:
            break;
    }
}

/** socket连接成功 */
- (void)socketManeger:(EHISocketManager *)socketManager didConnectToHost:(NSString *)host port:(uint16_t)port {
    // 发送登录消息
    NSString *loginName = @"101";
    [self.socketManager sendLoginMessagaWithLoginName:loginName password:loginName token:loginName success:^{
        
    } failure:^(NSError *error) {
        
    }];
}

/** 和socket断开连接 */
- (void)socketManeger:(EHISocketManager *)socketManager socketDidDisconnectWithError:(NSError *)error {
    NSLog(@"socketDidDisconnectWithError, error = %@", error);
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

/** 发送文字 */
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
    [self scrollToLastCell];
    [self.socketManager sendText:text from:@"101" to:@"10100" extras:nil success:^{
        
    } failure:^(NSError *error) {
        
    }];
    
    // TODO: 插入数据表
    [self.dao addMessage:model];
}

/** 发送录音 */
- (void)sendVoiceMessage:(NSData *)data wavFilePath:(NSString *)filePath duration:(NSInteger)duration {
    // TODO: 上传音频
    
    EHICustomerServiceModel *model = [[EHICustomerServiceModel alloc] init];
    model.isAnonymousMessage = YES;
    model.fromType = EHIMessageFromTypeSender;
    model.messageStatus = EHIMessageStatusSuccess;
    model.messageType = EHIMessageTypeVoice;
    model.voiceUrl = filePath;
    model.time = [self currentDateStr];
    
//    __weak typeof(self) weakSelf = self;
//    [self.voiceCacheManager cacheSendVoiceWithUrl:model.voiceUrl completion:^(NSString *filePath, NSInteger duration) {
//        __strong typeof(weakSelf) self = weakSelf;
//        NSLog(@"voice cache file path = %@", filePath);
//        model.voiceUrl = filePath;
        model.voiceDuration = duration;
        [self.messageArrayM addObject:model];
        [self.tableView reloadData];
        [self scrollToLastCell];
        [self.dao addMessage:model];
//    }];
    
    
//    [self.socketManager sendVoice:nil success:^{
//        
//    } failure:^(NSError * error) {
//        
//    }];
}

/** 获取图片并发送 */
- (void)getPictures {
    TZImagePickerController *imagePickerVc = [[TZImagePickerController alloc] initWithMaxImagesCount:6 delegate:nil];
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
        [self.dao addMessage:model];
    }
    [self.tableView reloadData];
    [self scrollToLastCell];
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
    
    // TODO: 在接口回调中将数据添加到数据库中
    [self addMessagesToDatabase:nil];
}

/** 消息插入数据表 */
- (void)addMessagesToDatabase:(NSArray<EHICustomerServiceModel *> *)messages {
    for (EHICustomerServiceModel *model in messages) {
        // TODO: 将消息逐条插入数据表
        [self.dao addMessage:model];
    }
}

#pragma mark - about database

/** 加载历史信息 */
- (void)loadHistoryMessages {
    [self.dao getAnonymousMessageWithCompletion:^(NSArray * _Nonnull array) {
        [self.messageArrayM addObjectsFromArray:array];
        [self.tableView reloadData];
        [self scrollToLastCell];
    }];
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
        
        _topLabel.text = @"交谈中...";
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
        _bottomView.sendVoiceCallback = ^(NSData *amrdData, NSString *amrFilePath, NSInteger duration) {
            __strong typeof(weakSelf)self = weakSelf;
            NSLog(@"voice amrFilePath = %@", amrFilePath);
            [self sendVoiceMessage:amrdData wavFilePath:amrFilePath duration:duration];
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
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self.view action:@selector(endEditing:)];
        [_tableView addGestureRecognizer:tap];
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

- (EHINewCustomerServiceDAO *)dao {
    if (!_dao) {
        _dao = [[EHINewCustomerServiceDAO alloc] init];
    }
    return _dao;
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
