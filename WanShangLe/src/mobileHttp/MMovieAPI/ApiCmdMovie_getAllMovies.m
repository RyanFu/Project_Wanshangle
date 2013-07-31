//
//  ApiCmdBindingHuiShowAccount.m
//  mobileapi
//
//  Created by doujingxuan on 10/30/12.
//
//

#import "ApiCmdMovie_getAllMovies.h"
#import "common.h"

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

//http://api.wanshangle.com:10000/api? appId=000001 &api=movie.playing&sign=sign 
- (NSMutableDictionary*) getParamDict {
    
    NSMutableDictionary* paramDict = [[[NSMutableDictionary alloc] init] autorelease];
    [paramDict setObject:@"movie.playing" forKey:@"api"];
    
    return paramDict;
}


- (void) parseResultData:(NSDictionary*) dictionary {

    // get the data
    //ABLoggerDebug(@"1111 responseJSONObject ======== %@",self.responseJSONObject);
    
}

-(void) notifyDelegate:(NSDictionary*) dictionary{
    

}

@end
