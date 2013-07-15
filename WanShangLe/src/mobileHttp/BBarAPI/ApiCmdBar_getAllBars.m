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
/*
 获取城市酒吧活动
 
 参数名	 参数描述	 必须	 参考值
 api	 接口名称	 Y	 bar.eventlist
 appId	 应用ID	 Y	 000001
 time	 调用发起时间戳	 Y
 v	 接口版本	 Y	 1.0
 sign	 数字签名	 Y
 cityid	 城市ID	 Y
 offset	 索引起始	 N	 默认0
 limit	 每页条目数	 N	 默认30
 order	 条件排序	 N	 默认1, 时间:1, 人气:2, 距离3, 价格4
 lat	 当前用户纬度	 N	 只有在order为3的情况下传递
 lng	 当前用户经度	 N	只有在order为3的情况下传递
 
 Example:
 
 http://api.wanshangle.com:10000/api?appId=000001&sign=sign&time=1371988912&v=1.0&api=bar.eventlist&cityid=0755&&offset=0&limit=30&order=3
 */
- (NSMutableDictionary*) getParamDict {
    NSMutableDictionary* paramDict = [[[NSMutableDictionary alloc] init] autorelease];
    
    [paramDict setObject:@"bar.eventlist" forKey:@"api"];
    self.cityId = [[LocationManager defaultLocationManager] getUserCityId];
    [paramDict setObject:self.cityId forKey:@"cityid"];
    [paramDict setObject:[NSString stringWithFormat:@"%d",self.offset] forKey:@"offset"];
    [paramDict setObject:[NSString stringWithFormat:@"%d",self.limit] forKey:@"limit"];
    [paramDict setObject:self.dataType forKey:@"order"];
    
    if ([self.dataType intValue]==3) {//3代表附近的酒吧
        [paramDict setObject:[NSString stringWithFormat:@"%f",_latitude] forKey:@"lat"];
        [paramDict setObject:[NSString stringWithFormat:@"%f",_longitude] forKey:@"lng"];
    }
    
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
