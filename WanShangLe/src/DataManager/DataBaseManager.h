//
//  DataBaseManager.h
//  WanShangLe
//
//  Created by stephenliu on 13-6-6.
//  Copyright (c) 2013年 stephenliu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ApiNotify.h"
#import "DataBaseClass.h"

/**
 数据库管理类
 @author stephenliu
 */

typedef void (^GetCinemaNearbyList)(NSArray *cinemas,BOOL isSuccess);
typedef void (^GetKTVNearbyList)(NSArray *ktvs, BOOL isSuccess);

@interface DataBaseManager : NSObject{
    
}
/**
 单例对象
 @returns single instance type
 */
+ (instancetype)sharedInstance;

/**
 destroy single instance
 */
+ (void)destroySharedInstance;

/**
 computer database and resource folder size
 @param folderPath fodler path
 @returns res size
 */
- (unsigned long long int)folderSize:(NSString *)folderPath;
- (unsigned long long int)CoreDataSize;

//database uid key
- (NSString*)md5PathForKey:(NSString *) key;

//日期-时间
- (BOOL)isToday:(NSString *)date;
- (BOOL)isTomorrow:(NSString *)date;

- (NSString *)getTodayTimeStamp;
- (NSString *)getTodayZeroTimeStamp;
//获取星期几
- (NSString *)getNowDate;
- (NSString *)getTodayWeek;
- (NSString *)getTomorrowWeek;
- (NSString *)getWhickWeek:(NSDate*)aDate;
//获取时间
- (NSString *)getTimeFromDate:(NSString *)dateStr;
- (NSString *)timeByAddingTimeInterval:(int)time fromDate:(NSString *)dateStr;

//清除
- (void)cleanUp;
//通用的数据库保存函数
- (void)saveInManagedObjectContext:(NSManagedObjectContext *)coreDataContext;

/************ 城市 ***************/
- (void)insertAllCitysIntoCoreData;
- (City *)insertCityIntoCoreDataWith:(NSString *)cityName;
- (NSString *)validateCity:(NSString *)cityName;
- (NSString *)getNowUserCityId;
- (City *)getNowUserCityFromCoreData;
- (City *)getNowUserCityFromCoreDataWithName:(NSString *)name;

//测试 城市筛选
- (NSArray *)getUnCurrentCity;

/**
 推荐和想看接口
 @param apiType api 类型
 @param cType 是推荐还是想看
 @param delegate 代理
 */
- (BOOL)getRecommendOrLookForWeb:(NSString *)movieId
                         APIType:(WSLRecommendAPIType)apiType
                           cType:(WSLRecommendLookType)cType
                        delegate:(id<ApiNotify>)delegate;

/************ 关联表 ***************/
- (MMovie_City *)getFirstMMovie_CityFromCoreData:(NSString *)u_id;
- (MMovie_City *)insertMMovie_CityWithMovie:(MMovie *)a_movie andCity:(City *)a_city;
- (void)insertMMovie_CinemaWithMovies:(NSArray *)movies andCinemas:(NSArray *)cinemas;
- (MMovie_Cinema *)insertMMovie_CinemaWithaMovie:(MMovie *)aMovie andaCinema:(MCinema *)aCinema;

/************************  电影 *********************************/
/***************************************************************/
- (ApiCmd *)getAllMoviesListFromWeb:(id<ApiNotify>)delegate;
- (NSArray *)getAllMoviesListFromCoreData;
- (NSArray *)getAllMoviesListFromCoreDataWithCityName:(NSString *)cityName;
- (NSUInteger)getCountOfMoviesListFromCoreData;
- (NSUInteger)getCountOfMoviesListFromCoreDataWithCityName:(NSString *)cityName;
- (void)insertMoviesIntoCoreDataFromObject:(NSDictionary *)objectData withApiCmd:(ApiCmd*)apiCmd;
- (void)importMovie:(MMovie *)mMovie ValuesForKeysWithObject:(NSDictionary *)amovieData;
- (MMovie*)getMovieWithId:(NSString *)movieId;

