//
//  ViewController.m
//  J-IM-Demo
//
//  Created by yogurts on 2018/11/13.
//  Copyright © 2018 yogurts. All rights reserved.
//

#import "ViewController.h"
#import "EHISocketManager.h"

@interface ViewController ()

@property (nonatomic, strong) EHISocketManager *manager;
@property (weak, nonatomic) IBOutlet UITextView *textView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.manager = [EHISocketManager sharedInstance];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)sendMessage:(UIButton *)sender {
    [self.manager sendMessage];
}

- (IBAction)connect:(UIButton *)sender {
    [self.manager connect];
}

- (IBAction)disconnect:(UIButton *)sender {
    [self.manager disconnect];
}


@end
