//
//  ViewController.m
//  MyHomeKit
//
//  Created by 惠上科技 on 2018/6/11.
//  Copyright © 2018年 惠上科技. All rights reserved.
//

#import "ViewController.h"
#import "GCDSocketManager.h"
@interface ViewController ()
@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *userClickArray;
@end
@implementation ViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    
//    for (UIButton *userButton in _userClickArray) {
//        [userButton addTarget:self action:@selector(userClick:) forControlEvents:UIControlEventTouchUpInside];
//    }
}


-(void)userClick:(UIButton *)button{
    [[GCDSocketManager sharedSocketManager] sendDataToServer:button.titleLabel.text];
}


#pragma mark --------开始连接
- (IBAction)startConnect:(UIButton *)sender {
    [[GCDSocketManager sharedSocketManager] connectToServer];
}


#pragma mark --------断开连接
- (IBAction)stopConnect:(UIButton *)sender {
    [[GCDSocketManager sharedSocketManager] cutOffSocket];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
@end
