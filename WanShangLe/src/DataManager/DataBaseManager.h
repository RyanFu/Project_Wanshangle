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

typedef void (^GetCinemaNearbyList)(NSArray *cinemas);

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

- (BOOL)isToday:(NSString *)timeStamp;
- (NSString *)getTodayTimeStamp;

- (void)cleanUp;

- (void)saveInManagedObjectContext:(NSManagedObjectContext *)coreDataContext;

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

/************ 城市 ***************/
- (void)insertAllCitysIntoCoreData;
- (City *)insertCityIntoCoreDataWith:(NSString *)cityName;
- (NSString *)validateCity:(NSString *)cityName;
- (NSString *)getNowUserCityId;
- (City *)getNowUserCityFromCoreData;
- (City *)getNowUserCityFromCoreDataWithName:(NSString *)name;

/************ 电影 ***************/
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

/************ 演出 ***************/
- (ApiCmd *)getAllShowsListFromWeb:(id<ApiNotify>)delegate;
- (NSArray *)getAllShowsListFromCoreData;
- (NSArray *)getAllShowsListFromCoreDataWithCityName:(NSString *)cityName;
- (NSUInteger)getCountOfShowsListFromCoreData;
- (NSUInteger)getCountOfShowsListFromCoreDataWithCityName:(NSString *)cityName;
- (void)insertShowsIntoCoreDataFromObject:(NSDictionary *)objectData withApiCmd:(ApiCmd*)apiCmd;
- (void)importShow:(SShow *)sShow ValuesForKeysWithObject:(NSDictionary *)ashowDic;

/************ 酒吧 ***************/
- (ApiCmd *)getAllBarsListFromWeb:(id<ApiNotify>)delegate;
- (NSArray *)getAllBarsListFromCoreData;
- (NSArray *)getAllBarsListFromCoreDataWithCityName:(NSString *)cityName;
- (NSUInteger)getCountOfBarsListFromCoreData;
- (NSUInteger)getCountOfBarsListFromCoreDataWithCityName:(NSString *)cityName;
- (void)insertBarsIntoCoreDataFromObject:(NSDictionary *)objectData withApiCmd:(ApiCmd*)apiCmd;
- (void)importBar:(BBar *)bBar ValuesForKeysWithObject:(NSDictionary *)aBarDic;

/************ KTV ***************/
- (ApiCmd *)getAllKTVsListFromWeb:(id<ApiNotify>)delegate;
- (NSArray *)getAllKTVsListFromCoreData;
- (NSArray *)getAllKTVsListFromCoreDataWithCityName:(NSString *)cityName;
- (NSUInteger)getCountOfKTVsListFromCoreData;
- (NSUInteger)getCountOfKTVsListFromCoreDataWithCityName:(NSString *)cityName;
- (void)insertKTVsIntoCoreDataFromObject:(NSDictionary *)objectData withApiCmd:(ApiCmd*)apiCmd;
- (void)importKTV:(KKTV *)kKTV ValuesForKeysWithObject:(NSDictionary *)aKTVDic;
- (BOOL)addFavoriteKTVWithId:(NSNumber *)uid;
- (BOOL)deleteFavoriteKTVWithId:(NSNumber *)uid;

//获得KTV详情 KTV Detail Info
- (ApiCmd *)getDetailInfoFromWebWithaKTV:(KKTV *)aKTV
                                delegate:(id<ApiNotify>)delegate;
- (void)insertDetailInfoIntoCoreDataFromObject:(NSDictionary *)objectData
                                    withApiCmd:(ApiCmd*)apiCmd
                                      withaKTV:(KKTV *)aKTV;

//获得KTV购买信息 KTV Discounts Info
- (ApiCmd *)getDiscountInfoFromWebWithaKTV:(KKTV *)aKTV
                                  delegate:(id<ApiNotify>)delegate;
- (void)insertDiscountInfoIntoCoreDataFromObject:(NSDictionary *)objectData
                                      withApiCmd:(ApiCmd*)apiCmd
                                        withaKTV:(KKTV *)aKTV;

@end
