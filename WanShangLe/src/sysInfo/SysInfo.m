//
//  SysInfo.m
//  SingletonDemo
//
//  Created by 首 回 on 12-4-27.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "SysInfo.h"
#import "UIDevice-Hardware.h"
#import "Reachability.h"
#import "common.h"

static SysInfo * _info = nil;
@implementation SysInfo
@synthesize screenSize = _screenSize,osBeta = _osBeta,deviceType = _deviceType,operators = _operators,networkType = _networkType,other = _other,deviceName = _deviceName,macAddress = _macAddress;

+ (void) doInit {
    if (nil == _info) {
        _info = [[SysInfo alloc] init];
    }
}
+ (void) doDestroy {
    [_info release];
}
+ (id) defaultInfo {
    if (nil == _info) {
        [SysInfo doInit];
    }
    return _info;
}
- (id) init {
    self = [super init];
    
    if (self) {
       NSString * tmposName = [[UIDevice currentDevice] systemName];
       NSString * tmposBeta = [[UIDevice currentDevice] systemVersion];
       NSString * tmpdeviceType = [[UIDevice currentDevice] platformString];
       NSString * tmpdeviceName = [[UIDevice currentDevice] name];
       NSString * tmpmacAddress = [[UIDevice currentDevice] macaddress];
       
        NSString * tmpnetworkType =nil;
        Reachability * r =[Reachability reachabilityWithHostname:@"www.baidu.com"];
        switch ([r currentReachabilityStatus]) {
            case NotReachable:
                tmpnetworkType = @"No NetWork";
                break;
            case ReachableViaWWAN:
                tmpnetworkType = @"3G";
                break;
            case ReachableViaWiFi:
                tmpnetworkType = @"WIFI";
                break;
            default:
                break;
        }
        _osName = encodeURL(tmposName);
        _osBeta = encodeURL(tmposBeta);
        _deviceType = encodeURL(tmpdeviceType);
        _deviceName = encodeURL(tmpdeviceName);
        _macAddress = encodeURL(tmpmacAddress);
        _networkType = encodeURL(tmpnetworkType);

        ABLoggerDebug(@"device=iPhone&osName=%@&osVersion=%@&deviceType=%@&network=%@&macAddr=%@",_osName,_osBeta,_deviceType,_networkType,_macAddress);
        NSString * deviceInfo = [NSString stringWithFormat:@"vendor=huishow&device=iPhone&osName=%@&osVersion=%@&deviceType=%@&network=%@&macAddr=%@",tmposName,tmposBeta,tmpdeviceType,tmpnetworkType,tmpmacAddress];
        NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:deviceInfo forKey:@"deviceInfo"];
    }
    return  self;
}
-(NSString*)getParamString
{
    return [NSString stringWithFormat:@"vendor=huishow&device=iPhone&osName=%@&osVersion=%@&deviceType=%@&network=%@&macAddr=%@",_osName,_osBeta,_deviceType,_networkType,_macAddress];  
}

@end
