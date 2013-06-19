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
