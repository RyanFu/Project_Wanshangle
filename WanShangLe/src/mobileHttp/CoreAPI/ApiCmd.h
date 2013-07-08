//
//  ApiCmd.h
//  Gaopeng
//
//  Created by yuqiang on 11-10-11.
//  Copyright 2011年 GP. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ApiNotify.h"
#import "ASIHTTPRequestDelegate.h"

@class ASIHTTPRequest;
/**
 * @author yuqiang
 *
 * This is the base class for all Api Command,
 * You should inherit from this class to create a new command
 *
 */
@interface ApiCmd : NSObject<ApiNotify,ASIHTTPRequestDelegate>{

@private
    
    BOOL isFromCache;
    
    id<ApiNotify> apiClient; 
    id<ApiNotify> delegate; 
    
    NSArray* errorArray;
    NSArray* warnArray;
}
@property(nonatomic, assign) BOOL isFromCache;

@property(nonatomic,assign) id<ApiNotify> apiClient;
@property(nonatomic,assign) id<ApiNotify> delegate;

@property(nonatomic,retain) NSArray* errorArray;
@property(nonatomic,retain) NSArray* warnArray;

@property(nonatomic,retain) ASIHTTPRequest *httpRequest;
@property(nonatomic,retain) NSString *cityName;
@property(nonatomic,retain) NSString *cityId;
@property(nonatomic,retain) NSString *offset;
@property(nonatomic,retain) NSString *limit;
/**
 A JSON object constructed from the response data. If an error occurs while parsing, `nil` will be returned, and the `error` property will be set to the error.
 */
@property (readonly, nonatomic, retain) NSDictionary *responseJSONObject;
@property (readonly, nonatomic, retain) NSData *responseData;

- (BOOL) hasError;
- (BOOL) hasWarn;

-(void) notifyDelegate:(NSDictionary*) dictionary;

/**
 *  parse api error
 **/
- (void) parseApiError:(NSDictionary*) dictionary;

/**
 * parse result data, decendent should override this method
 **/
- (void) parseResultData:(NSDictionary*) dictionary;

/**
 * get all parameters list
 *
 * decendent should override this method
 *
 **/
- (NSMutableDictionary*) getParamDict;

/**
 *  define the cache key for command
 *  we would generate cache key from parameters, if this does not meet your requirement, 
 *  you can override this method to define your own key
 **/
- (NSString*) getCacheKey;

/**
 *  cache file path
 ***/
- (NSString*) getCacheFilePath;


/**
 *  execute apiCmd return an ASIHTTPRequest
 ***/
- (ASIHTTPRequest*)prepareExecuteApiCmd;

@end
