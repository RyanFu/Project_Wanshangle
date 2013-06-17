//
//  ApiCmdBindingHuiShowAccount.m
//  mobileapi
//
//  Created by doujingxuan on 10/30/12.
//
//

#import "ApiCmdShow_getAllShows.h"
#import "common.h"

@implementation ApiCmdShow_getAllShows

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
    NSURL *url = [NSURL URLWithString:@"https://raw.github.com/zyallday/HelloWorld/master/mobileapidemo/performance-list.json"];
    
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
    ABLoggerDebug(@"1111 responseJSONObject ======== %@",self.responseJSONObject);
}

-(void) notifyDelegate:(NSDictionary*) dictionary{
    

}

@end
