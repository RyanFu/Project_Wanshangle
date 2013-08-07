//
//  CoreManager.h
//  WanShangLe
//
//  Created by stephenliu on 13-6-4.
//  Copyright (c) 2013年 stephenliu. All rights reserved.
//

#import "ABLogger.h"
#import "LocationManager.h"
#import "ReachabilityManager.h"

#import "common.h"
#import "SysConfig.h"
#import "SysInfo.h"

//数据库
#import "CoreData+MagicalRecord.h"
#import "DataBaseManager.h"
#import "CacheManager.h"

//网络API
#import "ApiNotify.h"
#import "ApiConfig.h"
#import "ApiFault.h"
#import "ApiClient.h"
#import "ApiCmd.h"

//分享文案
#import "ShareDefine.h"

//测试宏标记
//#define TestCode

//软件版本
#define AppVersion @"1.0"

//如何是YES显示引导界面，NO不显示
#define NewApp @"NewApp"

//用户选择的城市
#define UserState @"administrativeArea"

//用户偏好设置
#define MMovie_CinemaFilterType @"MMovie_CinemaFilterType"
#define BBar_ActivityFilterType @"BBar_ActivityFilterType"
#define KKTV_FilterType         @"KKTV_FilterType"
#define SShow_FilterType        @"SShow_FilterType"
#define BuyInfo_HintType        @"BuyInfo_HintType"

#define UserSetting @"UserSetting"
#define DistanceFilter @"DistanceFilter"
#define DistanceFilterData @"DistanceFilterData"

//判断设备ios版本
#define SYSTEM_VERSION_GREATER_THAN(v)              ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedDescending)
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(v)     ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedDescending)

//判断设备是否支持retina
#ifndef ImageShowcase_Utility_h
#define ImageShowcase_Utility_h
#define isRetina ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(640,960), [[UIScreen mainScreen] currentMode].size) : NO)
#endif

//适配iphone5的屏幕
//adaptive iphone5 macro
#define iPhone5 ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(640,1136), [[UIScreen mainScreen] currentMode].size) : NO)
//CGRect ( 0, 20, 320, 548)
#define iPhoneAppFrame [[UIScreen mainScreen] applicationFrame]
#define iPhoneScreenBounds [[UIScreen mainScreen] bounds]
#define navigationBarHeight 44.0f
