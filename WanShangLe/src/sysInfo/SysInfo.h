//
//  SysInfo.h
//  SingletonDemo
//
//  Created by 首 回 on 12-4-27.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SysInfo : NSObject
{
    NSString * _osName; /*操作系统名称*/ 
    NSString * _screenSize; /*屏幕大小  目前获取不了*/
    NSString * _osBeta;  /*操作系统版本*/
    NSString * _deviceType; /*设备类型*/
    NSString * _operators; /*运营商  目前获取不了*/
    NSString * _networkType; /*网络类型*/
    NSString * _other;  /*其他*/
    NSString * _deviceName;  /*设备名称*/
    NSString * _macAddress;  /*mac地址*/
}
@property (nonatomic,readonly)NSString * screenSize;
@property (nonatomic,readonly)NSString * osBeta;
@property (nonatomic,readonly)NSString * deviceType;
@property (nonatomic,readonly)NSString * operators;
@property (nonatomic,readonly)NSString * networkType;
@property (nonatomic,readonly)NSString * other;
@property (nonatomic,readonly) NSString * deviceName;
@property (nonatomic,readonly) NSString * macAddress;
+ (void) doInit;
+ (void) doDestroy;
+ (id) defaultInfo;
-(NSString*)getParamString;
@end
