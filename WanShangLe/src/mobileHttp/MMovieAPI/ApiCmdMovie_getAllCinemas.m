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
    NSURL *url = [NSURL URLWithString:@"http://api.wanshangle.com:10000/api?appId=000001&sign=sign&time=1371988912&v=1.0&api=cinema.list&cityid=010"];
    
    [self.httpRequest setURL:url];
    
    return self.httpRequest;
}

- (NSMutableDictionary*) getParamDict {
    NSMutableDictionary* paramDict = [[[NSMutableDictionary alloc] init] autorelease];
    
    [paramDict setObject:@"extaccount.join" forKey:@"api"];
    
    return paramDict;
}


- (void) parseResultData:(NSDictionary*) dictionary {


    
    // get the data
//    ABLoggerDebug(@"1111 responseJSONObject ======== %@",self.responseJSONObject);
    
}

-(void) notifyDelegate:(NSDictionary*) dictionary{

}

@end
