// UILabel+AFNetworking.m
//
// Copyright (c) 2011 Gowalla (http://gowalla.com/)
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import <Foundation/Foundation.h>
#import <objc/runtime.h>
#import "MSchedule.h"
#import "MMovie.h"
#import "MCinema.h"

#if defined(__IPHONE_OS_VERSION_MIN_REQUIRED)
#import "UILabel+AFNetworking.h"

//@interface AFJsonCache : NSCache
//- (UIJson *)cachedJsonForRequest:(NSURLRequest *)request;
//- (void)cacheJson:(UIJson *)Json
//        forRequest:(NSURLRequest *)request;
//@end

#pragma mark -

static char kAFJSONRequestOperationObjectKey;

@interface UILabel (_AFNetworking)
@property (readwrite, nonatomic, strong, setter = af_setJsonRequestOperation:) AFJSONRequestOperation *af_jsonRequestOperation;
@end

@implementation UILabel (_AFNetworking)
@dynamic af_jsonRequestOperation;
@end

#pragma mark -

@implementation UILabel (AFNetworking)

- (AFHTTPRequestOperation *)af_jsonRequestOperation {
    return (AFHTTPRequestOperation *)objc_getAssociatedObject(self, &kAFJSONRequestOperationObjectKey);
}

- (void)af_setJsonRequestOperation:(AFJSONRequestOperation *)JsonRequestOperation {
    objc_setAssociatedObject(self, &kAFJSONRequestOperationObjectKey, JsonRequestOperation, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

+ (NSOperationQueue *)af_sharedJsonRequestOperationQueue {
    static NSOperationQueue *_af_jsonRequestOperationQueue = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _af_jsonRequestOperationQueue = [[NSOperationQueue alloc] init];
        [_af_jsonRequestOperationQueue setMaxConcurrentOperationCount:NSOperationQueueDefaultMaxConcurrentOperationCount];
    });
    
    return _af_jsonRequestOperationQueue;
}

//+ (AFJsonCache *)af_sharedJsonCache {
//    static AFJsonCache *_af_JsonCache = nil;
//    static dispatch_once_t oncePredicate;
//    dispatch_once(&oncePredicate, ^{
//        _af_JsonCache = [[AFJsonCache alloc] init];
//    });
//
//    return _af_JsonCache;
//}

#pragma mark -

//- (void)setJsonWithURL:(NSURL *)url {
//    [self setJsonWithURL:url placeholderJson:nil];
//}
//
//- (void)setJsonWithURL:(NSURL *)url
//       placeholderJson:(UIJson *)placeholderJson
//{
//    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
//    [request addValue:@"Json/*" forHTTPHeaderField:@"Accept"];
//
//    [self setJsonWithURLRequest:request placeholderJson:placeholderJson success:nil failure:nil];
//}

/*
 //http://api.wanshangle.com:10000/api? appId=000001&sign=sign&time=1371988912&v=1.0&api=movie.scheduling&movieid=35&cinemaid=97
 - (NSMutableDictionary*) getParamDict {
 
 NSMutableDictionary* paramDict = [[[NSMutableDictionary alloc] init] autorelease];
 [paramDict setObject:@"movie.scheduling" forKey:@"api"];
 [paramDict setObject:self.movie_id  forKey:@"movieid"];
 [paramDict setObject:self.cinema_id  forKey:@"cinemaid"];
 
 return paramDict;
 }
 
 */
