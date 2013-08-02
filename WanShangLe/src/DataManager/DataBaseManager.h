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
@property(nonatomic,readwrite) NSTimeInterval missTime;
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
//清除数据缓存
- (BOOL)cleanUpDataBaseCache;

//database uid key
- (NSString*)md5PathForKey:(NSString *) key;

/************ 时间处理 ***************/
//服务器时间
-(NSDate *)date;
//日期-时间
- (BOOL)isToday:(NSString *)date;
- (BOOL)isTomorrow:(NSString *)date;
//获取时间戳
- (NSString *)getTodayTimeStamp;
- (NSString *)getTodayZeroTimeStamp;
//获取星期几
- (NSString *)getNowDate;
- (NSString *)getTodayWeek;
- (NSString *)getTomorrowWeek;
- (NSString *)getWhickWeek:(NSDate*)aDate;
//获取时间
- (NSString *)getTimeFromDate:(NSString *)dateStr;
- (NSString *)getYMDFromDate:(NSString *)dateStr;
- (NSString *)getHumanityTimeFromDate:(NSString *)dateStr;
- (NSString *)timeByAddingTimeInterval:(int)time fromDate:(NSString *)dateStr;
//几天后的时间
- (NSString *)dateWithTimeIntervalSinceNow:(NSTimeInterval)timeInterval fromDate:(NSString *)beginDate;

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
- (NSMutableArray *)insertMoviesIntoCoreDataFromObject:(NSDictionary *)objectData withApiCmd:(ApiCmd*)apiCmd;
- (void)importMovie:(MMovie *)mMovie ValuesForKeysWithObject:(NSDictionary *)amovieData;
- (MMovie*)getMovieWithId:(NSString *)movieId;

//获取电影详情
- (ApiCmd *)getMovieDetailFromWeb:(id<ApiNotify>)delegate movieId:(NSString *)movieId;
- (MMovieDetail *)insertMovieDetailIntoCoreDataFromObject:(NSDictionary *)objectData withApiCmd:(ApiCmd*)apiCmd;
- (MMovieDetail *)insertMovieRecommendIntoCoreDataFromObject:(NSDictionary *)objectData withApiCmd:(ApiCmd*)apiCmd;
- (void)importMovieDetail:(MMovieDetail *)aMovieDetail ValuesForKeysWithObject:(NSDictionary *)amovieDetailData;
- (MMovieDetail *)getMovieDetailWithId:(NSString *)movieId;

//获得排期
- (ApiCmd *)getScheduleFromWebWithaMovie:(MMovie *)aMovie andaCinema:(MCinema *)aCinema timedistance:(NSString *)timedistance delegate:(id<ApiNotify>)delegate;
//从数据库里获取排期
- (MSchedule *)getScheduleFromCoreDataWithaMovie:(MMovie *)aMovie andaCinema:(MCinema *)aCinema timedistance:(NSString *)timedistance;

- (MSchedule *)insertScheduleIntoCoreDataFromObject:(NSDictionary *)objectData withApiCmd:(ApiCmd*)apiCmd withaMovie:(MMovie *)aMovie andaCinema:(MCinema *)aCinema timedistance:(NSString *)timedistance;
- (NSArray *)deleteUnavailableSchedules:(NSArray *)aArray;

//购买信息
- (ApiCmd *)getBuyInfoFromWebWithaMovie:(MMovie *)aMovie aCinema:(MCinema *)aCinema aSchedule:(NSString *)aSchedule delegate:(id<ApiNotify>)delegate;

- (MBuyTicketInfo *)getBuyInfoFromCoreDataWithCinema:(MCinema *)aCinema;

- (void)insertBuyInfoIntoCoreDataFromObject:(NSDictionary *)objectData withApiCmd:(ApiCmd*)apiCmd withaMovie:(MMovie *)aMovie andaCinema:(MCinema *)aCinema aSchedule:(NSString *)aSchedule;

/************************ 影院 ***************************************/
/********************************************************************/
- (ApiCmd *)getAllCinemasListFromWeb:(id<ApiNotify>)delegate;
- (NSArray *)getAllCinemasListFromCoreData;
- (NSArray *)getAllCinemasListFromCoreDataWithCityName:(NSString *)cityName;
- (BOOL)getNearbyCinemasListFromCoreDataWithCallBack:(GetCinemaNearbyList)callback;

