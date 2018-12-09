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
    
    self.bottomView.frame = CGRectMake(0, [UIScreen mainScreen].bounds.size.height - 100 - [EHINewCustomerSeerviceTools getBottomDistance], [UIScreen mainScreen].bounds.size.width, 100 + [EHINewCustomerSeerviceTools getBottomDistance]);
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
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    EHICustomerServiceModel *model = [self.messageArrayM objectAtIndex:indexPath.row];
    CGSize chatContentSize = model.chatContentSize;
    return chatContentSize.height;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:true];
    EHICustomerServiceModel *model = [self.messageArrayM objectAtIndex:indexPath.row];
    if (model.playStatus == EHIVoiceMessagePlayStatusUnplay ||
        model.playStatus == EHIVoiceMessagePlayStatusFinish) {
        model.playStatus = EHIVoiceMessagePlayStatusIsplaying;
        [self.voiceManager playVoiceWithUrl:model.voiceUrl];
    } else if (model.playStatus == EHIVoiceMessagePlayStatusPause) {
        model.playStatus = EHIVoiceMessagePlayStatusIsplaying;
        [self.voiceManager resumePlayWithUrl:model.voiceUrl time:model.secondsPlayed];
    } else {
        model.playStatus = EHIVoiceMessagePlayStatusPause;
        [self.voiceManager pausePlayWithUrl:model.voiceUrl completion:^(CGFloat seconds) {
            model.secondsPlayed = seconds;
        }];
    }
}

#pragma mark - send message

- (void)sendtextMessage:(NSString *)text {
//    [self.socketManager sendText:text success:^{
//        
//    } failure:^(NSError *error) {
//        
//    }];
    
    EHICustomerServiceModel *model = [[EHICustomerServiceModel alloc] init];
    model.fromType = EHIMessageFromTypeSender;
    model.messageStatus = EHIMessageStatusSuccess;
    model.messageType = EHIMessageTypeText;
    model.text = text;
    model.time = [self currentDateStr];
    [self.messageArrayM addObject:model];
    [self.tableView reloadData];
}

- (void)sendVoiceMessage:(NSData *)data {
    // TODO: 上传音频
    EHICustomerServiceModel *model = [[EHICustomerServiceModel alloc] init];
    model.fromType = EHIMessageFromTypeSender;
    model.messageStatus = EHIMessageStatusSuccess;
    model.messageType = EHIMessageTypeVoice;
    model.voiceUrl = [NSURL URLWithString:@"https://raw.githubusercontent.com/YOGURTtS/YGRecorder/master/myRecord.amr"];
    model.time = [self currentDateStr];
    [self.messageArrayM addObject:model];
    [self.tableView reloadData];
    
//    [self.socketManager sendVoice:nil success:^{
//
//    } failure:^(NSError * error) {
//
//    }];
}

/** 获取当前时间 */
- (NSString *)currentDateStr {
    NSDate *currentDate = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"YYYY/MM/dd hh:mm:ss SS "];
    NSString *dateString = [dateFormatter stringFromDate:currentDate];
    return dateString;
}

#pragma mark - lazy laod

- (EHICustomServiceBottomView *)bottomView {
    if (!_bottomView) {
        _bottomView = [[EHICustomServiceBottomView alloc] initWithFrame:CGRectZero];
        _bottomView.backgroundColor = [UIColor redColor];
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
        _bottomView.sendVoiceCallBack = ^(NSData *data) {
            __strong typeof(weakSelf)self = weakSelf;
            NSLog(@"voice data = %@", data);
            [self sendVoiceMessage:data];
        };
        
        // 发送图片消息
        
        
    }
    return _bottomView;
}

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        
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
    }
    return _voiceManager;
}

@end
