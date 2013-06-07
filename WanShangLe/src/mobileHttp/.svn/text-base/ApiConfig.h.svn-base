//
//  ApiConfig.h
//  Gaopeng
//
//  Created by yuqiang on 11-10-10.
//  Copyright 2011年 GP. All rights reserved.
//

#import <Foundation/Foundation.h>


/**
 * @author yuqiang
 *  
 * define the enviroment,
 */
enum Environment {APIDEV = 0, APIQA , APIPROD , APIEND};


/**
 *  @author yuqiang
 *
 *  this class should be used as a static configuration, 
 *  you should never instantiate it
 *
 */
@interface ApiConfig : NSObject

/**
 * get environment setting
 */
+ (enum Environment) getEnv;

/**
 * set environment 
 */
+ (void) setEnv:(enum Environment) env;

/**
 *  get api request url
 */
+ (NSString*) getApiRequestUrl;

+ (NSString*) getApiStaticUrlPrefix;

+ (NSString*) getApiAppId;

+ (NSString*) getApiSignParamKey;

/**
 * whether do api message debug
 */
+ (BOOL) getApiMessageDebug;

+ (void) setApiMessageDebug:(BOOL) isDebug;


@end



