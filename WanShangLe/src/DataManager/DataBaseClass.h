//
//  CoreManager.h
//  WanShangLe
//
//  Created by stephenliu on 13-6-4.
//  Copyright (c) 2013年 stephenliu. All rights reserved.
//

#import "ApiCmd_recommendOrLook.h"

@class City;
@class ApiCmd;
@class TimeStamp;
@class ActionState;

//-------------电影模块----------------/
@class MMovie_City;
@class MMovie_Cinema;
@class MMovie;
@class MCinema;
@class MMovieDetail;
@class MSchedule;
@class ApiCmdMovie_getAllMovies;
@class ApiCmdMovie_getAllCinemas;
@class ApiCmdMovie_getNearByCinemas;
@class ApiCmdMovie_getSearchCinemas;
@class ApiCmdMovie_getSchedule;
@class ApiCmdMovie_getBuyInfo;
//-------------KTV----------------/
@class KKTV;
@class KKTVBuyInfo;
@class KKTVPriceInfo;
@class ApiCmdKTV_getAllKTVs;
@class ApiCmdKTV_getBuyList;
@class ApiCmdKTV_getPriceList;
@class ApiCmdKTV_getSearchKTVs;
//-------------演出----------------/
@class SShow;
@class SShowDetail;
@class ApiCmdShow_getAllShows;
@class ApiCmdShow_getShowDetail;
//-------------酒吧----------------/
@class BBar;
@class BBarDetail;
@class ApiCmdBar_getAllBars;
@class ApiCmdBar_getBarDetail;
//分页数据
#define DataLimit 20

//API HTTPRequest TAG

//-------------推荐和想看----------------/
#define API_RecommendOrLookCmd 99 //推荐和想看
#define API_RecommendOrLookMovieType    @"MovieType" //推荐和想看
#define API_RecommendOrLookShowType     @"ShowType" //推荐和想看
#define API_RecommendOrLookKTVType      @"KTVType" //推荐和想看
#define API_RecommendOrLookBarType      @"BarType" //推荐和想看
//-------------MMovie----------------/
#define API_MMovieCmd           0 //电影 全部
#define API_MMovieDetailCmd     1 //电影 详情
#define API_MScheduleCmd        2 //电影 排期
#define API_MBuyInfoCmd         3 //电影 购买信息

#define API_MCinemaCmd          10 //影院 全部
#define API_MCinemaSearchCmd    11 //影院 搜索
#define API_MCinemaNearByCmd    12 //影院 附近

//-------------BBar----------------/
#define API_BBarTimeCmd         1 //酒吧 时间
#define API_BBarPopularCmd      2 //酒吧 人气
#define API_BBarNearByCmd       3 //酒吧 附近
#define API_BBarDetailCmd       4 //酒吧 详情
#define API_BBarRecOrLookCmd    5 //酒吧 详情

//-------------SShow----------------/
#define API_SShowCmd                       100 //演出
#define API_SShowDetailCmd                 101 //演出
#define API_SShow_Type_All_Cmd              1 //演出 类型 全部
#define API_SShow_Type_VocalConcert_Cmd     2 //演出 类型 演唱会
#define API_SShow_Type_Music_Cmd            3 //演出 类型 音乐会
#define API_SShow_Type_Talk_Cmd             4 //演出 类型 相声小品
#define API_SShow_Type_Drama_Cmd            5 //演出 类型 话剧
#define API_SShow_Type_Circus_Cmd           6 //演出 类型 马戏杂技
#define API_SShow_Type_Child_Cmd            7 //演出 类型 亲子

#define API_SShow_Time_All_Cmd              1 //演出 时间 全部
#define API_SShow_Time_Today_Cmd            2 //演出 时间 今天
#define API_SShow_Time_Tomorrow_Cmd         3 //演出 时间 明天
#define API_SShow_Time_Weekend_Cmd          4 //演出 时间 周末
#define API_SShow_Time_InThreeDay_Cmd       5 //演出 时间 三天内

#define API_SShow_Oreder_Recommend_Cmd      0 //演出 排序 推荐
#define API_SShow_Oreder_Time_Cmd           1 //演出 排序 时间先后
#define API_SShow_Oreder_PriceL_Cmd         2 //演出 排序 价格低到高
#define API_SShow_Oreder_PriceH_Cmd         3 //演出 排序 价格高到低
#define API_SShow_Oreder_Distance_Cmd       4 //演出 排序 距离近到远
#define API_SShow_Oreder_Rating_Cmd         5 //演出 排序 评分高到低

//-------------KKTV----------------/
#define API_KKTVCmd             401 //KTV 全部
#define API_KKTVSearchCmd       402 //KTV 搜索
#define API_KKTVNearByCmd       403 //KTV 附近
#define API_KKTVBuyListCmd      404 //KTV 团购
#define API_KKTVPriceListCmd    405 //KTV 价格

//数据类型
//-------------MMovie----------------/
//排期
#define ScheduleToday @"0"
#define ScheduleTomorrow @"1"
//-------------BBar----------------/
//-------------SShow----------------/
//-------------KKTV----------------/

//数据升级
#import "SystemDataUpdater.h"
#import "SystemDataUpdater1_0.h"  // updator for version 1.0

//用户偏好设置
#define MMovie_CinemaFilterType @"MMovie_CinemaFilterType"
#define BBar_ActivityFilterType @"BBar_ActivityFilterType"
#define KKTV_FilterType         @"KKTV_FilterType"
#define SShow_FilterType        @"SShow_FilterType"

//用户选择的城市
#define UserState @"administrativeArea"