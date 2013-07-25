//
//  ApiCmdBindingHuiShowAccount.m
//  mobileapi
//
//  Created by doujingxuan on 10/30/12.
//
//

#import "ApiCmdShow_getAllShows.h"
#import "common.h"

@implementation ApiCmdShow_getAllShows

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (void) dealloc {
    self.dataType = nil;
	[super dealloc];
}

- (ASIHTTPRequest*)prepareExecuteApiCmd{
    [super prepareExecuteApiCmd];
    
    // prepare http request
    NSURL *url = [NSURL URLWithString:@"https://raw.github.com/zyallday/HelloWorld/master/mobileapidemo/performance-list.json"];
    
    [self.httpRequest setURL:url];
    
    return self.httpRequest;
}

//http://api.wanshangle.com:10000/api? appId=000001&api=perform.list&sign=sign&token=&cityid=021
- (NSMutableDictionary*) getParamDict {
    NSMutableDictionary* paramDict = [[[NSMutableDictionary alloc] init] autorelease];
    
    [paramDict setObject:@"perform.list" forKey:@"api"];
    [paramDict setObject:self.cityId forKey:@"cityid"];
    
    [paramDict setObject:[NSString stringWithFormat:@"%d",self.offset] forKey:@"offset"];
    [paramDict setObject:[NSString stringWithFormat:@"%d",self.limit] forKey:@"limit"];
    
//    if ([self.dataType intValue]==3) {//3代表附近的酒吧
//        [paramDict setObject:[NSString stringWithFormat:@"%f",_latitude] forKey:@"lat"];
//        [paramDict setObject:[NSString stringWithFormat:@"%f",_longitude] forKey:@"lng"];
//    }
//    [paramDict setObject:self.dataType forKey:@"order"];
    
    return paramDict;
}

+(NSString *)getTimeStampUid:(NSString *)type{
    NSString *cityId = [[LocationManager defaultLocationManager] getUserCityId];
    NSString *key = [NSString stringWithFormat:@"api=perform.list&cityid=%@&order=%@",cityId,type];
    //   return md5(key);
    return key;
}


- (void) parseResultData:(NSDictionary*) dictionary {

    // get the data
    ABLoggerDebug(@"获取演出 列表数据 responseJSONObject ======== %@",self.responseJSONObject);
}

-(void) notifyDelegate:(NSDictionary*) dictionary{
    

}

@end
