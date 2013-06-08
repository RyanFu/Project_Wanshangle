//
//  DataBaseManager.m
//  WanShangLe
//
//  Created by stephenliu on 13-6-6.
//  Copyright (c) 2013年 stephenliu. All rights reserved.
//

#import "DataBaseManager.h"
#import "ApiCmdMovie_getAllMovies.h"
#import "MMovie.h"
#import "City.h"
#import "MMovie_City.h"

static DataBaseManager *_sharedInstance = nil;

@interface DataBaseManager(){
   NSString *updateTimeStamp;
}

@end

@implementation DataBaseManager

+ (instancetype)sharedInstance {
    
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        _sharedInstance = [[self alloc] init];
    });
    
    return _sharedInstance;
}

-(id)init{
    self = [super init];
    if (self) {
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        //formatter.dateFormat = @"yyyy-MM-dd HH:mm:ss ZZZ";
        formatter.dateFormat = @"yyyyMMdd";
        formatter.timeZone = [NSTimeZone localTimeZone];
        formatter.locale = [NSLocale currentLocale];
        updateTimeStamp = [[formatter stringFromDate:[NSDate date]] retain];
        ABLoggerInfo(@"today time stamp is ===== %@",updateTimeStamp);
        [formatter release];
    }
    return self;
}

+ (void)destroySharedInstance {
    
    [_sharedInstance release];
    _sharedInstance = nil;
}

- (unsigned long long int)folderSize:(NSString *)folderPath {
    NSArray *filesArray = [[NSFileManager defaultManager] subpathsOfDirectoryAtPath:folderPath error:nil];
    NSEnumerator *filesEnumerator = [filesArray objectEnumerator];
    NSString *fileName;
    unsigned long long int fileSize = 0;
    
    while (fileName = [filesEnumerator nextObject]) {
        NSDictionary *fileDictionary = [[NSFileManager defaultManager] attributesOfItemAtPath:[folderPath stringByAppendingPathComponent:fileName] error:nil];
        fileSize += [fileDictionary fileSize];
    }
    
    ABLoggerInfo(@"DataBase 数据库大小 ========= %f M",(fileSize/1024.0/1024.0));
    return fileSize;
}

#pragma mark -
#pragma mark 更新标记-时间戳
- (BOOL)isToday:(NSString *)timeStamp{
    
    if (isEmpty(timeStamp)) {
        return NO;
    }
    
    return [[self getTodayTimeStamp] intValue]==[timeStamp intValue];
}

- (NSString *)getTodayTimeStamp{

    return updateTimeStamp;
}

#pragma mark -
#pragma mark 关联表
/************ 关联表 ***************/
- (MMovie_City *)getFirstMMovie_CityFromCoreData:(NSString *)u_id;
{
    MMovie_City *mMovie_city = nil;
    mMovie_city = [MMovie_City MR_findFirstByAttribute:@"uid" withValue:u_id inContext:[NSManagedObjectContext MR_contextForCurrentThread]];
    
    return mMovie_city;
}

- (MMovie_City *)insertMMovie_CityWithMovie:(MMovie *)a_movie andCity:(City *)a_city{
    
    MMovie_City *mMovie_city = nil;
    
    ABLoggerInfo(@"插入 电影_城市 关联表 新数据 =======");
    mMovie_city = [MMovie_City MR_createInContext:[NSManagedObjectContext MR_contextForCurrentThread]];
    mMovie_city.uid = [NSString stringWithFormat:@"%@%d",[a_city name],[a_movie.uid intValue]];
    mMovie_city.city = a_city;
    mMovie_city.movie = a_movie;
    
    return mMovie_city;
}
//=========== 关联表 ===============/

#pragma mark -
#pragma mark 城市
/****************************************** 城市 *********************************************/

- (void)insertAllCitysIntoCoreData{
    
    NSString *cityPath = [[NSBundle mainBundle] pathForResource:@"city" ofType:@"json"];
    NSData *cityData = [NSData dataWithContentsOfFile:cityPath];
    NSDictionary *cityDic = [NSJSONSerialization JSONObjectWithData:cityData options:kNilOptions error:nil];
    NSArray *array = [cityDic objectForKey:@"citys"];
    
    City *city = nil;
    for (int i=0; i<[array count]; i++) {
        
        city = [City MR_findFirstByAttribute:@"uid" withValue:[[array objectAtIndex:i] objectForKey:@"id"] inContext:[NSManagedObjectContext MR_contextForCurrentThread]];
        if (city == nil)
        {
            ABLoggerInfo(@"插入 城市 新数据 ======= %@",[[array objectAtIndex:i] objectForKey:@"name"]);
            city = [City MR_createInContext:[NSManagedObjectContext MR_contextForCurrentThread]];
            city.name = [[array objectAtIndex:i] objectForKey:@"name"];
            city.uid = [[array objectAtIndex:i] objectForKey:@"id"];
        }
    }
    
    [[NSManagedObjectContext MR_contextForCurrentThread] MR_saveToPersistentStoreWithCompletion:^(BOOL success, NSError *error) {
        ABLoggerDebug(@"城市保存是否成功 ========= %d",success);
        ABLoggerDebug(@"错误信息 ========= %@",[error description]);
    }];
    
}