//获取 分页 影院数据
- (ApiCmd *)getCinemasListFromWeb:(id<ApiNotify>)delegate offset:(int)offset limit:(int)limit dataType:(NSString *)dataType isNewData:(BOOL)isNewData;
- (NSArray *)getCinemasListFromCoreDataOffset:(int)offset limit:(int)limit dataType:(NSString *)dataType validDate:(NSString *)validDate;
- (NSArray *)getCinemasListFromCoreDataWithCityName:(NSString *)cityId offset:(int)offset limit:(int)limit dataType:(NSString *)dataType validDate:(NSString *)validDate;

//获取 搜索 影院列表
- (ApiCmd *)getCinemasSearchListFromWeb:(id<ApiNotify>)delegate offset:(int)offset limit:(int)limit dataType:(NSString *)dataType searchString:(NSString *)searchString;

//影院附近分页
- (ApiCmd *)getNearbyCinemaListFromCoreDataDelegate:(id<ApiNotify>)delegate Latitude:(CLLocationDegrees)latitude longitude:(CLLocationDegrees)longitude offset:(int)offset limit:(int)limit dataType:(NSString *)dataType isNewData:(BOOL)isNewData;
//影院收藏分页
- (NSArray *)getFavoriteCinemasListFromCoreData;
- (NSArray *)getFavoriteCinemasListFromCoreDataWithCityName:(NSString *)cityName;

//影院数量
- (NSUInteger)getCountOfCinemasListFromCoreData;
- (NSUInteger)getCountOfCinemasListFromCoreDataWithCityName:(NSString *)cityName;

//插入数据库
- (NSArray *)insertCinemasIntoCoreDataFromObject:(NSDictionary *)objectData withApiCmd:(ApiCmd*)apiCmd;
//将搜索和附近的数据插入到数据库里
- (NSMutableArray *)insertTemporaryCinemasIntoCoreDataFromObject:(NSDictionary *)objectData withApiCmd:(ApiCmd*)apiCmd;

- (void)importCinema:(MCinema *)mCinema ValuesForKeysWithObject:(NSDictionary *)aCinemaData;
- (void)importDynamicMovie:(MMovie *)mMovie ValuesForKeysWithObject:(NSDictionary *)amovieData;

//影院折扣
- (ApiCmd *)getCinemaDiscountFromWebDelegate:(id<ApiNotify>)delegate cinema:(MCinema *)aCinema;
- (MBuyTicketInfo *)getCinemaDiscountFromCoreData:(MCinema *)aCinema;
- (MBuyTicketInfo *)insertCinemaDiscountIntoCoreData:(NSDictionary *)objectData cinema:(MCinema *)aCinema withApiCmd:(ApiCmd*)apiCmd;

- (BOOL)addFavoriteCinemaWithId:(NSString *)uid;
- (BOOL)deleteFavoriteCinemaWithId:(NSString *)uid;
- (BOOL)isFavoriteCinemaWithId:(NSString *)uid;
- (NSArray *)getRegionOrder;

/************************ 演出 *********************************/
/***************************************************************/
- (ApiCmd *)getAllShowsListFromWeb:(id<ApiNotify>)delegate;
- (NSArray *)getAllShowsListFromCoreData;
- (NSArray *)getAllShowsListFromCoreDataWithCityName:(NSString *)cityName;
- (NSUInteger)getCountOfShowsListFromCoreData;
- (NSUInteger)getCountOfShowsListFromCoreDataWithCityName:(NSString *)cityName;


//分页 演出
- (ApiCmd *)getShowsListFromWeb:(id<ApiNotify>)delegate
                         offset:(int)offset
                          limit:(int)limit
                       Latitude:(CLLocationDegrees)latitude
                      longitude:(CLLocationDegrees)longitude
                       dataType:(NSString *)dataType
                       dataOrder:(NSString *)dataOrder
                       dataTimedistance:(NSString *)dataTimedistance
                       dataSort:(NSString *)dataSort
                      isNewData:(BOOL)isNewData;

//插入数据
- (NSArray *)insertShowsIntoCoreDataFromObject:(NSDictionary *)objectData withApiCmd:(ApiCmd*)apiCmd;
- (void)importShow:(SShow *)sShow ValuesForKeysWithObject:(NSDictionary *)ashowDic;

//读数据
- (NSArray *)getShowsListFromCoreDataWithCityName:(NSString *)cityId
                                           offset:(int)offset
                                            limit:(int)limit
                                         Latitude:(CLLocationDegrees)latitude
                                        longitude:(CLLocationDegrees)longitude
                                         dataType:(NSString *)dataType
                                        dataOrder:(NSString *)dataOrder
                                 dataTimedistance:(NSString *)dataTimedistance
                                         dataSort:(NSString *)dataSort
                                        validDate:(NSString *)validDate;

