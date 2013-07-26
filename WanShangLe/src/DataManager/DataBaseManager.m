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

#pragma mark 缓存大小
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

#pragma mark 清除数据缓存
- (BOOL)cleanUpDataBaseCache{
    
    //清除缓存的图片
    NSString *cachePath = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"com.hackemist.SDWebImageCache.default"];
    ABLoggerDebug(@"cachePath = %@",cachePath);
    [[NSFileManager defaultManager] removeItemAtPath:cachePath error:nil];
    
    //清除缓存的CoreData
    
    return YES;
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
//服务器时间
-(NSDate *)date{
    NSDate *newDate = [[NSDate date] dateByAddingTimeInterval:_missTime];
//    ABLoggerDebug(@"手机时间 ======= %@",[NSDate date]);
//    ABLoggerDebug(@"服务器时间 ======= %@",newDate);
//    ABLoggerDebug(@"时间差 ======= %0.0f",_missTime);
    return newDate;
}

- (BOOL)isToday:(NSString *)date{
    _timeFormatter.dateFormat = @"yyyy-MM-dd";
    NSString *nowDate = [_timeFormatter stringFromDate:[[DataBaseManager sharedInstance] date]];
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
    //    ABLoggerDebug(@"%@",[_timeFormatter stringFromDate:aDate]);
    return [_timeFormatter stringFromDate:aDate];
}

-(NSDate *)trueDate:(NSDate *)formatDate{
    
    NSTimeZone *zone = [NSTimeZone localTimeZone];;
    
    NSInteger interval = [zone secondsFromGMTForDate: formatDate];
    
    NSDate *localeDate = [formatDate  dateByAddingTimeInterval: interval];
    
    ABLoggerDebug(@"localeDate ====== %@", localeDate);
    
    return localeDate;
}

//几天后的时间
- (NSString *)dateWithTimeIntervalSinceNow:(NSTimeInterval)timeInterval fromDate:(NSString *)beginDate{
    _timeFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    NSDate *afterDate = [_timeFormatter dateFromString:beginDate];
    afterDate = [NSDate dateWithTimeIntervalSinceNow:timeInterval];//(2*30*24 * 60 * 60)两个月
    
    return [_timeFormatter stringFromDate:afterDate];
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
    
    NSString *movie_cinema_uid = [[NSString alloc] initWithFormat:@"%@%@%@%@",aCinema.cityId,aCinema.cityName,aCinema.uid,aMovie.uid];
    movie_cinema = [MMovie_Cinema MR_findFirstByAttribute:@"uid" withValue:movie_cinema_uid inContext:[NSManagedObjectContext MR_contextForCurrentThread]];
    if (movie_cinema == nil) {
        movie_cinema = [MMovie_Cinema MR_createInContext:[NSManagedObjectContext MR_contextForCurrentThread]];
    }
    movie_cinema.uid = movie_cinema_uid;
    movie_cinema.movie = aMovie;
    movie_cinema.cinema = aCinema;
    movie_cinema.locationDate = [self getTodayTimeStamp];
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
    apiCmdMovie_getAllMovies.cityId = [[LocationManager defaultLocationManager] getUserCityId];
    [apiClient executeApiCmdAsync:apiCmdMovie_getAllMovies];
    [apiCmdMovie_getAllMovies.httpRequest setTag:API_MMovieCmd];
    
    return [apiCmdMovie_getAllMovies autorelease];
}

- (NSArray *)getAllMoviesListFromCoreData
{
    return [self getAllMoviesListFromCoreDataWithCityName:nil];
}