//获取电影详情
- (ApiCmd *)getMovieDetailFromWeb:(id<ApiNotify>)delegate movieId:(NSString *)movieId;
- (BOOL)insertMovieDetailIntoCoreDataFromObject:(NSDictionary *)objectData withApiCmd:(ApiCmd*)apiCmd;
- (BOOL)insertMovieRecommendIntoCoreDataFromObject:(NSString *)movieId data:(NSDictionary *)objectData withApiCmd:(ApiCmd*)apiCmd;
- (void)importMovieDetail:(MMovieDetail *)aMovieDetail ValuesForKeysWithObject:(NSDictionary *)amovieDetailData;
- (MMovieDetail *)getMovieDetailWithId:(NSString *)movieId;

//获得排期
- (ApiCmd *)getScheduleFromWebWithaMovie:(MMovie *)aMovie andaCinema:(MCinema *)aCinema delegate:(id<ApiNotify>)delegate;
- (MSchedule *)getScheduleFromCoreDataWithaMovie:(MMovie *)aMovie andaCinema:(MCinema *)aCinema;
- (void)insertScheduleIntoCoreDataFromObject:(NSDictionary *)objectData withApiCmd:(ApiCmd*)apiCmd withaMovie:(MMovie *)aMovie andaCinema:(MCinema *)aCinema;
- (NSArray *)deleteUnavailableSchedules:(NSArray *)aArray;

//购买信息
- (ApiCmd *)getBuyInfoFromWebWithaMovie:(MMovie *)aMovie
                                aCinema:(MCinema *)aCinema
                              aSchedule:(NSString *)aSchedule
                               delegate:(id<ApiNotify>)delegate;
- (void)insertBuyInfoIntoCoreDataFromObject:(NSDictionary *)objectData
                                 withApiCmd:(ApiCmd*)apiCmd
                                 withaMovie:(MMovie *)aMovie
                                 andaCinema:(MCinema *)aCinema
                                  aSchedule:(NSString *)aSchedule;

/************ 影院 ***************/
- (ApiCmd *)getAllCinemasListFromWeb:(id<ApiNotify>)delegate;
- (NSArray *)getAllCinemasListFromCoreData;
- (NSArray *)getAllCinemasListFromCoreDataWithCityName:(NSString *)cityName;
- (BOOL)getNearbyCinemasListFromCoreDataWithCallBack:(GetCinemaNearbyList)callback;
- (NSArray *)getFavoriteCinemasListFromCoreData;
- (NSArray *)getFavoriteCinemasListFromCoreDataWithCityName:(NSString *)cityName;
- (NSUInteger)getCountOfCinemasListFromCoreData;
- (NSUInteger)getCountOfCinemasListFromCoreDataWithCityName:(NSString *)cityName;
- (void)insertCinemasIntoCoreDataFromObject:(NSDictionary *)objectData withApiCmd:(ApiCmd*)apiCmd;
- (void)importCinema:(MCinema *)mCinema ValuesForKeysWithObject:(NSDictionary *)aCinemaData;
- (void)importDynamicMovie:(MMovie *)mMovie ValuesForKeysWithObject:(NSDictionary *)amovieData;
- (BOOL)addFavoriteCinemaWithId:(NSNumber *)uid;
- (BOOL)deleteFavoriteCinemaWithId:(NSNumber *)uid;
- (NSArray *)getRegionOrder;

/************************ 演出 *********************************/
/***************************************************************/
- (ApiCmd *)getAllShowsListFromWeb:(id<ApiNotify>)delegate;
- (NSArray *)getAllShowsListFromCoreData;
- (NSArray *)getAllShowsListFromCoreDataWithCityName:(NSString *)cityName;
- (NSUInteger)getCountOfShowsListFromCoreData;
- (NSUInteger)getCountOfShowsListFromCoreDataWithCityName:(NSString *)cityName;
- (void)insertShowsIntoCoreDataFromObject:(NSDictionary *)objectData withApiCmd:(ApiCmd*)apiCmd;
- (void)importShow:(SShow *)sShow ValuesForKeysWithObject:(NSDictionary *)ashowDic;

/************************ 酒吧 *********************************/
/***************************************************************/
//酒吧 分页 
- (ApiCmd *)getBarsListFromWeb:(id<ApiNotify>)delegate
                        offset:(int)offset
                         limit:(int)limit
                      Latitude:(CLLocationDegrees)latitude
                     longitude:(CLLocationDegrees)longitude
                      dataType:(NSString *)dataType
                     isNewData:(BOOL)isNewData;

