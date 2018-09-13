//
//  GCDSocketManager.m
//  MyHomeKit
//
//  Created by 惠上科技 on 2018/6/11.
//  Copyright © 2018年 惠上科技. All rights reserved.
//

#import "GCDSocketManager.h"
#define SocketHost @"192.168.1.124"  //地址
#define SocketPort 9999  //端口号
@interface GCDSocketManager ()<GCDAsyncSocketDelegate>
//握手次数
@property(nonatomic,assign)NSInteger pushCount;

//断开重连定时器
@property(nonatomic,strong)NSTimer *timer;

// 检测心跳的定时器
@property (nonatomic,strong)NSTimer *heartBeatTimer;

//重连次数
@property(nonatomic,assign)NSInteger reconnectCount;
@end
@implementation GCDSocketManager
//全局访问点
+(instancetype)sharedSocketManager{
    static GCDSocketManager *_instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[self alloc] init];
    });
    return _instance;
}

//可以在这里做你想做的一些初始操作
-(instancetype)init{
    self = [super init];
    if (self) {
    }
    return self;
}

#pragma mark - 这里是操作发送心跳包定时器的方法
- (void)openTimer {
    [self closeTimer];
    if (self.heartBeatTimer ==nil || !self.heartBeatTimer) {
        self.heartBeatTimer = [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(heartCheck) userInfo:nil repeats:YES];
    }
    
}
- (void)closeTimer {
    [self.heartBeatTimer invalidate];
    self.heartBeatTimer =nil;
}

- (void)heartCheck {
    [self sendDataToServer:@"我在心跳"];
}



#pragma mark ---------请求连接
-(void)connectToServer{
    //初始化握手次数
    self.pushCount = 0;
    
    //初始化socket
    self.socket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
    
    //连接失败的错误
    NSError *error = nil;
    
    //开始连接
    [self.socket connectToHost:SocketHost onPort:SocketPort error:&error];
    
    //如果连接失败，打印错误，看看具体是什么原因造成的
    if (error) {
        NSLog(@"SocketConnectError：%@",error);
    }
}


#pragma mark -----------如果连接成功
//连接成功的回调
-(void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port{
    //如果socket连接成功，可以向服务器发送一些服务器需要的数据
    [self openTimer];
}


//连接成功后向服务器发送数据
-(void)sendDataToServer:(NSString *)userType{
    if (!self.socket.isConnected & ![userType isEqualToString:@"我在心跳"]) {
        NSLog(@"服务器中断了我需要重新连接");
        [self connectToServer];
        return;
    }
    //发送数据代码省略...
    
//    NSString *str =@"1";
    
    NSData *jsonData = [userType dataUsingEncoding:NSUTF8StringEncoding];
    
    //发送
    [self.socket writeData:jsonData withTimeout:-1 tag:1];
    //读取数据
    [self.socket readDataWithTimeout:-1 tag:200];
}

//连接成功向服务器发送数据后，服务器会有响应
-(void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag{
    NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"客户端收到数据---%@",str);
    
    
    //这句代码必须写
    [self.socket readDataWithTimeout:-1 tag:200];
    
    //服务器推送次数
    self.pushCount++;
    
    //此处进行校验，校验格式看服务器那边给什么格式，还有如果校验成功做些什么事，校验失败做些什么事
    //代码省略
}


#pragma mark --------连接失败
//连接失败的回调
-(void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err{
    NSLog(@"Socket连接失败");
    
    //握手次数设置为0，因为连接失败是进行重新连接的，下次使用握手次数进行校验时必须重新开始校验
    self.pushCount = 0;
    
    //会在程序进入前台/后台时，分别记录当前程序处于什么状态
    //如果处于前台，连接失败就进行重连
    //如果处于后台，连接失败就不在重连
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *currentStatu = [userDefaults valueForKey:@"Statu"];
    
    //程序在前台才会重连
    if ([currentStatu isEqualToString:@"foreground"]) {
        //重连次数
        self.reconnectCount ++;
        
        //如果连接失败 累加1秒重新连接 减少服务器压力
        NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:1.0 * self.reconnectCount target:self selector:@selector(reconnectServer) userInfo:nil repeats:NO];
        self.timer = timer;
    }
}

//如果连接失败，5秒后重新连接
-(void)reconnectServer{
    self.pushCount = 0;
    self.reconnectCount = 0;
    
    //连接失败重新连接
    NSError *error = nil;
    [self.socket connectToHost:SocketHost onPort:SocketPort error:&error];
    if (error) {
        NSLog(@"SocketConnectError:%@",error);
    }
}

#pragma mark -------断开连接
//断开连接
-(void)cutOffSocket{
    NSLog(@"socket断开连接");
    self.pushCount = 0;
    self.reconnectCount = 0;
    [self.timer invalidate];
    self.timer = nil;
    [self.socket disconnect];
}
@end
