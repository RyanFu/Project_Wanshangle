//
//  ApiCmdBindingHuiShowAccount.m
//  mobileapi
//
//  Created by doujingxuan on 10/30/12.
//
//

#import "ApiCmd_app_update.h"
#import "common.h"

@implementation ApiCmd_app_update

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
    NSURL *url = [NSURL URLWithString:@"https://raw.github.com/zyallday/HelloWorld/master/mobileapidemo/hotmovie-info.json"];
    
    [self.httpRequest setURL:url];
    
    return self.httpRequest;
}

/*
 {
 httpCode: 200,
 errors: [ ],
 data: {
     update: false,
     uri: ""
 },
 token: null,
 timestamp: "1375320559"
 }
 
 */

//http://api.wanshangle.com:10000/api? appId=000001&sign=sign&time=1371988912&v=1.0&api=server.update&clientversion=1.0

- (NSMutableDictionary*) getParamDict {
    
    NSMutableDictionary* paramDict = [[[NSMutableDictionary alloc] init] autorelease];
    [paramDict setObject:@"server.update"  forKey:@"api"];
    [paramDict setObject:AppVersion  forKey:@"clientversion"];
    
    return paramDict;
}

+ (NSURL *)getRequestURL{
    // prepare post data
    NSMutableDictionary* paramDict = [[NSMutableDictionary alloc] init];
    [paramDict setObject:@"server.update" forKey:@"api"];
    [paramDict setObject:@"1.2.0"  forKey:@"clientversion"];
//    [paramDict setObject:AppVersion  forKey:@"clientversion"];
    
    // add appId & cookie & phoneType
    [paramDict setValue:[ApiConfig getApiAppId] forKey:@"appId"];
    [paramDict setValue:@"sign" forKey:@"sign"];
    [paramDict setValue:[NSString stringWithFormat:@"%0.0f",[[[DataBaseManager sharedInstance] date] timeIntervalSince1970]] forKey:@"time"];
    
    NSMutableString *urlStr = [[NSMutableString alloc] init];
    [urlStr appendString:[ApiConfig getApiRequestUrl]];
    
    for (NSString *key in [paramDict allKeys]) {
        [urlStr appendFormat:@"&%@=%@",key,[paramDict objectForKey:key]];
    }
    
    // prepare http request
    NSURL *url = [NSURL URLWithString:urlStr];
    ABLoggerInfo(@"软件更新 url ===== %@",urlStr);
    [urlStr release];
    return url;
}

- (void) parseResultData:(NSDictionary*) dictionary {
    
    // get the data
    //ABLoggerDebug(@"1111 responseJSONObject ======== %@",self.responseJSONObject);
    
}

-(void) notifyDelegate:(NSDictionary*) dictionary{
    
    
}

@end
