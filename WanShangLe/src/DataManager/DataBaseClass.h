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
@class MBuyTicketInfo;
@class MCinemaDiscount;
@class ApiCmdMovie_getAllMovies;
@class ApiCmdMovie_getAllCinemas;
@class ApiCmdMovie_getNearByCinemas;
@class ApiCmdMovie_getSearchCinemas;
@class ApiCmdMovie_getSchedule;
@class ApiCmdMovie_getBuyInfo;
@class ApiCmdMovie_getCinemaDiscount;
//-------------KTV----------------/
@class KKTV;
@class KKTVBuyInfo;
@class KKTVPriceInfo;
@class ApiCmdKTV_getAllKTVs;
@class ApiCmdKTV_getBuyList;
@class ApiCmdKTV_getPriceList;
@class ApiCmdKTV_getSearchKTVs;
@class ApiCmdKTV_getNearByKTVs;
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
#define DataLimit 40
#define DataCount 20

//电影团购信息 描述是1为选座 2为团购 3为券
#define XuanZuo  1
#define TuanGou  2
#define TuanJuan 3

//API HTTPRequest TAG
//-------------推荐和想看----------------/
#define API_RecommendOrLookCmd 99 //推荐和想看
#define API_RecommendOrLookMovieType    @"MovieType" //推荐和想看
#define API_RecommendOrLookShowType     @"ShowType" //推荐和想看
#define API_RecommendOrLookKTVType      @"KTVType" //推荐和想看
#define API_RecommendOrLookBarType      @"BarType" //推荐和想看
//-------------MMovie----------------/
#define API_MMovieCmd           10 //电影 全部
#define API_MMovieDetailCmd     11 //电影 详情
#define API_MScheduleCmd        12 //电影 今天排期
#define API_MScheduleCmdTomorrow  13 //电影 明天排期
#define API_MCinemaValidMovies  14 //电影 指定影院有效的电影
#define API_MBuyInfoCmd         15 //电影 购买信息
#define API_MDiscountInfoCmd    16 //电影 折扣信息

#define API_MCinemaCmd          1 //影院 全部
#define API_MCinemaSearchCmd    2 //影院 搜索
#define API_MCinemaNearByCmd    3 //影院 附近

//-------------BBar----------------/
#define API_BBarTimeCmd         1 //酒吧 时间
#define API_BBarPopularCmd      2 //酒吧 人气
#define API_BBarNearByCmd       3 //酒吧 附近
#define API_BBarDetailCmd       4 //酒吧 详情
#define API_BBarRecOrLookCmd    5 //酒吧 详情

//-------------SShow----------------/
#define API_SShowCmd                       100 //演出 列表
#define API_SShowDetailCmd                 101 //演出 详情

#define API_SShow_Type_All_Cmd              @"全部" //演出 类型
#define API_SShow_Type_VocalConcert_Cmd     @"演唱会" //演出 类型 
#define API_SShow_Type_Music_Cmd            @"音乐会" //演出 类型 
#define API_SShow_Type_Talk_Cmd             @"话剧歌剧" //演出 类型 
#define API_SShow_Type_Dance_Cmd            @"舞蹈芭蕾" //演出 类型 
#define API_SShow_Type_Circus_Cmd           @"曲艺杂谈" //演出 类型 
#define API_SShow_Type_Sport_Cmd            @"体育比赛" //演出 类型 
#define API_SShow_Type_Child_Cmd            @"儿童亲子" //演出 类型 

#define API_SShow_Time_All_Cmd              @"0" //演出 时间 全部
#define API_SShow_Time_Today_Cmd            @"1" //演出 时间 今天
#define API_SShow_Time_Tomorrow_Cmd         @"2" //演出 时间 明天
#define API_SShow_Time_AfterTomorrow_Cmd    @"3" //演出 时间 后天

#define API_SShow_SortASC_Cmd    @"asc" //演出 排序 低-高
#define API_SShow_SortDESC_Cmd   @"desc" //演出 排序 高-低

#define API_SShow_Oreder_Time_Cmd      @"1" //演出 时间
#define API_SShow_Oreder_Rating_Cmd    @"2" //演出 评分
#define API_SShow_Oreder_Distance_Cmd  @"3" //演出 距离
#define API_SShow_Oreder_Price_Cmd     @"4" //演出 价格

//-------------KKTV----------------/
#define API_KKTVCmd             1 //KTV 全部
#define API_KKTVSearchCmd       2 //KTV 搜索
#define API_KKTVNearByCmd       3 //KTV 附近
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