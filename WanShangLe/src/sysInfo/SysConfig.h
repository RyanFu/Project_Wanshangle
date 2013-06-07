//
//  config.h
//  uimain
//
//  Created by Qiang Yu on 3/29/12.
//  Copyright (c) 2012 Tsinghua. All rights reserved.
//

enum SysEnv {SysDev, SysQa, SysProd, SysEnvEnd};

enum ApiLogLevel{
    ApiLogNone = 0,
    ApiLogError,
    ApiLogWarn,
    ApiLogInfo,
    ApiLogDebug,
};

@interface SysConfig : NSObject

// configure the system runtime environments
+ (enum SysEnv) getSysEnv;
+ (void) setSysEnv:(enum SysEnv) env;


+ (void) doSystemInit;
+ (void) doSystemDestroy;

// get configuration values
+ (NSString*) getBarcodeServerUrl;
+ (NSString*) getShortServerUrl;

+ (NSString*) getSetting:(NSString*) key;
+ (void) setSetting:(NSString*) value key:(NSString*) key;
+(NSString*)getUmengSNSAppkey;
+(NSString*)getCurrentVerson;
+(NSString*)getReviewUrl;
//+(NSString*)getUmengStatisticAppkey;
//+(NSString*)getFlurryAppkey;

@end
