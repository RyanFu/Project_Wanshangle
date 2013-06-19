//
//  ApiCmd.m
//  Gaopeng
//
//  Created by yuqiang on 11-10-11.
//  Copyright 2011年 GP. All rights reserved.
//
#import "common.h"
#import "ApiConfig.h"

#import "ApiFault.h"
#import "ApiCmd.h"
#import "ASIHTTPRequest.h"

@interface ApiCmd()
@property (readwrite, nonatomic, retain) NSDictionary *responseJSONObject;
@property (readwrite, nonatomic, retain) NSData *responseData;
@end

@implementation ApiCmd

@synthesize isFromCache, apiClient, delegate;
@synthesize errorArray, warnArray;
@synthesize responseJSONObject = _responseJSONObject;
@synthesize responseData = _responseData;
@synthesize httpRequest = _httpRequest;

- (id)init
{
    self = [super init];
    if (self) {
        [self cleanup];
    }
    
    return self;
}

- (void) dealloc {
    [self cleanup];
	[super dealloc];
}

- (void)cleanup{
    self.apiClient = nil;
    self.delegate = nil;
    self.errorArray = nil;
    self.warnArray = nil;
    self.responseData = nil;
    self.responseJSONObject = nil;
    self.httpRequest = nil;
    self.isFromCache = NO;
}

- (BOOL) hasError {
    if (nil == errorArray) {
        return NO;
    }
    
    return [errorArray count] > 0;
}

- (BOOL) hasWarn {
    if (nil == warnArray) {
        return NO;
    }
    
    return [warnArray count] > 0;
}

/*
 object.name = path;
 object.hash = [[self responseHeaders] objectForKey:@"ETag"];
 object.bytes = [[[self responseHeaders] objectForKey:@"Content-Length"] intValue];
 object.contentType = [[self responseHeaders] objectForKey:@"Content-Type"];
 object.lastModified = [[self responseHeaders] objectForKey:@"Last-Modified"];
 object.metadata = [NSMutableDictionary dictionary];
 */
- (ASIHTTPRequest*)prepareExecuteApiCmd{
    
    // prepare http request
    NSURL *url = [NSURL URLWithString:[ApiConfig getApiRequestUrl]];
    
    self.httpRequest = [ASIHTTPRequest requestWithURL:url];
    
    NSMutableDictionary *requestHeaders = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                           @"application/json", @"Content-Type",
                                           nil];
    [_httpRequest setRequestHeaders:requestHeaders];
    [_httpRequest setDelegate:self];
    
    //  [_httpRequest addRequestHeader:@"User-Agent" value:@"Wan_Shang_Le"];
    //  [_httpRequest setUserInfo:nil];
    //  [_httpRequest setNumberOfTimesToRetryOnTimeout:2];
    //	[_httpRequest addRequestHeader:@"If-Modified-Since" value:@""];
    //	[_httpRequest addRequestHeader:@"If-None-Match" value:@""];
    return _httpRequest;
}

- (void) parseJsonWithResponseData{
    
    if (nil == _responseData || [_responseData length] == 0) {
        return;
    }
    
    NSError *error = nil;
    self.responseJSONObject = [NSJSONSerialization JSONObjectWithData:self.responseData options:0 error:&error];
    
    if (error) {
        ABLoggerInfo(@"Fail to parseJson with error:\n%@", [error localizedDescription]);
    }
    
    if (nil == _responseJSONObject) {
        ABLoggerError(@"can not parse NSData to string");
        return;
    }
    
    ABLoggerDebug(@"response data lenght ============= %d",[self.responseData length]);
    //ABLoggerDebug(@"response string ============= %@",[[NSString alloc] initWithData:self.responseData encoding:NSUTF8StringEncoding]);
    
    if ([ApiConfig getApiMessageDebug]) {
        //apiLogInfo(@"Return Json String:\n%@", _responseJSONObject);
    }
}

- (void) parseApiError:(NSDictionary*) dictionary {
    
    // reset the old state
    self.errorArray = nil;
    
    NSArray* errorNode = defaultNilObject([dictionary objectForKey:@"errors"]);
    
    if (nil == errorNode) {
        // no error
        return;
    }
    
    NSMutableArray* apiFaultArray = [[[NSMutableArray alloc] initWithCapacity:[errorNode count]] autorelease];
    self.errorArray =  apiFaultArray;
    
    for(NSUInteger index = 0; index < [errorNode count]; index++){
        NSDictionary* faultNode = [errorNode objectAtIndex:index];
        ApiFault* fault = [[[ApiFault alloc] init] autorelease];
        [fault parseDict:faultNode];
        [apiFaultArray addObject:fault];
    }
    
    
    // reset the old state
    self.warnArray = nil;
    
    NSArray* warnNode = defaultNilObject([dictionary objectForKey:@"warns"]);
    
    if (nil == warnNode) {
        // no error
        return;
    }
    
    apiFaultArray = [[[NSMutableArray alloc] initWithCapacity:[warnNode count]] autorelease];
    self.warnArray =  apiFaultArray;
    
    for(NSUInteger index = 0; index < [warnNode count]; index++){
        NSDictionary* faultNode = [warnNode objectAtIndex:index];
        ApiFault* fault = [[[ApiFault alloc] init] autorelease];
        [fault parseDict:faultNode];
        [apiFaultArray addObject:fault];
    }
    
}

