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

@interface EHINewCustomerServiceControllerViewController () <UITableViewDelegate, UITableViewDataSource>

/** tableView */
@property (nonatomic, strong) UITableView *tableView;

/** 底部视图，包括快捷入口和输入部分 */
@property (nonatomic, strong) EHICustomServiceBottomView *bottomView;

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
    
    self.bottomView.frame = CGRectMake(0, [UIScreen mainScreen].bounds.size.height - 100, [UIScreen mainScreen].bounds.size.width, 100);
    self.tableView.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height - CGRectGetHeight(self.bottomView.frame));
}



#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 5;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"EHICustomerServiceCell";
    EHICustomerServiceCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    cell.backgroundColor = [UIColor cyanColor];
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
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
    }
    return _bottomView;
}

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        
        _tableView.tableFooterView = [UIView new];
        _tableView.dataSource = self;
        _tableView.delegate = self;
        [_tableView registerClass:[EHICustomerServiceCell class] forCellReuseIdentifier:@"EHICustomerServiceCell"];
    }
    return _tableView;
}

@end
