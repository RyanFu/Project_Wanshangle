//
//  ApiCmdBindingHuiShowAccount.m
//  mobileapi
//
//  Created by doujingxuan on 10/30/12.
//
//

#import "ApiCmd_recommendOrLook.h"
#import "common.h"

@implementation ApiCmd_recommendOrLook

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
	[super dealloc];
}

- (ASIHTTPRequest*)prepareExecuteApiCmd{
    [super prepareExecuteApiCmd];
    
    // prepare http request
    NSURL *url = [NSURL URLWithString:@"https://raw.github.com/zyallday/HelloWorld/master/mobileapidemo/hotmovie-info.json"];
    
    [self.httpRequest setURL:url];
    
    return self.httpRequest;
}

//http://api.wanshangle.com:10000/api? appId=000001&sign=sign&time=1371988912&v=1.0&api=movie.interact&movieid=1&action=1
- (NSMutableDictionary*) getParamDict {
    
    NSMutableDictionary* paramDict = [[[NSMutableDictionary alloc] init] autorelease];
    [paramDict setObject:[self getActionType:_mType] forKey:@"action"];
    [paramDict setObject:[self getAPIType:_mAPIType]  forKey:@"api"];
    [paramDict setObject:self.movie_id  forKey:@"movieid"];
    
    return paramDict;
}

- (NSString *)getActionType:(WSLRecommendLookType)type{
    NSString *typeStr = nil;
    switch (type) {
        case WSLRecommendLookTypeRecommend:
            typeStr = @"recommend";
            break;
        case WSLRecommendLookTypeLook:
            typeStr = @"look";
            break;            
        default:
            typeStr = @"1";
            break;
    }
    
    return typeStr;
}

- (NSString *)getAPIType:(WSLRecommendAPIType)type{
    NSString *typeStr = nil;
    switch (type) {
        case WSLRecommendAPITypeMovieInteract:
            typeStr = @"movie.interact";
            break;         
        default:
            typeStr = @"";
            break;
    }
    
    return typeStr;
}


- (void) parseResultData:(NSDictionary*) dictionary {
    
    // get the data
    //ABLoggerDebug(@"1111 responseJSONObject ======== %@",self.responseJSONObject);
    
}

-(void) notifyDelegate:(NSDictionary*) dictionary{
    
    
}

@end
