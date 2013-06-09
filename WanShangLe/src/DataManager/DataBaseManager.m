//
//  DataBaseManager.m
//  WanShangLe
//
//  Created by stephenliu on 13-6-6.
//  Copyright (c) 2013年 stephenliu. All rights reserved.
//

#import "DataBaseManager.h"
#import "ASIHTTPRequest.h"
#import "ApiCmdMovie_getAllMovies.h"
#import "ApiCmdMovie_getAllCinemas.h"
#import "MMovie_Cinema.h"
#import "MMovie_City.h"
#import "MMovie.h"
#import "MCinema.h"
#import "City.h"


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

-(void)dealloc {
    [updateTimeStamp release];
    [super dealloc];
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

- (void)insertMMovie_CinemaWithMovie:(NSArray *)movies andCinema:(NSArray *)cinemas
{
    
    if ([movies count]==0 || [cinemas count]==0) {
        return;
    }
    
    MMovie *aMovie = nil;
    MCinema *aCinema = nil;
    MMovie_Cinema *movie_cinema = nil;
    
    for (int i=0; i<[movies count]; i++) {
        
        aMovie = [movies objectAtIndex:i];
        
        for (int j=0; j<[cinemas count]; j++) {
            
            aCinema = [cinemas objectAtIndex:j];
            
            NSString *movie_cinema_uid = [[NSString alloc] initWithFormat:@"%@%d%d",[aCinema.city name],[aCinema.uid intValue],[aMovie.uid intValue]];
            movie_cinema = [MMovie_Cinema MR_findFirstByAttribute:@"uid" withValue:movie_cinema_uid inContext:[NSManagedObjectContext MR_contextForCurrentThread]];
            if (movie_cinema == nil) {
                ABLoggerDebug(@"插入 电影--影院 关联表-数据");
                movie_cinema = [MMovie_Cinema MR_createInContext:[NSManagedObjectContext MR_contextForCurrentThread]];
            }
            movie_cinema.uid = movie_cinema_uid;
            movie_cinema.movie = aMovie;
            movie_cinema.cinema = aCinema;
            [movie_cinema_uid release];
        }
        
    }
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
    return [self getNowUserCityFromCoreDataWithName:nil];
}

- (City *)getNowUserCityFromCoreDataWithName:(NSString *)name
{
    City *city = nil;
    if (isEmpty(name)) {
        name = [[LocationManager defaultLocationManager] getUserCity];
    }
    
    NSAssert(name !=nil, @"当前用户选择城市不能为空 NULL");
    
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
        ABLoggerWarn(@"不能请求电影列表数据，因为已经请求了");
        return nil;
    }
    
    [[[CacheManager sharedInstance] mUserDefaults] setObject:@"1" forKey:UpdatingMoviesList];
    ApiClient* apiClient = [ApiClient defaultClient];
    
    ApiCmdMovie_getAllMovies* apiCmdMovie_getAllMovies = [[ApiCmdMovie_getAllMovies alloc] init];
    apiCmdMovie_getAllMovies.delegate = delegate;
    apiCmdMovie_getAllMovies.cityName = [[LocationManager defaultLocationManager] getUserCity];
    [apiClient executeApiCmdAsync:apiCmdMovie_getAllMovies];
    [apiCmdMovie_getAllMovies.httpRequest setTag:API_MMovieCmd];
    
    //    if (已经更新过) {
    //      [delegate apiNotifyLocationResult:apiCmdMovie_getAllMovies error:nil];
    //    }
    
    return [apiCmdMovie_getAllMovies autorelease];
}

- (NSArray *)getAllMoviesListFromCoreData
{
    return [self getAllMoviesListFromCoreDataWithCityName:nil];
}

- (NSArray *)getAllMoviesListFromCoreDataWithCityName:(NSString *)cityName{
    
    if (isEmpty(cityName)) {
        cityName = [[LocationManager defaultLocationManager] getUserCity];
    }
    
    NSArray *array = [MMovie_City MR_findAllWithPredicate:[NSPredicate predicateWithFormat:@"city.name = %@", cityName] inContext:[NSManagedObjectContext MR_contextForCurrentThread]];
    
    NSMutableArray *returnArray = [NSMutableArray arrayWithCapacity:10];
    
    for (MMovie_City *movie_city in array) {
        [returnArray addObject:movie_city.movie];
    }
    
    //    returnArray = (NSMutableArray *)[returnArray sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
    //        NSString *first =  [(MMovie*)a name];
    //        NSString *second = [(MMovie*)b name];
    //        return [first compare:second];
    //    }];
    
    return returnArray;
}

