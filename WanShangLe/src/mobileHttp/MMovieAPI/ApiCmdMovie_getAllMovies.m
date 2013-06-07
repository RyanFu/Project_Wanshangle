//
//  ApiCmdBindingHuiShowAccount.m
//  mobileapi
//
//  Created by doujingxuan on 10/30/12.
//
//

#import "ApiCmdMovie_getAllMovies.h"
#import "common.h"
#import "MMovie.h"

@implementation ApiCmdMovie_getAllMovies

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

- (NSMutableDictionary*) getParamDict {
    NSMutableDictionary* paramDict = [[[NSMutableDictionary alloc] init] autorelease];
    
    [paramDict setObject:@"extaccount.join" forKey:@"api"];
    
    return paramDict;
}


- (void) parseResultData:(NSDictionary*) dictionary {

    dispatch_sync(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [[DataBaseManager sharedInstance] insertMoviesIntoCoreDataFromObject:dictionary];
        
        [[[CacheManager sharedInstance] mUserDefaults] setObject:@"0" forKey:UpdatingMoviesList];
        [[NSUserDefaults standardUserDefaults] setObject:[[DataBaseManager sharedInstance] getTodayTimeStamp] forKey:IsUpdatedMoviesList];
    });
    
    // get the data
    //ABLoggerDebug(@"1111 responseJSONObject ======== %@",self.responseJSONObject);
    
}

@end