- (City *)getNowUserCityFromCoreData
{
    City *city = nil;
    NSString *name = [[LocationManager defaultLocationManager] getUserCity];
    
    if (isEmpty(name))return nil;
    
    city = [City MR_findFirstByAttribute:@"name" withValue:name inContext:[NSManagedObjectContext MR_contextForCurrentThread]];
    
    if (city == nil)
    {
        ABLoggerInfo(@"插入 城市 新数据 ======= %@",name);
        city = [City MR_createInContext:[NSManagedObjectContext MR_contextForCurrentThread]];
        city.name = name;
    }
    
    return city;
}
//========================================= 城市 =========================================/

#pragma mark -
#pragma mark 电影
/****************************************** 电影 *********************************************/
- (ApiCmdMovie_getAllMovies *)getAllMoviesListFromWeb:(id<ApiNotify>)delegate{
    ABLoggerMethod();
           
    if ([[[[CacheManager sharedInstance] mUserDefaults] objectForKey:UpdatingMoviesList] intValue]) {
        ABLoggerWarn(@"不能请求数据，因为已经请求了");
        return nil;
    }
    
    [[[CacheManager sharedInstance] mUserDefaults] setObject:@"1" forKey:UpdatingMoviesList];
    ApiClient* apiClient = [ApiClient defaultClient];
    
    ApiCmdMovie_getAllMovies* apiCmdMovie_getAllMovies = [[ApiCmdMovie_getAllMovies alloc] init];
    apiCmdMovie_getAllMovies.delegate = delegate;
    [apiClient executeApiCmdAsync:apiCmdMovie_getAllMovies];
    
    return [apiCmdMovie_getAllMovies autorelease];
}

- (NSArray *)getAllMoviesListFromCoreData
{
    return [MMovie MR_findAllInContext:[NSManagedObjectContext MR_contextForCurrentThread]];
}

/*
 创建一条数据的时候，如果在哪个managedObjectContext下创建的就得由哪个context来save，这样最终rootSaveingContext才会知道有变化才会save
 */
- (void)insertMoviesIntoCoreDataFromObject:(NSDictionary *)objectData
{
    ABLoggerMethod();
    NSArray *array = [[objectData objectForKey:@"data"] objectForKey:@"movies"];
    
    MMovie *mMovie = nil;
    for (int i=0; i<[array count]; i++) {
        
        mMovie = [MMovie MR_findFirstByAttribute:@"uid" withValue:[[array objectAtIndex:i] objectForKey:@"id"] inContext:[NSManagedObjectContext MR_contextForCurrentThread]];
        if (mMovie == nil)
        {
            ABLoggerInfo(@"插入 一条电影 新数据 ======= %@",[[array objectAtIndex:i] objectForKey:@"name"]);
            mMovie = [MMovie MR_createInContext:[NSManagedObjectContext MR_contextForCurrentThread]];
        }
        
        [self importMovie:mMovie ValuesForKeysWithObject:[array objectAtIndex:i]];
        
        City *city = [self getNowUserCityFromCoreData];
        
        MMovie_City *movie_city = nil;
        movie_city = [self getFirstMMovie_CityFromCoreData:[NSString stringWithFormat:@"%@%d",[city name],[mMovie.uid intValue]]];
        if (movie_city == nil) {
            [self insertMMovie_CityWithMovie:mMovie andCity:city];
        }
        
    }
    
    [[NSManagedObjectContext MR_contextForCurrentThread] MR_saveToPersistentStoreWithCompletion:^(BOOL success, NSError *error) {
        ABLoggerDebug(@"电影保存是否成功 ========= %d",success);
        ABLoggerDebug(@"错误信息 ========= %@",[error description]);
    }];
    
}

/***************************
 {
 "timestamp":1369275251,
 "errors":[],
 "data":{
 "count":20,
 "movies":[
 {
 "id":101,
 "name":"钢铁侠三",
 "rating":7.8,
 "ratingFrom":"豆瓣",
 "ratingpeople":120000,
 "webImg":"http://img31.mtime.cn/mt/2013/05/03/124825.16945557.jpg",
 "newMovie":0,
 "aword":"一个世纪英雄再次拯救我们",
 "viewtypes":[0,1,1]
 },
 ***/
- (void)importMovie:(MMovie *)mMovie ValuesForKeysWithObject:(NSDictionary *)amovieData
{
    ABLoggerMethod();
    mMovie.uid = [amovieData objectForKey:@"id"];
    mMovie.name = [amovieData objectForKey:@"name"];
    mMovie.rating = [amovieData objectForKey:@"rating"];
    mMovie.ratingFrom = [amovieData objectForKey:@"ratingFrom"];
    mMovie.ratingpeople = [amovieData objectForKey:@"ratingpeople"];
    mMovie.webImg = [amovieData objectForKey:@"webImg"];
    mMovie.newMovie = [amovieData objectForKey:@"newMovie"];
    mMovie.aword = [amovieData objectForKey:@"aword"];
    mMovie.twoD = [[amovieData objectForKey:@"viewtypes"] objectAtIndex:0];
    mMovie.threeD = [[amovieData objectForKey:@"viewtypes"] objectAtIndex:1];
    mMovie.iMaxD = [[amovieData objectForKey:@"viewtypes"] objectAtIndex:2];
}
//========================================= 电影 =========================================/

-(void)dealloc {
    [updateTimeStamp release];
    [super dealloc];
}

@end