- (NSArray *)getBarsListFromCoreDataOffset:(int)offset
                                     limit:(int)limit
                                  Latitude:(CLLocationDegrees)latitude
                                 longitude:(CLLocationDegrees)longitude
                                  dataType:(NSString *)dataType
                                 validDate:(NSString *)validDate;

- (NSArray *)getBarsListFromCoreDataWithCityName:(NSString *)cityId
                                          offset:(int)offset
                                           limit:(int)limit
                                        Latitude:(CLLocationDegrees)latitude
                                       longitude:(CLLocationDegrees)longitude
                                        dataType:(NSString *)dataType
                                       validDate:(NSString *)validDate;

- (ApiCmd *)getAllBarsListFromWeb:(id<ApiNotify>)delegate;
- (NSArray *)getAllBarsListFromCoreData;
- (NSArray *)getAllBarsListFromCoreDataWithCityName:(NSString *)cityName;
- (NSUInteger)getCountOfBarsListFromCoreData;
- (NSUInteger)getCountOfBarsListFromCoreDataWithCityName:(NSString *)cityName;
- (NSArray *)insertBarsIntoCoreDataFromObject:(NSDictionary *)objectData withApiCmd:(ApiCmd*)apiCmd;
- (void)importBar:(BBar *)bBar ValuesForKeysWithObject:(NSDictionary *)aBarDic;

/************************ KTV *********************************/
/***************************************************************/
//获取 全部 KTV数据
- (ApiCmd *)getAllKTVsListFromWeb:(id<ApiNotify>)delegate;
- (NSArray *)getAllKTVsListFromCoreData;
- (NSArray *)getAllKTVsListFromCoreDataWithCityName:(NSString *)cityId;

//获取 分页 KTV数据
- (ApiCmd *)getKTVsListFromWeb:(id<ApiNotify>)delegate offset:(int)offset limit:(int)limit;
- (NSArray *)getKTVsListFromCoreDataOffset:(int)offset limit:(int)limit;
- (NSArray *)getKTVsListFromCoreDataWithCityName:(NSString *)cityId offset:(int)offset limit:(int)limit;

//获取 搜索 TKV列表
- (ApiCmd *)getKTVsSearchListFromWeb:(id<ApiNotify>)delegate offset:(int)offset limit:(int)limit searchString:(NSString *)searchString;

//KTV附近分页
- (BOOL)getNearbyKTVListFromCoreDataWithCallBack:(GetKTVNearbyList)callback;
- (ApiCmd *)getNearbyKTVListFromCoreDataWithCallBack:(id<ApiNotify>)delegate
                                            Latitude:(CLLocationDegrees)latitude
                                           longitude:(CLLocationDegrees)longitude
                                              offset:(int)offset
                                               limit:(int)limit;
//KTV收藏分页
- (NSArray *)getFavoriteKTVListFromCoreData;
- (NSArray *)getFavoriteKTVListFromCoreDataWithCityName:(NSString *)cityName;

- (NSUInteger)getCountOfKTVsListFromCoreData;
- (NSUInteger)getCountOfKTVsListFromCoreDataWithCityName:(NSString *)cityName;

- (NSArray *)insertKTVsIntoCoreDataFromObject:(NSDictionary *)objectData withApiCmd:(ApiCmd*)apiCmd;
- (void)importKTV:(KKTV *)kKTV ValuesForKeysWithObject:(NSDictionary *)aKTVDic;
- (BOOL)addFavoriteKTVWithId:(NSString *)uid;
- (BOOL)deleteFavoriteKTVWithId:(NSString *)uid;

//获得KTV 团购列表 KTV Info
- (ApiCmd *)getKTVTuanGouListFromWebWithaKTV:(KKTV *)aKTV
                                  delegate:(id<ApiNotify>)delegate;
- (void)insertKTVTuanGouListIntoCoreDataFromObject:(NSDictionary *)objectData
                                      withApiCmd:(ApiCmd*)apiCmd
                                        withaKTV:(KKTV *)aKTV;

//获得KTV 价格列表 Info
- (ApiCmd *)getKTVPriceListFromWebWithaKTV:(KKTV *)aKTV
                                delegate:(id<ApiNotify>)delegate;
- (void)insertKTVPriceListIntoCoreDataFromObject:(NSDictionary *)objectData
                                    withApiCmd:(ApiCmd*)apiCmd
                                      withaKTV:(KKTV *)aKTV;
@end
