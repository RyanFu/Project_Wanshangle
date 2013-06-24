//
//  LocationManager.m
//  WanShangLe
//
//  Created by stephenliu on 13-6-4.
//  Copyright (c) 2013年 stephenliu. All rights reserved.
//

#import "LocationManager.h"
#import "UIAlertView+MKBlockAdditions.h"
#import "SIAlertView.h"

@interface LocationManager()<MKMapViewDelegate,UIAlertViewDelegate,CLLocationManagerDelegate>{
    
}
@property (nonatomic, retain) CLGeocoder *geoCoder;
@property (nonatomic, retain) MKMapView *map;
@property (nonatomic, retain) CLLocationManager *locationManager;
@property (nonatomic, copy) SetUserCityCallBack userCityCallBack;
@end

@implementation LocationManager
@synthesize geoCoder = _geoCoder;
@synthesize map = _map;

- (void)dealloc
{
    self.geoCoder = nil;
    self.map = nil;
    self.userCityCallBack = nil;
    
    [super dealloc];
}

+ (instancetype)defaultLocationManager {
    static LocationManager *_locationManager = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        _locationManager = [[self alloc] init];
    });
    
    return _locationManager;
}

- (id)init{
    self = [super init];
    if (self) {

    }
    return self;
}

/*
- (void)startLocationUserGPS{
    ABLoggerMethod();
    
    if ([self checkGPSEnable]) {
        if (!_map) {
            _map = [[MKMapView alloc] init];
            [_map setHidden:YES];
        }
        _map.showsUserLocation =YES;
        _map.delegate = self;
    }
}

- (void)stopLocationUserGPS{
    _map.showsUserLocation = NO;
    self.map = nil;
}
*/


- (BOOL)checkGPSEnable{
    ABLoggerMethod();
    BOOL isEnable = YES;
    
    if (![CLLocationManager locationServicesEnabled]){
        isEnable = NO;
        ABLoggerDebug(@"定位服没有打开");
    }
    
    if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied){
        isEnable = NO;
        ABLoggerDebug(@"软件没有被用户授权 = kCLAuthorizationStatusDenied");
    }
    
    if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusRestricted){
        isEnable = NO;
        ABLoggerDebug(@"软件没有被系统授权 = kCLAuthorizationStatusRestricted");
    }
    
    //    if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusNotDetermined){
    //        isEnable = NO;
    //        ABLoggerDebug(@"软件没有被系统授权 = kCLAuthorizationStatusNotDetermined");
    //    }
    
    if (![[ReachabilityManager defaultReachabilityManager] isReachableNetwork]) {
        isEnable = NO;
        ABLoggerDebug(@"没有网络啊+++++");
    }
    
    return isEnable;
}

#pragma mark -
#pragma mark MKMapViewDelegate
- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation {
    
    ABLoggerMethod();
    CLLocation * newLocation = userLocation.location;
    
    //解析并获取当前坐标对应得地址信息
    if ([[[UIDevice currentDevice] systemVersion]floatValue] >= 5.0) {
        CLGeocoder *clGeoCoder = [[CLGeocoder alloc] init];
        CLGeocodeCompletionHandler handle = ^(NSArray *placemarks,NSError *error)
        {
            for (CLPlacemark * placeMark in placemarks)
            {
                
#ifdef AB_LOGGER
                for (NSString *key in [placeMark addressDictionary]) {
                    ABLoggerInfo(@"定位到城市 %@ === %@",key,[[placeMark addressDictionary] objectForKey:key]);
                }
#endif
                
                if (SYSTEM_VERSION_LESS_THAN(@"6.0")) {
                    ABLoggerWarn(@"GPS 定位到城市 === %@",[[placeMark addressDictionary] objectForKey:@"City"]);
                    [self setUserCity:[[placeMark addressDictionary] objectForKey:@"City"] CallBack:nil];
                }else{
                    ABLoggerWarn(@"GPS 定位到城市 === %@",placeMark.administrativeArea);
                    [self setUserCity:placeMark.administrativeArea CallBack:nil];
                    
                }
            }
        };
        [clGeoCoder reverseGeocodeLocation:newLocation completionHandler:handle];
        [clGeoCoder release];
        [self stopLocationUserGPS];
    }
}

- (void)mapView:(MKMapView *)mapView didFailToLocateUserWithError:(NSError *)error{
    ABLoggerMethod();
    if (error) {
        ABLoggerError(@"error ======== %@",[error debugDescription]);
    }
}


- (void)startLocationUserGPS
{
    if ([self checkGPSEnable]) {
    // if location services are restricted do nothing
    if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied ||
        [CLLocationManager authorizationStatus] == kCLAuthorizationStatusRestricted)
    {
        return;
    }
    
    // if locationManager does not currently exist, create it
    if (!_locationManager)
    {
        _locationManager = [[CLLocationManager alloc] init];
        [_locationManager setDelegate:self];
        _locationManager.distanceFilter = 10.0f; // we don't need to be any more accurate than 10m
    }
    
    [_locationManager startUpdatingLocation];
        
    }
}

