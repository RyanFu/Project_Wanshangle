//
//  LocationManager.h
//  WanShangLe
//
//  Created by stephenliu on 13-6-4.
//  Copyright (c) 2013年 stephenliu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

typedef void (^SetUserCityCallBack)(void);
typedef void (^GetUserGPSLocation)(BOOL isNewLocation);

/**
 @author stephenliu
 */
@interface LocationManager : NSObject{
    
}
@property(nonatomic,assign) UIButton *cityLabel;
/**
 single instance
 @returns instancetype
 */
+ (instancetype)defaultLocationManager;

/**
 start to location user GPS
 */
- (BOOL)startLocationUserGPS;

/**
 stop to location user GPS
 */
- (void)stopLocationUserGPS;

/**
 获取默认城市
 @returns 用户选择的城市
 */
- (NSString *)getUserCity;

/**
 set user city
 @returns
 */
- (BOOL)setUserCity:(NSString *)newCity CallBack:(SetUserCityCallBack)callback;

/**
 get user location
 @returns
 */
- (BOOL)getUserGPSLocationWithCallBack:(GetUserGPSLocation)callback;

/**
 用户到指定经纬度坐标的距离
 @param latitude 纬度坐标
 @param longitude 经度坐标
 @returns 距离
 */
- (double)distanceBetweenUserToLatitude:(CLLocationDegrees)latitude longitude:(CLLocationDegrees)longitude;

/**
 两个GPS坐标距离
 @param from 第一个GPS
 @param to 第二个GPS
 @returns 距离
 */
- (double)distanceBetweenCoordinatesFrom:(CLLocation *)from to:(CLLocation *)to;
@end
