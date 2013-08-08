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
    self.timedistance = nil;
	[super dealloc];
}

- (ASIHTTPRequest*)prepareExecuteApiCmd{
    [super prepareExecuteApiCmd];
    
    // prepare http request
    NSURL *url = [NSURL URLWithString:@"https://raw.github.com/zyallday/HelloWorld/master/mobileapidemo/ticket-purchase-detail.json"];
    
    [self.httpRequest setURL:url];
    
    return self.httpRequest;
}

//http://api.wanshangle.com:10000/api? &playtime=2013-08-09%2016:50:00&sign=sign&movieid=33&api=cinema.movieinfo&appId=000001&v=1.0&time=1375945570&cinemaid=110&timedistance=1
- (NSMutableDictionary*) getParamDict {
    NSMutableDictionary* paramDict = [[[NSMutableDictionary alloc] init] autorelease];
    
    [paramDict setObject:@"cinema.movieinfo" forKey:@"api"];
    [paramDict setObject:self.cinemaId forKey:@"cinemaid"];
    [paramDict setObject:self.movieId forKey:@"movieid"];
    [paramDict setObject:self.playtime forKey:@"playtime"];
    [paramDict setObject:self.timedistance forKey:@"timedistance"];
    
    return paramDict;
}


- (void) parseResultData:(NSDictionary*) dictionary {
    ABLoggerDebug(@"影院团购信息 === %@",dictionary);
    
}

-(void) notifyDelegate:(NSDictionary*) dictionary{

}

@end
