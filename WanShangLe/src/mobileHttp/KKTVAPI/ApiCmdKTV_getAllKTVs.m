//
//  ApiCmdBindingHuiShowAccount.m
//  mobileapi
//
//  Created by doujingxuan on 10/30/12.
//
//

#import "ApiCmdKTV_getAllKTVs.h"
#import "common.h"

@implementation ApiCmdKTV_getAllKTVs

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (void) dealloc {
    
	[super dealloc];
}

- (ASIHTTPRequest*)prepareExecuteApiCmd{
    [super prepareExecuteApiCmd];
    
    // prepare http request
    NSURL *url = [NSURL URLWithString:@"https://raw.github.com/zyallday/HelloWorld/master/mobileapidemo/ktv-list-request.json"];
    
    [self.httpRequest setURL:url];
    
    return self.httpRequest;
}

//http://api.wanshangle.com:10000/api? appId=000001&api=ktv.list&sign=sign&time=1371988912&v=1.0&cityid=0755
- (NSMutableDictionary*)getParamDict {
    NSMutableDictionary* paramDict = [[[NSMutableDictionary alloc] init] autorelease];
    
    [paramDict setObject:@"ktv.list" forKey:@"api"];
    NSString *city_id = [[LocationManager defaultLocationManager] getUserCityId];
    [paramDict setObject:city_id forKey:@"cityid"];
    [paramDict setObject:[NSString stringWithFormat:@"%d",self.offset] forKey:@"offset"];
    [paramDict setObject:[NSString stringWithFormat:@"%d",self.limit] forKey:@"limit"];
    
    return paramDict;
}

+(NSString *)getTimeStampUid:(NSString *)type{
    NSString *cityId = [[LocationManager defaultLocationManager] getUserCityId];
    NSString *key = [NSString stringWithFormat:@"api=ktv.list&cityid=%@&order=All",cityId];
    //   return md5(key);
    return key;
}

- (void) parseResultData:(NSDictionary*) dictionary {

    // get the data
    ABLoggerDebug(@"1111 responseJSONObject ======== %@",self.responseJSONObject);
    
//    NSString *timeStamp = [self.responseJSONObject objectForKey:@"timestamp"];
//    NSDate *date = [NSDate dateWithTimeIntervalSince1970:[timeStamp intValue]];
//
//    NSTimeInterval locationTimeStamp = [[NSDate date] timeIntervalSince1970];
//    [DataBaseManager sharedInstance].missTime = [timeStamp doubleValue]-locationTimeStamp;

//    NSDate *newDate = [[NSDate date] dateByAddingTimeInterval:missTime];
//    ABLoggerDebug(@"server date ======= %@",date);
//    ABLoggerDebug(@"iphone date ======= %@",[NSDate date]);
//    ABLoggerDebug(@"new Date ======= %@",newDate);
//    ABLoggerDebug(@"mist time ======= %d",missTime);
}

-(void) notifyDelegate:(NSDictionary*) dictionary{
    

}

@end
