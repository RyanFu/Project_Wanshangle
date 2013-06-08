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
@class City;
@class MMovie,MCinema;
@class MMovie_City;
@class MMovie_Cinema;

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

/************ 关联表 ***************/
- (MMovie_City *)getFirstMMovie_CityFromCoreData:(NSString *)u_id;
- (MMovie_City *)insertMMovie_CityWithMovie:(MMovie *)a_movie andCity:(City *)a_city;

/************ 城市 ***************/
- (void)insertAllCitysIntoCoreData;
- (City *)getNowUserCityFromCoreData;

/************ 电影 ***************/
- (ApiCmdMovie_getAllMovies *)getAllMoviesListFromWeb:(id<ApiNotify>)delegate;
- (NSArray *)getAllMoviesListFromCoreData;
- (void)insertMoviesIntoCoreDataFromObject:(NSDictionary *)objectData;
- (void)importMovie:(MMovie *)mMovie ValuesForKeysWithObject:(NSDictionary *)amovieData;

/************ 影院 ***************/
- (ApiCmdMovie_getAllCinemas *)getAllCinemasListFromWeb:(id<ApiNotify>)delegate;
- (NSArray *)getAllCinemasListFromCoreData;
- (void)insertCinemasIntoCoreDataFromObject:(NSDictionary *)objectData;
- (void)importCinema:(MCinema *)mCinema ValuesForKeysWithObject:(NSDictionary *)aCinemaData;

@end