- (NSArray *)getAllMoviesListFromCoreDataWithCityName:(NSString *)cityName{
    
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
 {
 httpCode: 200,
 errors: [ ],
 data: {
 movies: [
 {
 id: "19",
 uniquekey: "3a35241f73cb36a91fb90d4339272798",
 name: "不二神探",
 url: "http://movie.douban.com/subject/10604486/",
 rating: "4.9",
 ratingcount: "36877",
 director: "王子鸣",
 star: "文章,李连杰,刘诗诗,陈妍希,柳岩,马伊琍,黄晓明,佟大为,冯德伦,吴京,邹兆龙,郑嘉颖,梁小龙,谢天华,张梓琳,邓丽欣,田亮,方力申,梁家仁,林雪,何超仪",
 type: "喜剧,动作,犯罪",
 hotstarttime: null,
 tag: "0",
 startday: "2013-06-21",
 description: "　　短短几天内，电影明星、舞蹈演员、跳水冠军，三个没有任何关联的知名人士面带微笑意外死亡，在社会上引起不小的轰动。与此同时，擅长搞怪耍宝的热血青年警察王不二（文章 饰）与深藏不露的警队老油条黄飞红（李连杰 饰）搭档破案，惹出不少的乱子，令他们的上司Ａｎｇｅｌａ（陈妍希 饰）郁闷不已。某天，地产项目经理王峰（佟大为 饰）微笑死亡，案子交到Ａｎｇｅｌａ一组手中。为了尽快扭转警局中的不利局面，Ａｎｇｅｌａ、王不二和黄飞红展开全力追查，他们率先从与几名死者都有过交往的女演员刘金水（刘诗诗 饰）入手。而在这一过程中，妖艳鬼魅的戴依依（柳岩 饰）出现，无疑令案情朝向更为扑朔迷离的方向发展。 　　最终真相如何，王不二能否立下奇功？",
 duration: "98",
 coverurl: "http://em.wanshangle.com:8888/attachments/image/movie/c8/rq/80290_1373878359.jpg",
 imagesurl: "http://img3.douban.com/img/trailer/medium/2011511021.jpg,http://img3.douban.com/view/photo/albumicon/public/p1997525540.jpg,http://img3.douban.com/view/photo/albumicon/public/p1958078286.jpg,http://img3.douban.com/view/photo/albumicon/public/p1958082672.jpg,http://img3.douban.com/view/photo/albumicon/public/p1997525534.jpg",
 trailersurl: "http://movie.douban.com/trailer/136839/#content",
 status: "0",
 coverimg: "",
 createtime: "2013-07-15 16:54:05",
 createdbysuid: "12",
 lastmodifiedtime: "2013-07-17 15:33:56",
 lastmodifiedbysuid: "12",
 currentstatus: "3",
 votecountadded: "0",
 ratingadded: "0",
 ratingcountadded: "0",
 recommendadded: "66",
 wantedadded: "39"
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
    
    mMovie.rating =[amovieData objectForKey:@"rating"];
    mMovie.ratingpeople = [amovieData objectForKey:@"ratingcount"];
    
    mMovie.locationDate = [self getTodayTimeStamp];
}

- (void)importDynamicMovie:(MMovie *)mMovie ValuesForKeysWithObject:(NSDictionary *)amovieData
{
    //    ABLoggerInfo(@"amovieData == %@",amovieData);
    mMovie.newMovie = [amovieData objectForKey:@"newMovie"];
    mMovie.ratingFrom = [amovieData objectForKey:@"ratingFrom"];
    mMovie.twoD = [NSNumber numberWithInt:[[[amovieData objectForKey:@"viewtypes"] objectAtIndex:0] intValue]];
    mMovie.threeD = [NSNumber numberWithInt:[[[amovieData objectForKey:@"viewtypes"] objectAtIndex:1] intValue]];
    mMovie.iMaxD = [NSNumber numberWithInt:[[[amovieData objectForKey:@"viewtypes"] objectAtIndex:2] intValue]];
}

- (BOOL)addFavoriteCinemaWithId:(NSString *)uid{
    NSManagedObjectContext* threadContext = [NSManagedObjectContext MR_contextForCurrentThread];
    MCinema *tCinema = [MCinema MR_findFirstByAttribute:@"uid" withValue:uid inContext:threadContext];
    
    if (!tCinema) {
        return NO;
    }
    
    tCinema.favorite = [NSNumber numberWithBool:YES];
    
    [threadContext MR_saveToPersistentStoreAndWait];
    
    return YES;
}

- (BOOL)deleteFavoriteCinemaWithId:(NSString *)uid{
    NSManagedObjectContext* threadContext = [NSManagedObjectContext MR_contextForCurrentThread];
    MCinema *tCinema = [MCinema MR_findFirstByAttribute:@"uid" withValue:uid inContext:threadContext];
    
    if (!tCinema) {
        return NO;
    }
    
    tCinema.favorite = [NSNumber numberWithBool:NO];
    
    [threadContext MR_saveToPersistentStoreAndWait];
    
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

- (MMovieDetail *)insertMovieDetailIntoCoreDataFromObject:(NSDictionary *)objectData withApiCmd:(ApiCmd*)apiCmd{
    
    MMovieDetail *tMovieDetail = nil;
    
    if (objectData) {
        
        NSDictionary *tDic = [[objectData objectForKey:@"data"] objectForKey:@"info"];
        
        NSManagedObjectContext *context = [NSManagedObjectContext MR_contextForCurrentThread];
        NSString *movie_id = [tDic objectForKey:@"id"];
        
        
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
    }
    
    [[[ApiClient defaultClient] requestArray] removeObject:apiCmd];
    ABLoggerWarn(@"remove request array count === %d",[[[ApiClient defaultClient] requestArray] count]);
    
    return tMovieDetail;
}

- (void)importMovieDetail:(MMovieDetail *)aMovieDetail ValuesForKeysWithObject:(NSDictionary *)amovieDetailData{
    aMovieDetail.wantlook = [amovieDetailData objectForKey:@"wantedadded"];
    aMovieDetail.recommendation = [amovieDetailData objectForKey:@"recommendadded"];
    aMovieDetail.info = amovieDetailData;
    aMovieDetail.uid = [amovieDetailData objectForKey:@"id"];
    aMovieDetail.locationDate = [self getTodayTimeStamp];
}

/*
 {
 httpCode: 200,
 errors: [ ],
 data: {
 info: {
 id: "1",
 uniquekey: "8241d9ad7f3858e73038a37b05083d0d",
 name: "早见，晚爱",
 url: "http://www.gewara.com//movie/124755671",
 rating: "0.0",
 ratingcount: "0",
 director: "刘国昌",
 star: "周渝民,童瑶,曹云金,白羽,叶倩云,陈维涵,刘鑫,姜寒,海波",
 type: "剧情, 爱情",
 hotstarttime: "2013-07-15 19:07:09",
 tag: "0",
 startday: "2013-07-19",
 description: "　　年轻创业美女老板周挺带领三姐妹与腹黑男展开一场斗智斗勇的收购反击战。曾经的校园初恋为了各自立场不得不近场搏杀，不可退让——然而旧情难消，余情未了，新欢作祟，恶棍搅局，更有屌丝财主阳奉阴违，暗度陈仓，白富美强爱上位，骑虎难下……在这部充斥阳谋与初恋的商战危情中，且看美女老板究竟是以身抵债，名利双煞，还以情破局、重归原点？一切悬念尽在一天的9小时中悉数道来……",
 duration: "100",
 coverurl: "http://em.wanshangle.com:8888/attachments/image/movie/5i/rv/22750_1373853172.jpg",
 imagesurl: "",
 trailersurl: "",
 status: "0",
 coverimg: "",
 createtime: "2013-07-15 09:53:59",
 createdbysuid: "12",
 lastmodifiedtime: "2013-07-15 19:07:09",
 lastmodifiedbysuid: "9",
 currentstatus: "3",
 votecountadded: "0",
 ratingadded: "0",
 ratingcountadded: "0",
 recommendadded: "59",
 wantedadded: "25"
 }
 },
 token: null,
 timestamp: "1374138625"
 }
 */

- (MMovieDetail *)insertMovieRecommendIntoCoreDataFromObject:(NSDictionary *)objectData withApiCmd:(ApiCmd*)apiCmd{
    
    NSDictionary *infoDic = [[objectData objectForKey:@"data"] objectForKey:@"interact"];
    NSManagedObjectContext *context = [NSManagedObjectContext MR_contextForCurrentThread];
    MMovieDetail *movieDetail = [MMovieDetail MR_findFirstByAttribute:@"uid" withValue:[infoDic objectForKey:@"movieid"] inContext:context];
    
    if (movieDetail==nil) {
        movieDetail = [MMovieDetail MR_createInContext:context];
        movieDetail.uid = [infoDic objectForKey:@"movieid"];
    }
    movieDetail.recommendation = [infoDic objectForKey:@"recommend"];
    movieDetail.wantlook = [infoDic objectForKey:@"look"];
    
    [self saveInManagedObjectContext:context];
    
    [[[ApiClient defaultClient] requestArray] removeObject:apiCmd];
    ABLoggerWarn(@"remove request array count === %d",[[[ApiClient defaultClient] requestArray] count]);
    
    return movieDetail;
    
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
- (ApiCmd *)getScheduleFromWebWithaMovie:(MMovie *)aMovie
                              andaCinema:(MCinema *)aCinema
                            timedistance:(NSString *)timedistance
                                delegate:(id<ApiNotify>)delegate
{
    ApiCmd *tapiCmd = [delegate apiGetDelegateApiCmd];
    
    MSchedule *tSchedule = [self getScheduleFromCoreDataWithaMovie:aMovie andaCinema:aCinema timedistance:timedistance];
    if (tSchedule!=nil) {
        NSDictionary *tDic = [NSDictionary dictionaryWithObjectsAndKeys:tSchedule,@"schedule",
                              timedistance,@"timedistance",nil];
        [delegate apiNotifyLocationResult:tapiCmd cacheDictionaryData:tDic];
        return tapiCmd;
    }
    
    //因为数据库里没有数据或是数据过期，所以向服务器请求数据
    if (tapiCmd!=nil)
        if ([[[[ApiClient defaultClient] networkQueue] operations]containsObject:tapiCmd.httpRequest]) {
            ABLoggerWarn(@"不能请求 排期了 列表数据，因为已经请求了");
            return tapiCmd;
        }
    
    ApiClient* apiClient = [ApiClient defaultClient];
    ApiCmdMovie_getSchedule* apiCmdMovie_getSchedule = [[ApiCmdMovie_getSchedule alloc] init];
    apiCmdMovie_getSchedule.delegate = delegate;
    apiCmdMovie_getSchedule.cityName = [[LocationManager defaultLocationManager] getUserCity];
    apiCmdMovie_getSchedule.cityId = [[LocationManager defaultLocationManager] getUserCityId];
    apiCmdMovie_getSchedule.movie_id = aMovie.uid;
    apiCmdMovie_getSchedule.cinema_id = aCinema.uid;
    apiCmdMovie_getSchedule.timedistance = timedistance;
    [apiClient executeApiCmdAsync:apiCmdMovie_getSchedule];
    [apiCmdMovie_getSchedule.httpRequest setTag:API_MScheduleCmd];
    
    return [apiCmdMovie_getSchedule autorelease];
}

- (MSchedule *)getScheduleFromCoreDataWithaMovie:(MMovie *)aMovie andaCinema:(MCinema *)aCinema timedistance:(NSString *)timedistance{
    //isToday
    MSchedule *schedule = nil;
    NSString *movie_cinema_uid = [[NSString alloc] initWithFormat:@"%@%@%@%@",aCinema.cityId,aCinema.cityName,aCinema.uid,aMovie.uid];
    NSString *todayTimeStamp = [self getTodayZeroTimeStamp];
    schedule = [MSchedule MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"uid = %@ and locationDate >= %@ and timedistance = %@",movie_cinema_uid,todayTimeStamp,timedistance] inContext:[NSManagedObjectContext MR_contextForCurrentThread]];
    [movie_cinema_uid release];
    return schedule;
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

- (MSchedule *)insertScheduleIntoCoreDataFromObject:(NSDictionary *)objectData
                                         withApiCmd:(ApiCmd*)apiCmd
                                         withaMovie:(MMovie *)aMovie
                                         andaCinema:(MCinema *)aCinema{
    NSManagedObjectContext* context = [NSManagedObjectContext MR_contextForCurrentThread];
    
    NSDictionary *dataDic = [objectData objectForKey:@"data"];
    
    NSString *movie_cinema_uid = [[NSString alloc] initWithFormat:@"%@%@%@%@",aCinema.cityId,aCinema.cityName,aCinema.uid,aMovie.uid];
    MMovie_Cinema *movie_cinema = [MMovie_Cinema MR_findFirstByAttribute:@"uid" withValue:movie_cinema_uid inContext:context];
    if (movie_cinema == nil) {
        MMovie *tMovie = [MMovie MR_findFirstByAttribute:@"uid" withValue:aMovie.uid inContext:context];
        MCinema *tCinema = [MCinema MR_findFirstByAttribute:@"uid" withValue:aCinema.uid inContext:context];
        movie_cinema = [self insertMMovie_CinemaWithaMovie:tMovie andaCinema:tCinema];
    }
    
    NSString *todayTimeStamp = [self getTodayZeroTimeStamp];
    NSString *timedistance = [(ApiCmdMovie_getSchedule *)apiCmd timedistance];
    MSchedule *tSchedule = [MSchedule MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"uid = %@ and locationDate >= %@ and timedistance = %@",movie_cinema_uid,todayTimeStamp,timedistance] inContext:context];
    if (tSchedule==nil) {
        tSchedule = [MSchedule MR_createInContext:context];
    }
    
    ABLoggerDebug(@"dataDic == %@",dataDic);
    tSchedule.scheduleInfo = dataDic;
    tSchedule.uid = movie_cinema_uid;
    tSchedule.locationDate = [self getTodayTimeStamp];
    tSchedule.timedistance = timedistance;
    
    [context MR_saveToPersistentStoreAndWait];
    
    [movie_cinema_uid release];
    [[[ApiClient defaultClient] requestArray] removeObject:apiCmd];
    ABLoggerWarn(@"remove request array count === %d",[[[ApiClient defaultClient] requestArray] count]);
    
    return tSchedule;
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
    apiCmdMovie_getBuyInfo.cityId = [[LocationManager defaultLocationManager] getUserCityId];
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
    
    [[[ApiClient defaultClient] requestArray] removeObject:apiCmd];
    ABLoggerWarn(@"remove request array count === %d",[[[ApiClient defaultClient] requestArray] count]);
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
    apiCmdMovie_getAllCinemas.cityId = [[LocationManager defaultLocationManager] getUserCityId];
    
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
            double distance = [lm distanceBetweenUserToLatitude:[tCinema.latitude doubleValue] longitude:[tCinema.longitude doubleValue]];
            tCinema.distance = [NSNumber numberWithInt:distance];
        }
        
        [self saveInManagedObjectContext:[NSManagedObjectContext MR_contextForCurrentThread]];
        
        NSArray *array =  [cinemas sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
            MCinema *cinema1 = (MCinema *)obj1;
            MCinema *cinema2 = (MCinema *)obj2;
            return [cinema1.distance compare:cinema2.distance];
        }];
        
        if (mCallBack) {
            mCallBack(array,isSuccess);
        }
    }];
    
    return isSuccess;
}

#pragma mark 获取 分页 影院数据
- (ApiCmd *)getCinemasListFromWeb:(id<ApiNotify>)delegate
                           offset:(int)offset
                            limit:(int)limit
                         dataType:(NSString *)dataType
                        isNewData:(BOOL)isNewData
{
    ApiCmd *tapiCmd = [delegate apiGetDelegateApiCmd];
    
    offset = (offset<0)?0:offset;
    
    NSString *validDate = [self getTodayZeroTimeStamp];;
    NSString *uid = [ApiCmdMovie_getAllCinemas getTimeStampUid:nil];
    TimeStamp *timeStamp = [TimeStamp MR_findFirstByAttribute:@"uid" withValue:uid inContext:[NSManagedObjectContext MR_contextForCurrentThread]];
    //判断是否刷新数据
    if (isNewData) {
        if (timeStamp == nil)
        {
            ABLoggerInfo(@"插入 影院 TimeStamp 新数据 ======= %@",uid);
            timeStamp = [TimeStamp MR_createInContext:[NSManagedObjectContext MR_contextForCurrentThread]];
        }
        timeStamp.uid = uid;
        timeStamp.locationDate = [self getTodayTimeStamp];
        [[NSManagedObjectContext MR_contextForCurrentThread] MR_saveToPersistentStoreAndWait];
        validDate = timeStamp.locationDate;
    }else{
        if (timeStamp!=nil) {
            if (([validDate compare:timeStamp.locationDate options:NSNumericSearch] != NSOrderedDescending)) {
                validDate = timeStamp.locationDate;
            }
        }
    }
    
    //先从数据库里面读取数据
    NSArray *coreData_array = [self getCinemasListFromCoreDataWithCityName:nil offset:offset limit:limit dataType:dataType validDate:validDate];
    
    if ([coreData_array count]>0 && delegate && [delegate respondsToSelector:@selector(apiNotifyLocationResult:cacheData:)]) {
        [delegate apiNotifyLocationResult:nil cacheData:coreData_array];
        return tapiCmd;
    }
    
    //因为数据库里没有数据或是数据过期，所以向服务器请求数据
    if (tapiCmd!=nil)
        if ([[[[ApiClient defaultClient] networkQueue] operations]containsObject:tapiCmd.httpRequest]) {
            ABLoggerWarn(@"不能请求 影院 列表数据，因为已经请求了");
            return tapiCmd;
        }
    
    ApiClient* apiClient = [ApiClient defaultClient];
    
    ApiCmdMovie_getAllCinemas* apiCmdMovie_getAllCinemas = [[ApiCmdMovie_getAllCinemas alloc] init];
    apiCmdMovie_getAllCinemas.delegate = delegate;
    apiCmdMovie_getAllCinemas.offset = offset;
    apiCmdMovie_getAllCinemas.limit = limit;
    if (limit==0) {
        apiCmdMovie_getAllCinemas.limit = DataLimit;
    }
    
    apiCmdMovie_getAllCinemas.cityId = [[LocationManager defaultLocationManager] getUserCityId];
    apiCmdMovie_getAllCinemas.cityName = [[LocationManager defaultLocationManager] getUserCity];
    apiCmdMovie_getAllCinemas.dataType = dataType;
    [apiClient executeApiCmdAsync:apiCmdMovie_getAllCinemas];
    [apiCmdMovie_getAllCinemas.httpRequest setTag:API_MCinemaCmd];
    [apiCmdMovie_getAllCinemas.httpRequest setNumberOfTimesToRetryOnTimeout:2];
    [apiCmdMovie_getAllCinemas.httpRequest setTimeOutSeconds:60*2];
    
    return [apiCmdMovie_getAllCinemas autorelease];
    
}

- (NSArray *)getCinemasListFromCoreDataWithCityName:(NSString *)cityId
                                             offset:(int)offset
                                              limit:(int)limit
                                           dataType:(NSString *)dataType
                                          validDate:(NSString *)validDate{
    if (isEmpty(cityId)) {
        cityId = [[LocationManager defaultLocationManager] getUserCityId];
    }
    
    NSArray *returnArray = [MCinema MR_findAllSortedBy:@"districtId"
                                             ascending:YES
                                         withPredicate:[NSPredicate predicateWithFormat:@"cityId = %@ and locationDate >= %@ and dataType = %@",cityId,validDate,dataType]
                                                offset:offset
                                                 limit:limit
                                             inContext:[NSManagedObjectContext MR_contextForCurrentThread]];
    ABLoggerDebug(@"cinema count === %d",[returnArray count]);
    return returnArray;
}

#pragma mark 获取 搜索 影院列表
- (ApiCmd *)getCinemasSearchListFromWeb:(id<ApiNotify>)delegate
                                 offset:(int)offset
                                  limit:(int)limit
                               dataType:(NSString *)dataType
                           searchString:(NSString *)searchString{
    ApiCmd *tapiCmd = [delegate apiGetDelegateApiCmd];
    
    offset = (offset<=0)?0:offset;
    
    if (tapiCmd!=nil)
        if ([[[[ApiClient defaultClient] networkQueue] operations]containsObject:tapiCmd.httpRequest]) {
            ABLoggerWarn(@"不能请求 影院 列表数据，因为已经请求了");
            return tapiCmd;
        }
    
    ApiClient* apiClient = [ApiClient defaultClient];
    
    ApiCmdMovie_getSearchCinemas* apiCmdMovie_getSearchCinemas = [[ApiCmdMovie_getSearchCinemas alloc] init];
    apiCmdMovie_getSearchCinemas.delegate = delegate;
    apiCmdMovie_getSearchCinemas.offset = offset;
    
    apiCmdMovie_getSearchCinemas.limit = limit;
    if (limit==0) {
        apiCmdMovie_getSearchCinemas.limit = DataLimit;
    }
    apiCmdMovie_getSearchCinemas.searchString = searchString;
    apiCmdMovie_getSearchCinemas.dataType = dataType;
    apiCmdMovie_getSearchCinemas.cityId = [[LocationManager defaultLocationManager] getUserCityId];
    [apiClient executeApiCmdAsync:apiCmdMovie_getSearchCinemas];
    [apiCmdMovie_getSearchCinemas.httpRequest setTag:API_MCinemaSearchCmd];
    
    return [apiCmdMovie_getSearchCinemas autorelease];
}

#pragma mark 影院附近分页
- (ApiCmd *)getNearbyCinemaListFromCoreDataDelegate:(id<ApiNotify>)delegate
                                           Latitude:(CLLocationDegrees)latitude
                                          longitude:(CLLocationDegrees)longitude
                                             offset:(int)offset
                                              limit:(int)limit
                                           dataType:(NSString *)dataType
                                          isNewData:(BOOL)isNewData{
    
    ApiCmd *tapiCmd = [delegate apiGetDelegateApiCmd];

    offset = (offset<0)?0:offset;

//    NSString *validDate = [self getTodayZeroTimeStamp];;
//    NSString *uid = [ApiCmdMovie_getNearByCinemas getTimeStampUid:nil];
//    TimeStamp *timeStamp = [TimeStamp MR_findFirstByAttribute:@"uid" withValue:uid inContext:[NSManagedObjectContext MR_contextForCurrentThread]];
//    //判断是否刷新数据
//    if (isNewData) {
//        if (timeStamp == nil)
//        {
//            ABLoggerInfo(@"插入 附近影院 TimeStamp 新数据 ======= %@",uid);
//            timeStamp = [TimeStamp MR_createInContext:[NSManagedObjectContext MR_contextForCurrentThread]];
//        }
//        timeStamp.uid = uid;
//        timeStamp.locationDate = [self getTodayTimeStamp];
//        [[NSManagedObjectContext MR_contextForCurrentThread] MR_saveToPersistentStoreAndWait];
//        validDate = timeStamp.locationDate;
//    }else{
//        if (timeStamp!=nil) {
//            if (([validDate compare:timeStamp.locationDate options:NSNumericSearch] != NSOrderedDescending)) {
//                validDate = timeStamp.locationDate;
//            }
//        }
//    }
    
    //附近搜索是事实的，因为位置是容易变化的，所以不从数据库里读数据，每次都从服务器那边读取数据
    if (tapiCmd!=nil)
        if ([[[[ApiClient defaultClient] networkQueue] operations]containsObject:tapiCmd.httpRequest]) {
            ABLoggerWarn(@"不能请求 附近影院 列表数据，因为已经请求了");
            return tapiCmd;
        }
    
    ApiClient* apiClient = [ApiClient defaultClient];
    
    ApiCmdMovie_getNearByCinemas* apiCmdMovie_getNearByCinemas = [[ApiCmdMovie_getNearByCinemas alloc] init];
    apiCmdMovie_getNearByCinemas.delegate = delegate;
    apiCmdMovie_getNearByCinemas.offset = offset;
    apiCmdMovie_getNearByCinemas.limit = limit;
    if (limit==0) {
        apiCmdMovie_getNearByCinemas.limit = DataLimit;
    }
    
    apiCmdMovie_getNearByCinemas.cityId = [[LocationManager defaultLocationManager] getUserCityId];
    apiCmdMovie_getNearByCinemas.cityName = [[LocationManager defaultLocationManager] getUserCity];
    apiCmdMovie_getNearByCinemas.latitude = latitude;
    apiCmdMovie_getNearByCinemas.longitude = longitude;
    apiCmdMovie_getNearByCinemas.dataType = dataType;
    [apiClient executeApiCmdAsync:apiCmdMovie_getNearByCinemas];
    [apiCmdMovie_getNearByCinemas.httpRequest setTag:API_MCinemaNearByCmd];
    [apiCmdMovie_getNearByCinemas.httpRequest setNumberOfTimesToRetryOnTimeout:2];
    [apiCmdMovie_getNearByCinemas.httpRequest setTimeOutSeconds:60*2];
    
    return [apiCmdMovie_getNearByCinemas autorelease];
    
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

#pragma mark 插入 影院 到数据库
- (NSArray *)insertCinemasIntoCoreDataFromObject:(NSDictionary *)objectData withApiCmd:(ApiCmd*)apiCmd
{
    //    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    
    CFTimeInterval time1 = Elapsed_Time;
    
    NSArray *info_array = [[objectData objectForKey:@"data"] objectForKey:@"list"];
    NSMutableArray *returnArray = [[NSMutableArray alloc] initWithCapacity:20];
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
            mCinema.cityId = apiCmd.cityId;
            mCinema.cityName = apiCmd.cityName;
            mCinema.locationDate = [self getTodayTimeStamp];
            mCinema.dataType = apiCmd.dataType;
            mCinema.districtId =  [NSNumber numberWithInt:[[cinema_dic objectForKey:@"districtid"] intValue]];
            [self importCinema:mCinema ValuesForKeysWithObject:cinema_dic];
            
            [returnArray addObject:mCinema];
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
    return [returnArray autorelease];
}

#pragma mark 将搜索和附近的数据插入到数据库里
- (NSArray *)insertTemporaryCinemasIntoCoreDataFromObject:(NSDictionary *)objectData withApiCmd:(ApiCmd*)apiCmd{
    CFTimeInterval time1 = Elapsed_Time;
    NSManagedObjectContext *context = [NSManagedObjectContext MR_contextForCurrentThread];
    NSArray *info_array = [[objectData objectForKey:@"data"] objectForKey:@"list"];
    NSMutableArray *returnArray = [[NSMutableArray alloc] initWithCapacity:20];
    MCinema *mCinema = nil;
    
    for (int i=0; i<[info_array count]; i++) {
   
        NSDictionary *cinema_dic = [info_array objectAtIndex:i];
        
        mCinema = [MCinema MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"uid = %@ and dataType = %@",[cinema_dic objectForKey:@"id"],apiCmd.dataType] inContext:context];
        if (mCinema == nil)
        {
            ABLoggerInfo(@"插入 一条影院 新数据 ======= %@",[cinema_dic objectForKey:@"name"]);
            mCinema = [MCinema MR_createInContext:context];
        }
//        NSArray *regionOrder = [self getRegionOrder];
//        int index = [[cinema_dic objectForKey:@"districtid"] intValue];
//        if (index>=[regionOrder count]) {
//            index = [regionOrder count]-1;
//        }else if (index<0){
//            index = 0;
//        }
        mCinema.districtId = [NSNumber numberWithInt:[[cinema_dic objectForKey:@"districtid"] intValue]];
        mCinema.district = [cinema_dic objectForKey:@"districtName"];
        mCinema.cityId = apiCmd.cityId;
        mCinema.cityName = apiCmd.cityName;
        mCinema.locationDate = [self getTodayTimeStamp];
        mCinema.dataType = apiCmd.dataType;
        [self importCinema:mCinema ValuesForKeysWithObject:cinema_dic];
        
        [returnArray addObject:mCinema];
        
    }
    
    [context MR_saveToPersistentStoreWithCompletion:^(BOOL success, NSError *error) {
        ABLoggerDebug(@"影院保存是否成功 ========= %d",success);
        ABLoggerDebug(@"错误信息 ========= %@",[error description]);
    }];
    
    //    [cinemas release];
    
    CFTimeInterval time2 = Elapsed_Time;
    ElapsedTime(time2, time1);
    
    [[[ApiClient defaultClient] requestArray] removeObject:apiCmd];
    ABLoggerWarn(@"remove request array count === %d",[[[ApiClient defaultClient] requestArray] count]);
    
    //    });
    return [returnArray autorelease];
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
    mCinema.longitude = [NSNumber numberWithDouble:[[aCinemaData objectForKey:@"longitude"] doubleValue]];
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
    apiCmdShow_getAllShows.cityId = [[LocationManager defaultLocationManager] getUserCityId];
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

#pragma mark 分页 演出
- (ApiCmd *)getShowsListFromWeb:(id<ApiNotify>)delegate
                         offset:(int)offset
                          limit:(int)limit
                       Latitude:(CLLocationDegrees)latitude
                      longitude:(CLLocationDegrees)longitude
                       dataType:(NSString *)dataType
                      isNewData:(BOOL)isNewData
{
    ApiCmd *tapiCmd = [delegate apiGetDelegateApiCmd];
    
    offset = (offset<0)?0:offset;
    
    NSString *validDate = [self getTodayZeroTimeStamp];;
    NSString *uid = [ApiCmdShow_getAllShows getTimeStampUid:dataType];
    TimeStamp *timeStamp = [TimeStamp MR_findFirstByAttribute:@"uid" withValue:uid inContext:[NSManagedObjectContext MR_contextForCurrentThread]];
    //判断是否刷新数据
    if (isNewData) {
        if (timeStamp == nil)
        {
            ABLoggerInfo(@"插入 演出 TimeStamp 新数据 ======= %@",uid);
            timeStamp = [TimeStamp MR_createInContext:[NSManagedObjectContext MR_contextForCurrentThread]];
        }
        timeStamp.uid = uid;
        timeStamp.locationDate = [self getTodayTimeStamp];
        [[NSManagedObjectContext MR_contextForCurrentThread] MR_saveToPersistentStoreAndWait];
        validDate = timeStamp.locationDate;
    }else{
        if (timeStamp!=nil) {
            if (([validDate compare:timeStamp.locationDate options:NSNumericSearch] != NSOrderedDescending)) {
                validDate = timeStamp.locationDate;
            }
        }
    }
    
    //先从数据库里面读取数据
    NSArray *coreData_array = [self getShowsListFromCoreDataOffset:offset limit:limit Latitude:latitude longitude:longitude dataType:dataType validDate:validDate];
    
    if ([coreData_array count]>0 && delegate && [delegate respondsToSelector:@selector(apiNotifyLocationResult:cacheData:)]) {
        [delegate apiNotifyLocationResult:nil cacheData:coreData_array];
        return tapiCmd;
    }
    
    //因为数据库里没有数据或是数据过期，所以向服务器请求数据
    if (tapiCmd!=nil)
        if ([[[[ApiClient defaultClient] networkQueue] operations]containsObject:tapiCmd.httpRequest]) {
            ABLoggerWarn(@"不能请求 演出 列表数据，因为已经请求了");
            return tapiCmd;
        }
    
    ApiClient* apiClient = [ApiClient defaultClient];
    
    ApiCmdShow_getAllShows* apiCmdShow_getAllShows = [[ApiCmdShow_getAllShows alloc] init];
    apiCmdShow_getAllShows.delegate = delegate;
    apiCmdShow_getAllShows.offset = offset;
    apiCmdShow_getAllShows.limit = limit;
    if (limit==0) {
        apiCmdShow_getAllShows.limit = DataLimit;
    }
    
    apiCmdShow_getAllShows.cityId = [[LocationManager defaultLocationManager] getUserCityId];
    apiCmdShow_getAllShows.cityName = [[LocationManager defaultLocationManager] getUserCity];
    apiCmdShow_getAllShows.dataType = dataType;
    [apiClient executeApiCmdAsync:apiCmdShow_getAllShows];
    [apiCmdShow_getAllShows.httpRequest setTag:API_SShowCmd];
    
    return [apiCmdShow_getAllShows autorelease];
    
}

#pragma mark -
#pragma mark 演出 插入数据
- (NSArray *)insertShowsIntoCoreDataFromObject:(NSDictionary *)objectData withApiCmd:(ApiCmd*)apiCmd{
    CFTimeInterval time1 = Elapsed_Time;
    
    NSArray *array = [[objectData objectForKey:@"data"]objectForKey:@"perform"];
    NSMutableArray *returnArray = [[NSMutableArray alloc] initWithCapacity:20];
    
    SShow *sShow = nil;
    for (int i=0; i<[array count]; i++) {
        sShow = [SShow MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"uid = %@ and dataType = %@",[[array objectAtIndex:i] objectForKey:@"id"],apiCmd.dataType] inContext:[NSManagedObjectContext MR_contextForCurrentThread]];
        if (sShow == nil)
        {
            ABLoggerInfo(@"插入 一条演出 新数据 ======= %@",[[array objectAtIndex:i] objectForKey:@"name"]);
            sShow = [SShow MR_createInContext:[NSManagedObjectContext MR_contextForCurrentThread]];
        }
        [self importShow:sShow ValuesForKeysWithObject:[array objectAtIndex:i]];
        
        sShow.dataType = apiCmd.dataType; //数据类型
        sShow.locationDate = [self getTodayTimeStamp];
        sShow.cityId = apiCmd.cityId;
        [returnArray addObject:sShow];
    }
    
    [[NSManagedObjectContext MR_contextForCurrentThread] MR_saveToPersistentStoreWithCompletion:^(BOOL success, NSError *error) {
        ABLoggerDebug(@"演出 保存是否成功 ========= %d",success);
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
 count: 18,
 performances: [
 {
 id: "22",
 uniquekey: "7718405e9dbe6100a38f42b61be7bdad",
 name: "上海芭蕾舞团经典芭蕾舞《天鹅湖》",
 url: "http://www.damai.cn/ticket_52009.html",
 dayrange: "2013.09.30",
 starttime: "2013-09-30 00:00:00",
 endtime: "2099-12-31 00:00:00",
 type: "舞蹈芭蕾",
 description: "　　演出团体：上海芭蕾舞团 　　主演：吴虎生、范晓枫、陈艳 　　编导：德里克·迪恩 　　作曲：柴科夫斯基 　　舞美、服装设计：彼得·法莫尔 　　演出介绍： 　　《天鹅湖》创作背景 　　十九世纪末叶，柴可夫斯基的《天鹅湖》、《睡美人》和《胡桃夹子》把芭蕾音乐提高到交响音乐的水平。在他的舞剧中，音乐是和作品内容与舞台动作紧密联系的重要组成部分。柴可夫斯基提高了舞剧音乐的表现力，通过交响性的展开和对人物性格的刻划，加深了作品的戏剧性。他在《天鹅湖》中，以富于浪漫色彩的抒情笔触，表现了诗一般的意境，刻划了主人公优美纯洁的性格和忠贞不渝的爱情；并以磅礴的戏剧力量描绘了敌对势力的矛盾冲突。因此，柴可夫斯基的《天鹅湖》，至今还是芭蕾音乐的典范作品。《天鹅湖》取材于神话故事，描述被妖人洛特巴尔特用魔法变为天鹅的公主奥杰塔和王子齐格弗里德相爱。最后，爱情的力量战胜了魔法，奥杰塔得以恢复为人身。 　　剧情介绍 　　序幕 　　可爱的奥杰塔公主被邪恶的魔王罗特巴尔特抓走。在湖边魔王用魔法将公主变成了白天鹅。 　　第一幕 　　庆祝王子齐格弗里德生日的准备工作正在进行。王子的老教师吩咐手下在宫殿的花园里布置花环。他宣布王子的到来，庆祝活动紧接着开始。 　　皇后前来庆祝王子的生日，并送给他一个精致的弓箭。她把王子拉到一边，对他说你已经成年，应该考虑婚姻的问题。皇后离开后，庆祝活动继续进行。 　　黄昏来临，朋友们散去，王子独自沉思，他看见一群天鹅从头顶飞过，于是带上弓箭出发去打猎。 　　第三幕 　　王子的生日庆祝活动正在进行，各国嘉宾前来庆贺。皇后让儿子在六位公主中挑选一位作为未婚妻，但他却显得很冷淡，因为他心中只有奥杰塔。在母亲的要求下他和公主们跳了舞，但最后还是拒绝从中挑选未婚妻。 　　魔王罗特巴尔特带着装扮成天鹅女王的女儿奥吉莉亚来到城堡。王子以为是奥杰塔，奥吉莉亚紧随王子离开大厅。在一段舞蹈后，奥吉莉亚和王子回到大厅一起跳舞。 　　在邪恶的奥吉莉亚的欺骗下，王子轻信了她就是他的真爱，王子向奥吉莉亚发誓对她永恒的爱情。恶魔胜利了，誓言已被破坏，奥杰塔和她的女友们将会永远毁灭。恶魔指向出现在窗后的奥杰塔的形象，与奥吉莉亚得意地离开了大厅。 　　快绝望的王子跑出大厅寻找奥杰塔并请求她的宽恕，留下失望的皇后，大厅一片混乱。 　　第四幕 　　痛苦的奥杰塔回到湖边。王子紧追并请求她的宽恕，她终于答应了。 　　魔王罗特巴尔特又出现了，提醒王子他先前对奥吉莉亚的誓言。 　　奥杰塔觉得不可忍受，伤心至极，便跳进了湖中。王子随后也跳进了湖中，两人都被淹死了。邪恶的咒语破解了，魔王罗特巴尔特被王子和奥杰塔之间忠诚的爱情力量摧毁了。 　　新的一天黎明又开始了，王子和奥杰塔在永恒的爱中团聚了。 　　温馨提示 　　1.2米以下儿童谢绝入场（儿童项目除外），1.2米以上儿童需持票入场。",
 coverurl: "http://pimg.damai.cn/perform/project/520/52009_n.jpg",
 coverimg: "",
 status: "0",
 supplierid: "11",
 extid: "52009",
 extshopid: "1127",
 cityid: "2",
 districtid: "12",
 extpayurl: "http://m.damai.cn/#52009_",
 paytype: "2",
 votecountadded: "0",
 currentstatus: "3",
 createtime: "2013-07-15 16:33:56",
 createdbysuid: "13",
 lastmodifiedtime: "2013-07-15 16:34:16",
 lastmodifiedbysuid: "13",
 recommendadded: "80",
 wantedadded: "87",
 prices: [
 80,
 120,
 180,
 280
 ]
 },
 {},
 */
- (void)importShow:(SShow *)sShow ValuesForKeysWithObject:(NSDictionary *)ashowDic{
    sShow.uid = [ashowDic objectForKey:@"id"];
    sShow.name = [ashowDic objectForKey:@"name"];
    if ([[ashowDic objectForKey:@"prices"] count]>0) {
        sShow.price = [[ashowDic objectForKey:@"prices"] objectAtIndex:0];
    }
    sShow.beginTime = [ashowDic objectForKey:@"starttime"];
    sShow.endTime = [ashowDic objectForKey:@"endtime"];
    sShow.rating = [NSNumber numberWithInt:[[ashowDic objectForKey:@"extshopid"] intValue]];
    sShow.webImg = [ashowDic objectForKey:@"coverurl"];
    sShow.recommend = [NSNumber numberWithInt:[[ashowDic objectForKey:@"recommendadded"] intValue]];
    sShow.wantLook = [NSNumber numberWithInt:[[ashowDic objectForKey:@"wantedadded"] intValue]];
    
}

//读数据
- (NSArray *)getShowsListFromCoreDataOffset:(int)offset
                                      limit:(int)limit
                                   Latitude:(CLLocationDegrees)latitude
                                  longitude:(CLLocationDegrees)longitude
                                   dataType:(NSString *)dataType
                                  validDate:(NSString *)validDate{
    return [self getShowsListFromCoreDataWithCityName:nil offset:offset limit:limit Latitude:latitude longitude:longitude dataType:dataType validDate:validDate];
}
//读数据
- (NSArray *)getShowsListFromCoreDataWithCityName:(NSString *)cityId
                                           offset:(int)offset
                                            limit:(int)limit
                                         Latitude:(CLLocationDegrees)latitude
                                        longitude:(CLLocationDegrees)longitude
                                         dataType:(NSString *)dataType
                                        validDate:(NSString *)validDate{
    
    NSArray *typeArray = [dataType componentsSeparatedByString:@"#"];
    NSString *sortedBy = @"recommend";
    BOOL isAscending = NO;
    switch ([[typeArray lastObject] intValue]) {
        case API_SShow_Oreder_Recommend_Cmd://推荐
            sortedBy = @"recommend";
            break;
        case API_SShow_Oreder_Time_Cmd://时间
            sortedBy = @"beginTime";
            isAscending = YES;
            break;
        case API_SShow_Oreder_PriceL_Cmd://价格低到高
            sortedBy = @"price";
            isAscending = YES;
            break;
        case API_SShow_Oreder_PriceH_Cmd://价格高到低
            sortedBy = @"price";
            break;
        case API_SShow_Oreder_Distance_Cmd://距离近到远
            sortedBy = @"distance";
            isAscending = YES;
            break;
        case API_SShow_Oreder_Rating_Cmd:
        default://评分高到底
            sortedBy = @"recommend";
            break;
    }
    
    if (isEmpty(cityId)) {
        cityId = [[LocationManager defaultLocationManager] getUserCityId];
    }
    
    return [SShow MR_findAllSortedBy:sortedBy
                           ascending:isAscending
                       withPredicate:[NSPredicate predicateWithFormat:@"cityId = %@ and locationDate >= %@ and dataType = %@",cityId,validDate,dataType]
                              offset:offset
                               limit:limit
                           inContext:[NSManagedObjectContext MR_contextForCurrentThread]];
}

//获取 演出详情
- (ApiCmd *)getShowDetailFromWeb:(id<ApiNotify>)delegate showId:(NSString *)showId{
    
    ApiCmd *tapiCmd = [delegate apiGetDelegateApiCmd];
    
    //因为数据库里没有数据或是数据过期，所以向服务器请求数据
    if (tapiCmd!=nil)
        if ([[[[ApiClient defaultClient] networkQueue] operations]containsObject:tapiCmd.httpRequest]) {
            ABLoggerWarn(@"不能请求 酒吧 列表数据，因为已经请求了");
            return tapiCmd;
        }
    
    ApiClient* apiClient = [ApiClient defaultClient];
    
    ApiCmdShow_getShowDetail* apiCmdShow_getShowDetail = [[ApiCmdShow_getShowDetail alloc] init];
    apiCmdShow_getShowDetail.delegate = delegate;
    apiCmdShow_getShowDetail.showId = showId;
    apiCmdShow_getShowDetail.cityId = [[LocationManager defaultLocationManager] getUserCityId];
    apiCmdShow_getShowDetail.cityName = [[LocationManager defaultLocationManager] getUserCity];
    [apiClient executeApiCmdAsync:apiCmdShow_getShowDetail];
    [apiCmdShow_getShowDetail.httpRequest setTag:API_SShowDetailCmd];
    
    return [apiCmdShow_getShowDetail autorelease];
}

/*
 {
 httpCode: 200,
 errors: [ ],
 data: {
 info: {
 id: "22",
 uniquekey: "7718405e9dbe6100a38f42b61be7bdad",
 name: "上海芭蕾舞团经典芭蕾舞《天鹅湖》",
 url: "http://www.damai.cn/ticket_52009.html",
 dayrange: "2013.09.30",
 starttime: "2013-09-30 00:00:00",
 endtime: "2099-12-31 00:00:00",
 type: "舞蹈芭蕾",
 description: "　　演出团体：上海芭蕾舞团 　　主演：吴虎生、范晓枫、陈艳 　　编导：德里克·迪恩 　　作曲：柴科夫斯基 　　舞美、服装设计：彼得·法莫尔 　　演出介绍： 　　《天鹅湖》创作背景 　　十九世纪末叶，柴可夫斯基的《天鹅湖》、《睡美人》和《胡桃夹子》把芭蕾音乐提高到交响音乐的水平。在他的舞剧中，音乐是和作品内容与舞台动作紧密联系的重要组成部分。柴可夫斯基提高了舞剧音乐的表现力，通过交响性的展开和对人物性格的刻划，加深了作品的戏剧性。他在《天鹅湖》中，以富于浪漫色彩的抒情笔触，表现了诗一般的意境，刻划了主人公优美纯洁的性格和忠贞不渝的爱情；并以磅礴的戏剧力量描绘了敌对势力的矛盾冲突。因此，柴可夫斯基的《天鹅湖》，至今还是芭蕾音乐的典范作品。《天鹅湖》取材于神话故事，描述被妖人洛特巴尔特用魔法变为天鹅的公主奥杰塔和王子齐格弗里德相爱。最后，爱情的力量战胜了魔法，奥杰塔得以恢复为人身。 　　剧情介绍 　　序幕 　　可爱的奥杰塔公主被邪恶的魔王罗特巴尔特抓走。在湖边魔王用魔法将公主变成了白天鹅。 　　第一幕 　　庆祝王子齐格弗里德生日的准备工作正在进行。王子的老教师吩咐手下在宫殿的花园里布置花环。他宣布王子的到来，庆祝活动紧接着开始。 　　皇后前来庆祝王子的生日，并送给他一个精致的弓箭。她把王子拉到一边，对他说你已经成年，应该考虑婚姻的问题。皇后离开后，庆祝活动继续进行。 　　黄昏来临，朋友们散去，王子独自沉思，他看见一群天鹅从头顶飞过，于是带上弓箭出发去打猎。 　　第三幕 　　王子的生日庆祝活动正在进行，各国嘉宾前来庆贺。皇后让儿子在六位公主中挑选一位作为未婚妻，但他却显得很冷淡，因为他心中只有奥杰塔。在母亲的要求下他和公主们跳了舞，但最后还是拒绝从中挑选未婚妻。 　　魔王罗特巴尔特带着装扮成天鹅女王的女儿奥吉莉亚来到城堡。王子以为是奥杰塔，奥吉莉亚紧随王子离开大厅。在一段舞蹈后，奥吉莉亚和王子回到大厅一起跳舞。 　　在邪恶的奥吉莉亚的欺骗下，王子轻信了她就是他的真爱，王子向奥吉莉亚发誓对她永恒的爱情。恶魔胜利了，誓言已被破坏，奥杰塔和她的女友们将会永远毁灭。恶魔指向出现在窗后的奥杰塔的形象，与奥吉莉亚得意地离开了大厅。 　　快绝望的王子跑出大厅寻找奥杰塔并请求她的宽恕，留下失望的皇后，大厅一片混乱。 　　第四幕 　　痛苦的奥杰塔回到湖边。王子紧追并请求她的宽恕，她终于答应了。 　　魔王罗特巴尔特又出现了，提醒王子他先前对奥吉莉亚的誓言。 　　奥杰塔觉得不可忍受，伤心至极，便跳进了湖中。王子随后也跳进了湖中，两人都被淹死了。邪恶的咒语破解了，魔王罗特巴尔特被王子和奥杰塔之间忠诚的爱情力量摧毁了。 　　新的一天黎明又开始了，王子和奥杰塔在永恒的爱中团聚了。 　　温馨提示 　　1.2米以下儿童谢绝入场（儿童项目除外），1.2米以上儿童需持票入场。",
 coverurl: "http://pimg.damai.cn/perform/project/520/52009_n.jpg",
 coverimg: "",
 status: "0",
 supplierid: "11",
 extid: "52009",
 extshopid: "1127",
 cityid: "2",
 districtid: "12",
 extpayurl: "http://m.damai.cn/#52009_",
 paytype: "2",
 votecountadded: "0",
 currentstatus: "3",
 createtime: "2013-07-15 16:33:56",
 createdbysuid: "13",
 lastmodifiedtime: "2013-07-15 16:34:16",
 lastmodifiedbysuid: "13",
 recommendadded: "80",
 wantedadded: "87",
 recommend: "0",
 like: "0",
 prices: [
 80,
 120,
 180,
 280
 ]
 }
 },
 token: null,
 timestamp: "1373963379"
 }
 */
- (SShowDetail *)insertShowDetailIntoCoreDataFromObject:(NSDictionary *)objectData withApiCmd:(ApiCmd*)apiCmd{
    
    NSDictionary *infoDic = [[objectData objectForKey:@"data"] objectForKey:@"info"];
    NSManagedObjectContext *context = [NSManagedObjectContext MR_contextForCurrentThread];
    SShowDetail *showDetail = [SShowDetail MR_findFirstByAttribute:@"uid" withValue:[infoDic objectForKey:@"id"] inContext:context];
    
    if (showDetail==nil) {
        showDetail = [SShowDetail MR_createInContext:context];
    }
    showDetail.introduce = [infoDic objectForKey:@"description"];
    showDetail.locationDate = [self getTodayTimeStamp];
    showDetail.uid = [infoDic objectForKey:@"id"];
    showDetail.recommendation = [infoDic objectForKey:@"recommend"];
    showDetail.wantLook = [infoDic objectForKey:@"like"];
    showDetail.name = [infoDic objectForKey:@"name"];
    NSString *prices = [[infoDic objectForKey:@"prices"] componentsJoinedByString:@","];
    showDetail.prices = prices;
    
    [self saveInManagedObjectContext:context];
    [[[ApiClient defaultClient] requestArray] removeObject:apiCmd];
    ABLoggerWarn(@"remove request array count === %d",[[[ApiClient defaultClient] requestArray] count]);
    
    return showDetail;
}

/*
 {
 httpCode: 200,
 errors: [ ],
 data: {
 interact: {
 performid: "12",
 recommend: "21",
 look: "3"
 }
 },
 token: null,
 timestamp: "1374115032"
 }
 */
- (SShowDetail *)insertShowDetailRecommendOrLookCountIntoCoreDataFromObject:(NSDictionary *)objectData withApiCmd:(ApiCmd*)apiCmd{
    
    NSDictionary *infoDic = [[objectData objectForKey:@"data"] objectForKey:@"interact"];
    NSManagedObjectContext *context = [NSManagedObjectContext MR_contextForCurrentThread];
    SShowDetail *showDetail = [SShowDetail MR_findFirstByAttribute:@"uid" withValue:[infoDic objectForKey:@"performid"] inContext:context];
    
    if (showDetail==nil) {
        showDetail = [SShowDetail MR_createInContext:context];
        showDetail.uid = [infoDic objectForKey:@"performid"];
    }
    showDetail.recommendation = [infoDic objectForKey:@"recommend"];
    showDetail.wantLook = [infoDic objectForKey:@"look"];
    
    [self saveInManagedObjectContext:context];
    
    [[[ApiClient defaultClient] requestArray] removeObject:apiCmd];
    ABLoggerWarn(@"remove request array count === %d",[[[ApiClient defaultClient] requestArray] count]);
    
    return showDetail;
}

- (SShowDetail *)getShowDetailFromCoreDataWithId:(NSString *)showId{
    return [SShowDetail MR_findFirstByAttribute:@"uid" withValue:showId inContext:[NSManagedObjectContext MR_contextForCurrentThread]];
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
    apiCmdBar_getAllBars.cityId = [[LocationManager defaultLocationManager] getUserCityId];
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
        validDate = timeStamp.locationDate;
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
    apiCmdBar_getAllBars.cityName = [[LocationManager defaultLocationManager] getUserCity];
    apiCmdBar_getAllBars.dataType = dataType;
    [apiClient executeApiCmdAsync:apiCmdBar_getAllBars];
    [apiCmdBar_getAllBars.httpRequest setTag:API_BBarTimeCmd];
    
    return [apiCmdBar_getAllBars autorelease];
    
}

//附近 酒吧
- (ApiCmd *)getBarsNearByListFromWeb:(id<ApiNotify>)delegate
                              offset:(int)offset
                               limit:(int)limit
                            Latitude:(CLLocationDegrees)latitude
                           longitude:(CLLocationDegrees)longitude
                            dataType:(NSString *)dataType
                           isNewData:(BOOL)isNewData{
    
    ApiCmd *tapiCmd = [delegate apiGetDelegateApiCmd];
    
    offset = (offset<0)?0:offset;
    
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
    apiCmdBar_getAllBars.cityName = [[LocationManager defaultLocationManager] getUserCity];
    apiCmdBar_getAllBars.dataType = dataType;
    apiCmdBar_getAllBars.latitude = latitude;
    apiCmdBar_getAllBars.longitude = longitude;
    [apiClient executeApiCmdAsync:apiCmdBar_getAllBars];
    [apiCmdBar_getAllBars.httpRequest setTag:API_BBarNearByCmd];
    
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
    if ([dataType intValue]==2) {//1代表时间，2代表人气，3代表附近
        sortStr = @"popular";
        isAscending = NO;
    }
    if (isEmpty(cityId)) {
        cityId = [[LocationManager defaultLocationManager] getUserCityId];
    }
    
    return [BBar MR_findAllSortedBy:sortStr
                          ascending:isAscending
                      withPredicate:[NSPredicate predicateWithFormat:@"cityId = %@ and locationDate >= %@ and dataType = %@",cityId,validDate,dataType]
                             offset:offset
                              limit:limit
                          inContext:[NSManagedObjectContext MR_contextForCurrentThread]];
}


#pragma mark 酒吧 插入数据
- (NSArray *)insertBarsIntoCoreDataFromObject:(NSDictionary *)objectData withApiCmd:(ApiCmd*)apiCmd{
    CFTimeInterval time1 = Elapsed_Time;
    
    NSMutableArray *returnArray = [[NSMutableArray alloc] initWithCapacity:20];
    NSArray *array = [[objectData objectForKey:@"data"]objectForKey:@"events"];
    
    BBar *bBar = nil;
    for (int i=0; i<[array count]; i++) {
        
        //        bBar = [BBar MR_findFirstByAttribute:@"uid" withValue:[[array objectAtIndex:i] objectForKey:@"id"] inContext:[NSManagedObjectContext MR_contextForCurrentThread]];
        bBar = [BBar MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"uid = %@ and dataType = %@",[[array objectAtIndex:i] objectForKey:@"id"],apiCmd.dataType] inContext:[NSManagedObjectContext MR_contextForCurrentThread]];
        if (bBar == nil)
        {
            ABLoggerInfo(@"插入 一条 酒吧 新数据 ======= %@",[[array objectAtIndex:i] objectForKey:@"name"]);
            bBar = [BBar MR_createInContext:[NSManagedObjectContext MR_contextForCurrentThread]];
        }
        [self importBar:bBar ValuesForKeysWithObject:[array objectAtIndex:i]];
        bBar.cityId = apiCmd.cityId;
        bBar.locationDate = [self getTodayTimeStamp];
        bBar.dataType = apiCmd.dataType; //数据类型，1是时间过滤，2是人气过滤，3是附近
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
    bBar.popular = [NSNumber numberWithInt:[[aBarDic objectForKey:@"hotadded"] integerValue]];
    bBar.address = [aBarDic objectForKey:@"address"];
    bBar.begintime = [aBarDic objectForKey:@"begintime"];
    bBar.phoneNumber = [[aBarDic objectForKey:@"tel"] stringValue];
    //    bBar.longitude = [aBarDic objectForKey:@"longitude"];
    //    bBar.latitude = [aBarDic objectForKey:@"latitude"];
    bBar.locationDate = [self getTodayTimeStamp];
}

//获取酒吧详情
- (ApiCmd *)getBarDetailFromWeb:(id<ApiNotify>)delegate barId:(NSString *)eventid{
    
    ApiCmd *tapiCmd = [delegate apiGetDelegateApiCmd];
    if ([[[[ApiClient defaultClient] networkQueue] operations]containsObject:tapiCmd.httpRequest]) {
        ABLoggerWarn(@"不能请求电影详情数据，因为已经请求了");
        return tapiCmd;
    }
    
    ApiClient* apiClient = [ApiClient defaultClient];
    
    ApiCmdBar_getBarDetail* apiCmdBar_getBarDetail = [[ApiCmdBar_getBarDetail alloc] init];
    apiCmdBar_getBarDetail.delegate = delegate;
    apiCmdBar_getBarDetail.eventid = eventid;
    [apiClient executeApiCmdAsync:apiCmdBar_getBarDetail];
    [apiCmdBar_getBarDetail.httpRequest setTag:API_BBarDetailCmd];
    
    return [apiCmdBar_getBarDetail autorelease];
    
}

//插入 酒吧 详情
/*
 {
 httpCode: 200,
 errors: [ ],
 data: {
     eventinfo: {
     id: "10",
     barid: "6",
     barname: "bar",
     eventname: "欢乐相聚10",
     address: "",
     latitude: "",
     longitude: "",
     type: "2",
     cityid: "0",
     districtid: "1",
     begintime: "2013-07-26",
     endtime: "2013-07-27",
     eventtime: "22.5",
     hotadded: "45",
     price: "446",
     recommendadded: "3",
     wantedadded: "99",
     description: null,
     eventurl: null,
     tag: "0",
     currentstatus: "3",
     createtime: "2013-07-15 15:52:24",
     createdbysuid: "11",
     lastmodifiedtime: "2013-07-15 15:56:26",
     lastmodifiedbysuid: "11"
 }
 },
 token: null,
 timestamp: "1374575326"
 }
 */
- (BBarDetail *)insertBarDetailIntoCoreDataFromObject:(NSDictionary *)objectData withApiCmd:(ApiCmd*)apiCmd{
    
    BBarDetail *tBarDetail = nil;
    
    if (objectData) {
        
        NSDictionary *tDic = [[objectData objectForKey:@"data"] objectForKey:@"eventinfo"];
        
        NSManagedObjectContext *context = [NSManagedObjectContext MR_contextForCurrentThread];
        NSString *bar_id = [tDic objectForKey:@"id"];
        
        
        BBar *tBar = [BBar MR_findFirstByAttribute:@"uid" withValue:bar_id inContext:context];
        
        if (tBar==nil) {
            tBar = [BBar MR_createInContext:context];
            tBar.uid = bar_id;
        }
        
        if (tBar.barDetail==nil) {
            tBarDetail = [BBarDetail MR_createInContext:context];
            ABLoggerInfo(@"插入 一条 酒吧详情 记录");
        }
        tBar.barDetail = tBarDetail;
        tBarDetail.bar = tBar;
        [self importBarDetail:tBarDetail ValuesForKeysWithObject:tDic];
        
        [context MR_saveToPersistentStoreAndWait];
    }
    
    [[[ApiClient defaultClient] requestArray] removeObject:apiCmd];
    ABLoggerWarn(@"remove request array count === %d",[[[ApiClient defaultClient] requestArray] count]);
    
    return tBarDetail;
}

- (void)importBarDetail:(BBarDetail *)tBarDetail ValuesForKeysWithObject:(NSDictionary *)aBarDic{
    tBarDetail.wantlook = [aBarDic objectForKey:@"wantedadded"];
    tBarDetail.recommendation = [aBarDic objectForKey:@"recommendadded"];
    tBarDetail.detailInfo = aBarDic;
    tBarDetail.uid = [aBarDic objectForKey:@"id"];
    tBarDetail.locationDate = [self getTodayTimeStamp];
}

- (BBarDetail *)insertBarRecommendIntoCoreDataFromObject:(NSDictionary *)objectData withApiCmd:(ApiCmd*)apiCmd{
    
    NSDictionary *infoDic = [[objectData objectForKey:@"data"] objectForKey:@"interact"];
    if (infoDic==nil) {
        return nil;
    }
    NSManagedObjectContext *context = [NSManagedObjectContext MR_contextForCurrentThread];
    BBarDetail *barDetail = [BBarDetail MR_findFirstByAttribute:@"uid" withValue:[infoDic objectForKey:@"movieid"] inContext:context];
    
    if (barDetail==nil) {
        barDetail = [BBarDetail MR_createInContext:context];
        barDetail.uid = [infoDic objectForKey:@"id"];
    }
    barDetail.recommendation = [infoDic objectForKey:@"recommend"];
    barDetail.wantlook = [infoDic objectForKey:@"look"];
    
    [self saveInManagedObjectContext:context];
    
    [[[ApiClient defaultClient] requestArray] removeObject:apiCmd];
    ABLoggerWarn(@"remove request array count === %d",[[[ApiClient defaultClient] requestArray] count]);
    
    return barDetail;
    
}

- (BBarDetail *)getBarDetailWithId:(NSString *)barId{
    
    BBarDetail *tBarDetail = nil;
    if (barId) {
        tBarDetail = [BBarDetail MR_findFirstByAttribute:@"uid" withValue:barId inContext:[NSManagedObjectContext MR_contextForCurrentThread]];
        return tBarDetail;
    }
    
    return tBarDetail;
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
    apiCmdKTV_getAllKTVs.cityName = [[LocationManager defaultLocationManager] getUserCity];
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
- (ApiCmd *)getKTVsListFromWeb:(id<ApiNotify>)delegate
                        offset:(int)offset
                         limit:(int)limit
                      dataType:(NSString *)dataType
                     isNewData:(BOOL)isNewData
{
    ApiCmd *tapiCmd = [delegate apiGetDelegateApiCmd];
    
    offset = (offset<=0)?0:offset;
    
    NSString *validDate = [self getTodayZeroTimeStamp];;
    NSString *uid = [ApiCmdKTV_getAllKTVs getTimeStampUid:nil];
    TimeStamp *timeStamp = [TimeStamp MR_findFirstByAttribute:@"uid" withValue:uid inContext:[NSManagedObjectContext MR_contextForCurrentThread]];
    //判断是否刷新数据
    if (isNewData) {
        if (timeStamp == nil)
        {
            ABLoggerInfo(@"插入 KTV TimeStamp 新数据 ======= %@",uid);
            timeStamp = [TimeStamp MR_createInContext:[NSManagedObjectContext MR_contextForCurrentThread]];
        }
        timeStamp.uid = uid;
        timeStamp.locationDate = [self getTodayTimeStamp];
        [[NSManagedObjectContext MR_contextForCurrentThread] MR_saveToPersistentStoreAndWait];
        validDate = timeStamp.locationDate;
    }else{
        if (timeStamp!=nil) {
            if (([validDate compare:timeStamp.locationDate options:NSNumericSearch] != NSOrderedDescending)) {
                validDate = timeStamp.locationDate;
            }
        }
    }
    
    //先从数据库里面读取数据
    NSArray *coreData_array = [self getKTVsListFromCoreDataWithCityName:nil offset:offset limit:limit dataType:dataType validDate:validDate];
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
    apiCmdKTV_getAllKTVs.cityName = [[LocationManager defaultLocationManager] getUserCity];
    apiCmdKTV_getAllKTVs.dataType = dataType;
    [apiClient executeApiCmdAsync:apiCmdKTV_getAllKTVs];
    [apiCmdKTV_getAllKTVs.httpRequest setTag:API_KKTVCmd];
    [apiCmdKTV_getAllKTVs.httpRequest setNumberOfTimesToRetryOnTimeout:2];
    [apiCmdKTV_getAllKTVs.httpRequest setTimeOutSeconds:60*2];
    
    return [apiCmdKTV_getAllKTVs autorelease];
}

#pragma mark 搜索 KTV数据
- (ApiCmd *)getKTVsSearchListFromWeb:(id<ApiNotify>)delegate
                              offset:(int)offset
                               limit:(int)limit
                            dataType:(NSString *)dataType
                        searchString:(NSString *)searchString
{
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
    apiCmdKTV_getSearchKTVs.dataType = dataType;
    [apiClient executeApiCmdAsync:apiCmdKTV_getSearchKTVs];
    [apiCmdKTV_getSearchKTVs.httpRequest setTag:API_KKTVSearchCmd];
    
    return [apiCmdKTV_getSearchKTVs autorelease];
}

- (NSArray *)getKTVsListFromCoreDataOffset:(int)offset
                                     limit:(int)limit
                                  dataType:(NSString *)dataType
                                 validDate:(NSString *)validDate{
    return [self getKTVsListFromCoreDataWithCityName:nil offset:offset limit:limit dataType:dataType validDate:validDate];
}

- (NSArray *)getKTVsListFromCoreDataWithCityName:(NSString *)cityId
                                          offset:(int)offset
                                           limit:(int)limit
                                        dataType:(NSString *)dataType
                                       validDate:(NSString *)validDate{
    if (isEmpty(cityId)) {
        cityId = [[LocationManager defaultLocationManager] getUserCityId];
    }
    NSArray *returnArray = [KKTV MR_findAllSortedBy:@"districtid"
                                             ascending:YES
                                         withPredicate:[NSPredicate predicateWithFormat:@"cityId = %@ and locationDate >= %@ and dataType = %@",cityId,validDate,dataType]
                                                offset:offset
                                                 limit:limit
                                             inContext:[NSManagedObjectContext MR_contextForCurrentThread]];
    ABLoggerDebug(@"ktv count === %d",[returnArray count]);

    return returnArray;
}

#pragma mark 附近 KTV数据
- (BOOL)getNearbyKTVListFromCoreDataWithCallBack:(GetKTVNearbyList)callback{
    GetKTVNearbyList mCallBack = [callback copy];
    
    NSArray *ktvs = [self getAllKTVsListFromCoreData];
    LocationManager *lm = [LocationManager defaultLocationManager];
    BOOL isSuccess =  [lm getUserGPSLocationWithCallBack:^(BOOL isEnableGPS, BOOL isSuccess) {
        
        for (KKTV *tKTV in ktvs) {
            double distance = [lm distanceBetweenUserToLatitude:[tKTV.latitude doubleValue] longitude:[tKTV.longitude doubleValue]];
            tKTV.distance = [NSNumber numberWithInt:distance];
        }
        
        [self saveInManagedObjectContext:[NSManagedObjectContext MR_contextForCurrentThread]];
        
        NSArray *array =  [ktvs sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
            MCinema *cinema1 = (MCinema *)obj1;
            MCinema *cinema2 = (MCinema *)obj2;
            return [cinema1.distance compare:cinema2.distance];
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
                                            dataType:(NSString *)dataType
                                           isNewData:(BOOL)isNewData
{
    offset = (offset<=0)?0:offset;
    
    ApiCmd *tapiCmd = [delegate apiGetDelegateApiCmd];
    
    if (tapiCmd!=nil)
        if ([[[[ApiClient defaultClient] networkQueue] operations]containsObject:tapiCmd.httpRequest]) {
            ABLoggerWarn(@"不能请求 KTV 列表数据，因为已经请求了");
            return tapiCmd;
        }
    
    ApiClient* apiClient = [ApiClient defaultClient];
    
    ApiCmdKTV_getNearByKTVs* apiCmdKTV_getNearByKTVs = [[ApiCmdKTV_getNearByKTVs alloc] init];
    apiCmdKTV_getNearByKTVs.delegate = delegate;
    apiCmdKTV_getNearByKTVs.offset = offset;
    
    apiCmdKTV_getNearByKTVs.limit = limit;
    if (limit==0) {
        apiCmdKTV_getNearByKTVs.limit = DataLimit;
    }
    
    apiCmdKTV_getNearByKTVs.cityId = [[LocationManager defaultLocationManager] getUserCityId];
    apiCmdKTV_getNearByKTVs.dataType = dataType;
    apiCmdKTV_getNearByKTVs.latitude = latitude;
    apiCmdKTV_getNearByKTVs.longitude = longitude;
    [apiClient executeApiCmdAsync:apiCmdKTV_getNearByKTVs];
    [apiCmdKTV_getNearByKTVs.httpRequest setTag:API_KKTVNearByCmd];
    [apiCmdKTV_getNearByKTVs.httpRequest setNumberOfTimesToRetryOnTimeout:2];
    [apiCmdKTV_getNearByKTVs.httpRequest setTimeOutSeconds:60*2];
    
    return [apiCmdKTV_getNearByKTVs autorelease];
    
}

#pragma mark 常去 KTV
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
 count: "20",
 infos: [
 {
     districtName: "长宁区",
     list: [
     {
     id: "519",
     uniquekey: "b11f330d5a81c3fbc85cf7c826615938",
     name: "新罗马假期KTV",
     description: null,
     address: "长宁路547号",
     contactphone: null,
     contactphonex: "021-52380679",
     contactphonetypex: "1",
     contactphoney: "",
     contactphonetypey: "1",
     contactphonez: "",
     contactphonetypez: "1",
     latitude: "35.281521",
     longitude: "107.950447",
     cityid: "2",
     districtid: "3",
     logourl: "logourl",
     coverurl: "http://i1.dpfile.com/2009-12-11/3319992_b.jpg(700x700)/thumb.jpg",
     specialoffers: "",
     trafficroutes: "",
     exturl: "http://dpurl.cn/p/NcycBI9eR0",
     createtime: "2013-07-16 18:23:11",
     createdbysuid: "11",
     lastmodifiedtime: "2013-07-23 15:21:17",
     lastmodifiedbysuid: "11",
     source: "1",
     currentstatus: "3"
 },
 */

#pragma mark KTV 插入 数据库
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
            kKTV.cityName = apiCmd.cityName;
            kKTV.locationDate = [self getTodayTimeStamp];
            kKTV.dataType = apiCmd.dataType;
            [self importKTV:kKTV ValuesForKeysWithObject:[arrayktvs objectAtIndex:j]];
            [returnArray addObject:kKTV];
        }
    }
    
    [dataBaseContext MR_saveToPersistentStoreWithCompletion:^(BOOL success, NSError *error) {
        ABLoggerDebug(@"KTV 保存是否成功 ========= %d",success);
        ABLoggerDebug(@"错误信息 ========= %@",[error description]);
    }];
    
    CFTimeInterval time2 = Elapsed_Time;
    ElapsedTime(time2, time1);
    
    [[[ApiClient defaultClient] requestArray] removeObject:apiCmd];
    ABLoggerWarn(@"remove request array count === %d",[[[ApiClient defaultClient] requestArray] count]);
    
    return [returnArray autorelease];
}

#pragma mark  KTV 搜索和附近 结果数据 插入 数据库
- (NSArray *)insertTemporaryKTVsIntoCoreDataFromObject:(NSDictionary *)objectData withApiCmd:(ApiCmd*)apiCmd{
    CFTimeInterval time1 = Elapsed_Time;
    NSManagedObjectContext *dataBaseContext = [NSManagedObjectContext MR_contextForCurrentThread];
    NSArray *array = [[objectData objectForKey:@"data"]objectForKey:@"list"];
    
    KKTV *kKTV = nil;
    NSMutableArray *returnArray = [[NSMutableArray alloc] initWithCapacity:20];
    for (int i=0; i<[array count]; i++) {
        NSDictionary *ktvDic = [array objectAtIndex:i];
        NSString *uid = [ktvDic objectForKey:@"id"];
        kKTV = [KKTV MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"uid = %@ and dataType = %@",uid,apiCmd.dataType] inContext:dataBaseContext];
        if (kKTV == nil)
        {
            ABLoggerInfo(@"插入 一条 KTV 新数据 ======= %@",[ktvDic objectForKey:@"name"]);
            kKTV = [KKTV MR_createInContext:dataBaseContext];
        }
        
        NSArray *regionOrder = [self getRegionOrder];
        int index = [[ktvDic objectForKey:@"districtid"] intValue];
        if (index>=[regionOrder count]) {
            index = [regionOrder count]-1;
        }else if (index<0){
            index = 0;
        }
        
//        kKTV.district = [ktvDic objectForKey:@"districtName"];
        kKTV.district = [regionOrder objectAtIndex:index];
        kKTV.districtid = [NSNumber numberWithInt:[[ktvDic objectForKey:@"districtid"] intValue]];
        kKTV.dataType = apiCmd.dataType;
        kKTV.locationDate = [self getTodayTimeStamp];
        kKTV.cityId = apiCmd.cityId;
        [self importKTV:kKTV ValuesForKeysWithObject:ktvDic];
        [returnArray addObject:kKTV];
    }
    
    [dataBaseContext MR_saveToPersistentStoreWithCompletion:^(BOOL success, NSError *error) {
        ABLoggerDebug(@"KTV 保存是否成功 ========= %d",success);
        ABLoggerDebug(@"错误信息 ========= %@",[error description]);
    }];
    
    CFTimeInterval time2 = Elapsed_Time;
    ElapsedTime(time2, time1);
    
    [[[ApiClient defaultClient] requestArray] removeObject:apiCmd];
    ABLoggerWarn(@"remove request array count === %d",[[[ApiClient defaultClient] requestArray] count]);
    
    return [returnArray autorelease];
}

- (void)importKTV:(KKTV *)kKTV ValuesForKeysWithObject:(NSDictionary *)aKTVDic{
    kKTV.name = [aKTVDic objectForKey:@"name"];
    kKTV.uid = [aKTVDic objectForKey:@"id"];
    kKTV.districtid = [NSNumber numberWithInt:[[aKTVDic objectForKey:@"districtid"] intValue]];
    kKTV.address = [aKTVDic objectForKey:@"address"];
    kKTV.phoneNumber = [aKTVDic objectForKey:@"contactphonex"];
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
    [[[ApiClient defaultClient] requestArray] removeObject:apiCmd];
    ABLoggerWarn(@"remove request array count === %d",[[[ApiClient defaultClient] requestArray] count]);
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

- (KKTVPriceInfo *)insertKTVPriceListIntoCoreDataFromObject:(NSDictionary *)objectData
                                      withApiCmd:(ApiCmd*)apiCmd
                                        withaKTV:(KKTV *)aKTV{
    
    NSManagedObjectContext* threadContext = [NSManagedObjectContext MR_contextForCurrentThread];
    
    KKTVPriceInfo *tKtvPriceInfo = [KKTVPriceInfo MR_findFirstByAttribute:@"uid" withValue:aKTV.uid inContext:threadContext];
    
    if (tKtvPriceInfo==nil) {
        tKtvPriceInfo = [KKTVPriceInfo MR_createInContext:threadContext];
    }
    tKtvPriceInfo.locationDate = [self getTodayTimeStamp];
    tKtvPriceInfo.uid = aKTV.uid;
    tKtvPriceInfo.priceInfoDic = [objectData objectForKey:@"data"];
    
    [threadContext MR_saveToPersistentStoreWithCompletion:^(BOOL success, NSError *error) {
        ABLoggerDebug(@"保存 KTV 价格信息 成功 == %d",success);
    }];
    
    [[[ApiClient defaultClient] requestArray] removeObject:apiCmd];
    ABLoggerWarn(@"remove request array count === %d",[[[ApiClient defaultClient] requestArray] count]);
    
    return tKtvPriceInfo;
}

- (KKTVPriceInfo *)getKTVPriceInfoFromCoreDataWithId:(NSString *)ktvId{
    return [KKTVPriceInfo MR_findFirstByAttribute:@"uid" withValue:ktvId inContext:[NSManagedObjectContext MR_contextForCurrentThread]];
}
//========================================= KTV =========================================/

//========================================= 喜欢和想看 =========================================/
#pragma mark -
#pragma mark 推荐和想看
- (BOOL)getRecommendOrLookForWeb:(NSString *)objectID
                         APIType:(WSLRecommendAPIType)apiType
                           cType:(WSLRecommendLookType)cType
                        delegate:(id<ApiNotify>)delegate{
    
    ApiClient* apiClient = [ApiClient defaultClient];
    
    ApiCmd_recommendOrLook* apiCmd_recommendOrLook = [[[ApiCmd_recommendOrLook alloc] init] autorelease];
    apiCmd_recommendOrLook.delegate = delegate;
    apiCmd_recommendOrLook.object_id= objectID;
    apiCmd_recommendOrLook.mAPIType = apiType;
    apiCmd_recommendOrLook.mType = cType;
    [apiClient executeApiCmdAsync:apiCmd_recommendOrLook];
    [apiCmd_recommendOrLook.httpRequest setTag:API_RecommendOrLookCmd];
    
    return YES;
}

- (BOOL)isSelectedLike:(NSString *)uid withType:(NSString *)type{
    
    NSManagedObjectContext* threadContext = [NSManagedObjectContext MR_contextForCurrentThread];
    ActionState *actionState = [ActionState MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"uid = %@ and type = %@", uid,type] inContext:threadContext];
    
    BOOL b = NO;
    
    if (actionState!=nil) {
        return [actionState.recommend boolValue];
    }
    
    return b;
}

- (BOOL)isSelectedWantLook:(NSString *)uid  withType:(NSString *)type{
    
    NSManagedObjectContext* threadContext = [NSManagedObjectContext MR_contextForCurrentThread];
    
    ActionState *actionState = [ActionState MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"uid = %@ and type = %@", uid,type] inContext:threadContext];
    
    
    BOOL b = NO;
    
    if (actionState!=nil) {
        return [actionState.wantLook boolValue];
    }
    
    return b;
}

/*
 beginTime
 endTime
 like
 locationDate
 recommend
 type
 uid
 vote
 wantLook
 recommendCount
 wantlookCount
 */
- (BOOL)addActionState:(NSDictionary *)dataDic{
    
    
    NSManagedObjectContext* threadContext = [NSManagedObjectContext MR_contextForCurrentThread];
    
    ActionState *actionState = [ActionState MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"uid = %@ and type = %@", [dataDic objectForKey:@"uid"],[dataDic objectForKey:@"type"]] inContext:threadContext];
    
    if (actionState==nil) {
        actionState = [ActionState MR_createInContext:threadContext];
        actionState.locationDate = [self getTodayTimeStamp];
        actionState.uid = [dataDic objectForKey:@"uid"];
        actionState.beginTime = [dataDic objectForKey:@"beginTime"];
        actionState.endTime = [dataDic objectForKey:@"endTime"];
        actionState.type = [dataDic objectForKey:@"type"];
    }
    
    
    if ([dataDic objectForKey:@"wantLook"]!=nil) {
        actionState.wantLook = [dataDic objectForKey:@"wantLook"];  //想看
    }
    
    if ([dataDic objectForKey:@"recommend"]!=nil) {
        actionState.recommend = [dataDic objectForKey:@"recommend"];//赞和推荐
    }
    
    actionState.vote = [dataDic objectForKey:@"vote"];
    actionState.like = [dataDic objectForKey:@"like"];
    
    return YES;
}

@end