- (void)stopLocationUserGPS
{
    [_locationManager stopUpdatingLocation];
    self.locationManager = nil;
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    // if the location is older than 30s ignore
    if (fabs([newLocation.timestamp timeIntervalSinceDate:[NSDate date]]) > 30)
    {
        return;
    } 
    //解析并获取当前坐标对应得地址信息
    if ([[[UIDevice currentDevice] systemVersion]floatValue] >= 5.0) {
        CLGeocoder *clGeoCoder = [[CLGeocoder alloc] init];
        CLGeocodeCompletionHandler handle = ^(NSArray *placemarks,NSError *error)
        {
            for (CLPlacemark * placeMark in placemarks)
            {
                
#ifdef AB_LOGGER
                for (NSString *key in [placeMark addressDictionary]) {
                    ABLoggerInfo(@"定位到城市 %@ === %@",key,[[placeMark addressDictionary] objectForKey:key]);
                }
#endif
                
                if (SYSTEM_VERSION_LESS_THAN(@"6.0")) {
                    ABLoggerWarn(@"GPS 定位到城市 === %@",[[placeMark addressDictionary] objectForKey:@"City"]);
                    [self setUserCity:[[placeMark addressDictionary] objectForKey:@"City"] CallBack:nil];
                }else{
                    ABLoggerWarn(@"GPS 定位到城市 === %@",placeMark.administrativeArea);
                    [self setUserCity:placeMark.administrativeArea CallBack:nil];
                    
                }
            }
        };
        [clGeoCoder reverseGeocodeLocation:newLocation completionHandler:handle];
        [clGeoCoder release];
        [self stopLocationUserGPS];
    }
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    ABLoggerWarn(@"fail to location");
}

- (NSString *)getUserCity{
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *city = [userDefaults objectForKey:UserState];
    
    ABLoggerWarn(@"从UserDefault 获取 user city === %@",city);
    
    return city;
}

- (BOOL)setUserCity:(NSString *)newCity CallBack:(SetUserCityCallBack)callback{
    
    if (isEmpty(newCity)) {
        return NO;
    }
    
    newCity = [newCity substringToIndex:2];
    
    self.userCityCallBack = callback;
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    NSString *city = [self getUserCity];
    if (city) {
        if(![city isEqual:newCity]){
            ABLoggerWarn(@"切换城市 from %@ to %@",city,newCity);
            
            SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"确定要切换城市为%@吗?,亲!",newCity] andMessage:nil];
            [alertView addButtonWithTitle:@"取消"
                                     type:SIAlertViewButtonTypeCancel
                                  handler:^(SIAlertView *alertView) {
                                      ABLoggerDebug(@"取消换城市");
                                  }];
            [alertView addButtonWithTitle:@"确定"
                                     type:SIAlertViewButtonTypeDefault
                                  handler:^(SIAlertView *alertView) {
                                      [[DataBaseManager sharedInstance] cleanUp];
                                      [userDefaults setObject:newCity forKey:UserState];
                                      [userDefaults synchronize];
                                      
                                      [[LocationManager defaultLocationManager].cityLabel setTitle:newCity forState:UIControlStateNormal];
                                      if (_userCityCallBack) {
                                          _userCityCallBack();
                                      }
                                      ABLoggerDebug(@"确定切换城市");
                                  }];
            
            alertView.transitionStyle = SIAlertViewTransitionStyleDropDown;
            alertView.backgroundStyle = SIAlertViewBackgroundStyleSolid;
            
            [alertView show];
            [alertView release];
        }else{
            [[LocationManager defaultLocationManager].cityLabel setTitle:newCity forState:UIControlStateNormal];
        }
    }else{
        ABLoggerInfo(@"第一次选择城市");
        SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"第一次选择城市%@,亲!",newCity] andMessage:nil];
        [alertView addButtonWithTitle:@"取消"
                                 type:SIAlertViewButtonTypeCancel
                              handler:^(SIAlertView *alertView) {
                                  ABLoggerDebug(@"取消换城市");
                              }];
        [alertView addButtonWithTitle:@"确定"
                                 type:SIAlertViewButtonTypeDefault
                              handler:^(SIAlertView *alertView) {
                                  [[DataBaseManager sharedInstance] cleanUp];
                                  [userDefaults setObject:newCity forKey:UserState];
                                  [userDefaults synchronize];
                                  [[LocationManager defaultLocationManager].cityLabel setTitle:newCity forState:UIControlStateNormal];
                                  if (_userCityCallBack) {
                                      _userCityCallBack();
                                  }
                                  ABLoggerDebug(@"确定切换城市");
                              }];
        
        alertView.transitionStyle = SIAlertViewTransitionStyleDropDown;
        alertView.backgroundStyle = SIAlertViewBackgroundStyleSolid;
        
        [alertView show];
        [alertView release];
    }
    
    return YES;
}

- (double)distanceBetweenUserToLatitude:(NSString *)latitude longitude:(NSString *)longitude{
    
    CLLocationDegrees _latitude, _longitude;
    
    _latitude = [latitude doubleValue];
    _longitude = [longitude doubleValue];
    
    CLLocation *toLocation = [[[CLLocation alloc] initWithLatitude:_latitude longitude:_longitude] autorelease];
    
    return [self distanceBetweenCoordinatesFrom:_map.userLocation.location to:toLocation];
}

- (double)distanceBetweenCoordinatesFrom:(CLLocation *)from to:(CLLocation *)to{
    
    CLLocationDistance distance = [to distanceFromLocation:from];
    
    ABLoggerDebug(@" %.2f m",distance);
    
    return distance;
}

@end