- (void)setJSONWithWithMovie:(MMovie *)aMovie
                      cinema:(MCinema *)aCinema
                 placeholder:(NSString *)placeholderString
                     success:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, NSString *resultString))success
                     failure:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error))failure;
{
    [self cancelJSONRequestOperation];
    
    NSString *cachedJson = [self getCachedJsonForCoreDataWithMovie:aMovie cinema:aCinema];
    if (!isEmpty(cachedJson)) {
        if (success) {
            success(nil, nil, cachedJson);
        } else {
            self.text = cachedJson;
        }
        self.af_jsonRequestOperation = nil;
    } else {
        self.text = placeholderString;
        NSMutableURLRequest *urlRequest = [[NSMutableURLRequest alloc] initWithURL:[self getURLWithMovie:aMovie cinema:aCinema]];
        AFJSONRequestOperation *requestOperation = [[AFJSONRequestOperation alloc] initWithRequest:urlRequest];
        [requestOperation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
            if ([urlRequest isEqual:[self.af_jsonRequestOperation request]]) {
                if (success) {
                    success(operation.request, operation.response, responseObject);
                } else if (responseObject) {
                    self.text = responseObject;
                }
                
                if (self.af_jsonRequestOperation == operation) {
                    self.af_jsonRequestOperation = nil;
                }
            }
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            if ([urlRequest isEqual:[self.af_jsonRequestOperation request]]) {
                if (failure) {
                    failure(operation.request, operation.response, error);
                }
                
                if (self.af_jsonRequestOperation == operation) {
                    self.af_jsonRequestOperation = nil;
                }
            }
        }];
        
        self.af_jsonRequestOperation = requestOperation;
        
        [[[self class] af_sharedJsonRequestOperationQueue] addOperation:self.af_jsonRequestOperation];
    }
}

- (void)cancelJSONRequestOperation{
    [self.af_jsonRequestOperation cancel];
    self.af_jsonRequestOperation = nil;
}

- (NSString *)getCachedJsonForCoreDataWithMovie:(MMovie *)aMovie
                                         cinema:(MCinema *)aCinema
{
    MSchedule *tSchedule = [[DataBaseManager sharedInstance] getScheduleFromCoreDataWithaMovie:aMovie andaCinema:aCinema timedistance:ScheduleToday];
    if (tSchedule==nil) {
        return nil;
    }
    
    NSDictionary *responseDic = tSchedule.scheduleInfo;
    
    NSDictionary *schedules = [responseDic objectForKey:@"scheduling"];
    NSArray *todayArray = [schedules objectForKey:@"starts"];
    todayArray = [[DataBaseManager sharedInstance] deleteUnavailableSchedules:todayArray];
    
    return [NSString stringWithFormat:@"还剩%d场",[todayArray count]];
}

- (void)insertTodayScheduleForCoreDataWithMovie:(MMovie *)aMovie
                                               cinema:(MCinema *)aCinema
                                         responseJson:(NSDictionary *)responseJson
{
    ABLoggerDebug(@"responseJson === %@",responseJson);
}

//http://api.wanshangle.com:10000/api? appId=000001&sign=sign&time=1371988912&v=1.0&api=movie.scheduling&movieid=1&cinemaid=1&timedistance=0
- (NSURL *)getURLWithMovie:(MMovie *)aMovie
                    cinema:(MCinema *)aCinema{
    // prepare post data
    NSMutableDictionary* paramDict = [[NSMutableDictionary alloc] init];
    [paramDict setObject:@"movie.scheduling" forKey:@"api"];
    [paramDict setObject:aMovie.uid forKey:@"movieid"];
    [paramDict setObject:aCinema.uid  forKey:@"cinemaid"];
    
    // add appId & cookie & phoneType
    [paramDict setValue:[ApiConfig getApiAppId] forKey:@"appId"];
    [paramDict setValue:@"1.0" forKey:@"v"];
    [paramDict setValue:@"sign" forKey:@"sign"];
    [paramDict setValue:[NSString stringWithFormat:@"%0.0f",[[NSDate date] timeIntervalSince1970]] forKey:@"time"];
    
    NSMutableString *urlStr = [[NSMutableString alloc] init];
    [urlStr appendString:[ApiConfig getApiRequestUrl]];
    
    for (NSString *key in [paramDict allKeys]) {
        [urlStr appendFormat:@"&%@=%@",key,[paramDict objectForKey:key]];
    }
    
    // prepare http request
    NSURL *url = [NSURL URLWithString:urlStr];
    ABLoggerInfo(@"request url ===== %@",urlStr);
    return url;
}

@end

#endif
