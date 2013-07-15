//
//  DataBaseManager.m
//  WanShangLe
//
//  Created by stephenliu on 13-6-6.
//  Copyright (c) 2013年 stephenliu. All rights reserved.
//

static DataBaseManager *_sharedInstance = nil;

#import "DataBaseManager.h"
#import "ChineseToPinyin.h"
#import "DataBase.h"

@interface DataBaseManager(){
    
}
@property(nonatomic,retain)NSDateFormatter *timeFormatter;
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
        [self initData];
    }
    return self;
}

- (void)initData{
    _timeFormatter = [[NSDateFormatter alloc] init];
    _timeFormatter.timeZone = [NSTimeZone localTimeZone];
    _timeFormatter.locale = [NSLocale currentLocale];
}

- (void)dealloc {
    self.timeFormatter = nil;
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
#pragma mark 日期-时间
- (BOOL)isToday:(NSString *)date{
   _timeFormatter.dateFormat = @"yyyy-MM-dd";
    NSString *nowDate = [_timeFormatter stringFromDate:[NSDate date]];
    NSString *cmpDate = [[date componentsSeparatedByString:@" "] objectAtIndex:0];
    return ([nowDate compare:cmpDate options:NSNumericSearch] == NSOrderedSame);
}

- (BOOL)isTomorrow:(NSString *)date{
    return YES;
}

- (NSString *)getTodayTimeStamp{
    
    //formatter.dateFormat = @"yyyy-MM-dd HH:mm:ss ZZZ";
    _timeFormatter.dateFormat = @"yyyyMMddHHmmssSSS";
    NSString *updateTimeStamp = [_timeFormatter stringFromDate:[NSDate date]];
    ABLoggerInfo(@"获取当前时间 ===== %@",updateTimeStamp);
    return updateTimeStamp;
}

- (NSString *)getTodayZeroTimeStamp{
    //formatter.dateFormat = @"yyyy-MM-dd HH:mm:ss ZZZ";
    _timeFormatter.dateFormat = @"yyyyMMdd000000000";
    NSString *updateTimeStamp = [_timeFormatter stringFromDate:[NSDate date]];
    ABLoggerInfo(@"today time stamp is ===== %@",updateTimeStamp);
    return updateTimeStamp;
}

#pragma mark 获取星期几
- (NSString *)getNowDate{
    
    _timeFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    
    return [_timeFormatter stringFromDate:[NSDate date]];
}

- (NSString *)getTodayWeek{
    return [self getWhickWeek:[NSDate date]];
}
- (NSString *)getTomorrowWeek{
    //得到(24 * 60 * 60)即24小时之前的日期，dateWithTimeIntervalSinceNow:
    NSDate *tomorrow = [NSDate dateWithTimeIntervalSinceNow: (24 * 60 * 60)];
    
    return [self getWhickWeek:tomorrow];
}

- (NSString *)getWhickWeek:(NSDate*)aDate{
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    
    NSInteger unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSWeekdayCalendarUnit |
    NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit;
    
    NSDateComponents *comps = [calendar components:unitFlags fromDate:aDate];
    int week = [comps weekday];
    
    NSString *weekStr = nil;
    switch (week) {
        case 1:
            weekStr = @"周日";
            break;
        case 2:
            weekStr = @"周一";
            break;
        case 3:
            weekStr = @"周二";
            break;
        case 4:
            weekStr = @"周三";
            break;
        case 5:
            weekStr = @"周四";
            break;
        case 6:
            weekStr = @"周五";
            break;
        default:
            weekStr = @"周六";
            break;
    }
    
    [calendar release];
    return weekStr;
    
    /*
     int month = [comps month];
     int day = [comps day];
     int hour = [comps hour];
     int min = [comps minute];
     int sec = [comps second];*/
}

#pragma mark 获取时间
//time = "2013-07-03 10:00:00";
- (NSString *)getTimeFromDate:(NSString *)dateStr{
    if (isEmpty(dateStr)) {
        return nil;
    }
    _timeFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    NSDate *aDate = [_timeFormatter dateFromString:dateStr];
    
    _timeFormatter.dateFormat = @"HH:mm";
    
    return [_timeFormatter stringFromDate:aDate];
}

- (NSString *)timeByAddingTimeInterval:(int)time fromDate:(NSString *)dateStr{
    
    if (isEmpty(dateStr) || isEmpty(dateStr)) {
        return nil;
    }
    _timeFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    NSDate *aDate = [_timeFormatter dateFromString:dateStr];
    
    int interval = time*60;
    aDate = [aDate dateByAddingTimeInterval:interval];
    
    _timeFormatter.dateFormat = @"HH:mm";
    
    return [_timeFormatter stringFromDate:aDate];
}

-(NSDate *)trueDate:(NSDate *)formatDate{
    
    NSTimeZone *zone = [NSTimeZone localTimeZone];;
    
    NSInteger interval = [zone secondsFromGMTForDate: formatDate];
    
    NSDate *localeDate = [formatDate  dateByAddingTimeInterval: interval];
    
    ABLoggerDebug(@"localeDate ====== %@", localeDate);
    
    return localeDate;
}

#pragma mark -
#pragma mark 推荐和想看
- (BOOL)getRecommendOrLookForWeb:(NSString *)movieId
                         APIType:(WSLRecommendAPIType)apiType
                           cType:(WSLRecommendLookType)cType
                        delegate:(id<ApiNotify>)delegate{
    
    //    if (!isEmpty(movieId)) {
    //
    //        NSManagedObjectContext *context = [NSManagedObjectContext MR_contextForCurrentThread];
    //        MMovie *aMovie = [MMovie MR_findFirstByAttribute:@"uid" withValue:movieId inContext:context];
    //        if (aMovie==nil) {
    //            return NO;
    //        }
    //
    //        BOOL canRequest = YES;
    //        switch (cType) {
    //            case WSLRecommendLookTypeRecommend:
    //                canRequest = ![aMovie.movieDetail.doneRec boolValue];
    //                break;
    //            case WSLRecommendLookTypeLook:
    //                canRequest = ![aMovie.movieDetail.doneLook boolValue];
    //                break;
    //
    //            default:
    //                break;
    //        }
    //
    //        if (!canRequest) {
    //            return NO;
    //        }
    //    }else{
    //        return NO;
    //    }
    
    ApiClient* apiClient = [ApiClient defaultClient];
    
    ApiCmd_recommendOrLook* apiCmd_recommendOrLook = [[ApiCmd_recommendOrLook alloc] init];
    apiCmd_recommendOrLook.delegate = delegate;
    apiCmd_recommendOrLook.movie_id = movieId;
    apiCmd_recommendOrLook.mAPIType = apiType;
    apiCmd_recommendOrLook.mType = cType;
    [apiClient executeApiCmdAsync:apiCmd_recommendOrLook];
    [apiCmd_recommendOrLook.httpRequest setTag:API_MMovieRecOrLookCmd];
    
    return YES;
}

#pragma mark -
#pragma mark 关联表
/************ 关联表 ***************/
//- (MMovie_City *)getFirstMMovie_CityFromCoreData:(NSString *)u_id;
//{
//    MMovie_City *mMovie_city = nil;
//    mMovie_city = [MMovie_City MR_findFirstByAttribute:@"uid" withValue:u_id inContext:[NSManagedObjectContext MR_contextForCurrentThread]];
//
//    return mMovie_city;
//}
//
//- (MMovie_City *)insertMMovie_CityWithMovie:(MMovie *)a_movie andCity:(City *)a_city{
//
//    MMovie_City *mMovie_city = nil;
//
//    ABLoggerInfo(@"插入 电影_城市 关联表 新数据 [a_city name] ======= %@",[a_city name]);
//    mMovie_city = [MMovie_City MR_createInContext:[NSManagedObjectContext MR_contextForCurrentThread]];
//    mMovie_city.uid = [NSString stringWithFormat:@"%@%@",[a_city name],a_movie.uid];
//    mMovie_city.city = a_city;
//    mMovie_city.movie = a_movie;
//
//    return mMovie_city;
//}

- (MMovie_Cinema *)insertMMovie_CinemaWithaMovie:(MMovie *)aMovie andaCinema:(MCinema *)aCinema{
    
    MMovie_Cinema *movie_cinema = nil;
    
    if (!aMovie || !aCinema) {
        ABLoggerWarn(@"不能 插入 电影_影院，不能为空");
        return movie_cinema;
    }
    
    NSString *movie_cinema_uid = [[NSString alloc] initWithFormat:@"%@%@%d%@",aCinema.cityId,aCinema.cityName,[aCinema.uid intValue],aMovie.uid];
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
    
    ABLoggerDebug(@"插入 电影--影院 关联表-数据");
    
    MMovie *aMovie = nil;
    MCinema *aCinema = nil;
    MMovie_Cinema *movie_cinema = nil;
    
    for (int i=0; i<[movies count]; i++) {
        
        aMovie = [movies objectAtIndex:i];
        
        for (int j=0; j<[cinemas count]; j++) {
            
            aCinema = [cinemas objectAtIndex:j];
            
            NSString *movie_cinema_uid = [[NSString alloc] initWithFormat:@"%@%@%d%@",aCinema.cityId,aCinema.cityName,[aCinema.uid intValue],aMovie.uid];
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

- (City *)insertCityIntoCoreDataWith:(NSString *)cityName{
    
    if (!cityName) {
        cityName = [[LocationManager defaultLocationManager] getUserCity];
    }
    
    City *city = nil;
    NSManagedObjectContext *context = [NSManagedObjectContext MR_contextForCurrentThread];
    
    NSString *newCityName = [self validateCity:cityName];
    if (isEmpty(newCityName)) {
        return nil;
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
    
    city.locationDate = [self getTodayTimeStamp];
    
    [self saveInManagedObjectContext:context];
    
    return city;
}

- (NSString *)validateCity:(NSString *)cityName{
    
    if (isEmpty(cityName)) {
        return nil;
    }
    
    NSString *city_name = [ChineseToPinyin pinyinFromChiniseString:cityName];
    ABLoggerInfo(@"city_name ===== %@",city_name);
    NSString *cityPath = [[NSBundle mainBundle] pathForResource:@"city" ofType:@"json"];
    NSData *cityData = [NSData dataWithContentsOfFile:cityPath];
    NSDictionary *cityDic = [NSJSONSerialization JSONObjectWithData:cityData options:kNilOptions error:nil];
    NSArray *array = [cityDic objectForKey:@"citys"];
    
    for (NSDictionary *dic in array) {
        NSString *tname = [dic objectForKey:@"name"];
        
        NSString *aName = [ChineseToPinyin pinyinFromChiniseString:tname];
        
        ABLoggerInfo(@"range ===== %@",NSStringFromRange(NSMakeRange(0, aName.length)));
        if ([city_name isEqualToString:aName]) {
            ABLoggerWarn(@"相等");
        }
        
        if ([city_name compare:aName options:NSCaseInsensitiveSearch range:NSMakeRange(0, aName.length)] == NSOrderedSame) {
            return [dic objectForKey:@"name"];
        }
        
        NSRange range=[city_name rangeOfString:aName options:NSCaseInsensitiveSearch];
        if(range.location!=NSNotFound){
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
    
    city_name = [ChineseToPinyin pinyinFromChiniseString:cityName];
    NSString *cityPath = [[NSBundle mainBundle] pathForResource:@"city" ofType:@"json"];
    NSData *cityData = [NSData dataWithContentsOfFile:cityPath];
    NSDictionary *cityDic = [NSJSONSerialization JSONObjectWithData:cityData options:kNilOptions error:nil];
    NSArray *array = [cityDic objectForKey:@"citys"];
    
    for (NSDictionary *dic in array) {
        NSString *tname = [dic objectForKey:@"name"];
        
        tname = [ChineseToPinyin pinyinFromChiniseString:tname];
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
        city = [self insertCityIntoCoreDataWith:name];
    }
    
    return city;
}

//测试 城市筛选
- (NSArray *)getUnCurrentCity{
    
    NSString *cityId = nil;
    cityId = [[LocationManager defaultLocationManager] getUserCityId];
    
    return [City MR_findAllSortedBy:@"uid" ascending:YES withPredicate:[NSPredicate predicateWithFormat:@"uid != %@",cityId] offset:0 limit:1000 inContext:[NSManagedObjectContext MR_contextForCurrentThread]];
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
    
    //    returnArray = (NSMutableArray *)[returnArray sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
    //        NSString *first =  [(MMovie*)a name];
    //        NSString *second = [(MMovie*)b name];
    //        return [first compare:second];
    //    }];
    
    return [MMovie MR_findAllInContext:[NSManagedObjectContext MR_contextForCurrentThread]];
}

- (NSUInteger)getCountOfMoviesListFromCoreData{
    return [self getCountOfMoviesListFromCoreDataWithCityName:nil];
}

- (NSUInteger)getCountOfMoviesListFromCoreDataWithCityName:(NSString *)cityName{
    return [MMovie MR_countOfEntitiesWithContext:[NSManagedObjectContext MR_contextForCurrentThread]];
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
        
        mMovie = [MMovie MR_findFirstByAttribute:@"uid" withValue:[[array objectAtIndex:i] objectForKey:@"id"]  inContext:[NSManagedObjectContext MR_contextForCurrentThread]];
        if (mMovie == nil)
        {
            ABLoggerInfo(@"插入 一条 New电影 新数据 ======= %@",[[array objectAtIndex:i] objectForKey:@"name"]);
            mMovie = [MMovie MR_createInContext:[NSManagedObjectContext MR_contextForCurrentThread]];
        }
        [self importMovie:mMovie ValuesForKeysWithObject:[array objectAtIndex:i]];
        
        //        City *city = [self getNowUserCityFromCoreDataWithName:apiCmd.cityName];
        //
        //        MMovie_City *movie_city = nil;
        //        movie_city = [self getFirstMMovie_CityFromCoreData:[NSString stringWithFormat:@"%@%@",[city name],mMovie.uid]];
        //        if (movie_city == nil) {
        //            [self insertMMovie_CityWithMovie:mMovie andCity:city];
        //        }
        
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
 movies: [
 {
 id: "35",
 uniquekey: "3a35241f73cb36a91fb90d4339272798",
 name: "不二神探",
 url: "http://movie.douban.com/subject/10604486/",
 rating: "5.3",
 ratingcount: "531",
 director: "王子鸣",
 star: "文章,李连杰,刘诗诗,陈妍希,柳岩,马伊琍,黄晓明,佟大为,冯德伦,吴京,邹兆龙,郑嘉颖,梁小龙,谢天华,张梓琳,邓丽欣,田亮,方力申,梁家仁,林雪,何超仪",
 type: "喜剧,动作,犯罪",
 hotstarttime: null,
 tag: "0",
 startday: "2013-06-21",
 description: "短短数日内，三起“微笑杀人案”震动全城。调查过程中，青年警探、警局“活宝”王不二（文章饰）语出惊人：这是一起连环谋杀案！遂与搭档黄非红（李连杰饰）开始了一段惊悚刺激，同时又状况不断的“缉凶”之旅。黄非红在旁边看似总是乌龙，但其实是真正的功夫高手，每到关键时刻，他总能帮助王不二化险为夷。案件侦办过程中，王不二先是将怀疑对像锁定为女明星刘金水（刘诗诗饰），随着案情的深入，刘金水的嫌疑被逐渐撇清，她的姐姐戴依依（柳岩饰）等人又成了王不二的怀疑对象。最后，王不二决定假扮刘金水的男友来引诱凶手现身。与此同时，危险也慢慢向王不二靠近，真相即将大白于天下，王不二与凶手的终极对决，也就此展开……",
 duration: "98",
 coverurl: "http://em.wanshangle.com:8888/attachments/image/movie/78332_1373265685.gif",
 imagesurl: "http://img3.douban.com/img/trailer/medium/1994465296.jpg,http://img3.douban.com/view/photo/albumicon/public/p1989440172.jpg,http://img3.douban.com/view/photo/albumicon/public/p1958082672.jpg,http://img3.douban.com/view/photo/albumicon/public/p1994516377.jpg,http://img3.douban.com/view/photo/albumicon/public/p1979919731.jpg",
 trailersurl: "http://movie.douban.com/trailer/135868/#content",
 status: "0",
 coverimg: "",
 createtime: "2013-06-28 13:56:47",
 createdbysuid: "9",
 lastmodifiedtime: "2013-07-08 14:41:37",
 lastmodifiedbysuid: "12",
 currentstatus: "3",
 votecountadded: "0",
 ratingadded: "0",
 ratingcountadded: "0",
 recommendadded: "0",
 wantedadded: "0"
 },
 
 dynamic: [
 {
 rating: 5.3,
 ratingFrom: "豆瓣",
 ratingCount: "531",
 viewtypes: [
 "0",
 "1",
 "1"
 ]
 },
 ***/
- (void)importMovie:(MMovie *)mMovie ValuesForKeysWithObject:(NSDictionary *)amovieData
{
    //    ABLoggerInfo(@"amovieData == %@",amovieData);
    mMovie.uid = [amovieData objectForKey:@"id"];
    mMovie.name = [amovieData objectForKey:@"name"];
    mMovie.webImg = [amovieData objectForKey:@"coverurl"];
    mMovie.aword = [amovieData objectForKey:@"description"];
    mMovie.duration = [amovieData objectForKey:@"duration"];
}

- (void)importDynamicMovie:(MMovie *)mMovie ValuesForKeysWithObject:(NSDictionary *)amovieData
{
    ABLoggerInfo(@"amovieData == %@",amovieData);
    mMovie.rating = [NSString stringWithFormat:@"%d",[[amovieData objectForKey:@"rating"] intValue]];
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
    
    return [JSONObject objectForKey:@"region"];
}

- (MMovie*)getMovieWithId:(NSString *)movieId{
    MMovie *tmovie = nil;
    if (movieId) {
        tmovie = [MMovie MR_findFirstByAttribute:@"uid" withValue:movieId inContext:[NSManagedObjectContext MR_contextForCurrentThread]];
    }
    
    return tmovie;
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

/*
 {
 httpCode: 200,
 errors: [ ],
 data: {
 interact: {
 movieid: "1",
 recommend: "13",
 look: "2"
 }
 },
 token: null,
 timestamp: "1372236865"
 }
 */
- (BOOL)insertMovieRecommendIntoCoreDataFromObject:(NSString *)movieId data:(NSDictionary *)objectData withApiCmd:(ApiCmd*)apiCmd{
    
    if (!isEmpty(movieId)) {
        
        NSDictionary *tDic = [[objectData objectForKey:@"data"] objectForKey:@"interact"];
        
        NSManagedObjectContext *context = [NSManagedObjectContext MR_contextForCurrentThread];
        MMovie *aMovie = [MMovie MR_findFirstByAttribute:@"uid" withValue:movieId inContext:context];
        if (aMovie==nil) {
            return NO;
        }
        
        aMovie.movieDetail.recommendadded = [tDic objectForKey:@"recommend"];
        aMovie.movieDetail.wantedadded = [tDic objectForKey:@"look"];
        
        [self saveInManagedObjectContext:context];
        return YES;
    }
    
    return NO;
}

- (MMovieDetail *)getMovieDetailWithId:(NSString *)movieId{
    
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
    
    ApiClient* apiClient = [ApiClient defaultClient];
    
    ApiCmdMovie_getSchedule* apiCmdMovie_getSchedule = [[ApiCmdMovie_getSchedule alloc] init];
    apiCmdMovie_getSchedule.delegate = delegate;
    apiCmdMovie_getSchedule.cityName = [[LocationManager defaultLocationManager] getUserCity];
    apiCmdMovie_getSchedule.movie_id = aMovie.uid;
    apiCmdMovie_getSchedule.cinema_id = [aCinema.uid stringValue];
    [apiClient executeApiCmdAsync:apiCmdMovie_getSchedule];
    [apiCmdMovie_getSchedule.httpRequest setTag:API_MScheduleCmd];
    
    return [apiCmdMovie_getSchedule autorelease];
}

- (MSchedule *)getScheduleFromCoreDataWithaMovie:(MMovie *)aMovie andaCinema:(MCinema *)aCinema{
    
    MMovie_Cinema *movie_cinema = nil;
    NSString *movie_cinema_uid = [[NSString alloc] initWithFormat:@"%@%@%d%@",aCinema.cityId,aCinema.cityName,[aCinema.uid intValue],aMovie.uid];
    movie_cinema = [MMovie_Cinema MR_findFirstByAttribute:@"uid" withValue:movie_cinema_uid inContext:[NSManagedObjectContext MR_contextForCurrentThread]];
    [movie_cinema_uid release];
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
    
    NSString *movie_cinema_uid = [[NSString alloc] initWithFormat:@"%@%@%d%@",aCinema.cityId,aCinema.cityName,[aCinema.uid intValue],aMovie.uid];
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

//去除过期的电影排期
- (NSArray *)deleteUnavailableSchedules:(NSArray *)aArray{
    
    NSMutableArray *returnArray = [[NSMutableArray alloc] initWithCapacity:10];
    
    NSString *nowTime = [[DataBaseManager sharedInstance] getNowDate];
    for (NSDictionary *tDic in aArray) {
        NSString *scheduleTime = [tDic objectForKey:@"time"];
        if ([scheduleTime compare:nowTime options:NSNumericSearch] == NSOrderedDescending) {
            [returnArray addObject:tDic];
        }
    }
    
    return [returnArray autorelease];
}

#pragma mark 购买信息
- (ApiCmdMovie_getBuyInfo *)getBuyInfoFromWebWithaMovie:(MMovie *)aMovie
                                                aCinema:(MCinema *)aCinema
                                              aSchedule:(NSString *)aSchedule
                                               delegate:(id<ApiNotify>)delegate
{
    
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
    
    if (tapiCmd.httpRequest!=nil) {
        if ([[[[ApiClient defaultClient] networkQueue] operations] containsObject:tapiCmd.httpRequest]) {
            ABLoggerWarn(@"不能请求影院列表数据，因为已经请求了");
            return tapiCmd;
        }
    }
    
    ABLoggerWarn(@"tapiCmd.httpRequest ====== %@",tapiCmd.httpRequest);
    ABLoggerWarn(@"networkQueue ====== %@",[[[ApiClient defaultClient] networkQueue] operations]);
    
    ApiClient* apiClient = [ApiClient defaultClient];
    
    ApiCmdMovie_getAllCinemas* apiCmdMovie_getAllCinemas = [[ApiCmdMovie_getAllCinemas alloc] init];
    apiCmdMovie_getAllCinemas.delegate = delegate;
    apiCmdMovie_getAllCinemas.cityName = [[LocationManager defaultLocationManager] getUserCity];
    
    [apiClient executeApiCmdAsync:apiCmdMovie_getAllCinemas];
    [apiCmdMovie_getAllCinemas.httpRequest setTag:API_MCinemaCmd];
    [apiCmdMovie_getAllCinemas.httpRequest setNumberOfTimesToRetryOnTimeout:2];
    [apiCmdMovie_getAllCinemas.httpRequest setTimeOutSeconds:60*2];
    
    return [apiCmdMovie_getAllCinemas autorelease];
}

- (NSArray *)getAllCinemasListFromCoreData
{
    return [self getAllCinemasListFromCoreDataWithCityName:nil];
}


- (NSArray *)getAllCinemasListFromCoreDataWithCityName:(NSString *)cityName{
    
    if (isEmpty(cityName)) {
        cityName = [[LocationManager defaultLocationManager] getUserCityId];
    }
    
    return [MCinema MR_findAllSortedBy:@"name" ascending:NO withPredicate:[NSPredicate predicateWithFormat:@"cityId = %@", cityName]  inContext:[NSManagedObjectContext MR_contextForCurrentThread]];
}

- (BOOL)getNearbyCinemasListFromCoreDataWithCallBack:(GetCinemaNearbyList)callback{
    
    GetCinemaNearbyList mCallBack = [callback copy];
    
    NSArray *cinemas = [self getAllCinemasListFromCoreData];
    LocationManager *lm = [LocationManager defaultLocationManager];
    BOOL isSuccess =  [lm getUserGPSLocationWithCallBack:^(BOOL isEnableGPS, BOOL isSuccess) {
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
        
        if (mCallBack) {
            mCallBack(array,isSuccess);
        }
    }];
    
    return isSuccess;
}

- (NSArray *)getFavoriteCinemasListFromCoreData{
    return [self getFavoriteCinemasListFromCoreDataWithCityName:nil];
}

- (NSArray *)getFavoriteCinemasListFromCoreDataWithCityName:(NSString *)cityName{
    if (isEmpty(cityName)) {
        cityName = [[LocationManager defaultLocationManager] getUserCityId];
    }
    
    return [MCinema MR_findAllSortedBy:@"name" ascending:NO withPredicate:[NSPredicate predicateWithFormat:@"cityId = %@ and favorite = YES", cityName]  inContext:[NSManagedObjectContext MR_contextForCurrentThread]];
}

- (NSUInteger)getCountOfCinemasListFromCoreData{
    return [self getCountOfCinemasListFromCoreDataWithCityName:nil];
}

- (NSUInteger)getCountOfCinemasListFromCoreDataWithCityName:(NSString *)cityName{
    
    if (isEmpty(cityName)) {
        cityName = [[LocationManager defaultLocationManager] getUserCityId];
    }
    int count = [MCinema MR_countOfEntitiesWithPredicate:[NSPredicate predicateWithFormat:@"cityId = %@", cityName] inContext:[NSManagedObjectContext MR_contextForCurrentThread]];
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
        
        NSArray *cinema_array = [[info_array objectAtIndex:i] objectForKey:@"list"];
        NSString *districtName = [[info_array objectAtIndex:i] objectForKey:@"districtName"];
        
        for(int j=0; j<[cinema_array count]; j++) {
            
            NSDictionary *cinema_dic = [cinema_array objectAtIndex:j];
            
            mCinema = [MCinema MR_findFirstByAttribute:@"uid" withValue:[cinema_dic objectForKey:@"id"] inContext:[NSManagedObjectContext MR_contextForCurrentThread]];
            if (mCinema == nil)
            {
                ABLoggerInfo(@"插入 一条影院 新数据 ======= %@",[cinema_dic objectForKey:@"name"]);
                mCinema = [MCinema MR_createInContext:[NSManagedObjectContext MR_contextForCurrentThread]];
            }
            //            [cinemas addObject:mCinema];
            mCinema.district = districtName;
            mCinema.cityId = [self getNowUserCityFromCoreDataWithName:apiCmd.cityName].uid;
            [self importCinema:mCinema ValuesForKeysWithObject:cinema_dic];
        }
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
 httpCode: 200,
 errors: [ ],
 data: {
 count: 2,
 infos: [
 {
 districtName: "海淀区",
 list: [
 {
 id: "94",
 uniquekey: "3bc32f5056f3c01b957aa62dccb741f7",
 name: "17.5今典花园影城",
 shortname: "17.5今典花园店",
 description: "",
 address: "北京市海淀区文慧园北路9号蒙太奇大厦二层",
 contactphonex: "010-62228452",
 contactphonetypex: "1",
 contactphoney: "",
 contactphonetypey: "1",
 contactphonez: "",
 contactphonetypez: "1",
 latitude: "39.958636",
 longitude: "116.367761",
 cityid: "1",
 districtid: "8",
 logourl: "logourl",
 coverurl: "http://em.wanshangle.com:8888/attachments/image/cinema/71670_1372211089.jpg",
 specialoffers: "",
 trafficroutes: "乘坐498路到今典花园下；乘坐21路、331路、375路、387路、392路、490路、498路、562路、604路、632路、691路、693路、80路、84电车到文慧桥北下车",
 exturl: "",
 createtime: "2013-06-26 09:59:48",
 createdbysuid: "11",
 lastmodifiedtime: "2013-06-26 10:02:27",
 lastmodifiedbysuid: "11",
 source: "1",
 currentstatus: "3"
 },
 {},
 {},
 {},
 {},
 {}
 ],
 dynamic: [
 {
 cinemaid: "94",
 rounds: 0,
 prices: "0-0",
 channel: [
 0,
 1,
 1
 ],
 hotmovies: [ ]
 },
 {},
 {},
 {},
 {},
 {}
 ]
 },
 {
 districtName: "东城区",
 list: [],
 dynamic: []
 }
 ]
 },
 token: null,
 timestamp: "1373621139"
 */
- (void)importCinema:(MCinema *)mCinema ValuesForKeysWithObject:(NSDictionary *)aCinemaData
{
    mCinema.uid = [aCinemaData objectForKey:@"id"];
    mCinema.name = [aCinemaData objectForKey:@"name"];
    mCinema.address = [aCinemaData objectForKey:@"address"];
    mCinema.phoneNumber = [aCinemaData objectForKey:@"contactphonex"];
    mCinema.longitue = [NSNumber numberWithDouble:[[aCinemaData objectForKey:@"longitude"] doubleValue]];
    mCinema.latitude = [NSNumber numberWithDouble:[[aCinemaData objectForKey:@"latitude"] doubleValue]];
    mCinema.districtId = [aCinemaData objectForKey:@"districtid"];
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
    [apiCmdShow_getAllShows.httpRequest setTag:API_SShow_Type_All_Cmd];
    
    return [apiCmdShow_getAllShows autorelease];
}


- (NSArray *)getAllShowsListFromCoreData{
    return [self getAllShowsListFromCoreDataWithCityName:nil];
}

- (NSArray *)getAllShowsListFromCoreDataWithCityName:(NSString *)cityName{
    
    if (isEmpty(cityName)) {
        cityName = [[LocationManager defaultLocationManager] getUserCityId];
    }
    
    return [SShow MR_findAllSortedBy:@"name" ascending:NO withPredicate:[NSPredicate predicateWithFormat:@"cityId = %@", cityName]  inContext:[NSManagedObjectContext MR_contextForCurrentThread]];
}

- (NSUInteger)getCountOfShowsListFromCoreData{
    return [self getCountOfShowsListFromCoreDataWithCityName: nil];
}

- (NSUInteger)getCountOfShowsListFromCoreDataWithCityName:(NSString *)cityName{
    if (isEmpty(cityName)) {
        cityName = [[LocationManager defaultLocationManager] getUserCityId];
    }
    int count = [SShow MR_countOfEntitiesWithPredicate:[NSPredicate predicateWithFormat:@"cityId = %@", cityName] inContext:[NSManagedObjectContext MR_contextForCurrentThread]];
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
        sShow.cityId = city.uid;
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
    [apiCmdBar_getAllBars.httpRequest setTag:API_BBarTimeCmd];
    
    return [apiCmdBar_getAllBars autorelease];
    
}

- (NSArray *)getAllBarsListFromCoreData{
    return [self getAllBarsListFromCoreDataWithCityName:nil];
}

- (NSArray *)getAllBarsListFromCoreDataWithCityName:(NSString *)cityName{
    if (isEmpty(cityName)) {
        cityName = [[LocationManager defaultLocationManager] getUserCityId];
    }
    
    return [BBar MR_findAllSortedBy:@"name" ascending:NO withPredicate:[NSPredicate predicateWithFormat:@"cityId = %@", cityName]  inContext:[NSManagedObjectContext MR_contextForCurrentThread]];
}

- (NSUInteger)getCountOfBarsListFromCoreData{
    return [self getCountOfBarsListFromCoreDataWithCityName:nil];
}

- (NSUInteger)getCountOfBarsListFromCoreDataWithCityName:(NSString *)cityName{
    if (isEmpty(cityName)) {
        cityName = [[LocationManager defaultLocationManager] getUserCityId];
    }
    int count = [BBar MR_countOfEntitiesWithPredicate:[NSPredicate predicateWithFormat:@"cityId = %@", cityName] inContext:[NSManagedObjectContext MR_contextForCurrentThread]];
    return count;
}

#pragma mark 酒吧 分页 时间
- (ApiCmd *)getBarsListFromWeb:(id<ApiNotify>)delegate
                        offset:(int)offset
                         limit:(int)limit
                      Latitude:(CLLocationDegrees)latitude
                     longitude:(CLLocationDegrees)longitude
                      dataType:(NSString *)dataType
                     isNewData:(BOOL)isNewData{
    
    ApiCmd *tapiCmd = [delegate apiGetDelegateApiCmd];
    
    offset = (offset<0)?0:offset;
    
    NSString *validDate = [self getTodayZeroTimeStamp];;
    NSString *uid = [ApiCmdBar_getAllBars getTimeStampUid:dataType];
    TimeStamp *timeStamp = [TimeStamp MR_findFirstByAttribute:@"uid" withValue:uid inContext:[NSManagedObjectContext MR_contextForCurrentThread]];
    //判断是否刷新数据
    if (isNewData) {
        if (timeStamp == nil)
        {
            ABLoggerInfo(@"插入 酒吧 TimeStamp 新数据 ======= %@",uid);
            timeStamp = [TimeStamp MR_createInContext:[NSManagedObjectContext MR_contextForCurrentThread]];
        }
        timeStamp.uid = uid;
        timeStamp.locationDate = [self getTodayTimeStamp];
        [[NSManagedObjectContext MR_contextForCurrentThread] MR_saveToPersistentStoreAndWait];
    }else{
        if (timeStamp!=nil) {
            if (([validDate compare:timeStamp.locationDate options:NSNumericSearch] != NSOrderedDescending)) {
                validDate = timeStamp.locationDate;
            }
        }
    }
    
    //先从数据库里面读取数据
    NSArray *coreData_array = [self getBarsListFromCoreDataOffset:offset limit:limit Latitude:latitude longitude:longitude dataType:dataType validDate:validDate];
    
    if ([coreData_array count]>0 && delegate && [delegate respondsToSelector:@selector(apiNotifyLocationResult:cacheData:)]) {
        [delegate apiNotifyLocationResult:nil cacheData:coreData_array];
        return tapiCmd;
    }
    
    //因为数据库里没有数据或是数据过期，所以向服务器请求数据
    if (tapiCmd!=nil)
        if ([[[[ApiClient defaultClient] networkQueue] operations]containsObject:tapiCmd.httpRequest]) {
            ABLoggerWarn(@"不能请求 酒吧 列表数据，因为已经请求了");
            return tapiCmd;
        }
    
    ApiClient* apiClient = [ApiClient defaultClient];
    
    ApiCmdBar_getAllBars* apiCmdBar_getAllBars = [[ApiCmdBar_getAllBars alloc] init];
    apiCmdBar_getAllBars.delegate = delegate;
    apiCmdBar_getAllBars.offset = offset;
    
    apiCmdBar_getAllBars.limit = limit;
    if (limit==0) {
        apiCmdBar_getAllBars.limit = DataLimit;
    }
    
    apiCmdBar_getAllBars.cityId = [[LocationManager defaultLocationManager] getUserCityId];
    [apiClient executeApiCmdAsync:apiCmdBar_getAllBars];
    [apiCmdBar_getAllBars.httpRequest setTag:API_KKTVCmd];
    
    return [apiCmdBar_getAllBars autorelease];
    
}

- (NSArray *)getBarsListFromCoreDataOffset:(int)offset
                                     limit:(int)limit
                                  Latitude:(CLLocationDegrees)latitude
                                 longitude:(CLLocationDegrees)longitude
                                  dataType:(NSString *)dataType
                                 validDate:(NSString *)validDate{
    
    return [self getBarsListFromCoreDataWithCityName:nil offset:offset limit:limit Latitude:latitude longitude:longitude dataType:dataType validDate:validDate];
    
}

- (NSArray *)getBarsListFromCoreDataWithCityName:(NSString *)cityId
                                          offset:(int)offset
                                           limit:(int)limit
                                        Latitude:(CLLocationDegrees)latitude
                                       longitude:(CLLocationDegrees)longitude
                                        dataType:(NSString *)dataType
                                       validDate:(NSString *)validDate{
    NSString *sortStr = @"begintime";
    BOOL isAscending = YES;
    if ([dataType intValue]==2) {
        sortStr = @"popular";
        isAscending = NO;
    }
    
    return [BBar MR_findAllSortedBy:sortStr ascending:isAscending withPredicate:[NSPredicate predicateWithFormat:@"locationDate >= %@",validDate] offset:offset limit:limit inContext:[NSManagedObjectContext MR_contextForCurrentThread]];
}



- (NSArray *)insertBarsIntoCoreDataFromObject:(NSDictionary *)objectData withApiCmd:(ApiCmd*)apiCmd{
    CFTimeInterval time1 = Elapsed_Time;
    
    NSMutableArray *returnArray = [[NSMutableArray alloc] initWithCapacity:20];
    NSArray *array = [[objectData objectForKey:@"data"]objectForKey:@"events"];
    
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
        bBar.cityId = city.uid;
        [returnArray addObject:bBar];
    }
    
    [[NSManagedObjectContext MR_contextForCurrentThread] MR_saveToPersistentStoreWithCompletion:^(BOOL success, NSError *error) {
        ABLoggerDebug(@"酒吧 保存是否成功 ========= %d",success);
        ABLoggerDebug(@"错误信息 ========= %@",[error description]);
    }];
    
    CFTimeInterval time2 = Elapsed_Time;
    ElapsedTime(time2, time1);
    
    [[[ApiClient defaultClient] requestArray] removeObject:apiCmd];
    ABLoggerWarn(@"remove request array count === %d",[[[ApiClient defaultClient] requestArray] count]);
    
    return [returnArray autorelease];
}

/*
 {
 httpCode: 200,
 errors: [ ],
 data: {
 count: 16,
 events: [
 {
 id: "1",
 barid: "1",
 barname: "bar",
 eventname: "欢乐相聚",
 address: "",
 latitude: "31.21569",
 longitude: "121.43956",
 type: "1",
 cityid: "0",
 districtid: "1",
 begintime: "2013-07-15 10:00:00",
 endtime: "2013-07-16",
 eventtime: "10.5",
 hotadded: "41",
 price: "60",
 recommendadded: "29",
 wantedadded: "11",
 description: null,
 eventurl: null,
 tag: "0",
 currentstatus: "3",
 createtime: "2013-07-15 15:32:43",
 createdbysuid: "11",
 lastmodifiedtime: "2013-07-15 15:45:52",
 lastmodifiedbysuid: "11",
 hot: 41,
 recommend: 29,
 want: 11
 },
 {},
 {}
 ]
 },
 token: null,
 timestamp: "1373876492"
 }
 */
- (void)importBar:(BBar *)bBar ValuesForKeysWithObject:(NSDictionary *)aBarDic{
    bBar.uid = [aBarDic objectForKey:@"id"];
    bBar.barId = [aBarDic objectForKey:@"barid"];
    bBar.name = [aBarDic objectForKey:@"eventname"];
    bBar.barName = [aBarDic objectForKey:@"barname"];
    bBar.popular = [aBarDic objectForKey:@"hotadded"];
    bBar.address = [aBarDic objectForKey:@"address"];
    bBar.begintime = [aBarDic objectForKey:@"begintime"];
    bBar.phoneNumber = [[aBarDic objectForKey:@"tel"] stringValue];
//    bBar.longitude = [aBarDic objectForKey:@"longitude"];
//    bBar.latitude = [aBarDic objectForKey:@"latitude"];
    bBar.locationDate = [self getTodayTimeStamp];
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
    apiCmdKTV_getAllKTVs.cityId = [[LocationManager defaultLocationManager] getUserCityId];
    [apiClient executeApiCmdAsync:apiCmdKTV_getAllKTVs];
    [apiCmdKTV_getAllKTVs.httpRequest setTag:API_KKTVCmd];
    
    return [apiCmdKTV_getAllKTVs autorelease];
}

- (NSArray *)getAllKTVsListFromCoreData{
    return [self getAllKTVsListFromCoreDataWithCityName:nil];
}

- (NSArray *)getAllKTVsListFromCoreDataWithCityName:(NSString *)cityId{
    if (isEmpty(cityId)) {
        cityId = [[LocationManager defaultLocationManager] getUserCityId];
    }
    
    //    return [KKTV MR_findAllWithPredicate:[NSPredicate predicateWithFormat:@"cityId = %@", cityId] inContext:[NSManagedObjectContext MR_contextForCurrentThread]];
    return [KKTV MR_findAllSortedBy:@"districtid" ascending:NO withPredicate:[NSPredicate predicateWithFormat:@"cityId = %@", cityId]  inContext:[NSManagedObjectContext MR_contextForCurrentThread]];
}

#pragma mark 获取 分页 KTV数据
- (ApiCmd *)getKTVsListFromWeb:(id<ApiNotify>)delegate offset:(int)offset limit:(int)limit{
    ApiCmd *tapiCmd = [delegate apiGetDelegateApiCmd];
    
    offset = (offset<=0)?0:offset;
    //先从数据库里面读取数据
    NSArray *coreData_array = [self getKTVsListFromCoreDataOffset:offset limit:limit];
    
    if ([coreData_array count]>0 && delegate && [delegate respondsToSelector:@selector(apiNotifyLocationResult:cacheData:)]) {
        [delegate apiNotifyLocationResult:nil cacheData:coreData_array];
        return tapiCmd;
    }
    
    if (tapiCmd!=nil)
        if ([[[[ApiClient defaultClient] networkQueue] operations]containsObject:tapiCmd.httpRequest]) {
            ABLoggerWarn(@"不能请求 KTV 列表数据，因为已经请求了");
            return tapiCmd;
        }
    
    ApiClient* apiClient = [ApiClient defaultClient];
    
    ApiCmdKTV_getAllKTVs* apiCmdKTV_getAllKTVs = [[ApiCmdKTV_getAllKTVs alloc] init];
    apiCmdKTV_getAllKTVs.delegate = delegate;
    apiCmdKTV_getAllKTVs.offset = offset;
    
    apiCmdKTV_getAllKTVs.limit = limit;
    if (limit==0) {
        apiCmdKTV_getAllKTVs.limit = DataLimit;
    }
    
    apiCmdKTV_getAllKTVs.cityId = [[LocationManager defaultLocationManager] getUserCityId];
    [apiClient executeApiCmdAsync:apiCmdKTV_getAllKTVs];
    [apiCmdKTV_getAllKTVs.httpRequest setTag:API_KKTVCmd];
    
    return [apiCmdKTV_getAllKTVs autorelease];
}

#pragma mark 搜索 KTV数据
- (ApiCmd *)getKTVsSearchListFromWeb:(id<ApiNotify>)delegate offset:(int)offset limit:(int)limit searchString:(NSString *)searchString{
    ApiCmd *tapiCmd = [delegate apiGetDelegateApiCmd];
    
    offset = (offset<=0)?0:offset;
    
    if (tapiCmd!=nil)
        if ([[[[ApiClient defaultClient] networkQueue] operations]containsObject:tapiCmd.httpRequest]) {
            ABLoggerWarn(@"不能请求 KTV 列表数据，因为已经请求了");
            return tapiCmd;
        }
    
    ApiClient* apiClient = [ApiClient defaultClient];
    
    ApiCmdKTV_getSearchKTVs* apiCmdKTV_getSearchKTVs = [[ApiCmdKTV_getSearchKTVs alloc] init];
    apiCmdKTV_getSearchKTVs.delegate = delegate;
    apiCmdKTV_getSearchKTVs.offset = offset;
    
    apiCmdKTV_getSearchKTVs.limit = limit;
    if (limit==0) {
        apiCmdKTV_getSearchKTVs.limit = DataLimit;
    }
    apiCmdKTV_getSearchKTVs.searchString = searchString;
    apiCmdKTV_getSearchKTVs.cityId = [[LocationManager defaultLocationManager] getUserCityId];
    [apiClient executeApiCmdAsync:apiCmdKTV_getSearchKTVs];
    [apiCmdKTV_getSearchKTVs.httpRequest setTag:API_KKTVCmd];
    
    return [apiCmdKTV_getSearchKTVs autorelease];
}

- (NSArray *)getKTVsListFromCoreDataOffset:(int)offset limit:(int)limit{
    return [self getKTVsListFromCoreDataWithCityName:nil offset:offset limit:limit];
}

- (NSArray *)getKTVsListFromCoreDataWithCityName:(NSString *)cityId offset:(int)offset limit:(int)limit{
    if (isEmpty(cityId)) {
        cityId = [[LocationManager defaultLocationManager] getUserCityId];
    }
    
    return [KKTV MR_findAllSortedBy:@"districtid" ascending:YES withPredicate:[NSPredicate predicateWithFormat:@"cityId = %@", cityId] offset:offset limit:limit inContext:[NSManagedObjectContext MR_contextForCurrentThread]];
}

#pragma mark 附近 KTV数据
- (BOOL)getNearbyKTVListFromCoreDataWithCallBack:(GetKTVNearbyList)callback{
    GetKTVNearbyList mCallBack = [callback copy];
    
    NSArray *ktvs = [self getAllKTVsListFromCoreData];
    LocationManager *lm = [LocationManager defaultLocationManager];
    BOOL isSuccess =  [lm getUserGPSLocationWithCallBack:^(BOOL isEnableGPS, BOOL isSuccess) {
        
        for (KKTV *tKTV in ktvs) {
            double distance = [lm distanceBetweenUserToLatitude:[tKTV.latitude doubleValue] longitude:[tKTV.longitude doubleValue]];
            tKTV.nearby = [NSNumber numberWithInt:distance];
        }
        
        [self saveInManagedObjectContext:[NSManagedObjectContext MR_contextForCurrentThread]];
        
        NSArray *array =  [ktvs sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
            MCinema *cinema1 = (MCinema *)obj1;
            MCinema *cinema2 = (MCinema *)obj2;
            return [cinema1.nearby compare:cinema2.nearby];
        }];
        
        if (mCallBack) {
            mCallBack(array,isSuccess);
        }
    }];
    
    return isSuccess;
    
}

#pragma mark 附近 分页 KTV数据
- (ApiCmd *)getNearbyKTVListFromCoreDataWithCallBack:(id<ApiNotify>)delegate
                                            Latitude:(CLLocationDegrees)latitude
                                           longitude:(CLLocationDegrees)longitude
                                              offset:(int)offset
                                               limit:(int)limit
{
    offset = (offset<=0)?0:offset;
    
    ApiCmd *tapiCmd = [delegate apiGetDelegateApiCmd];
    
    if (tapiCmd!=nil)
        if ([[[[ApiClient defaultClient] networkQueue] operations]containsObject:tapiCmd.httpRequest]) {
            ABLoggerWarn(@"不能请求 KTV 列表数据，因为已经请求了");
            return tapiCmd;
        }
    
    ApiClient* apiClient = [ApiClient defaultClient];
    
    ApiCmdKTV_getAllKTVs* apiCmdKTV_getAllKTVs = [[ApiCmdKTV_getAllKTVs alloc] init];
    apiCmdKTV_getAllKTVs.delegate = delegate;
    apiCmdKTV_getAllKTVs.offset = offset;
    
    apiCmdKTV_getAllKTVs.limit = limit;
    if (limit==0) {
        apiCmdKTV_getAllKTVs.limit = DataLimit;
    }
    
    apiCmdKTV_getAllKTVs.cityId = [[LocationManager defaultLocationManager] getUserCityId];
    [apiCmdKTV_getAllKTVs.httpRequest setTag:API_KKTVCmd];
    [apiClient executeApiCmdAsync:apiCmdKTV_getAllKTVs];
    
    return [apiCmdKTV_getAllKTVs autorelease];
    
}

- (NSArray *)getFavoriteKTVListFromCoreData{
    return [self getFavoriteKTVListFromCoreDataWithCityName:nil];
}

- (NSArray *)getFavoriteKTVListFromCoreDataWithCityName:(NSString *)cityName{
    if (isEmpty(cityName)) {
        cityName = [[LocationManager defaultLocationManager] getUserCityId];
    }
    
    return [KKTV MR_findAllSortedBy:@"districtid" ascending:YES withPredicate:[NSPredicate predicateWithFormat:@"cityId = %@ and favorite = YES", cityName]  inContext:[NSManagedObjectContext MR_contextForCurrentThread]];
}

- (NSUInteger)getCountOfKTVsListFromCoreData{
    return [self getCountOfKTVsListFromCoreDataWithCityName:nil];
}

- (NSUInteger)getCountOfKTVsListFromCoreDataWithCityName:(NSString *)cityName{
    if (isEmpty(cityName)) {
        cityName = [[LocationManager defaultLocationManager] getUserCityId];
    }
    int count = [KKTV MR_countOfEntitiesWithPredicate:[NSPredicate predicateWithFormat:@"cityId = %@", cityName] inContext:[NSManagedObjectContext MR_contextForCurrentThread]];
    return count;
    
}

/*
 
 {
 httpCode: 200,
 errors: [ ],
 data: {
 count: "2",
 list: [
 {
 districtName: "罗湖区",
 list: [
 {
 id: "4",
 uniquekey: "4e102c824e1953e791027ea00e54234b",
 name: "镭射卡拉OK",
 description: "",
 address: "丹沙路沙湾花园",
 contactphone: "0755-28749649",
 latitude: "22.61036",
 longitude: "114.16132",
 cityid: "4",
 districtid: "2",
 logourl: "logourl",
 coverurl: "http://i2.dpfile.com/pc/000c14f9d31465a8820b18e3f42ed45d(700x700)/thumb.jpg",
 specialoffers: "",
 trafficroutes: "655路",
 exturl: "http://dpurl.cn/p/Cs9r4Ka-A4",
 createtime: "2013-07-03 16:37:37",
 createdbysuid: "11",
 lastmodifiedtime: "2013-07-05 15:59:05",
 lastmodifiedbysuid: "1",
 source: "1",
 currentstatus: "3"
 }
 ]
 },
 */
- (NSArray *)insertKTVsIntoCoreDataFromObject:(NSDictionary *)objectData withApiCmd:(ApiCmd*)apiCmd{
    CFTimeInterval time1 = Elapsed_Time;
    NSManagedObjectContext *dataBaseContext = [NSManagedObjectContext MR_contextForCurrentThread];
    NSArray *array = [[objectData objectForKey:@"data"]objectForKey:@"list"];
    
    KKTV *kKTV = nil;
    NSMutableArray *returnArray = [[NSMutableArray alloc] initWithCapacity:20];
    for (int i=0; i<[array count]; i++) {
        
        NSString *districtStr = [[array objectAtIndex:i] objectForKey:@"districtName"];
        NSArray *arrayktvs = [[array objectAtIndex:i] objectForKey:@"list"];
        for (int j=0; j<[arrayktvs count]; j++) {
            kKTV = [KKTV MR_findFirstByAttribute:@"uid" withValue:[[arrayktvs objectAtIndex:j] objectForKey:@"id"] inContext:dataBaseContext];
            if (kKTV == nil)
            {
                ABLoggerInfo(@"插入 一条 KTV 新数据 ======= %@",[[arrayktvs objectAtIndex:j] objectForKey:@"name"]);
                kKTV = [KKTV MR_createInContext:dataBaseContext];
            }
            kKTV.district = districtStr;
            kKTV.cityId = apiCmd.cityId;
            [self importKTV:kKTV ValuesForKeysWithObject:[arrayktvs objectAtIndex:j]];
            [returnArray addObject:kKTV];
        }
    }
    
    //    [dataBaseContext MR_saveToPersistentStoreWithCompletion:^(BOOL success, NSError *error) {
    //        ABLoggerDebug(@"KTV 保存是否成功 ========= %d",success);
    //        ABLoggerDebug(@"错误信息 ========= %@",[error description]);
    //    }];
    [dataBaseContext MR_saveToPersistentStoreAndWait];
    
    CFTimeInterval time2 = Elapsed_Time;
    ElapsedTime(time2, time1);
    
    [[[ApiClient defaultClient] requestArray] removeObject:apiCmd];
    ABLoggerWarn(@"remove request array count === %d",[[[ApiClient defaultClient] requestArray] count]);
    
    return [returnArray autorelease];
}

- (void)importKTV:(KKTV *)kKTV ValuesForKeysWithObject:(NSDictionary *)aKTVDic{
    kKTV.name = [aKTVDic objectForKey:@"name"];
    kKTV.uid = [aKTVDic objectForKey:@"id"];
    kKTV.districtid = [aKTVDic objectForKey:@"districtid"];
    kKTV.address = [aKTVDic objectForKey:@"address"];
    kKTV.phoneNumber = [aKTVDic objectForKey:@"contactphone"];
    kKTV.longitude = [NSNumber numberWithFloat:[[aKTVDic objectForKey:@"longitude"] floatValue]];
    kKTV.latitude = [NSNumber numberWithFloat:[[aKTVDic objectForKey:@"latitude"] floatValue]];
}

- (BOOL)addFavoriteKTVWithId:(NSString *)uid{
    
    NSManagedObjectContext* threadContext = [NSManagedObjectContext MR_contextForCurrentThread];
    KKTV *tKTV = [KKTV MR_findFirstByAttribute:@"uid" withValue:uid inContext:threadContext];
    
    if (!tKTV) {
        return NO;
    }
    
    tKTV.favorite = [NSNumber numberWithBool:YES];
    
    [threadContext MR_saveToPersistentStoreAndWait];
    //    [threadContext MR_saveToPersistentStoreWithCompletion:^(BOOL success, NSError *error) {
    //        ABLoggerDebug(@"收藏KTV 保存是否成功 ========= %d",success);
    //        ABLoggerDebug(@"错误信息 ========= %@",[error description]);
    //    }];
    
    return YES;
}

- (BOOL)deleteFavoriteKTVWithId:(NSString *)uid{
    
    NSManagedObjectContext* threadContext = [NSManagedObjectContext MR_contextForCurrentThread];
    KKTV *tKTV = [KKTV MR_findFirstByAttribute:@"uid" withValue:uid inContext:threadContext];
    
    if (!tKTV) {
        return NO;
    }
    
    tKTV.favorite = [NSNumber numberWithBool:NO];
    [threadContext MR_saveToPersistentStoreAndWait];
    //    [threadContext MR_saveToPersistentStoreWithCompletion:^(BOOL success, NSError *error) {
    //        ABLoggerDebug(@"收藏KTV 保存是否成功 ========= %d",success);
    //        ABLoggerDebug(@"错误信息 ========= %@",[error description]);
    //    }];
    
    return YES;
}

//获得KTV 团购列表 KTV Info
- (ApiCmd *)getKTVTuanGouListFromWebWithaKTV:(KKTV *)aKTV
                                    delegate:(id<ApiNotify>)delegate{
    ApiCmd *tapiCmd = [delegate apiGetDelegateApiCmd];
    
}
- (void)insertKTVTuanGouListIntoCoreDataFromObject:(NSDictionary *)objectData
                                        withApiCmd:(ApiCmd*)apiCmd
                                          withaKTV:(KKTV *)aKTV{
    
}

//获得KTV 价格列表 Info
- (ApiCmd *)getKTVPriceListFromWebWithaKTV:(KKTV *)aKTV
                                  delegate:(id<ApiNotify>)delegate{
    
    ApiCmd *tapiCmd = [delegate apiGetDelegateApiCmd];
    
    if ([[[[ApiClient defaultClient] networkQueue] operations]containsObject:tapiCmd.httpRequest]) {
        ABLoggerWarn(@"不能请求 KTV 价格列表 数据，因为已经请求了");
        return tapiCmd;
    }
    
    ApiClient* apiClient = [ApiClient defaultClient];
    
    ApiCmdKTV_getPriceList* apiCmdKTV_getPriceList = [[ApiCmdKTV_getPriceList alloc] init];
    apiCmdKTV_getPriceList.delegate = delegate;
    apiCmdKTV_getPriceList.cityName = [[LocationManager defaultLocationManager] getUserCity];
    apiCmdKTV_getPriceList.ktvId = aKTV.uid;
    [apiClient executeApiCmdAsync:apiCmdKTV_getPriceList];
    [apiCmdKTV_getPriceList.httpRequest setTag:API_KKTVPriceListCmd];
    
    return [apiCmdKTV_getPriceList autorelease];
}

- (void)insertKTVPriceListIntoCoreDataFromObject:(NSDictionary *)objectData
                                      withApiCmd:(ApiCmd*)apiCmd
                                        withaKTV:(KKTV *)aKTV{
    
}
//========================================= KTV =========================================/
@end
