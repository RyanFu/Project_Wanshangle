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
    
    self.object_id = nil;
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
 对于所有的需要与用户交互的接口, 也就是module.interact这样的接口, 其中的action参数全部遵循以下规则
 
 投票:　1，
 推荐：　2，
 想看(想去)，　3，
 喜欢(热度/人气)，　4
 */

//http://api.wanshangle.com:10000/api? appId=000001&sign=sign&time=1371988912&v=1.0&api=movie.interact&movieid=1&action=1
- (NSMutableDictionary*) getParamDict {
    
    NSMutableDictionary* paramDict = [[[NSMutableDictionary alloc] init] autorelease];
    [paramDict setObject:[self getActionType:_mType] forKey:@"action"];
    [paramDict setObject:[self getAPIType:_mAPIType]  forKey:@"api"];
    [paramDict setObject:self.object_id  forKey:[self getObjectIDType:_mAPIType]];
    
    return paramDict;
}

- (NSString *)getActionType:(WSLRecommendLookType)type{
    NSString *typeStr = nil;
    switch (type) {
        case WSLRecommendLookTypeRecommend:
            typeStr = @"2";
            break;
        case WSLRecommendLookTypeLook:
            typeStr = @"3";
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
        case WSLRecommendAPITypePerformInteract:
            typeStr = @"perform.interact";
            break;         
        case WSLRecommendAPITypeKTVInteract:
            typeStr = @"ktv.interact";
            break;         
        case WSLRecommendAPITypeBarInteract:
            typeStr = @"bar.interact";
            break;         
        default:
            typeStr = @"";
            break;
    }
    
    return typeStr;
}

- (NSString *)getObjectIDType:(WSLRecommendAPIType)type{
    NSString *typeStr = nil;
    switch (type) {
        case WSLRecommendAPITypeMovieInteract:
            typeStr = @"movieid";
            break;
        case WSLRecommendAPITypeKTVInteract:
            typeStr = @"ktvid";
            break;
        case WSLRecommendAPITypeBarInteract:
            typeStr = @"barid";
            break;
        case WSLRecommendAPITypePerformInteract:
            typeStr = @"performid";
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
