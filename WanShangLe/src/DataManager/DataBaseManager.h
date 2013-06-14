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

@class ApiCmdMovie_getAllMovies,ApiCmdMovie_getAllCinemas;
@class ApiCmdMovie_getSchedule;
@class City;
@class MMovie,MCinema;
@class MMovie_City;
@class MMovie_Cinema;
@class MSchedule;
@class ApiCmd;

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
                                 andaCinema:(MCinema *)aCinema;

/************ 影院 ***************/
- (ApiCmdMovie_getAllCinemas *)getAllCinemasListFromWeb:(id<ApiNotify>)delegate;
- (NSArray *)getAllCinemasListFromCoreData;
- (NSArray *)getAllCinemasListFromCoreDataWithCityName:(NSString *)cityName;
- (NSUInteger)getCountOfCinemasListFromCoreData;
- (NSUInteger)getCountOfCinemasListFromCoreDataWithCityName:(NSString *)cityName;
- (void)insertCinemasIntoCoreDataFromObject:(NSDictionary *)objectData withApiCmd:(ApiCmd*)apiCmd;
- (void)importCinema:(MCinema *)mCinema ValuesForKeysWithObject:(NSDictionary *)aCinemaData;

@end
