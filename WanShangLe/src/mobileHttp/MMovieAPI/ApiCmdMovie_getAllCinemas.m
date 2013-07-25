//
//  ApiCmdBindingHuiShowAccount.m
//  mobileapi
//
//  Created by doujingxuan on 10/30/12.
//
//

#import "ApiCmdMovie_getAllCinemas.h"
#import "common.h"

@implementation ApiCmdMovie_getAllCinemas

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
//    NSURL *url = [NSURL URLWithString:@"https://raw.github.com/zyallday/HelloWorld/master/mobileapidemo/all-cinemas-list.json"];
//    NSURL *url = [NSURL URLWithString:@"http://api.wanshangle.com:10000/api?appId=000001&sign=sign&time=1371988912&v=1.0&api=cinema.list&cityid=010"];
//    [self.httpRequest setURL:url];
    
    return self.httpRequest;
}

//http://api.wanshangle.com:10000/api? &api=cinema.list&time=1374226945&appId=000001&sign=sign&v=1.0&cityid=021&offset=0&limit=1
- (NSMutableDictionary*) getParamDict {
    NSMutableDictionary* paramDict = [[[NSMutableDictionary alloc] init] autorelease];
    
    [paramDict setObject:@"cinema.list" forKey:@"api"];
    NSString *city_id = [[LocationManager defaultLocationManager] getUserCityId];
    [paramDict setObject:city_id forKey:@"cityid"];
    [paramDict setObject:[NSString stringWithFormat:@"%d",self.offset] forKey:@"offset"];
    [paramDict setObject:[NSString stringWithFormat:@"%d",self.limit] forKey:@"limit"];
    
    return paramDict;
}

+(NSString *)getTimeStampUid:(NSString *)type{
    NSString *cityId = [[LocationManager defaultLocationManager] getUserCityId];
    NSString *key = [NSString stringWithFormat:@"api=cinema.list&cityid=%@&order=All",cityId];
    //   return md5(key);
    return key;
}

- (void) parseResultData:(NSDictionary*) dictionary {

    // get the data
    ABLoggerDebug(@"影院 responseJSONObject ======== %@",self.responseJSONObject);
}

-(void) notifyDelegate:(NSDictionary*) dictionary{

}

@end
