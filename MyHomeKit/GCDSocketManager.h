//
//  GCDSocketManager.h
//  MyHomeKit
//
//  Created by 惠上科技 on 2018/6/11.
//  Copyright © 2018年 惠上科技. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GCDAsyncSocket.h>
@interface GCDSocketManager : NSObject
@property(nonatomic,strong)GCDAsyncSocket *socket;

//单例
+(instancetype)sharedSocketManager;

//连接
-(void)connectToServer;

//断开
-(void)cutOffSocket;

//连接成功后向服务器发送数据
-(void)sendDataToServer:(NSString *)userType;
@end
