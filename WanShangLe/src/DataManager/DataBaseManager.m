//
//  DataBaseManager.m
//  WanShangLe
//
//  Created by stephenliu on 13-6-6.
//  Copyright (c) 2013年 stephenliu. All rights reserved.
//

static DataBaseManager *_sharedInstance = nil;

#import "DataBaseManager.h"
#import "POAPinyin.h"
#import "DataBase.h"


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
        
    }
    return self;
}

- (void)dealloc {
    [updateTimeStamp release];
    [super dealloc];
}

+ (void)destroySharedInstance {
    
    [_sharedInstance release];
    _sharedInstance = nil;
}

#pragma mark -
#pragma mark 函数
- (void)cleanUp{
    [[CacheManager sharedInstance] cleanUp];
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

- (unsigned long long int)CoreDataSize{
    
    NSString *applicationName = [[[NSBundle mainBundle] infoDictionary] valueForKey:(NSString *)kCFBundleNameKey];
    
    NSString *coreDataPath = [[NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:applicationName];
    ABLoggerDebug(@"coreData path = %@",coreDataPath);
    
    NSString *cachePath = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"com.hackemist.SDWebImageCache.default"];
    ABLoggerDebug(@"cachePath = %@",cachePath);
    
    return [self folderSize:coreDataPath]+[self folderSize:cachePath];
}

- (NSString*)md5PathForKey:(NSString *) key{
    
    return md5(key);
}

- (void)saveInManagedObjectContext:(NSManagedObjectContext *)coreDataContext{
    [coreDataContext MR_saveToPersistentStoreWithCompletion:^(BOOL success, NSError *error) {
        ABLoggerDebug(@"保存是否成功 ========= %d",success);
        ABLoggerDebug(@"错误信息 ========= %@",[error description]);
    }];
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
    
    if (!updateTimeStamp) {
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        //formatter.dateFormat = @"yyyy-MM-dd HH:mm:ss ZZZ";
        formatter.dateFormat = @"yyyyMMdd";
        formatter.timeZone = [NSTimeZone localTimeZone];
        formatter.locale = [NSLocale currentLocale];
        updateTimeStamp = [[formatter stringFromDate:[NSDate date]] retain];
        ABLoggerInfo(@"today time stamp is ===== %@",updateTimeStamp);
        [formatter release];
    }
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
    mMovie_city.uid = [NSString stringWithFormat:@"%@%@",[a_city name],a_movie.uid];
    mMovie_city.city = a_city;
    mMovie_city.movie = a_movie;
    
    return mMovie_city;
}

- (MMovie_Cinema *)insertMMovie_CinemaWithaMovie:(MMovie *)aMovie andaCinema:(MCinema *)aCinema{
    
    MMovie_Cinema *movie_cinema = nil;
    
    if (!aMovie || !aCinema) {
        ABLoggerWarn(@"不能 插入 电影_影院，不能为空");
        return movie_cinema;
    }
    
    NSString *movie_cinema_uid = [[NSString alloc] initWithFormat:@"%@%d%@",[aCinema.city name],[aCinema.uid intValue],aMovie.uid];
    movie_cinema = [MMovie_Cinema MR_findFirstByAttribute:@"uid" withValue:movie_cinema_uid inContext:[NSManagedObjectContext MR_contextForCurrentThread]];
    if (movie_cinema == nil) {
        movie_cinema = [MMovie_Cinema MR_createInContext:[NSManagedObjectContext MR_contextForCurrentThread]];
    }
    movie_cinema.uid = movie_cinema_uid;
    movie_cinema.movie = aMovie;
    movie_cinema.cinema = aCinema;
    [movie_cinema_uid release];
    
    return movie_cinema;
}

- (void)insertMMovie_CinemaWithMovies:(NSArray *)movies andCinemas:(NSArray *)cinemas
{
    if ([movies count]==0 || [cinemas count]==0) {
        ABLoggerWarn(@"不能 插入 电影_影院，不能为空");
        return;
    }
    
    if ([[[[CacheManager sharedInstance] mUserDefaults] objectForKey:InsertingMovie_CinemaList] intValue]) {
        ABLoggerWarn(@"不能 插入 电影_影院，因为已经请求了");
        return;
    }
    
    ABLoggerDebug(@"插入 电影--影院 关联表-数据");
    
    [[[CacheManager sharedInstance] mUserDefaults] setObject:@"1" forKey:InsertingMovie_CinemaList];
    
    MMovie *aMovie = nil;
    MCinema *aCinema = nil;
    MMovie_Cinema *movie_cinema = nil;
    
    for (int i=0; i<[movies count]; i++) {
        
        aMovie = [movies objectAtIndex:i];
        
        for (int j=0; j<[cinemas count]; j++) {
            
            aCinema = [cinemas objectAtIndex:j];
            
            NSString *movie_cinema_uid = [[NSString alloc] initWithFormat:@"%@%d%@",[aCinema.city name],[aCinema.uid intValue],aMovie.uid];
            movie_cinema = [MMovie_Cinema MR_findFirstByAttribute:@"uid" withValue:movie_cinema_uid inContext:[NSManagedObjectContext MR_contextForCurrentThread]];
            if (movie_cinema == nil) {
                movie_cinema = [MMovie_Cinema MR_createInContext:[NSManagedObjectContext MR_contextForCurrentThread]];
            }
            movie_cinema.uid = movie_cinema_uid;
            movie_cinema.movie = aMovie;
            movie_cinema.cinema = aCinema;
            [movie_cinema_uid release];
        }
        
    }
    
    [[NSManagedObjectContext MR_contextForCurrentThread] MR_saveToPersistentStoreWithCompletion:^(BOOL success, NSError *error) {
        ABLoggerDebug(@"电影-影院-关联表-保存是否成功 ========= %d",success);
        ABLoggerDebug(@"错误信息 ========= %@",[error description]);
    }];
    
    [[[CacheManager sharedInstance] mUserDefaults] setObject:@"0" forKey:InsertingMovie_CinemaList];
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

- (BOOL)insertCityIntoCoreDataWith:(NSString *)cityName{
    
    if (!cityName) {
        cityName = [[LocationManager defaultLocationManager] getUserCity];
    }
    
    City *city = nil;
    NSManagedObjectContext *context = [NSManagedObjectContext MR_contextForCurrentThread];
    
    NSString *newCityName = [self validateCity:cityName];
    if (isEmpty(newCityName)) {
        return NO;
    }
    
    city = [City MR_findFirstByAttribute:@"name" withValue:newCityName inContext:context];
    
    if (city==nil) {
         ABLoggerInfo(@"插入 城市 新数据 ======= %@",newCityName);
        city = [City MR_createInContext:context];
    }
    
    city.name = newCityName;
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:newCityName forKey:UserState];
    
    city.uid = [self getBundleCityIdWithCityName:newCityName];
    [userDefaults setObject:city.uid forKey:newCityName];
    [userDefaults synchronize];

    [self saveInManagedObjectContext:context];
  
    return YES;
}

- (NSString *)validateCity:(NSString *)cityName{
    
    NSString *city_name = [POAPinyin quickConvert:cityName];
    NSString *cityPath = [[NSBundle mainBundle] pathForResource:@"city" ofType:@"json"];
    NSData *cityData = [NSData dataWithContentsOfFile:cityPath];
    NSDictionary *cityDic = [NSJSONSerialization JSONObjectWithData:cityData options:kNilOptions error:nil];
    NSArray *array = [cityDic objectForKey:@"citys"];
    
    
    for (NSDictionary *dic in array) {
        NSString *tname = [dic objectForKey:@"name"];
        
        tname = [POAPinyin quickConvert:tname];
        if ([tname compare:city_name options:NSCaseInsensitiveSearch range:NSMakeRange(0, tname.length)] == NSOrderedSame) {
            [POAPinyin clearCache];
            return [dic objectForKey:@"name"];
        }
    }
    
    return nil;
}

- (NSString *)getBundleCityIdWithCityName:(NSString *)cityName{
    
    NSString *city_name = nil;
    if (isEmpty(cityName)) {
        cityName = [[LocationManager defaultLocationManager] getUserCity];
    }
    
    city_name = [POAPinyin quickConvert:cityName];
    NSString *cityPath = [[NSBundle mainBundle] pathForResource:@"city" ofType:@"json"];
    NSData *cityData = [NSData dataWithContentsOfFile:cityPath];
    NSDictionary *cityDic = [NSJSONSerialization JSONObjectWithData:cityData options:kNilOptions error:nil];
    NSArray *array = [cityDic objectForKey:@"citys"];
    
    for (NSDictionary *dic in array) {
        NSString *tname = [dic objectForKey:@"name"];
        
        tname = [POAPinyin quickConvert:tname];
        if ([tname compare:city_name options:NSCaseInsensitiveSearch] == NSOrderedSame) {
            return [dic objectForKey:@"id"];
        }
    }
    
    return nil;
}

- (NSString *)getNowUserCityId{
    
    City *city = [self getNowUserCityFromCoreData];
    if (city.uid) {
        return city.uid;
    }
    
    return [self getBundleCityIdWithCityName:nil];
    
    assert(0);
    return nil;
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
    
    NSManagedObjectContext *context = [NSManagedObjectContext MR_contextForCurrentThread];
    
    city = [City MR_findFirstByAttribute:@"name" withValue:name inContext:context];//中文名
    
    if (city == nil)
    {
        ABLoggerInfo(@"插入 城市 新数据 ======= %@",name);
        [self insertCityIntoCoreDataWith:name];
    }
    
    [self saveInManagedObjectContext:context];
    
    return city;
}

//========================================= 城市 =========================================/

#pragma mark -
#pragma mark 电影
/****************************************** 电影 *********************************************/
- (ApiCmd *)getAllMoviesListFromWeb:(id<ApiNotify>)delegate{
    
    ApiCmd *tapiCmd = [delegate apiGetDelegateApiCmd];
    if ([[[[ApiClient defaultClient] networkQueue] operations]containsObject:tapiCmd.httpRequest]) {
        ABLoggerWarn(@"不能请求电影列表数据，因为已经请求了");
        return tapiCmd;
    }
    
    ApiClient* apiClient = [ApiClient defaultClient];
    
    ApiCmdMovie_getAllMovies* apiCmdMovie_getAllMovies = [[ApiCmdMovie_getAllMovies alloc] init];
    apiCmdMovie_getAllMovies.delegate = delegate;
    apiCmdMovie_getAllMovies.cityName = [[LocationManager defaultLocationManager] getUserCity];
    [apiClient executeApiCmdAsync:apiCmdMovie_getAllMovies];
    [apiCmdMovie_getAllMovies.httpRequest setTag:API_MMovieCmd];
    
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
    
    CFTimeInterval time1 = Elapsed_Time;
    
    NSArray *array = [[objectData objectForKey:@"data"] objectForKey:@"movies"];
    NSArray *array_dynamic = [[objectData objectForKey:@"data"] objectForKey:@"dynamic"];
    
    MMovie *mMovie = nil;
    for (int i=0; i<[array count]; i++) {
        
        mMovie = [MMovie MR_findFirstByAttribute:@"uid" withValue:[NSNumber numberWithInt:[[[array objectAtIndex:i] objectForKey:@"id"] intValue]]  inContext:[NSManagedObjectContext MR_contextForCurrentThread]];
        if (mMovie == nil)
        {
            ABLoggerInfo(@"插入 一条 New电影 新数据 ======= %@",[[array objectAtIndex:i] objectForKey:@"name"]);
            mMovie = [MMovie MR_createInContext:[NSManagedObjectContext MR_contextForCurrentThread]];
        }
        [self importMovie:mMovie ValuesForKeysWithObject:[array objectAtIndex:i]];
        
        City *city = [self getNowUserCityFromCoreDataWithName:apiCmd.cityName];
        
        MMovie_City *movie_city = nil;
        movie_city = [self getFirstMMovie_CityFromCoreData:[NSString stringWithFormat:@"%@%@",[city name],mMovie.uid]];
        if (movie_city == nil) {
            [self insertMMovie_CityWithMovie:mMovie andCity:city];
        }
        
        [self importDynamicMovie:mMovie ValuesForKeysWithObject:[array_dynamic objectAtIndex:i]];
        
    }
    
    //    for (int i=0; i<[array_dynamic count]; i++) {
    //
    //        mMovie = [MMovie MR_findFirstByAttribute:@"uid" withValue:[NSNumber numberWithInt:[[[array_dynamic objectAtIndex:i] objectForKey:@"id"] intValue]]  inContext:[NSManagedObjectContext MR_contextForCurrentThread]];
    //        if (mMovie == nil)
    //        {
    //            ABLoggerInfo(@"插入 一条 更新动态电影 新数据 ======= %@",[[array_dynamic objectAtIndex:i] objectForKey:@"name"]);
    //            mMovie = [MMovie MR_createInContext:[NSManagedObjectContext MR_contextForCurrentThread]];
    //        }
    //        [self importDynamicMovie:mMovie ValuesForKeysWithObject:[array_dynamic objectAtIndex:i]];
    //    }
    
    //    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    //        NSArray *movies = [self getAllMoviesListFromCoreDataWithCityName:apiCmd.cityName];
    //        NSArray *cinemas = [self getAllCinemasListFromCoreDataWithCityName:apiCmd.cityName];
    //        [self insertMMovie_CinemaWithMovies:movies andCinemas:cinemas];
    //    });
    
    [[NSManagedObjectContext MR_contextForCurrentThread] MR_saveToPersistentStoreWithCompletion:^(BOOL success, NSError *error) {
        ABLoggerDebug(@"电影保存是否成功 ========= %d",success);
        ABLoggerDebug(@"错误信息 ========= %@",[error description]);
    }];
    
    CFTimeInterval time2 = Elapsed_Time;
    ElapsedTime(time2, time1);
    
    [[[ApiClient defaultClient] requestArray] removeObject:apiCmd];
    ABLoggerWarn(@"remove request array count === %d",[[[ApiClient defaultClient] requestArray] count]);
    
    //    });
}

/**
 {
 "timestamp":1369275251,
 "errors":[],
 "data":{
 "count":20,
 "movies":[
 {
 "id":101,
 "name":"钢铁侠三",
 "webImg":"http://img31.mtime.cn/mt/2013/05/03/124825.16945557.jpg",
 "aword":"一个世纪英雄再次拯救我们"
 },
 
 "dynamic":[
 {
 "id":101,
 "rating":7.8,
 "ratingFrom":"豆瓣",
 "ratingpeople":120000,
 "newMovie":0,
 "viewtypes":[0,1,1]
 },
 
 "deletions":[]
 ***/
- (void)importMovie:(MMovie *)mMovie ValuesForKeysWithObject:(NSDictionary *)amovieData
{
    ABLoggerInfo(@"amovieData == %@",amovieData);
    mMovie.uid = [amovieData objectForKey:@"id"];
    mMovie.name = [amovieData objectForKey:@"name"];
    mMovie.webImg = [amovieData objectForKey:@"coverurl"];
    mMovie.aword = [amovieData objectForKey:@"description"];
}

- (void)importDynamicMovie:(MMovie *)mMovie ValuesForKeysWithObject:(NSDictionary *)amovieData
{
    ABLoggerInfo(@"amovieData == %@",amovieData);
    mMovie.rating = [NSNumber numberWithInt:[[amovieData objectForKey:@"rating"] intValue]];
    mMovie.ratingFrom = [amovieData objectForKey:@"ratingFrom"];
    mMovie.ratingpeople = [amovieData objectForKey:@"ratingcount"];
    mMovie.newMovie = [amovieData objectForKey:@"newMovie"];
    mMovie.twoD = [NSNumber numberWithInt:[[[amovieData objectForKey:@"viewtypes"] objectAtIndex:0] intValue]];
    mMovie.threeD = [NSNumber numberWithInt:[[[amovieData objectForKey:@"viewtypes"] objectAtIndex:1] intValue]];
    mMovie.iMaxD = [NSNumber numberWithInt:[[[amovieData objectForKey:@"viewtypes"] objectAtIndex:2] intValue]];
}

- (BOOL)addFavoriteCinemaWithId:(NSNumber *)uid{
    NSManagedObjectContext* threadContext = [NSManagedObjectContext MR_contextForCurrentThread];
    MCinema *tCinema = [MCinema MR_findFirstByAttribute:@"uid" withValue:uid inContext:threadContext];
    
    if (!tCinema) {
        return NO;
    }
    
    tCinema.favorite = [NSNumber numberWithBool:YES];
    
    [threadContext MR_saveToPersistentStoreWithCompletion:^(BOOL success, NSError *error) {
        ABLoggerDebug(@"收藏影院 保存是否成功 ========= %d",success);
        ABLoggerDebug(@"错误信息 ========= %@",[error description]);
    }];
    
    return YES;
}

- (BOOL)deleteFavoriteCinemaWithId:(NSNumber *)uid{
    NSManagedObjectContext* threadContext = [NSManagedObjectContext MR_contextForCurrentThread];
    MCinema *tCinema = [MCinema MR_findFirstByAttribute:@"uid" withValue:uid inContext:threadContext];
    
    if (!tCinema) {
        return NO;
    }
    
    tCinema.favorite = [NSNumber numberWithBool:NO];
    
    [threadContext MR_saveToPersistentStoreWithCompletion:^(BOOL success, NSError *error) {
        ABLoggerDebug(@"取消收藏影院 保存是否成功 ========= %d",success);
        ABLoggerDebug(@"错误信息 ========= %@",[error description]);
    }];
    
    return YES;
}

- (NSArray *)getRegionOrder{
    
    NSError *error = nil;
    
    NSString *jsonPath = [[NSBundle mainBundle] pathForResource:[[LocationManager defaultLocationManager] getUserCity] ofType:@"json"];
    NSData *JSONData = [NSData dataWithContentsOfFile:jsonPath];
    NSDictionary *JSONObject = [NSJSONSerialization JSONObjectWithData:JSONData options:0 error:&error];
    
    ABLoggerInfo(@"JSONObject = %@",JSONObject);
    
    return [JSONObject objectForKey:@"region"];
}

#pragma mark 获取电影详情
- (ApiCmd *)getMovieDetailFromWeb:(id<ApiNotify>)delegate movieId:(NSString *)movieId{
    
    ApiCmd *tapiCmd = [delegate apiGetDelegateApiCmd];
    if ([[[[ApiClient defaultClient] networkQueue] operations]containsObject:tapiCmd.httpRequest]) {
        ABLoggerWarn(@"不能请求电影详情数据，因为已经请求了");
        return tapiCmd;
    }
    
    ApiClient* apiClient = [ApiClient defaultClient];
    
    ApiCmdMovie_getAllMovieDetail* apiCmdMovie_getAllMovieDetail = [[ApiCmdMovie_getAllMovieDetail alloc] init];
    apiCmdMovie_getAllMovieDetail.delegate = delegate;
    ABLoggerInfo(@"_mMovie.uid === %@",movieId );
    apiCmdMovie_getAllMovieDetail.movie_id = movieId;
    [apiClient executeApiCmdAsync:apiCmdMovie_getAllMovieDetail];
    [apiCmdMovie_getAllMovieDetail.httpRequest setTag:API_MMovieDetailCmd];
    
    return [apiCmdMovie_getAllMovieDetail autorelease];
}

- (BOOL)insertMovieDetailIntoCoreDataFromObject:(NSDictionary *)objectData withApiCmd:(ApiCmd*)apiCmd{
    
    if (objectData) {
        
        NSDictionary *tDic = [[objectData objectForKey:@"data"] objectForKey:@"info"];
        
        NSManagedObjectContext *context = [NSManagedObjectContext MR_contextForCurrentThread];
        NSString *movie_id = [tDic objectForKey:@"id"];
        
        MMovieDetail *tMovieDetail = nil;
        MMovie *tMovie = [MMovie MR_findFirstByAttribute:@"uid" withValue:movie_id inContext:context];
        
        if (tMovie==nil) {
            tMovie = [MMovie MR_createInContext:context];
            tMovie.uid = movie_id;
        }
        
        if (tMovie.movieDetail==nil) {
            tMovieDetail = [MMovieDetail MR_createInContext:context];
            ABLoggerInfo(@"插入 一条 电影详情 记录");
        }
        tMovie.movieDetail = tMovieDetail;
        tMovieDetail.movie = tMovie;
        [self importMovieDetail:tMovie.movieDetail ValuesForKeysWithObject:tDic];
    
        [self saveInManagedObjectContext:context];
        
        return YES;
    }
    
    return NO;
}

- (void)importMovieDetail:(MMovieDetail *)aMovieDetail ValuesForKeysWithObject:(NSDictionary *)amovieDetailData{
    aMovieDetail.wantedadded = [amovieDetailData objectForKey:@"wantedadded"];
    aMovieDetail.recommendadded = [amovieDetailData objectForKey:@"recommendadded"];
    aMovieDetail.info = amovieDetailData;
}

- (MMovieDetail *)getMovieDetailWithId:(NSNumber *)movieId{
    
    MMovieDetail *tMovieDetail = nil;
    if (movieId) {
        MMovie *tmovie = [MMovie MR_findFirstByAttribute:@"uid" withValue:movieId inContext:[NSManagedObjectContext MR_contextForCurrentThread]];
        return tmovie.movieDetail;
    }
    
    return tMovieDetail;
}

#pragma mark 获得排期
- (ApiCmdMovie_getSchedule *)getScheduleFromWebWithaMovie:(MMovie *)aMovie
                                               andaCinema:(MCinema *)aCinema
                                                 delegate:(id<ApiNotify>)delegate
{
    ABLoggerDebug(@"=== %@",[[CacheManager sharedInstance] mUserDefaults]);
    
    ApiClient* apiClient = [ApiClient defaultClient];
    
    ApiCmdMovie_getSchedule* apiCmdMovie_getSchedule = [[ApiCmdMovie_getSchedule alloc] init];
    apiCmdMovie_getSchedule.delegate = delegate;
    apiCmdMovie_getSchedule.cityName = [[LocationManager defaultLocationManager] getUserCity];
    [apiClient executeApiCmdAsync:apiCmdMovie_getSchedule];
    [apiCmdMovie_getSchedule.httpRequest setTag:API_MScheduleCmd];
    
    return [apiCmdMovie_getSchedule autorelease];
}

- (MSchedule *)getScheduleFromCoreDataWithaMovie:(MMovie *)aMovie andaCinema:(MCinema *)aCinema{
    
    MMovie_Cinema *movie_cinema = nil;
    NSString *movie_cinema_uid = [[NSString alloc] initWithFormat:@"%@%d%@",[aCinema.city name],[aCinema.uid intValue],aMovie.uid];
    movie_cinema = [MMovie_Cinema MR_findFirstByAttribute:@"uid" withValue:movie_cinema_uid inContext:[NSManagedObjectContext MR_contextForCurrentThread]];
    
    return movie_cinema.schedule;
}

/*
 {
 data =     {
 schedule =         (
 {
 cinemaId = 10011;
 count = 11;
 lowprice = 35;
 starts =                 (
 "9:20",
 "9:40",
 "10:20",
 "10:40",
 "12:20",
 "13:20",
 "13:40",
 "15:20",
 "17:20",
 "19:20",
 "21:20"
 );
 viewtypes =                 (
 1,
 0,
 0
 );
 },
 {
 cinemaId = 10011;
 count = 11;
 lowprice = 35;
 starts =                 (
 "9:20",
 "9:40",
 "10:20",
 "10:40",
 "12:20",
 "13:20",
 "13:40",
 "15:20",
 "17:20",
 "19:20",
 "21:20"
 );
 viewtypes =                 (
 1,
 0,
 0
 );
 }
 );
 };
 errors =     (
 );
 }[;
 */

- (void)insertScheduleIntoCoreDataFromObject:(NSDictionary *)objectData
                                  withApiCmd:(ApiCmd*)apiCmd
                                  withaMovie:(MMovie *)aMovie
                                  andaCinema:(MCinema *)aCinema{
    
    NSDictionary *dataDic = [objectData objectForKey:@"data"];
    
    NSString *movie_cinema_uid = [[NSString alloc] initWithFormat:@"%@%d%@",[aCinema.city name],[aCinema.uid intValue],aMovie.uid];
    MMovie_Cinema *movie_cinema = [MMovie_Cinema MR_findFirstByAttribute:@"uid" withValue:movie_cinema_uid inContext:[NSManagedObjectContext MR_contextForCurrentThread]];
    if (movie_cinema == nil) {
        MMovie *tMovie = [MMovie MR_findFirstByAttribute:@"uid" withValue:aMovie.uid inContext:[NSManagedObjectContext MR_contextForCurrentThread]];
        MCinema *tCinema = [MCinema MR_findFirstByAttribute:@"uid" withValue:aCinema.uid inContext:[NSManagedObjectContext MR_contextForCurrentThread]];
        movie_cinema = [self insertMMovie_CinemaWithaMovie:tMovie andaCinema:tCinema];
    }
    
    if (!movie_cinema.schedule) {
        movie_cinema.schedule = [MSchedule MR_createInContext:[NSManagedObjectContext MR_contextForCurrentThread]];
    }
    
    movie_cinema.schedule.scheduleInfo = dataDic;
    
    [[NSManagedObjectContext MR_contextForCurrentThread] MR_saveToPersistentStoreWithCompletion:^(BOOL success, NSError *error) {
        ABLoggerDebug(@"排期 保存是否成功 ========= %d",success);
        ABLoggerDebug(@"错误信息 ========= %@",[error description]);
    }];
    
    [movie_cinema_uid release];
}

#pragma mark 购买信息
- (ApiCmdMovie_getBuyInfo *)getBuyInfoFromWebWithaMovie:(MMovie *)aMovie
                                                aCinema:(MCinema *)aCinema
                                              aSchedule:(NSString *)aSchedule
                                               delegate:(id<ApiNotify>)delegate
{
    ABLoggerDebug(@"=== %@",[[CacheManager sharedInstance] mUserDefaults]);
    
    ApiClient* apiClient = [ApiClient defaultClient];
    
    ApiCmdMovie_getBuyInfo* apiCmdMovie_getBuyInfo = [[ApiCmdMovie_getBuyInfo alloc] init];
    apiCmdMovie_getBuyInfo.delegate = delegate;
    apiCmdMovie_getBuyInfo.cityName = [[LocationManager defaultLocationManager] getUserCity];
    [apiClient executeApiCmdAsync:apiCmdMovie_getBuyInfo];
    [apiCmdMovie_getBuyInfo.httpRequest setTag:API_MBuyInfoCmd];
    
    return [apiCmdMovie_getBuyInfo autorelease];
}

/*
 {
 "errors":[],
 "data":{
 "count":6,
 "vendors":[
 {
 "vendorId":"100001",
 "name":"美团",
 "price":30,
 "channel":[1,0,0],
 "img":"http://xxxxxx.jpg",
 "url":"http://www.meituan.com/",
 "clicks":2321,
 "intro":"使用规则"
 },
 */
- (void)insertBuyInfoIntoCoreDataFromObject:(NSDictionary *)objectData
                                 withApiCmd:(ApiCmd*)apiCmd
                                 withaMovie:(MMovie *)aMovie
                                 andaCinema:(MCinema *)aCinema
                                  aSchedule:(NSString *)aSchedule{
    
    NSDictionary *dataDic = [objectData objectForKey:@"data"];
    
    NSString *keyPath = [[NSString alloc] initWithFormat:@"%d%@%@",[aCinema.uid intValue],aMovie.uid,aSchedule];
    NSString *movie_cinema_schedule_uid = [self md5PathForKey:keyPath];
    [keyPath release];
    
    MBuyTicketInfo *buyInfo = [MBuyTicketInfo MR_findFirstByAttribute:@"uid" withValue:movie_cinema_schedule_uid inContext:[NSManagedObjectContext MR_contextForCurrentThread]];
    if (buyInfo == nil) {
        buyInfo = [MBuyTicketInfo MR_createInContext:[NSManagedObjectContext MR_contextForCurrentThread]];
    }
    
    buyInfo.uid = movie_cinema_schedule_uid;
    buyInfo.groupBuyInfo = dataDic;
    
    [[NSManagedObjectContext MR_contextForCurrentThread] MR_saveToPersistentStoreWithCompletion:^(BOOL success, NSError *error) {
        ABLoggerDebug(@"排期 保存是否成功 ========= %d",success);
        ABLoggerDebug(@"错误信息 ========= %@",[error description]);
    }];
}
//========================================= 电影 =========================================/

#pragma mark -
#pragma mark 影院
/****************************************** 影院 *********************************************/
- (ApiCmd *)getAllCinemasListFromWeb:(id<ApiNotify>)delegate
{
    
    ApiCmd *tapiCmd = [delegate apiGetDelegateApiCmd];
    
    if ([[[[ApiClient defaultClient] networkQueue] operations] containsObject:tapiCmd.httpRequest]) {
        ABLoggerWarn(@"不能请求影院列表数据，因为已经请求了");
        return tapiCmd;
    }
    
    ABLoggerWarn(@"tapiCmd.httpRequest ====== %@",tapiCmd.httpRequest);
    ABLoggerWarn(@"networkQueue ====== %@",[[[ApiClient defaultClient] networkQueue] operations]);
    
    ApiClient* apiClient = [ApiClient defaultClient];
    
    ApiCmdMovie_getAllCinemas* apiCmdMovie_getAllCinemas = [[ApiCmdMovie_getAllCinemas alloc] init];
    apiCmdMovie_getAllCinemas.delegate = delegate;
    apiCmdMovie_getAllCinemas.cityName = [[LocationManager defaultLocationManager] getUserCity];
    
    [apiClient executeApiCmdAsync:apiCmdMovie_getAllCinemas];
    [apiCmdMovie_getAllCinemas.httpRequest setTag:API_MCinemaCmd];
    
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

- (BOOL)getNearbyCinemasListFromCoreDataWithCallBack:(GetCinemaNearbyList)callback{
    
    GetCinemaNearbyList mCallBack = [callback copy];
    
    NSArray *cinemas = [self getAllCinemasListFromCoreData];
    LocationManager *lm = [LocationManager defaultLocationManager];
    BOOL isSuccess =  [lm getUserGPSLocationWithCallBack:^(BOOL isNewLocation) {
        for (MCinema *tCinema in cinemas) {
            double distance = [lm distanceBetweenUserToLatitude:[tCinema.latitude doubleValue] longitude:[tCinema.longitue doubleValue]];
            tCinema.nearby = [NSNumber numberWithInt:distance];
        }
        
        [self saveInManagedObjectContext:[NSManagedObjectContext MR_contextForCurrentThread]];
        
        NSArray *array =  [cinemas sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
            MCinema *cinema1 = (MCinema *)obj1;
            MCinema *cinema2 = (MCinema *)obj2;
            return [cinema1.nearby compare:cinema2.nearby];
        }];
        ABLoggerInfo(@"cinemas === %@",array);
        
        if (mCallBack && isNewLocation) {
            mCallBack(array);
        }
    }];
    
    return isSuccess;
}

- (NSArray *)getFavoriteCinemasListFromCoreData{
    return [self getFavoriteCinemasListFromCoreDataWithCityName:nil];
}

- (NSArray *)getFavoriteCinemasListFromCoreDataWithCityName:(NSString *)cityName{
    if (isEmpty(cityName)) {
        cityName = [[LocationManager defaultLocationManager] getUserCity];
    }
    
    return [MCinema MR_findAllSortedBy:@"name" ascending:NO withPredicate:[NSPredicate predicateWithFormat:@"city.name = %@ and favorite = YES", cityName]  inContext:[NSManagedObjectContext MR_contextForCurrentThread]];
}

- (NSUInteger)getCountOfCinemasListFromCoreData{
    return [self getCountOfCinemasListFromCoreDataWithCityName:nil];
}

- (NSUInteger)getCountOfCinemasListFromCoreDataWithCityName:(NSString *)cityName{
    
    if (isEmpty(cityName)) {
        cityName = [[LocationManager defaultLocationManager] getUserCity];
    }
    int count = [MCinema MR_countOfEntitiesWithPredicate:[NSPredicate predicateWithFormat:@"city.name = %@", cityName] inContext:[NSManagedObjectContext MR_contextForCurrentThread]];
    return count;
}

- (void)insertCinemasIntoCoreDataFromObject:(NSDictionary *)objectData withApiCmd:(ApiCmd*)apiCmd
{
    //    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    
    CFTimeInterval time1 = Elapsed_Time;
    
    NSArray *info_array = [[objectData objectForKey:@"data"] objectForKey:@"infos"];
    //    NSMutableArray *cinemas = [[NSMutableArray alloc] initWithCapacity:100];
    MCinema *mCinema = nil;
    
    for (int i=0; i<[info_array count]; i++) {
        
        NSArray *cinema_array = [[info_array objectAtIndex:i] objectForKey:@"cinemas"];
        NSArray *dynamic_array = [[info_array objectAtIndex:i] objectForKey:@"dynamic"];
        NSString *district = [[info_array objectAtIndex:i] objectForKey:@"district"];
        
        for(int j=0; j<[cinema_array count]; j++) {
            
            NSDictionary *cinema_dic = [cinema_array objectAtIndex:j];
            
            mCinema = [MCinema MR_findFirstByAttribute:@"uid" withValue:[cinema_dic objectForKey:@"id"] inContext:[NSManagedObjectContext MR_contextForCurrentThread]];
            if (mCinema == nil)
            {
                ABLoggerInfo(@"插入 一条影院 新数据 ======= %@",[cinema_dic objectForKey:@"name"]);
                mCinema = [MCinema MR_createInContext:[NSManagedObjectContext MR_contextForCurrentThread]];
            }
            //            [cinemas addObject:mCinema];
            mCinema.district = district;
            mCinema.city = [self getNowUserCityFromCoreDataWithName:apiCmd.cityName];
            [self importCinema:mCinema ValuesForKeysWithObject:cinema_dic];
        }
        
        /*
         for(int j=0; j<[dynamic_array count]; j++) {
         
         NSDictionary *cinema_dic = [cinema_array objectAtIndex:j];
         
         mCinema = [MCinema MR_findFirstByAttribute:@"uid" withValue:[cinema_dic objectForKey:@"cinemaid"] inContext:[NSManagedObjectContext MR_contextForCurrentThread]];
         if (mCinema == nil)
         {
         ABLoggerInfo(@"插入 一条影院 新数据 ======= %@",[cinema_dic objectForKey:@"name"]);
         mCinema = [MCinema MR_createInContext:[NSManagedObjectContext MR_contextForCurrentThread]];
         }
         //            [cinemas addObject:mCinema];
         mCinema.district = district;
         mCinema.city = [self getNowUserCityFromCoreDataWithName:apiCmd.cityName];
         [self importCinema:mCinema ValuesForKeysWithObject:cinema_dic];
         }*/
        
    }
    
    [[NSManagedObjectContext MR_contextForCurrentThread] MR_saveToPersistentStoreWithCompletion:^(BOOL success, NSError *error) {
        ABLoggerDebug(@"影院保存是否成功 ========= %d",success);
        ABLoggerDebug(@"错误信息 ========= %@",[error description]);
    }];
    
    //    [cinemas release];
    
    CFTimeInterval time2 = Elapsed_Time;
    ElapsedTime(time2, time1);
    
    [[[ApiClient defaultClient] requestArray] removeObject:apiCmd];
    ABLoggerWarn(@"remove request array count === %d",[[[ApiClient defaultClient] requestArray] count]);
    
    //    });
    
}

/*
 {
 "httpCode":200,
 "errors":[
 ],
 "data":{
 "count":1,
 "infos":[
 {
 "district":"",
 "cinemas":[],
 "dynamic":[]
 }
 ]
 },
 "token":null,
 "timestamp":"1372063052"
 }
 
 
 
 
 {
 "error":{},
 "timestamp":"1369275251",
 "data":{
 "count": 10,
 "info": [
 {
 "district": "朝阳区",
 "cinemas": [
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
    mCinema.uid = [NSNumber numberWithInt:[[aCinemaData objectForKey:@"id"] intValue]];
    mCinema.name = [aCinemaData objectForKey:@"name"];
    mCinema.address = [aCinemaData objectForKey:@"address"];
    mCinema.phoneNumber = [aCinemaData objectForKey:@"contactphonex"];
    mCinema.longitue = [NSNumber numberWithDouble:[[aCinemaData objectForKey:@"longitude"] doubleValue]];
    mCinema.latitude = [NSNumber numberWithDouble:[[aCinemaData objectForKey:@"latitude"] doubleValue]];
}
//========================================= 影院 =========================================/

#pragma mark -
#pragma mark 演出
/****************************************** 演出 *********************************************/
- (ApiCmd *)getAllShowsListFromWeb:(id<ApiNotify>)delegate{
    
    ApiCmd *tapiCmd = [delegate apiGetDelegateApiCmd];
    if ([[[[ApiClient defaultClient] networkQueue] operations]containsObject:tapiCmd.httpRequest]) {
        ABLoggerWarn(@"不能请求演出列表数据，因为已经请求了");
        return tapiCmd;
    }
    
    ApiClient* apiClient = [ApiClient defaultClient];
    
    ApiCmdShow_getAllShows* apiCmdShow_getAllShows = [[ApiCmdShow_getAllShows alloc] init];
    apiCmdShow_getAllShows.delegate = delegate;
    apiCmdShow_getAllShows.cityName = [[LocationManager defaultLocationManager] getUserCity];
    [apiClient executeApiCmdAsync:apiCmdShow_getAllShows];
    [apiCmdShow_getAllShows.httpRequest setTag:API_SShowCmd];
    
    return [apiCmdShow_getAllShows autorelease];
}


- (NSArray *)getAllShowsListFromCoreData{
    return [self getAllShowsListFromCoreDataWithCityName:nil];
}

- (NSArray *)getAllShowsListFromCoreDataWithCityName:(NSString *)cityName{
    
    if (isEmpty(cityName)) {
        cityName = [[LocationManager defaultLocationManager] getUserCity];
    }
    
    return [SShow MR_findAllSortedBy:@"name" ascending:NO withPredicate:[NSPredicate predicateWithFormat:@"city.name = %@", cityName]  inContext:[NSManagedObjectContext MR_contextForCurrentThread]];
}

- (NSUInteger)getCountOfShowsListFromCoreData{
    return [self getCountOfShowsListFromCoreDataWithCityName: nil];
}

- (NSUInteger)getCountOfShowsListFromCoreDataWithCityName:(NSString *)cityName{
    if (isEmpty(cityName)) {
        cityName = [[LocationManager defaultLocationManager] getUserCity];
    }
    int count = [SShow MR_countOfEntitiesWithPredicate:[NSPredicate predicateWithFormat:@"city.name = %@", cityName] inContext:[NSManagedObjectContext MR_contextForCurrentThread]];
    return count;
}

/*
 {
 "errors":[],
 "data":{
 "count":10,
 "performances":[
 {
 "id":30010,
 "name":"赖声川话剧1",
 "type":2,
 "prices":[220,230,420,520],
 "date":"2013-06-30",
 "rating":8.0,
 "ratingFrom":"豆瓣",
 "ratingBy":120304,
 "intro":"内容介绍",
 "address":"地质礼堂话剧院",
 "poster":"https://raw.github.com/zyallday/HelloWorld/master/mobileapidemo/poster.png",
 "longitude":34.2343,
 "latitude":57.3445
 },
 */
- (void)insertShowsIntoCoreDataFromObject:(NSDictionary *)objectData withApiCmd:(ApiCmd*)apiCmd{
    CFTimeInterval time1 = Elapsed_Time;
    
    NSArray *array = [[objectData objectForKey:@"data"]objectForKey:@"performances"];
    
    SShow *sShow = nil;
    for (int i=0; i<[array count]; i++) {
        
        sShow = [SShow MR_findFirstByAttribute:@"uid" withValue:[[array objectAtIndex:i] objectForKey:@"id"] inContext:[NSManagedObjectContext MR_contextForCurrentThread]];
        if (sShow == nil)
        {
            ABLoggerInfo(@"插入 一条演出 新数据 ======= %@",[[array objectAtIndex:i] objectForKey:@"name"]);
            sShow = [SShow MR_createInContext:[NSManagedObjectContext MR_contextForCurrentThread]];
        }
        [self importShow:sShow ValuesForKeysWithObject:[array objectAtIndex:i]];
        
        City *city = [self getNowUserCityFromCoreDataWithName:apiCmd.cityName];
        sShow.city = city;
    }
    
    [[NSManagedObjectContext MR_contextForCurrentThread] MR_saveToPersistentStoreWithCompletion:^(BOOL success, NSError *error) {
        ABLoggerDebug(@"演出 保存是否成功 ========= %d",success);
        ABLoggerDebug(@"错误信息 ========= %@",[error description]);
    }];
    
    CFTimeInterval time2 = Elapsed_Time;
    ElapsedTime(time2, time1);
    
    [[[ApiClient defaultClient] requestArray] removeObject:apiCmd];
    ABLoggerWarn(@"remove request array count === %d",[[[ApiClient defaultClient] requestArray] count]);
    
    
}

- (void)importShow:(SShow *)sShow ValuesForKeysWithObject:(NSDictionary *)ashowDic{
    sShow.uid = [[ashowDic objectForKey:@"id"] stringValue];
    sShow.name = [ashowDic objectForKey:@"name"];
    sShow.where = @"体育中心";
    sShow.type = [ashowDic objectForKey:@"type"];
    sShow.price = [ashowDic objectForKey:@"prices"];
    sShow.date = [ashowDic objectForKey:@"date"];
    sShow.rating = [ashowDic objectForKey:@"rating"];
    sShow.ratingfrom = [ashowDic objectForKey:@"ratingFrom"];
    sShow.ratingpeople = [ashowDic objectForKey:@"ratingBy"];
    sShow.address = [ashowDic objectForKey:@"address"];
    sShow.webImg = [ashowDic objectForKey:@"poster"];
    sShow.longitude = [ashowDic objectForKey:@"longitude"];
    sShow.latitude = [ashowDic objectForKey:@"latitude"];
    
}
//========================================= 演出 =========================================/

#pragma mark -
#pragma mark 酒吧
/****************************************** 酒吧 *********************************************/
- (ApiCmd *)getAllBarsListFromWeb:(id<ApiNotify>)delegate;{
    
    ApiCmd *tapiCmd = [delegate apiGetDelegateApiCmd];
    if ([[[[ApiClient defaultClient] networkQueue] operations]containsObject:tapiCmd.httpRequest]) {
        ABLoggerWarn(@"不能请求演出列表数据，因为已经请求了");
        return tapiCmd;
    }
    
    ApiClient* apiClient = [ApiClient defaultClient];
    
    ApiCmdBar_getAllBars* apiCmdBar_getAllBars = [[ApiCmdBar_getAllBars alloc] init];
    apiCmdBar_getAllBars.delegate = delegate;
    apiCmdBar_getAllBars.cityName = [[LocationManager defaultLocationManager] getUserCity];
    [apiClient executeApiCmdAsync:apiCmdBar_getAllBars];
    [apiCmdBar_getAllBars.httpRequest setTag:API_BBarCmd];
    
    return [apiCmdBar_getAllBars autorelease];
    
}

- (NSArray *)getAllBarsListFromCoreData{
    return [self getAllBarsListFromCoreDataWithCityName:nil];
}

- (NSArray *)getAllBarsListFromCoreDataWithCityName:(NSString *)cityName{
    if (isEmpty(cityName)) {
        cityName = [[LocationManager defaultLocationManager] getUserCity];
    }
    
    return [BBar MR_findAllSortedBy:@"name" ascending:NO withPredicate:[NSPredicate predicateWithFormat:@"city.name = %@", cityName]  inContext:[NSManagedObjectContext MR_contextForCurrentThread]];
}

- (NSUInteger)getCountOfBarsListFromCoreData{
    return [self getCountOfBarsListFromCoreDataWithCityName:nil];
}

- (NSUInteger)getCountOfBarsListFromCoreDataWithCityName:(NSString *)cityName{
    if (isEmpty(cityName)) {
        cityName = [[LocationManager defaultLocationManager] getUserCity];
    }
    int count = [BBar MR_countOfEntitiesWithPredicate:[NSPredicate predicateWithFormat:@"city.name = %@", cityName] inContext:[NSManagedObjectContext MR_contextForCurrentThread]];
    return count;
}

- (void)insertBarsIntoCoreDataFromObject:(NSDictionary *)objectData withApiCmd:(ApiCmd*)apiCmd{
    CFTimeInterval time1 = Elapsed_Time;
    
    NSArray *array = [[objectData objectForKey:@"data"]objectForKey:@"pubs"];
    
    BBar *bBar = nil;
    for (int i=0; i<[array count]; i++) {
        
        bBar = [BBar MR_findFirstByAttribute:@"uid" withValue:[[array objectAtIndex:i] objectForKey:@"id"] inContext:[NSManagedObjectContext MR_contextForCurrentThread]];
        if (bBar == nil)
        {
            ABLoggerInfo(@"插入 一条 酒吧 新数据 ======= %@",[[array objectAtIndex:i] objectForKey:@"name"]);
            bBar = [BBar MR_createInContext:[NSManagedObjectContext MR_contextForCurrentThread]];
        }
        [self importBar:bBar ValuesForKeysWithObject:[array objectAtIndex:i]];
        
        City *city = [self getNowUserCityFromCoreDataWithName:apiCmd.cityName];
        bBar.city = city;
    }
    
    [[NSManagedObjectContext MR_contextForCurrentThread] MR_saveToPersistentStoreWithCompletion:^(BOOL success, NSError *error) {
        ABLoggerDebug(@"酒吧 保存是否成功 ========= %d",success);
        ABLoggerDebug(@"错误信息 ========= %@",[error description]);
    }];
    
    CFTimeInterval time2 = Elapsed_Time;
    ElapsedTime(time2, time1);
    
    [[[ApiClient defaultClient] requestArray] removeObject:apiCmd];
    ABLoggerWarn(@"remove request array count === %d",[[[ApiClient defaultClient] requestArray] count]);
    
}

/*
 {
 "errors":[],
 "data":{
 "count":10,
 "pubs":[
 {
 "id":40011,
 "name":"万圣节女士Party1",
 "popular":52,
 "address":"希尔顿酒店",
 "date":"2013-7-15",
 "tel":13800383800,
 "intro":"活动介绍：1，*****",
 "recommended":100,
 "like":100,
 "scene":"http://sdjflsajlfaslf.png",
 "longitude":34.2343,
 "latitude":57.3445
 },
 */
- (void)importBar:(BBar *)bBar ValuesForKeysWithObject:(NSDictionary *)aBarDic{
    bBar.uid = [[aBarDic objectForKey:@"id"] stringValue];
    bBar.name = [aBarDic objectForKey:@"name"];
    bBar.popular = [aBarDic objectForKey:@"popular"];
    bBar.address = [aBarDic objectForKey:@"address"];
    bBar.date = [aBarDic objectForKey:@"date"];
    bBar.phoneNumber = [[aBarDic objectForKey:@"tel"] stringValue];
    bBar.longitude = [aBarDic objectForKey:@"longitude"];
    bBar.latitude = [aBarDic objectForKey:@"latitude"];
}
//========================================= 酒吧 =========================================/

#pragma mark -
#pragma mark KTV
/****************************************** KTV *********************************************/
- (ApiCmd*)getAllKTVsListFromWeb:(id<ApiNotify>)delegate{
    
    ApiCmd *tapiCmd = [delegate apiGetDelegateApiCmd];
    
    if ([[[[ApiClient defaultClient] networkQueue] operations]containsObject:tapiCmd.httpRequest]) {
        ABLoggerWarn(@"不能请求 KTV 列表数据，因为已经请求了");
        return tapiCmd;
    }
    
    ApiClient* apiClient = [ApiClient defaultClient];
    
    ApiCmdKTV_getAllKTVs* apiCmdKTV_getAllKTVs = [[ApiCmdKTV_getAllKTVs alloc] init];
    apiCmdKTV_getAllKTVs.delegate = delegate;
    apiCmdKTV_getAllKTVs.cityName = [[LocationManager defaultLocationManager] getUserCity];
    [apiClient executeApiCmdAsync:apiCmdKTV_getAllKTVs];
    [apiCmdKTV_getAllKTVs.httpRequest setTag:API_KKTVCmd];
    
    return [apiCmdKTV_getAllKTVs autorelease];
}

- (NSArray *)getAllKTVsListFromCoreData{
    return [self getAllKTVsListFromCoreDataWithCityName:nil];
}

- (NSArray *)getAllKTVsListFromCoreDataWithCityName:(NSString *)cityName{
    if (isEmpty(cityName)) {
        cityName = [[LocationManager defaultLocationManager] getUserCity];
    }
    
    return [KKTV MR_findAllSortedBy:@"name" ascending:NO withPredicate:[NSPredicate predicateWithFormat:@"city.name = %@", cityName]  inContext:[NSManagedObjectContext MR_contextForCurrentThread]];
}

- (NSUInteger)getCountOfKTVsListFromCoreData{
    return [self getCountOfKTVsListFromCoreDataWithCityName:nil];
}

- (NSUInteger)getCountOfKTVsListFromCoreDataWithCityName:(NSString *)cityName{
    if (isEmpty(cityName)) {
        cityName = [[LocationManager defaultLocationManager] getUserCity];
    }
    int count = [KKTV MR_countOfEntitiesWithPredicate:[NSPredicate predicateWithFormat:@"city.name = %@", cityName] inContext:[NSManagedObjectContext MR_contextForCurrentThread]];
    return count;
    
}

/*
 {
 "timestamp":"1369275251",
 "errors":[],
 "data":{
 "count":10,
 "infos":[
 {
 "id":30011,
 "name":"钱柜静安店1",
 "addr":"静安区乌鲁木齐路21号",
 "lowprice":35,
 "tel":13800999900,
 "longitude":24.2355,
 "latitude":42.2352,
 "discounts":9
 },
 */
- (void)insertKTVsIntoCoreDataFromObject:(NSDictionary *)objectData withApiCmd:(ApiCmd*)apiCmd{
    CFTimeInterval time1 = Elapsed_Time;
    
    NSArray *array = [[objectData objectForKey:@"data"]objectForKey:@"infos"];
    
    KKTV *kKTV = nil;
    for (int i=0; i<[array count]; i++) {
        
        kKTV = [KKTV MR_findFirstByAttribute:@"uid" withValue:[[array objectAtIndex:i] objectForKey:@"id"] inContext:[NSManagedObjectContext MR_contextForCurrentThread]];
        if (kKTV == nil)
        {
            ABLoggerInfo(@"插入 一条 KTV 新数据 ======= %@",[[array objectAtIndex:i] objectForKey:@"name"]);
            kKTV = [KKTV MR_createInContext:[NSManagedObjectContext MR_contextForCurrentThread]];
        }
        [self importKTV:kKTV ValuesForKeysWithObject:[array objectAtIndex:i]];
        
        City *city = [self getNowUserCityFromCoreDataWithName:apiCmd.cityName];
        kKTV.city = city;
    }
    
    [[NSManagedObjectContext MR_contextForCurrentThread] MR_saveToPersistentStoreWithCompletion:^(BOOL success, NSError *error) {
        ABLoggerDebug(@"KTV 保存是否成功 ========= %d",success);
        ABLoggerDebug(@"错误信息 ========= %@",[error description]);
    }];
    
    CFTimeInterval time2 = Elapsed_Time;
    ElapsedTime(time2, time1);
    
    [[[ApiClient defaultClient] requestArray] removeObject:apiCmd];
    ABLoggerWarn(@"remove request array count === %d",[[[ApiClient defaultClient] requestArray] count]);
}

- (void)importKTV:(KKTV *)kKTV ValuesForKeysWithObject:(NSDictionary *)aKTVDic{
    kKTV.name = [aKTVDic objectForKey:@"name"];
    kKTV.uid = [[aKTVDic objectForKey:@"id"] stringValue];
    kKTV.address = [aKTVDic objectForKey:@"addr"];
    kKTV.price = [aKTVDic objectForKey:@"lowprice"];
    kKTV.phoneNumber = [[aKTVDic objectForKey:@"tel"] stringValue];
    kKTV.longitude = [aKTVDic objectForKey:@"longitude"];
    kKTV.latitude = [aKTVDic objectForKey:@"latitude"];
    kKTV.discounts = [aKTVDic objectForKey:@"discounts"];
}

- (BOOL)addFavoriteKTVWithId:(NSNumber *)uid{
    
    NSManagedObjectContext* threadContext = [NSManagedObjectContext MR_contextForCurrentThread];
    KKTV *tKTV = [KKTV MR_findFirstByAttribute:@"uid" withValue:uid inContext:threadContext];
    
    if (!tKTV) {
        return NO;
    }
    
    tKTV.favorite = [NSNumber numberWithBool:YES];
    
    [threadContext MR_saveToPersistentStoreWithCompletion:^(BOOL success, NSError *error) {
        ABLoggerDebug(@"收藏KTV 保存是否成功 ========= %d",success);
        ABLoggerDebug(@"错误信息 ========= %@",[error description]);
    }];
    
    return YES;
}

- (BOOL)deleteFavoriteKTVWithId:(NSNumber *)uid{
    
    NSManagedObjectContext* threadContext = [NSManagedObjectContext MR_contextForCurrentThread];
    KKTV *tKTV = [KKTV MR_findFirstByAttribute:@"uid" withValue:uid inContext:threadContext];
    
    if (!tKTV) {
        return NO;
    }
    
    tKTV.favorite = [NSNumber numberWithBool:NO];
    
    [threadContext MR_saveToPersistentStoreWithCompletion:^(BOOL success, NSError *error) {
        ABLoggerDebug(@"收藏KTV 保存是否成功 ========= %d",success);
        ABLoggerDebug(@"错误信息 ========= %@",[error description]);
    }];
    
    return YES;
}
//========================================= KTV =========================================/
@end
