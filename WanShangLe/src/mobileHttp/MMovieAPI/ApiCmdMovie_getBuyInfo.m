//
//  ApiCmdBindingHuiShowAccount.m
//  mobileapi
//
//  Created by doujingxuan on 10/30/12.
//
//

#import "ApiCmdMovie_getBuyInfo.h"
#import "common.h"

@implementation ApiCmdMovie_getBuyInfo

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (void) dealloc {
    self.cinemaId = nil;
    self.movieId = nil;
	[super dealloc];
}

- (ASIHTTPRequest*)prepareExecuteApiCmd{
    [super prepareExecuteApiCmd];
    
    // prepare http request
    NSURL *url = [NSURL URLWithString:@"https://raw.github.com/zyallday/HelloWorld/master/mobileapidemo/ticket-purchase-detail.json"];
    
    [self.httpRequest setURL:url];
    
    return self.httpRequest;
}

//http://api.wanshangle.com:10000/api? appId=000001&sign=sign&time=1371988912&v=1.0&api=cinema.movieinfo&cinemaid=393&movieid=48&timedistance=0&playtime=2013-08-07%2014:40:00
- (NSMutableDictionary*) getParamDict {
    NSMutableDictionary* paramDict = [[[NSMutableDictionary alloc] init] autorelease];
    
    [paramDict setObject:@"cinema.movieinfo" forKey:@"api"];
    [paramDict setObject:self.cinemaId forKey:@"cinemaid"];
    [paramDict setObject:self.movieId forKey:@"movieid"];
    [paramDict setObject:self.playtime forKey:@"playtime"];
    
    return paramDict;
}


- (void) parseResultData:(NSDictionary*) dictionary {
    ABLoggerDebug(@"影院团购信息 === %@",dictionary);
    
}

-(void) notifyDelegate:(NSDictionary*) dictionary{

}

@end