//获取 演出详情
- (ApiCmd *)getShowDetailFromWeb:(id<ApiNotify>)delegate showId:(NSString *)showId;
- (SShowDetail *)insertShowDetailIntoCoreDataFromObject:(NSDictionary *)objectData withApiCmd:(ApiCmd*)apiCmd;
- (SShowDetail *)insertShowDetailRecommendOrLookCountIntoCoreDataFromObject:(NSDictionary *)objectData withApiCmd:(ApiCmd*)apiCmd;
- (SShowDetail *)getShowDetailFromCoreDataWithId:(NSString *)showId;
/************************ 酒吧 *********************************/
/***************************************************************/
//分页 时间和人气 酒吧
- (ApiCmd *)getBarsListFromWeb:(id<ApiNotify>)delegate
                        offset:(int)offset
                         limit:(int)limit
                      Latitude:(CLLocationDegrees)latitude
                     longitude:(CLLocationDegrees)longitude
                      dataType:(NSString *)dataType
                     isNewData:(BOOL)isNewData;

//附近 酒吧
- (ApiCmd *)getBarsNearByListFromWeb:(id<ApiNotify>)delegate
                              offset:(int)offset
                               limit:(int)limit
                            Latitude:(CLLocationDegrees)latitude
                           longitude:(CLLocationDegrees)longitude
                            dataType:(NSString *)dataType
                           isNewData:(BOOL)isNewData;

//从数据库里获取酒吧数据
- (NSArray *)getBarsListFromCoreDataOffset:(int)offset
                                     limit:(int)limit
                                  Latitude:(CLLocationDegrees)latitude
                                 longitude:(CLLocationDegrees)longitude
                                  dataType:(NSString *)dataType
                                 validDate:(NSString *)validDate;
//从数据库里获取酒吧数据
- (NSArray *)getBarsListFromCoreDataWithCityName:(NSString *)cityId
                                          offset:(int)offset
                                           limit:(int)limit
                                        Latitude:(CLLocationDegrees)latitude
                                       longitude:(CLLocationDegrees)longitude
                                        dataType:(NSString *)dataType
                                       validDate:(NSString *)validDate;

//向数据库里插入数据
- (NSMutableArray *)insertBarsIntoCoreDataFromObject:(NSDictionary *)objectData withApiCmd:(ApiCmd*)apiCmd;
- (void)importBar:(BBar *)bBar ValuesForKeysWithObject:(NSDictionary *)aBarDic;
//插入推荐
- (BBarDetail *)insertBarRecommendIntoCoreDataFromObject:(NSDictionary *)objectData withApiCmd:(ApiCmd*)apiCmd;

//获取酒吧详情
- (ApiCmd *)getBarDetailFromWeb:(id<ApiNotify>)delegate barId:(NSString *)eventid;
- (BBarDetail *)getBarDetailWithId:(NSString *)barId;

- (BBarDetail *)insertBarDetailIntoCoreDataFromObject:(NSDictionary *)objectData withApiCmd:(ApiCmd*)apiCmd;
- (void)importBarDetail:(BBarDetail *)bBar ValuesForKeysWithObject:(NSDictionary *)aBarDic;

- (ApiCmd *)getAllBarsListFromWeb:(id<ApiNotify>)delegate;
- (NSArray *)getAllBarsListFromCoreData;
- (NSArray *)getAllBarsListFromCoreDataWithCityName:(NSString *)cityName;

- (NSUInteger)getCountOfBarsListFromCoreData;
- (NSUInteger)getCountOfBarsListFromCoreDataWithCityName:(NSString *)cityName;

/************************ KTV *********************************/
/***************************************************************/
//获取 全部 KTV数据
- (ApiCmd *)getAllKTVsListFromWeb:(id<ApiNotify>)delegate;
- (NSArray *)getAllKTVsListFromCoreData;
- (NSArray *)getAllKTVsListFromCoreDataWithCityName:(NSString *)cityId;

//获取 分页 KTV数据
- (ApiCmd *)getKTVsListFromWeb:(id<ApiNotify>)delegate
                        offset:(int)offset
                         limit:(int)limit
                      dataType:(NSString *)dataType
                     isNewData:(BOOL)isNewData;

