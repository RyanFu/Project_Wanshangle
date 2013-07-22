//
//  ApiCmdBindingHuiShowAccount.m
//  mobileapi
//
//  Created by doujingxuan on 10/30/12.
//
//

#import "ApiCmdMovie_getSchedule.h"
#import "common.h"

@implementation ApiCmdMovie_getSchedule

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (void) dealloc {
    
    self.movie_id = nil;
    self.cinema_id = nil;
    self.timedistance = nil;
    
	[super dealloc];
}

- (ASIHTTPRequest*)prepareExecuteApiCmd{
    [super prepareExecuteApiCmd];
    
    // prepare http request
    NSURL *url = [NSURL URLWithString:@"https://raw.github.com/zyallday/HelloWorld/master/mobileapidemo/movie-schedule.json"];
    
    [self.httpRequest setURL:url];
    
    return self.httpRequest;
}
//http://api.wanshangle.com:10000/api? appId=000001&sign=sign&time=1371988912&v=1.0&api=movie.scheduling&movieid=3&cinemaid=9&timedistance=1
- (NSMutableDictionary*) getParamDict {
    
    NSMutableDictionary* paramDict = [[[NSMutableDictionary alloc] init] autorelease];
    [paramDict setObject:@"movie.scheduling" forKey:@"api"];
    [paramDict setObject:self.movie_id  forKey:@"movieid"];
    [paramDict setObject:self.cinema_id  forKey:@"cinemaid"];
    [paramDict setObject:self.timedistance  forKey:@"timedistance"];
    
    return paramDict;
}


- (void) parseResultData:(NSDictionary*) dictionary {
    ABLoggerDebug(@"排期数据 ======= %@",dictionary);
    
}

-(void) notifyDelegate:(NSDictionary*) dictionary{

}

@end
