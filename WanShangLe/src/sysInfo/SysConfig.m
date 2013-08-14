//
//  config.m
//  uimain
//
//  Created by Qiang Yu on 3/29/12.
//  Copyright (c) 2012 Tsinghua. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SysConfig.h"

static NSString* _settingFile = nil;

// current enviroment
static enum SysEnv _currentEnv = SysDev;

// define configuration structure
struct SysConfig {
    enum ApiLogLevel logLevel; 
    char barcodeServerUrl[128];
    char shortServerUrl[128];
    char umengSNSAppkey[128];
    char reviewUrl[128];
    char currentVersonNumber[16];
//    char umengStatisticAppkey[128];
//    char flurryAppkey[128];
//    NSMutableDictionary * settingDict;
};


// configurations for different environments
struct SysConfig  _configureArray[SysEnvEnd] = {
    
    // for SysDev
    {
        .logLevel = ApiLogDebug,
        .barcodeServerUrl = "http://dev-barcode.huishow.net/barcode/barcode/",
        .shortServerUrl = "http://hs8.cn",
        .reviewUrl = "http://dev-www.huishow.net/contact.php",
//        .settingDict = nil,
        .umengSNSAppkey = "4fa9df4c52701547c600002b",
        .currentVersonNumber = "2.1",
//        .umengStatisticAppkey = "4fa9df4c52701547c600002b",
//        .flurryAppkey = "D49LPN8MF34IWYLS7RTR",
    },
    
    // for SysQa
    {
        .logLevel = ApiLogDebug,
        .barcodeServerUrl = "http://barcode.huishow.net/barcode/barcode/",
        .shortServerUrl = "http://hs8.cn",
        .reviewUrl = "http://dev-www.huishow.net/contact.php",
//        .settingDict = nil,
        .umengSNSAppkey = "4fa9df4c52701547c600002b",
        .currentVersonNumber = "2.1",
//        .umengStatisticAppkey = "4fa9df4c52701547c600002b",
//        .flurryAppkey = "D49LPN8MF34IWYLS7RTR",
    },
    
    // for SysProd
    {
        .logLevel = ApiLogError,
        .barcodeServerUrl = "http://barcode.huishow.com/barcode/barcode/",
        .shortServerUrl = "http://hs8.cn",
        .reviewUrl = "http://www.huishow.com/contact.php",
//        .settingDict = nil,
        .umengSNSAppkey = "4fa9df4c52701547c600002b",
        .currentVersonNumber = "2.1",
//        .umengStatisticAppkey = "4fa9df4c52701547c600002b",
//        .flurryAppkey = "D49LPN8MF34IWYLS7RTR",
    }

};
@implementation SysConfig

+ (enum SysEnv) getSysEnv{
    return _currentEnv;
}

+ (void) setSysEnv:(enum SysEnv) env {
    _currentEnv = env;
}

+ (struct SysConfig) getCurrentConfig {
    return _configureArray[_currentEnv];
}

+ (struct SysConfig*) getCurrentConfigPointer {
    return &_configureArray[_currentEnv];
}

+ (void) doSystemInit {
    
//    // init the setting dictionary
//    NSString* homePath = [NSHomeDirectory() stringByAppendingPathComponent:@"/Documents"];
//    _settingFile = [[homePath stringByAppendingPathComponent:@"setting.set"] retain];
//    
//    if([[NSFileManager defaultManager] fileExistsAtPath:_settingFile]){
//        [self getCurrentConfigPointer]->settingDict = [[NSMutableDictionary alloc] initWithContentsOfFile:_settingFile];
//    }
//    else{
//        [self getCurrentConfigPointer]->settingDict = [[NSMutableDictionary alloc] init];
//        NSDictionary* dict = [self getCurrentConfig].settingDict;
//        [dict setValue:@"1" forKey:@"sounds"];
//        [dict setValue:@"0" forKey:@"shock"];
//        [dict setValue:@"1" forKey:@"camera"];
//        [dict setValue:@"1" forKey:@"shake"];
//        [dict setValue:@"0" forKey:@"autourl"];
//        [dict setValue:@"0" forKey:@"copyboard"];
//        [dict setValue:@"1" forKey:@"30day"];
//        [dict setValue:@"1" forKey:@"genImageversion"];
//        [dict writeToFile:_settingFile atomically:YES];
//    }
}

+ (void) doSystemDestroy {
//    [[self getCurrentConfig].settingDict release];
    [_settingFile release];
}


+ (NSString*) getBarcodeServerUrl {
    return [NSString stringWithCString:[self getCurrentConfig].barcodeServerUrl 
                              encoding:NSUTF8StringEncoding];
}

+ (NSString*) getShortServerUrl {
    return [NSString stringWithCString:[self getCurrentConfig].shortServerUrl
                              encoding:NSUTF8StringEncoding];
}
+ (NSString*) getSetting:(NSString*) key{
//    return [[self getCurrentConfig].settingDict valueForKey:key];
}

+ (void) setSetting:(NSString*) value key:(NSString*) key{
//    [[self getCurrentConfig].settingDict setValue:value forKey:key];
//    [[self getCurrentConfig].settingDict writeToFile:_settingFile atomically:YES];
}
+(NSString*)getUmengSNSAppkey
{
    return [NSString stringWithCString:[self getCurrentConfig].umengSNSAppkey
                              encoding:NSUTF8StringEncoding];

}
+(NSString*)getCurrentVerson
{
    return [NSString stringWithCString:[self getCurrentConfig].currentVersonNumber
                              encoding:NSUTF8StringEncoding];
}
+(NSString*)getReviewUrl
{
    return [NSString stringWithCString:[self getCurrentConfig].reviewUrl
                              encoding:NSUTF8StringEncoding];

}
//+(NSString*)getUmengStatisticAppkey
//{
//    return [NSString stringWithCString:[self getCurrentConfig].umengStatisticAppkey
//                              encoding:NSUTF8StringEncoding];
//
//}
//+(NSString*)getFlurryAppkey
//{
//    return [NSString stringWithCString:[self getCurrentConfig].flurryAppkey
//                              encoding:NSUTF8StringEncoding];
//
//}

@end




