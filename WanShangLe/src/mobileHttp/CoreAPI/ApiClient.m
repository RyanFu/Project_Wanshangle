//
//  ApiClient.m
//  Gaopeng
//
//  Created by yuqiang on 11-10-11.
//  Copyright 2011年 GP. All rights reserved.
//
#import "ApiConfig.h"

#import "ApiCmd.h"
#import "ApiClient.h"
#import "ASIHTTPRequest.h"
#import "ASINetworkQueue.h"
#import "common.h"

// const static key
static NSString* keyToken = @"token";
static NSString* keyAppId = @"appId";
static NSString* keySign = @"sign";

static NSString* keyFormat = @"format";
static NSString* valueFormat = @"json";

static NSString* keyPhoneType = @"phoneType";
static NSString* valuePhoneType = @"iPhone";

@implementation ApiClient

// define getter/setter methods
@synthesize requestArray = _requestArray;

+ (instancetype)defaultClient {
    static ApiClient *_apiClient = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        _apiClient = [[self alloc] init];
    });
    
    return _apiClient;
}

/**
 *  do init work
 */
- (id)init
{
    self = [super init];
    if (self) {
        _networkQueue = [[ASINetworkQueue alloc] init];
        //[networkQueue setDelegate:self];
        [_networkQueue setShouldCancelAllRequestsOnFailure:NO];
        [_networkQueue go];
        
        _requestArray = [[NSMutableArray alloc] initWithCapacity:10];
    }
    return self;
}

-(void)cancelASIDataFormRequest
{
    [_networkQueue cancelAllOperations];
}

- (void) apiNotifyResult:(id) apiCmd  error:(NSError*) error {
    
}
/**
 *  release all resources
 *
 */
- (void) dealloc {
    
    self.networkQueue = nil;
    self.requestArray = nil;
    
	[super dealloc];
}

/**
 *  do signature of all parametrs
 */
- (NSString*) signParam:(NSMutableDictionary*) dict{
    
    // add all keys into array
    NSMutableArray* paramArray = [[[NSMutableArray alloc] initWithCapacity:[dict count]] autorelease];
    
    NSEnumerator *enumerator = [dict keyEnumerator];
    NSString* key;
    
    while ((key = [enumerator nextObject])) {
        [paramArray addObject:key];
    }
    
    // sort the param array
    [paramArray sortUsingComparator:^(id obj1, id obj2){
        NSString* str1 = obj1;
        NSString* str2 = obj2;
        return [str1 compare:str2];
    }];
    
    // append the values to form the pre-encryption string
    NSMutableString* mutableString = [[[NSMutableString alloc] initWithCapacity:128] autorelease];
    for (NSInteger index = 0; index < [paramArray count]; index++) {
        id tmpId = [dict objectForKey:[paramArray objectAtIndex:index]];
        
        NSString* strValue =  @"";
        
        if ([tmpId isKindOfClass:[NSString class]]) {
            strValue = tmpId;
        }else if([tmpId isKindOfClass:[NSNumber class]]){
            strValue = [tmpId stringValue];
        }else{
            // do nothing
            ABLoggerError(@"Error Value of [%@], can only accept NSString or NSNumber",[paramArray objectAtIndex:index]);
        }
        
        [mutableString appendString:strValue];
    }
    
    // append the apiSignParamKey
    [mutableString appendString:[ApiConfig getApiSignParamKey]];
    ABLoggerDebug(@"urlstring---------%@",mutableString);
    // do MD5 encryption
    return md5(mutableString);
}

