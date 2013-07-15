//
//  ApiCmdBindingHuiShowAccount.m
//  mobileapi
//
//  Created by doujingxuan on 10/30/12.
//
//

#import "ApiCmdBar_getAllBars.h"
#import "common.h"

@implementation ApiCmdBar_getAllBars

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
    NSURL *url = [NSURL URLWithString:@"https://raw.github.com/zyallday/HelloWorld/master/mobileapidemo/all-pubs-list.json"];
    
    [self.httpRequest setURL:url];
    
    return self.httpRequest;
}

//http://api.wanshangle.com:10000/api? appId=000001&sign=sign&time=1371988912&v=1.0&api=bar.eventlist&cityid=0755&&offset=0&limit=30&order=3
- (NSMutableDictionary*) getParamDict {
    NSMutableDictionary* paramDict = [[[NSMutableDictionary alloc] init] autorelease];
    
    [paramDict setObject:@"bar.eventlist" forKey:@"api"];
    self.cityId = [[LocationManager defaultLocationManager] getUserCityId];
    [paramDict setObject:self.cityId forKey:@"cityid"];
    [paramDict setObject:[NSString stringWithFormat:@"%d",self.offset] forKey:@"offset"];
    [paramDict setObject:[NSString stringWithFormat:@"%d",self.limit] forKey:@"limit"];
    [paramDict setObject:self.cityId forKey:@"order"];
    
    return paramDict;
}

+(NSString *)getTimeStampUid:(NSString *)type{
    NSString *cityId = [[LocationManager defaultLocationManager] getUserCityId];
    NSString *key = [NSString stringWithFormat:@"api=bar.eventlist&cityid=%@&order=%@",cityId,type];
//   return md5(key);
    return key;
}


- (void) parseResultData:(NSDictionary*) dictionary {

    // get the data
    ABLoggerDebug(@"1111 responseJSONObject ======== %@",self.responseJSONObject);
}

-(void) notifyDelegate:(NSDictionary*) dictionary{
    

}

@end
