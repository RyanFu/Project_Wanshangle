//
//  DataBaseManager.h
//  WanShangLe
//
//  Created by stephenliu on 13-6-6.
//  Copyright (c) 2013年 stephenliu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ApiNotify.h"

/**
	数据库管理类
	@author stephenliu
 */
@class City;
@class ApiCmd;
@class ApiCmdMovie_getAllMovies,ApiCmdMovie_getAllCinemas;
@class ApiCmdMovie_getSchedule,ApiCmdMovie_getBuyInfo;
@class ApiCmdShow_getAllShows,ApiCmdBar_getAllBars;
@class MMovie_City,MSchedule,MMovie_Cinema,MMovie,MCinema;
@class SShow,BBar;

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

/************ 关联表 ***************/
- (MMovie_City *)getFirstMMovie_CityFromCoreData:(NSString *)u_id;
- (MMovie_City *)insertMMovie_CityWithMovie:(MMovie *)a_movie andCity:(City *)a_city;
- (void)insertMMovie_CinemaWithMovies:(NSArray *)movies andCinemas:(NSArray *)cinemas;
- (void)insertMMovie_CinemaWithaMovie:(MMovie *)aMovie andaCinema:(MCinema *)aCinema;

/************ 城市 ***************/
- (void)insertAllCitysIntoCoreData;
- (City *)getNowUserCityFromCoreData;
- (City *)getNowUserCityFromCoreDataWithName:(NSString *)name;

/************ 电影 ***************/
- (ApiCmdMovie_getAllMovies *)getAllMoviesListFromWeb:(id<ApiNotify>)delegate;
- (NSArray *)getAllMoviesListFromCoreData;
- (NSArray *)getAllMoviesListFromCoreDataWithCityName:(NSString *)cityName;
- (NSUInteger)getCountOfMoviesListFromCoreData;
- (NSUInteger)getCountOfMoviesListFromCoreDataWithCityName:(NSString *)cityName;
- (void)insertMoviesIntoCoreDataFromObject:(NSDictionary *)objectData withApiCmd:(ApiCmd*)apiCmd;
- (void)importMovie:(MMovie *)mMovie ValuesForKeysWithObject:(NSDictionary *)amovieData;

//获得排期
- (ApiCmdMovie_getSchedule *)getScheduleFromWebWithaMovie:(MMovie *)aMovie andaCinema:(MCinema *)aCinema delegate:(id<ApiNotify>)delegate;
- (NSArray *)getScheduleFromCoreDataWithaMovie:(MMovie *)aMovie andaCinema:(MCinema *)aCinema isToday:(BOOL)isToday;
- (void)insertScheduleIntoCoreDataFromObject:(NSDictionary *)objectData withApiCmd:(ApiCmd*)apiCmd withaMovie:(MMovie *)aMovie andaCinema:(MCinema *)aCinema;

//购买信息
- (ApiCmdMovie_getBuyInfo *)getBuyInfoFromWebWithaMovie:(MMovie *)aMovie
                                               aCinema:(MCinema *)aCinema
                                                aSchedule:(NSString *)aSchedule
                                                 delegate:(id<ApiNotify>)delegate;
- (void)insertBuyInfoIntoCoreDataFromObject:(NSDictionary *)objectData
                                 withApiCmd:(ApiCmd*)apiCmd
                                 withaMovie:(MMovie *)aMovie
                                 andaCinema:(MCinema *)aCinema
                                 aSchedule:(NSString *)aSchedule;

/************ 影院 ***************/
- (ApiCmdMovie_getAllCinemas *)getAllCinemasListFromWeb:(id<ApiNotify>)delegate;
- (NSArray *)getAllCinemasListFromCoreData;
- (NSArray *)getAllCinemasListFromCoreDataWithCityName:(NSString *)cityName;
- (NSUInteger)getCountOfCinemasListFromCoreData;
- (NSUInteger)getCountOfCinemasListFromCoreDataWithCityName:(NSString *)cityName;
- (void)insertCinemasIntoCoreDataFromObject:(NSDictionary *)objectData withApiCmd:(ApiCmd*)apiCmd;
- (void)importCinema:(MCinema *)mCinema ValuesForKeysWithObject:(NSDictionary *)aCinemaData;

/************ 演出 ***************/
- (ApiCmdShow_getAllShows *)getAllShowsListFromWeb:(id<ApiNotify>)delegate;
- (NSArray *)getAllShowsListFromCoreData;
- (NSArray *)getAllShowsListFromCoreDataWithCityName:(NSString *)cityName;
- (NSUInteger)getCountOfShowsListFromCoreData;
- (NSUInteger)getCountOfShowsListFromCoreDataWithCityName:(NSString *)cityName;
- (void)insertShowsIntoCoreDataFromObject:(NSDictionary *)objectData withApiCmd:(ApiCmd*)apiCmd;
- (void)importShow:(SShow *)sShow ValuesForKeysWithObject:(NSDictionary *)ashowDic;

/************ 酒吧 ***************/
- (ApiCmdBar_getAllBars *)getAllBarsListFromWeb:(id<ApiNotify>)delegate;
- (NSArray *)getAllBarsListFromCoreData;
- (NSArray *)getAllBarsListFromCoreDataWithCityName:(NSString *)cityName;
- (NSUInteger)getCountOfBarsListFromCoreData;
- (NSUInteger)getCountOfBarsListFromCoreDataWithCityName:(NSString *)cityName;
- (void)insertBarsIntoCoreDataFromObject:(NSDictionary *)objectData withApiCmd:(ApiCmd*)apiCmd;
- (void)importBar:(BBar *)bBar ValuesForKeysWithObject:(NSDictionary *)aBarDic;
@end
