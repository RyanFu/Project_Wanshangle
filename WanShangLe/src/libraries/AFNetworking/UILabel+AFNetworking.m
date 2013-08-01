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
#import "ApiCmdMovie_getTodayTotalSchedule.h"

#if defined(__IPHONE_OS_VERSION_MIN_REQUIRED)
#import "UILabel+AFNetworking.h"

#pragma mark -

@interface AFJsonCache(){
    
}
@end

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
        [AFJSONRequestOperation addAcceptableContentTypes:[NSSet setWithObject:@"text/html"]];
        _af_jsonRequestOperationQueue = [[NSOperationQueue alloc] init];
        [_af_jsonRequestOperationQueue setMaxConcurrentOperationCount:NSOperationQueueDefaultMaxConcurrentOperationCount];
    });
    
    return _af_jsonRequestOperationQueue;
}

+ (AFJsonCache *)af_sharedJsonCache {
    static AFJsonCache *_af_jsonCache = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        _af_jsonCache = [[AFJsonCache alloc] init];
    });
    
    return _af_jsonCache;
}

//#pragma mark -
//- (void)setJSONWithWithMovie:(MMovie *)aMovie
//                      cinema:(MCinema *)aCinema
//                 placeholder:(NSString *)placeholderString
//                     success:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, NSString *resultString))success
//                     failure:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error))failure;
//{
//    [self cancelJSONRequestOperation];
//    NSString *key = [NSString stringWithFormat:@"%@-%@",aMovie.uid,aCinema.uid];
//    NSString *cachedJson = nil;
//    
//    cachedJson = [[[self class] af_sharedJsonCache] cachedJsonForRequest:key];
//    ABLoggerDebug(@"cached schedule === %@",cachedJson);
//    if (isEmpty(cachedJson)) {
//        cachedJson = [self getCachedJsonForCoreDataWithMovie:aMovie cinema:aCinema];
//    }
//    
//    if (!isEmpty(cachedJson)) {
//        if (success) {
//            success(nil, nil, cachedJson);
//        }
//        self.text = cachedJson;
//        self.af_jsonRequestOperation = nil;
//    } else {
//        self.text = placeholderString;
//        NSMutableURLRequest *urlRequest = [[NSMutableURLRequest alloc] initWithURL:[self getURLWithMovie:aMovie cinema:aCinema]];
//        
//        AFJSONRequestOperation *requestOperation = [[AFJSONRequestOperation alloc] initWithRequest:urlRequest];
//        
//        [requestOperation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
//            
//            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//            
//                NSString *resultString = [self parseResponseObject:responseObject Movie:aMovie cinema:aCinema];
//                if ([urlRequest isEqual:[self.af_jsonRequestOperation request]]) {
//                    if (success) {
//                        dispatch_async(dispatch_get_main_queue(), ^{
//                            self.text = resultString;
//                        });
//                        success(operation.request, operation.response, resultString);
//                    } else if (resultString) {
//                        dispatch_async(dispatch_get_main_queue(), ^{
//                            self.text = resultString;
//                        });
//                    }
//                    
//                    if (self.af_jsonRequestOperation == operation) {
//                        self.af_jsonRequestOperation = nil;
//                    }
//                }
//                [[[self class] af_sharedJsonCache] cacheJson:resultString forRequest:key];
//            });
//        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//            if ([urlRequest isEqual:[self.af_jsonRequestOperation request]]) {
//                if (failure) {
//                    failure(operation.request, operation.response, error);
//                }
//                
//                if (self.af_jsonRequestOperation == operation) {
//                    self.af_jsonRequestOperation = nil;
//                }
//            }
//        }];
//        
//        self.af_jsonRequestOperation = requestOperation;
//        
//        [[[self class] af_sharedJsonRequestOperationQueue] addOperation:self.af_jsonRequestOperation];
//    }
//}

#pragma mark -
- (void)setJSONWithWithMovie:(MMovie *)aMovie
                      cinema:(MCinema *)aCinema
                 placeholder:(NSString *)placeholderString
                     success:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, NSString *resultString))success
                     failure:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error))failure;
{
    [self cancelJSONRequestOperation];
    NSString *key = [NSString stringWithFormat:@"%@-%@",aMovie.uid,aCinema.uid];
    NSDictionary *cachedJson = nil;
    
    cachedJson = (NSDictionary *)[[[self class] af_sharedJsonCache] cachedJsonForRequest:key];
    ABLoggerDebug(@"cached schedule === %@",cachedJson);
    
    if (!isNull(cachedJson)) {
        if (success) {
            NSString *price = [NSString stringWithFormat:@"%d元",[[cachedJson objectForKey:@"lowestPrice"] intValue]];
            success(nil, nil, price);
        }
        NSString *rounds = [NSString stringWithFormat:@"还剩%d场 %@",[[cachedJson objectForKey:@"rounds"] intValue],[cachedJson objectForKey:@"type"]];
        self.text = rounds;
        self.af_jsonRequestOperation = nil;
    } else {
        self.text = placeholderString;
        NSURL *url = [ApiCmdMovie_getTodayTotalSchedule getURLWithMovie:aMovie cinema:aCinema];
        NSMutableURLRequest *urlRequest = [[NSMutableURLRequest alloc] initWithURL:url];
        
        AFJSONRequestOperation *requestOperation = [[AFJSONRequestOperation alloc] initWithRequest:urlRequest];
        
        /*
         {
         httpCode: 200,
         errors: [ ],
         data: {
             rounds: 1,
             lowestPrice: 120,
             language: "原版",
             type: "2D"
             },
             token: null,
             timestamp: "1375251080"
         }*/
        [requestOperation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                int rounds = [[[responseObject objectForKey:@"data"] objectForKey:@"rounds"] intValue];
                NSString *resultString = [NSString stringWithFormat:@"还剩%d场 %@",rounds,[[responseObject objectForKey:@"data"] objectForKey:@"type"]] ;
                NSString *priceString = [NSString stringWithFormat:@"%d元",[[[responseObject objectForKey:@"data"] objectForKey:@"lowestPrice"] intValue]];
                if ([urlRequest isEqual:[self.af_jsonRequestOperation request]]) {
                    if (success) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            self.text = resultString;
                            success(operation.request, operation.response, priceString);
                        });
                    } else if (resultString) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            self.text = resultString;
                        });
                    }
                    
                    if (self.af_jsonRequestOperation == operation) {
                        self.af_jsonRequestOperation = nil;
                    }
                }
                [[[self class] af_sharedJsonCache] cacheJson:[responseObject objectForKey:@"data"] forRequest:key];
            });
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
    
    return [self formatScheduleData:tSchedule];
}

