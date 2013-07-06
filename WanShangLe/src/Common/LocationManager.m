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
@property (nonatomic, retain) CLLocation *userLocation;
@property (nonatomic, retain) CLLocationManager *locationManager;
@property (nonatomic, copy) SetUserCityCallBack userCityCallBack;
@property (nonatomic, copy) GetUserGPSLocation getUserGPSLocation;
@end

@implementation LocationManager
@synthesize geoCoder = _geoCoder;
@synthesize map = _map;

- (void)dealloc
{
    self.geoCoder = nil;
    self.map = nil;
    self.userCityCallBack = nil;
    self.getUserGPSLocation = nil;
    self.userLocation = nil;
    self.locationCity = nil;
    
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


- (BOOL)startLocationUserGPS
{
    if ([self checkGPSEnable]) {
        [self stopLocationUserGPS];
        // if locationManager does not currently exist, create it
        if (!_locationManager)
        {
            _locationManager = [[CLLocationManager alloc] init];
            _locationManager.distanceFilter = 10.0f; // we don't need to be any more accurate than 10m
        }
        [_locationManager setDelegate:self];
        [_locationManager startUpdatingLocation];
        return YES;
    }
    
    return NO;
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
    
    if (self.getUserGPSLocation) {
        BOOL isNew = YES;
        if (self.userLocation) {
            if (self.userLocation.coordinate.latitude == newLocation.coordinate.latitude &&
                self.userLocation.coordinate.longitude == newLocation.coordinate.longitude) {
                isNew = YES;
            }
        }
        
        self.userLocation = newLocation;
        if (_getUserGPSLocation) {
            _getUserGPSLocation(isNew);
            self.getUserGPSLocation = nil;
        }
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
                    self.locationCity = [[placeMark addressDictionary] objectForKey:@"City"];
                }else{
                    ABLoggerWarn(@"GPS 定位到城市 === %@",placeMark.administrativeArea);
                    [self setUserCity:placeMark.administrativeArea CallBack:nil];
                    self.locationCity = placeMark.administrativeArea;
                    
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

- (NSString *)getUserCityId{
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *city = [userDefaults objectForKey:UserState];
    
    return [userDefaults objectForKey:city];
}

- (BOOL)setUserCity:(NSString *)newCity CallBack:(SetUserCityCallBack)callback{
    
    if (isEmpty(newCity)) {
        return NO;
    }
    
    //    unichar c = [newCity characterAtIndex:0];
    //    if (c >=0x4E00 && c <=0x9FFF){
    //        if ([[newCity substringFromIndex:[newCity length]-1] isEqualToString:@"市"]) {
    //            newCity = [newCity substringToIndex:[newCity length]-1];
    //            ABLoggerInfo(@"定位信息 == 汉字 == %@",newCity);
    //        }
    //    }else{
    //        ABLoggerInfo(@"定位信息 == 英文");
    //    }
    
    if ([[DataBaseManager sharedInstance] validateCity:newCity]) {
        
    }
    
    self.userCityCallBack = callback;
    
    NSString *city = [self getUserCity];
    if (city) {
        
        NSRange range=[newCity rangeOfString:city options:NSCaseInsensitiveSearch];
        if(range.location == NSNotFound){
            
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
                                      
                                      [[DataBaseManager sharedInstance] insertCityIntoCoreDataWith:newCity];
                                      
                                      [_cityLabel setTitle:[NSString stringWithFormat:@"%@%d",newCity,arc4random()%200] forState:UIControlStateNormal];
                                      [_cityLabel setValue:nil forKey:@"title"];
                                      if (_userCityCallBack) {
                                          _userCityCallBack();
                                          self.userCityCallBack = nil;
                                      }
                                      ABLoggerDebug(@"确定切换城市");
                                  }];
            
            alertView.transitionStyle = SIAlertViewTransitionStyleDropDown;
            alertView.backgroundStyle = SIAlertViewBackgroundStyleSolid;
            
            [alertView show];
            [alertView release];
        }else{
            [_cityLabel setTitle:newCity forState:UIControlStateNormal];
            [_cityLabel setValue:nil forKey:@"title"];
            if (_userCityCallBack) {
                _userCityCallBack();
                self.userCityCallBack = nil;
            }
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
                                  
                                  [[DataBaseManager sharedInstance] insertCityIntoCoreDataWith:newCity];
                                  
                                  [_cityLabel setTitle:newCity forState:UIControlStateNormal];
                                  [_cityLabel setValue:nil forKey:@"title"];
                                  if (_userCityCallBack) {
                                      _userCityCallBack();
                                      self.userCityCallBack = nil;
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

- (BOOL)getUserGPSLocationWithCallBack:(GetUserGPSLocation)callback{
    self.getUserGPSLocation = callback;
    return [self startLocationUserGPS];
}

- (double)distanceBetweenUserToLatitude:(CLLocationDegrees)latitude longitude:(CLLocationDegrees)longitude{
    
    CLLocationDegrees _latitude, _longitude;
    
    _latitude = latitude;
    _longitude = longitude;
    
    CLLocation *toLocation = [[[CLLocation alloc] initWithLatitude:_latitude longitude:_longitude] autorelease];
    
    return [self distanceBetweenCoordinatesFrom:_userLocation to:toLocation];
}

- (double)distanceBetweenCoordinatesFrom:(CLLocation *)from to:(CLLocation *)to{
    
    CLLocationDistance distance = [to distanceFromLocation:from];
    
    ABLoggerDebug(@"距离 === %.2f m",distance);
    
    return (distance<0?0:distance);
}

@end
