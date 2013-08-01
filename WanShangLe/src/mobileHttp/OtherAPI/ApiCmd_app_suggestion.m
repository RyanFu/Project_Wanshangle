//
//  ApiCmdBindingHuiShowAccount.m
//  mobileapi
//
//  Created by doujingxuan on 10/30/12.
//
//

#import "ApiCmd_app_suggestion.h"
#import "common.h"

@implementation ApiCmd_app_suggestion

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

//http://api.wanshangle.com:10000/api? appId=000001&sign=sign&api=server.feedback&content=123

- (NSMutableDictionary*) getParamDict {
    
    NSMutableDictionary* paramDict = [[[NSMutableDictionary alloc] init] autorelease];
    [paramDict setObject:@"server.update"  forKey:@"api"];
    [paramDict setObject:AppVersion  forKey:@"clientversion"];
    
    return paramDict;
}

+ (NSURL *)getRequestURL{
    // prepare post data
    NSMutableDictionary* paramDict = [[NSMutableDictionary alloc] init];
    [paramDict setObject:@"server.feedback" forKey:@"api"];
    
    // add appId & cookie & phoneType
    [paramDict setValue:[ApiConfig getApiAppId] forKey:@"appId"];
    [paramDict setValue:@"sign" forKey:@"sign"];
    
    NSMutableString *urlStr = [[NSMutableString alloc] init];
    [urlStr appendString:[ApiConfig getApiRequestUrl]];
    
    for (NSString *key in [paramDict allKeys]) {
        [urlStr appendFormat:@"&%@=%@",key,[paramDict objectForKey:key]];
    }
    
    // prepare http request
    NSURL *url = [NSURL URLWithString:urlStr];
    ABLoggerInfo(@"意见反馈 url ===== %@",urlStr);
    return url;
}

- (void) parseResultData:(NSDictionary*) dictionary {
    
    // get the data
    //ABLoggerDebug(@"1111 responseJSONObject ======== %@",self.responseJSONObject);
    
}

-(void) notifyDelegate:(NSDictionary*) dictionary{
    
    
}

@end