- (NSString *)parseResponseObject:(NSDictionary *)responseJson
                            Movie:(MMovie *)aMovie
                           cinema:(MCinema *)aCinema{
    ABLoggerDebug(@"responseJson === %@",responseJson);
    
    MSchedule *tSchedule = [[DataBaseManager sharedInstance] insertScheduleIntoCoreDataFromObject:responseJson
                                                                                       withApiCmd:nil
                                                                                       withaMovie:aMovie
                                                                                       andaCinema:aCinema
                                                                                     timedistance:@"0"];
    
    return [self formatScheduleData:tSchedule];
}

- (NSString *)formatScheduleData:(MSchedule *)tSchedule{
    NSDictionary *responseDic = tSchedule.scheduleInfo;
    
    NSDictionary *schedules = [responseDic objectForKey:@"scheduling"];
    NSArray *todayArray = [schedules objectForKey:@"starts"];
    todayArray = [[DataBaseManager sharedInstance] deleteUnavailableSchedules:todayArray];
    
    return [NSString stringWithFormat:@"还剩%d场",[todayArray count]];
}

//http://api.wanshangle.com:10000/api? appId=000001&sign=sign&time=1371988912&v=1.0&api=movie.scheduling&movieid=1&cinemaid=1&timedistance=0
//http://api.wanshangle.com:10000/api? appId=000001&sign=sign&time=1&v=1.0&api=movie.statistics&movieid=39&cinemaid=120
//- (NSURL *)getURLWithMovie:(MMovie *)aMovie
//                    cinema:(MCinema *)aCinema{
//    // prepare post data
//    NSMutableDictionary* paramDict = [[NSMutableDictionary alloc] init];
//    [paramDict setObject:@"movie.statistics" forKey:@"api"];
//    [paramDict setObject:aMovie.uid forKey:@"movieid"];
//    [paramDict setObject:aCinema.uid  forKey:@"cinemaid"];
//    
//    // add appId & cookie & phoneType
//    [paramDict setValue:[ApiConfig getApiAppId] forKey:@"appId"];
//    [paramDict setValue:AppVersion forKey:@"v"];
//    [paramDict setValue:@"sign" forKey:@"sign"];
//    [paramDict setValue:[NSString stringWithFormat:@"%0.0f",[[[DataBaseManager sharedInstance] date] timeIntervalSince1970]] forKey:@"time"];
//    
//    NSMutableString *urlStr = [[NSMutableString alloc] init];
//    [urlStr appendString:[ApiConfig getApiRequestUrl]];
//    
//    for (NSString *key in [paramDict allKeys]) {
//        [urlStr appendFormat:@"&%@=%@",key,[paramDict objectForKey:key]];
//    }
//    
//    // prepare http request
//    NSURL *url = [NSURL URLWithString:urlStr];
//    ABLoggerInfo(@"request url ===== %@",urlStr);
//    return url;
////    // prepare post data
////    NSMutableDictionary* paramDict = [[NSMutableDictionary alloc] init];
////    [paramDict setObject:@"movie.scheduling" forKey:@"api"];
////    [paramDict setObject:aMovie.uid forKey:@"movieid"];
////    [paramDict setObject:aCinema.uid  forKey:@"cinemaid"];
////    [paramDict setObject:@"0"  forKey:@"timedistance"];
////    
////    // add appId & cookie & phoneType
////    [paramDict setValue:[ApiConfig getApiAppId] forKey:@"appId"];
////    [paramDict setValue:@"1.0" forKey:@"v"];
////    [paramDict setValue:@"sign" forKey:@"sign"];
////    [paramDict setValue:[NSString stringWithFormat:@"%0.0f",[[[DataBaseManager sharedInstance] date] timeIntervalSince1970]] forKey:@"time"];
////    
////    NSMutableString *urlStr = [[NSMutableString alloc] init];
////    [urlStr appendString:[ApiConfig getApiRequestUrl]];
////    
////    for (NSString *key in [paramDict allKeys]) {
////        [urlStr appendFormat:@"&%@=%@",key,[paramDict objectForKey:key]];
////    }
////    
////    // prepare http request
////    NSURL *url = [NSURL URLWithString:urlStr];
////    ABLoggerInfo(@"request url ===== %@",urlStr);
////    return url;
//}
@end

@implementation AFJsonCache

-(id)init{
    if (self=[super init]) {
        _scheduleCache = [[NSMutableDictionary alloc] initWithCapacity:DataCount];
    }
    return self;
}

- (id)cachedJsonForRequest:(NSString *)request{

	return [_scheduleCache objectForKey:request];
}


- (void)cacheJson:(NSString *)Json
       forRequest:(NSString *)request
{
    if (Json && request) {
        [_scheduleCache setObject:Json forKey:request];
    }
}
@end

#endif
