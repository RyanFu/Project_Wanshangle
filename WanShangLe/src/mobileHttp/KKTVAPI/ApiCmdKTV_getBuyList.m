//
//  ApiCmdBindingHuiShowAccount.m
//  mobileapi
//
//  Created by doujingxuan on 10/30/12.
//
//

#import "ApiCmdKTV_getBuyList.h"
#import "common.h"

@implementation ApiCmdKTV_getBuyList

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (void) dealloc {
    self.ktvId = nil;
	[super dealloc];
}

- (ASIHTTPRequest*)prepareExecuteApiCmd{
    [super prepareExecuteApiCmd];
    
    // prepare http request
    NSURL *url = [NSURL URLWithString:@"https://raw.github.com/zyallday/HelloWorld/master/mobileapidemo/ktv-list-request.json"];
    
    [self.httpRequest setURL:url];
    
    return self.httpRequest;
}

//http://api.wanshangle.com:10000/api?%20appId=000001&api=ktv.deals&sign=sign&time=1371988912&v=1.0&ktvid=623
- (NSMutableDictionary*) getParamDict {
    NSMutableDictionary* paramDict = [[[NSMutableDictionary alloc] init] autorelease];
    
    [paramDict setObject:@"ktv.deals" forKey:@"api"];
    [paramDict setObject:self.ktvId forKey:@"ktvid"];
    
    return paramDict;
}


- (void) parseResultData:(NSDictionary*) dictionary {

    // get the data
    ABLoggerDebug(@"1111 responseJSONObject ======== %@",self.responseJSONObject);
}

-(void) notifyDelegate:(NSDictionary*) dictionary{
    

}

@end