- (NSUInteger)getCountOfMoviesListFromCoreData{
    return [self getCountOfCinemasListFromCoreDataWithCityName:nil];
}

- (NSUInteger)getCountOfMoviesListFromCoreDataWithCityName:(NSString *)cityName{
    
    if (isEmpty(cityName)) {
        cityName = [[LocationManager defaultLocationManager] getUserCity];
    }
    
    City *city = [City MR_findFirstByAttribute:@"name" withValue:cityName inContext:[NSManagedObjectContext MR_contextForCurrentThread]];
    
    return [[city movie_citys] count];
}


/*
 创建一条数据的时候，如果在哪个managedObjectContext下创建的就得由哪个context来save，这样最终rootSaveingContext才会知道有变化才会save
 */
- (void)insertMoviesIntoCoreDataFromObject:(NSDictionary *)objectData withApiCmd:(ApiCmd*)apiCmd
{
    
    //    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    
    CFTimeInterval time1 = Elapsed_Time;
    
    NSArray *array = [[objectData objectForKey:@"data"] objectForKey:@"movies"];
    NSMutableArray *movies = [[NSMutableArray alloc] initWithCapacity:10];
    
    MMovie *mMovie = nil;
    for (int i=0; i<[array count]; i++) {
        
        mMovie = [MMovie MR_findFirstByAttribute:@"uid" withValue:[[array objectAtIndex:i] objectForKey:@"id"] inContext:[NSManagedObjectContext MR_contextForCurrentThread]];
        if (mMovie == nil)
        {
            ABLoggerInfo(@"插入 一条电影 新数据 ======= %@",[[array objectAtIndex:i] objectForKey:@"name"]);
            mMovie = [MMovie MR_createInContext:[NSManagedObjectContext MR_contextForCurrentThread]];
        }
        [movies addObject:mMovie];
        [self importMovie:mMovie ValuesForKeysWithObject:[array objectAtIndex:i]];
        
        City *city = [self getNowUserCityFromCoreDataWithName:apiCmd.cityName];
        
        MMovie_City *movie_city = nil;
        movie_city = [self getFirstMMovie_CityFromCoreData:[NSString stringWithFormat:@"%@%d",[city name],[mMovie.uid intValue]]];
        if (movie_city == nil) {
            [self insertMMovie_CityWithMovie:mMovie andCity:city];
        }
        
    }
    
    NSArray *cinemas = [self getAllCinemasListFromCoreDataWithCityName:apiCmd.cityName];
    [self insertMMovie_CinemaWithMovie:movies andCinema:cinemas];
    
    [[NSManagedObjectContext MR_contextForCurrentThread] MR_saveToPersistentStoreWithCompletion:^(BOOL success, NSError *error) {
        ABLoggerDebug(@"电影保存是否成功 ========= %d",success);
        ABLoggerDebug(@"错误信息 ========= %@",[error description]);
    }];
    
    [movies release];
    
    CFTimeInterval time2 = Elapsed_Time;
    ElapsedTime(time2, time1);
    
    [[[ApiClient defaultClient] requestArray] removeObject:apiCmd];
    ABLoggerWarn(@"request array count === %d",[[[ApiClient defaultClient] requestArray] count]);
    
    //    });
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

#pragma mark -
#pragma mark 影院
/****************************************** 影院 *********************************************/
- (ApiCmdMovie_getAllCinemas *)getAllCinemasListFromWeb:(id<ApiNotify>)delegate
{
    ABLoggerMethod();
    
    if ([[[[CacheManager sharedInstance] mUserDefaults] objectForKey:UpdatingCinemasList] intValue]) {
        ABLoggerWarn(@"不能请求影院列表数据，因为已经请求了");
        return nil;
    }
    
    [[[CacheManager sharedInstance] mUserDefaults] setObject:@"1" forKey:UpdatingCinemasList];
    ApiClient* apiClient = [ApiClient defaultClient];
    
    ApiCmdMovie_getAllCinemas* apiCmdMovie_getAllCinemas = [[ApiCmdMovie_getAllCinemas alloc] init];
    apiCmdMovie_getAllCinemas.delegate = delegate;
    apiCmdMovie_getAllCinemas.cityName = [[LocationManager defaultLocationManager] getUserCity];
    [apiClient executeApiCmdAsync:apiCmdMovie_getAllCinemas];
    [apiCmdMovie_getAllCinemas.httpRequest setTag:API_MCinemaCmd];
    
    //    if (已经更新过) {
    //      [delegate apiNotifyLocationResult:apiCmdMovie_getAllCinemas error:nil];
    //    }
    
    
    return [apiCmdMovie_getAllCinemas autorelease];
}

- (NSArray *)getAllCinemasListFromCoreData
{
    return [self getAllCinemasListFromCoreDataWithCityName:nil];
}


- (NSArray *)getAllCinemasListFromCoreDataWithCityName:(NSString *)cityName{
    
    if (isEmpty(cityName)) {
        cityName = [[LocationManager defaultLocationManager] getUserCity];
    }
    
    return [MCinema MR_findAllSortedBy:@"name" ascending:NO withPredicate:[NSPredicate predicateWithFormat:@"city.name = %@", cityName]  inContext:[NSManagedObjectContext MR_contextForCurrentThread]];
}

- (NSUInteger)getCountOfCinemasListFromCoreData{
    return [self getCountOfCinemasListFromCoreDataWithCityName:nil];
}

- (NSUInteger)getCountOfCinemasListFromCoreDataWithCityName:(NSString *)cityName{
    
    if (isEmpty(cityName)) {
        cityName = [[LocationManager defaultLocationManager] getUserCity];
    }
    
    return [MCinema MR_countOfEntitiesWithPredicate:[NSPredicate predicateWithFormat:@"city.name = %@", cityName] inContext:[NSManagedObjectContext MR_contextForCurrentThread]];
}

- (void)insertCinemasIntoCoreDataFromObject:(NSDictionary *)objectData withApiCmd:(ApiCmd*)apiCmd
{
    //    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    
    CFTimeInterval time1 = Elapsed_Time;
    
    NSArray *info_array = [objectData objectForKey:@"info"];
    NSMutableArray *cinemas = [[NSMutableArray alloc] initWithCapacity:100];
    MCinema *mCinema = nil;
    
    for (int i=0; i<[info_array count]; i++) {
        
        NSArray *cinema_array = [[info_array objectAtIndex:i] objectForKey:@"cinemas"];
        NSString *district = [[info_array objectAtIndex:i] objectForKey:@"district"];
        
        for(int j=0; j<[cinema_array count]; j++) {
            
            NSDictionary *cinema_dic = [cinema_array objectAtIndex:j];
            
            mCinema = [MCinema MR_findFirstByAttribute:@"uid" withValue:[cinema_dic objectForKey:@"id"] inContext:[NSManagedObjectContext MR_contextForCurrentThread]];
            if (mCinema == nil)
            {
                ABLoggerInfo(@"插入 一条影院 新数据 ======= %@",[cinema_dic objectForKey:@"name"]);
                mCinema = [MCinema MR_createInContext:[NSManagedObjectContext MR_contextForCurrentThread]];
            }
            [cinemas addObject:mCinema];
            mCinema.district = district;
            mCinema.city = [self getNowUserCityFromCoreDataWithName:apiCmd.cityName];
            [self importCinema:mCinema ValuesForKeysWithObject:cinema_dic];
        }
        
    }
    
    NSArray *movies = [self getAllMoviesListFromCoreDataWithCityName:apiCmd.cityName];
    [self insertMMovie_CinemaWithMovie:movies andCinema:cinemas];
    
    [[NSManagedObjectContext MR_contextForCurrentThread] MR_saveToPersistentStoreWithCompletion:^(BOOL success, NSError *error) {
        ABLoggerDebug(@"影院保存是否成功 ========= %d",success);
        ABLoggerDebug(@"错误信息 ========= %@",[error description]);
    }];
    
    [cinemas release];
    
    CFTimeInterval time2 = Elapsed_Time;
    ElapsedTime(time2, time1);
    
    [[[ApiClient defaultClient] requestArray] removeObject:apiCmd];
    ABLoggerWarn(@"request array count === %d",[[[ApiClient defaultClient] requestArray] count]);
    
    //    });
    
}

/*
 "error":{
 },
 "timestamp":"1369275251",
 "count":10,
 "info":[
 {
 "district":"朝阳区",
 "cinemas":[
 {
 "id":10011,
 "name":"大望路电影院1",
 "addr":"大望路510号",
 "tel":13800990099,
 "longitue":34.2343,
 "latitude":57.3445
 },
 */
- (void)importCinema:(MCinema *)mCinema ValuesForKeysWithObject:(NSDictionary *)aCinemaData
{
    mCinema.uid = [aCinemaData objectForKey:@"id"];
    mCinema.name = [aCinemaData objectForKey:@"name"];
    mCinema.address = [aCinemaData objectForKey:@"addr"];
    mCinema.phoneNumber = [aCinemaData objectForKey:@"tel"];
    mCinema.longitue = [aCinemaData objectForKey:@"longitue"];
    mCinema.latitude = [aCinemaData objectForKey:@"latitude"];
}
//========================================= 影院 =========================================/

@end
