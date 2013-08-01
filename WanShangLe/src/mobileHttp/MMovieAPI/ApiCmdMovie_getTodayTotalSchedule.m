//
//  ApiCmdBindingHuiShowAccount.m
//  mobileapi
//
//  Created by doujingxuan on 10/30/12.
//
//

#import "ApiCmdMovie_getTodayTotalSchedule.h"
#import "common.h"
#import "MMovie.h"
#import "MCinema.h"

@implementation ApiCmdMovie_getTodayTotalSchedule

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (void) dealloc {
    
    self.movie_id = nil;
    self.cinema_id = nil;
    self.timedistance = nil;
    
	[super dealloc];
}

- (ASIHTTPRequest*)prepareExecuteApiCmd{
    [super prepareExecuteApiCmd];
    
    // prepare http request
    NSURL *url = [NSURL URLWithString:@"https://raw.github.com/zyallday/HelloWorld/master/mobileapidemo/movie-schedule.json"];
    
    [self.httpRequest setURL:url];
    
    return self.httpRequest;
}
//http://api.wanshangle.com:10000/api? appId=000001&sign=sign&time=1371988912&v=1.0&api=movie.scheduling&movieid=10&cinemaid=100&timedistance=1
- (NSMutableDictionary*) getParamDict {
    
    NSMutableDictionary* paramDict = [[[NSMutableDictionary alloc] init] autorelease];
    [paramDict setObject:@"movie.scheduling" forKey:@"api"];
    [paramDict setObject:self.movie_id  forKey:@"movieid"];
    [paramDict setObject:self.cinema_id  forKey:@"cinemaid"];
    [paramDict setObject:self.timedistance  forKey:@"timedistance"];
    
    return paramDict;
}

//http://api.wanshangle.com:10000/api? appId=000001&sign=sign&time=1371988912&v=1.0&api=movie.scheduling&movieid=1&cinemaid=1&timedistance=0
//http://api.wanshangle.com:10000/api? appId=000001&sign=sign&time=1&v=1.0&api=movie.statistics&movieid=39&cinemaid=120
+ (NSURL *)getURLWithMovie:(MMovie *)aMovie cinema:(MCinema *)aCinema{
    // prepare post data
    NSMutableDictionary* paramDict = [[NSMutableDictionary alloc] init];
    [paramDict setObject:@"movie.statistics" forKey:@"api"];
    [paramDict setObject:aMovie.uid forKey:@"movieid"];
    [paramDict setObject:aCinema.uid  forKey:@"cinemaid"];
    
    // add appId & cookie & phoneType
    [paramDict setValue:[ApiConfig getApiAppId] forKey:@"appId"];
    [paramDict setValue:AppVersion forKey:@"v"];
    [paramDict setValue:@"sign" forKey:@"sign"];
    [paramDict setValue:[NSString stringWithFormat:@"%0.0f",[[[DataBaseManager sharedInstance] date] timeIntervalSince1970]] forKey:@"time"];
    
    NSMutableString *urlStr = [[NSMutableString alloc] init];
    [urlStr appendString:[ApiConfig getApiRequestUrl]];
    
    for (NSString *key in [paramDict allKeys]) {
        [urlStr appendFormat:@"&%@=%@",key,[paramDict objectForKey:key]];
    }
    
    // prepare http request
    NSURL *url = [NSURL URLWithString:urlStr];
    ABLoggerInfo(@"request url ===== %@",urlStr);
    return url;
}


- (void) parseResultData:(NSDictionary*) dictionary {
    ABLoggerDebug(@"排期数据 ======= %@",dictionary);
    
}

-(void) notifyDelegate:(NSDictionary*) dictionary{

}

@end
