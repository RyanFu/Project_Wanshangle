//
//  ApiConfig.m
//  Gaopeng
//
//  Created by yuqiang on 11-10-10.
//  Copyright 2011年 GP. All rights reserved.
//

#import "ApiConfig.h"

/**
 *   I use C++ Code here because i want to alloc variables staticly
 *
 */

struct EnvConfig{
    char apiRequestUrl[128];
    char apiStaticUrlPrefix[128];
    char apiAppId[64];
    char apiSignParamKey[128];
};

// enviroments
static enum Environment apiEnv = APIDEV;

// enviroments configurations
static struct EnvConfig envConfigArray[APIEND] = {
    
    // APIDEV
    //http://dev-api.huishow.net/user/login?username=dev@huishow.com&password=123456
    {
     .apiRequestUrl = "http://api.wanshangle.com:10000/api?", 
     .apiStaticUrlPrefix = "http://cdn.gaopeng.com",
     .apiAppId = "000001", 
     .apiSignParamKey = "92bb2f0fd9d13edd85751207d1b6f82a",        
    },
    
    // APIQA
    {.apiRequestUrl = "http://api.wanshangle.com:10000/api?", 
     .apiStaticUrlPrefix= "http://cdn.gaopeng.com",
     .apiAppId = "000001", 
     .apiSignParamKey = "GAOPENGMOBILEVERSION1",
    },
    
    // APIPROD
    {.apiRequestUrl = "http://api.wanshangle.com:10000/api?",
     .apiStaticUrlPrefix = "http://cdn.gaopeng.com",
     .apiAppId = "000001", 
     .apiSignParamKey = "92bb2f0fd9d13edd85751207d1b6f82a",
    },

};

static const struct EnvConfig* getEnvConfig() {
    
    return &envConfigArray[apiEnv];
}

static const char* getApiRequestUrl() {
    return getEnvConfig()->apiRequestUrl;
}

static const char* getApiStaticUrlPrefix() {
    return getEnvConfig()->apiStaticUrlPrefix;
}

static const char* getApiAppId() {
    return getEnvConfig()->apiAppId;
}

static const char* getApiSignParamKey() {
    return getEnvConfig()->apiSignParamKey;
}


static BOOL apiMessageDebug = YES;

/**
 *  Object C class for other code to use
 *  
 */

@implementation ApiConfig

+ (enum Environment) getEnv{
    return apiEnv;
}

+ (void) setEnv:(enum Environment) env{
    apiEnv = env;
}

+ (NSString*) getApiRequestUrl{
    return [NSString stringWithUTF8String:getApiRequestUrl()];
}

+ (NSString*) getApiStaticUrlPrefix{
    return [NSString stringWithUTF8String:getApiStaticUrlPrefix()];
}

+ (NSString*) getApiAppId{
    return [NSString stringWithUTF8String:getApiAppId()];
}

+ (NSString*) getApiSignParamKey{
    return [NSString stringWithUTF8String:getApiSignParamKey()];
}

+ (BOOL) getApiMessageDebug{
    return apiMessageDebug;
}

+ (void) setApiMessageDebug:(BOOL) isDebug{
    apiMessageDebug = isDebug;
}

@end
