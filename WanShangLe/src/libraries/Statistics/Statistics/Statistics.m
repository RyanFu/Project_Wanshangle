//
//  Statistics.m
//  Statistics
//
//  
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Statistics.h"
//static NSString* CHANNELID = @"AdHoc Test";
static NSString* CHANNELID = @"iOS Test";
//static NSString* CHANNELID = @"91 assistant";
//static NSString* CHANNELID = @"App Store";

@implementation Statistics

/*添加数据统计对象的初始化方法如果存在直接调用不存在创建*/
+ (id) defaultStatistics {
    static Statistics *_statistics = nil;
    
    static dispatch_once_t mmSharedOnceToken;
    dispatch_once(&mmSharedOnceToken, ^{
        _statistics = [[Statistics alloc] init]; 
    });
    
    return _statistics;
}
/*统计数据时调用的方法*/
-(void)addStatistics:(NSString*)flurryAndUmeng{
    [Flurry logEvent:flurryAndUmeng];
    [MobClick event:flurryAndUmeng];
}
/*对umeng和flurry初始化*/
-(void)statisticsTraceLog{
    NSString * flurryAppkey = [NSString stringWithCString:"4WP3X2WWCNGFRZ7ZFHBB"
                                                 encoding:NSUTF8StringEncoding];
    [Flurry startSession:flurryAppkey];
    /*stary umeng trace log*/
    NSString * umengAppkey = [NSString stringWithCString:"51e4b87756240b3139143fb1"
                                                encoding:NSUTF8StringEncoding];
    [MobClick startWithAppkey:umengAppkey reportPolicy:REALTIME channelId:CHANNELID];
}
@end