//数据库获取KTV
- (NSArray *)getKTVsListFromCoreDataOffset:(int)offset
                                     limit:(int)limit
                                  dataType:(NSString *)dataType
                                 validDate:(NSString *)validDate;
//数据库获取KTV
- (NSArray *)getKTVsListFromCoreDataWithCityName:(NSString *)cityId
                                          offset:(int)offset
                                           limit:(int)limit
                                        dataType:(NSString *)dataType
                                       validDate:(NSString *)validDate;


//获取 搜索 TKV列表
- (ApiCmd *)getKTVsSearchListFromWeb:(id<ApiNotify>)delegate
                              offset:(int)offset
                               limit:(int)limit
                            dataType:(NSString *)dataType
                        searchString:(NSString *)searchString;

//KTV附近分页
- (BOOL)getNearbyKTVListFromCoreDataWithCallBack:(GetKTVNearbyList)callback;
- (ApiCmd *)getNearbyKTVListFromCoreDataWithCallBack:(id<ApiNotify>)delegate
                                            Latitude:(CLLocationDegrees)latitude
                                           longitude:(CLLocationDegrees)longitude
                                              offset:(int)offset
                                               limit:(int)limit
                                            dataType:(NSString *)dataType
                                           isNewData:(BOOL)isNewData;
//KTV收藏分页
- (NSArray *)getFavoriteKTVListFromCoreData;
- (NSArray *)getFavoriteKTVListFromCoreDataWithCityName:(NSString *)cityName;

- (NSUInteger)getCountOfKTVsListFromCoreData;
- (NSUInteger)getCountOfKTVsListFromCoreDataWithCityName:(NSString *)cityName;

//KTV 插入 数据库
- (NSArray *)insertKTVsIntoCoreDataFromObject:(NSDictionary *)objectData withApiCmd:(ApiCmd*)apiCmd;
//KTV 搜索和附近 结果数据 插入 数据库
- (NSArray *)insertTemporaryKTVsIntoCoreDataFromObject:(NSDictionary *)objectData withApiCmd:(ApiCmd*)apiCmd;

- (void)importKTV:(KKTV *)kKTV ValuesForKeysWithObject:(NSDictionary *)aKTVDic;
- (BOOL)addFavoriteKTVWithId:(NSString *)uid;
- (BOOL)deleteFavoriteKTVWithId:(NSString *)uid;
- (BOOL)isFavoriteKTVWithId:(NSString *)uid;

//获得KTV 团购列表 KTV Info
- (ApiCmd *)getKTVTuanGouListFromWebWithaKTV:(KKTV *)aKTV
                                    delegate:(id<ApiNotify>)delegate;
- (KKTVBuyInfo *)getKTVBuyInfoFromCoreDataWithId:(NSString *)ktvId;
- (void)insertKTVTuanGouListIntoCoreDataFromObject:(NSDictionary *)objectData
                                        withApiCmd:(ApiCmd*)apiCmd
                                          withaKTV:(KKTV *)aKTV;

//获得KTV 价格列表 Info
- (ApiCmd *)getKTVPriceListFromWebWithaKTV:(KKTV *)aKTV
                                  delegate:(id<ApiNotify>)delegate;
- (KKTVPriceInfo *)getKTVPriceInfoFromCoreDataWithId:(NSString *)ktvId;
- (KKTVPriceInfo *)insertKTVPriceListIntoCoreDataFromObject:(NSDictionary *)objectData
                                                 withApiCmd:(ApiCmd*)apiCmd
                                                   withaKTV:(KKTV *)aKTV;



/******************************** 喜欢和想看 *************************************/
/*******************************************************************************/
/**
 推荐和想看接口
 @param apiType api 类型
 @param cType 是推荐还是想看
 @param delegate 代理
 */
- (BOOL)getRecommendOrLookForWeb:(NSString *)objectID
                         APIType:(WSLRecommendAPIType)apiType
                           cType:(WSLRecommendLookType)cType
                        delegate:(id<ApiNotify>)delegate;

- (BOOL)isSelectedLike:(NSString *)uid withType:(NSString *)type; //判断是否赞
- (BOOL)isSelectedWantLook:(NSString *)uid withType:(NSString *)type; //判断是否想看
- (BOOL)addActionState:(NSDictionary *)dataDic; //添加赞和想看数据
/*****************************************/

//    returnArray = (NSMutableArray *)[returnArray sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
//        NSString *first =  [(MMovie*)a name];
//        NSString *second = [(MMovie*)b name];
//        return [first compare:second];
//    }];
@end
