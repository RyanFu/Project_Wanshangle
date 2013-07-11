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

//ShareSDK
#import <AGCommon/CoreDefinition.h>
#define BUNDLE_NAME @"Resource"
#define IMAGE_NAME @"sharesdk_img"
#define IMAGE_EXT @"jpg"
#define CONTENT @"ShareSDK不仅集成简单、支持如QQ好友、微信、新浪微博、腾讯微博等所有社交平台，而且还有强大的统计分析管理后台，实时了解用户、信息流、回流率、传播效应等数据，详情见官网http://sharesdk.cn @ShareSDK"
#define SHARE_URL @"http://www.sharesdk.cn"

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

//数据升级
#import "SystemDataUpdater.h"
#import "SystemDataUpdater1_0.h"  // updator for version 1.0

//API HTTPRequest Tag
//-------------MMovie----------------/
#define API_MMovieCmd           100 //电影
#define API_MMovieDetailCmd     101 //电影详情
#define API_MMovieRecOrLookCmd  102 //电影推荐想看
#define API_MCinemaCmd          120 //影院
#define API_MScheduleCmd        140 //排期
#define API_MBuyInfoCmd         160//购买信息
//-------------SShow----------------/
#define API_SShowCmd            180 //演出
#define API_SShowDetailCmd      200 //演出详情
//-------------BBar----------------/
#define API_BBarCmd             220 //演出
#define API_BBarDetailCmd       240 //演出详情
//-------------KKTV----------------/
#define API_KKTVCmd             260 //KTV 分页列表
#define API_KKTVSearchCmd       261 //KTV 搜索列表
#define API_KKTVBuyListCmd      265 //KTV 团购列表
#define API_KKTVPriceListCmd    266 //KTV 价格列表

//测试宏标记
//#define TestCode

//分页数据
#define DataLimit 20

//用户选择的城市
#define UserState @"administrativeArea"

//用户偏好设置
#define MMovie_CinemaFilterType @"MMovie_CinemaFilterType"
#define BBar_ActivityFilterType @"BBar_ActivityFilterType"
#define KKTV_FilterType         @"KKTV_FilterType"
#define SShow_FilterType        @"SShow_FilterType"

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