//- (ASIHTTPRequest*) prepareExecuteApiCmd:(ApiCmd*) cmd{
//    
//    // set apiClient of cmd
//    cmd.apiClient = self;
//    
//    // prepare post data
//    NSMutableDictionary* postDict = [cmd getParamDict];
//    NSString * newToken = nil;
//    NSUserDefaults *defaults = [NSUserDefaults  standardUserDefaults];
//    newToken = [defaults objectForKey:@"HSAPI"];
//    
//    // add appId & cookie & phoneType
//    [postDict setValue:[ApiConfig getApiAppId] forKey:keyAppId];
//    [postDict setValue:@"1.0" forKey:@"v"];
//    
//    // caculate signature of parameters
//    NSString* paramSign = [self signParam:postDict];
//    [postDict setValue:paramSign forKey:keySign];
//    
//    // add all parameters to post data
//    
//    // prepare http request
//    NSURL *url = [NSURL URLWithString:[ApiConfig getApiRequestUrl]];
//    
//    self.request = [ASIFormDataRequest requestWithURL:url];
//    NSString * userAgnet = [ASIHTTPRequest defaultUserAgentString];
//    apiLogDebug(@"userAgent is %@",userAgnet);
//    
//    NSString * deviceInfo = [defaults objectForKey:@"deviceInfo"];
//    apiLogDebug(@"deviceInfo is %@",deviceInfo);
//    userAgnet = [userAgnet stringByAppendingFormat:@"&%@",deviceInfo];
//    userAgnet = [userAgnet stringByAppendingFormat:@"&huishow=v2.2"];
//    apiLogDebug(@"NewUserAgent is %@",userAgnet);
//    
//    [request addRequestHeader:@"User-Agent" value:userAgnet];
//    apiLogDebug(@"request.requesetHeader is %@",[request.requestHeaders objectForKey:@"User-Agent"]);
//    
//    
//    if ([ApiConfig getApiMessageDebug]) {
//        apiLogInfo(@"ApiRequestURL : [%@]", [ApiConfig getApiRequestUrl]);
//        apiLogInfo(@"Request Param Count : [%d]", [postDict count]);
//    }
//    
//    NSEnumerator *enumerator = [postDict keyEnumerator];
//    id key;
//    
//    while ((key = [enumerator nextObject])) {
//        
//        NSString* value = (NSString*)[postDict objectForKey:key];
//        // set post data
//        if ([key isEqualToString:@"Filedata"]) {
//            [request setFile:value forKey:@"Filedata"];
//        }
//        else{
//            [request setPostValue:value forKey:(NSString*)key];
//        }
//        
//        // for debugging purpose
//        if ([ApiConfig getApiMessageDebug]) {
//            apiLogInfo(@"Post Param : Key [%@] Value [%@]", (NSString*)key, value);
//        }
//    }
//    //    [request setPostFormat:ASIMultipartFormDataPostFormat];
//    // save all result to a file
//    if (!isEmpty([cmd getCacheFilePath])) {
//        [request setDownloadDestinationPath:[cmd getCacheFilePath]];
//        apiLogDebug(@"save api result to cache file [%@]",[cmd getCacheFilePath]);
//    }
//    
//    return request;
//}

- (void) executeApiCmdAsync:(ApiCmd*) cmd{
    ABLoggerMethod();
    ASIHTTPRequest *request = [cmd prepareExecuteApiCmd];
    
    [_requestArray addObject:cmd];
    
    //  [request startAsynchronous];
    
    if ([request isExecuting]) {
        return;
    }
    
    @synchronized (_networkQueue) {
        [_networkQueue addOperation:request];
    }
    
    ABLoggerDebug(@"request array count === %d",[[[ApiClient defaultClient] requestArray] count]);
}


- (NSError*) executeApiCmd:(ApiCmd*) cmd{
    
    ASIHTTPRequest *request = [cmd prepareExecuteApiCmd];
    [request startSynchronous];
    
    NSError *error = [request error];
    
    if (error) {
        ABLoggerDebug(@"Error [%@]", [error localizedDescription]);
    }
    
    return error;
}

-(NSString*)errorInfo:(NSNumber*)errorNumber
{
    NSString * errorString;
    errorString= [errorNumber stringValue];
    NSMutableDictionary * tmpDict = [[[NSMutableDictionary alloc] initWithCapacity:30] autorelease];
    /*系统错误*/
    [tmpDict setObject:@"无效的调用接口" forKey:@"10004000"];
    [tmpDict setObject:@"参数未找到" forKey:@"10004001"];
    [tmpDict setObject:@"缺少必需参数" forKey:@"10004002"];
    [tmpDict setObject:@"请求的API不存在" forKey:@"10004003"];
    [tmpDict setObject:@"签名验证失败" forKey:@"10004004"];
    [tmpDict setObject:@"API需求参数未找到" forKey:@"10004005"];
    
    return [tmpDict objectForKey:errorString];
}
@end