- (void) parseResultData:(NSDictionary*) dictionary{
    // we do nothing here
    // you should override this method in decendent classes
}

- (void) parseResponseData{
    
    // parse json data
    [self parseJsonWithResponseData];
    
    if (nil == _responseJSONObject) {
        return;
    }
    
    // parse api error
    [self parseApiError:_responseJSONObject];
    
    if (![self hasError]) {
        // parse into object data
        [self parseResultData:_responseJSONObject];
    }else{
        ABLoggerDebug(@"Api response has error, do not parse result data");
    }
}

/**
 *   ASIHttp callback success
 **/
//- (void)request:(ASIHTTPRequest *)request didReceiveResponseHeaders:(NSDictionary *)responseHeaders{
//    NSMutableData *tmpData = [[NSMutableData alloc] init];
//    self.responseData = tmpData;
//    [tmpData release];
//}
//
//- (void)request:(ASIHTTPRequest *)request didReceiveData:(NSData *)data{
//    ABLoggerDebug(@"didReceiveData ======== %d",[data length]);
//    //[self.responseData appendData:data];
//}

- (void)requestFinished:(ASIHTTPRequest *)request
{
    int statusCode = [request responseStatusCode];
    ABLoggerDebug(@"responseStatusCode ========= %d",statusCode);
    
    self.responseData = [request responseData];
    
    [self parseResponseData];
    
    if (nil != apiClient) {
        // call apiClient first
        [apiClient apiNotifyResult:self error:nil];
    }
    
    if (delegate && [delegate respondsToSelector:@selector(apiNotifyResult:error:)]) {
        // call delegate
        [delegate apiNotifyResult:self error:nil];
    }else{
        [self apiNotifyResult:self error:nil];
    }
}

/**
 *  ASIHttp callback fail
 **/
- (void)requestFailed:(ASIHTTPRequest *)request
{
    NSError *error = [request error];
    
    if (delegate && [delegate respondsToSelector:@selector(apiNotifyResult:error:)]) {
        // call delegate
        [delegate apiNotifyResult:self error:error];
    }else{
        [self apiNotifyResult:self error:error];
    }
}

/**
 *  Implement ApiNotify Protocol
 **/
- (void) apiNotifyResult:(id) apiCmd  error:(NSError*) error {
    
    [[[ApiClient defaultClient] requestArray] removeObject:self];
    ABLoggerWarn(@"request array count === %d",[[[ApiClient defaultClient] requestArray] count]);
    
    ABLoggerWarn(@"apiNotifyResult called, you should override this method to have your own implementation");
}

- (NSMutableDictionary*) getParamDict{
    return [NSMutableDictionary dictionaryWithCapacity:1];
}

- (NSString*) getCacheKey {
    
    NSMutableString* cacheKey = [[[NSMutableString alloc] initWithCapacity:30] autorelease];
    
    // generate cache key from parameters
    NSDictionary* paramDict = [self getParamDict];
    
    // add all keys into array
    NSMutableArray* paramArray = [[[NSMutableArray alloc] initWithCapacity:[paramDict count]] autorelease];
    
    NSEnumerator *enumerator = [paramDict keyEnumerator];
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
    
    for (NSInteger index = 0; index < [paramArray count]; index++) {
        NSString* key = [paramArray objectAtIndex:index];
        id tmpId = [paramDict objectForKey:key];
        
        NSString* strValue =  @"";
        
        if ([tmpId isKindOfClass:[NSString class]]) {
            strValue = tmpId;
        }else if([tmpId isKindOfClass:[NSNumber class]]){
            strValue = [tmpId stringValue];
        }else{
            strValue =  @"";
        }
        
        [cacheKey appendFormat:@"_%@_%@_", key,
         [strValue stringByReplacingOccurrencesOfString:@"/" withString:@"_"]];
    }
    ABLoggerDebug(@"cacheKey------%@",cacheKey);
    cacheKey = (NSMutableString*)md5(cacheKey);
    ABLoggerDebug(@"cacheKey is %@",cacheKey);
    
    if (isEmpty(cacheKey)) {
        return nil;
    }
    return cacheKey;
}

- (NSString*) getCacheFilePath {
    
    if (isEmpty([self getCacheKey])) {
        return nil;
    }
    
    return getCacheFilePath([self getCacheKey]);
}

@end
