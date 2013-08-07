//
//  KKTV.h
//  WanShangLe
//
//  Created by stephenliu on 13-8-7.
//  Copyright (c) 2013年 stephenliu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class KKTVBuyInfo, KKTVPriceInfo;

@interface KKTV : NSManagedObject

@property (nonatomic, retain) NSString * address;
@property (nonatomic, retain) NSString * cityId;
@property (nonatomic, retain) NSString * cityName;
@property (nonatomic, retain) NSString * dataType;
@property (nonatomic, retain) NSNumber * discounts;
@property (nonatomic, retain) NSNumber * distance;
@property (nonatomic, retain) NSString * district;
@property (nonatomic, retain) NSNumber * districtid;
@property (nonatomic, retain) NSNumber * favorite;
@property (nonatomic, retain) NSNumber * juan;
@property (nonatomic, retain) NSNumber * latitude;
@property (nonatomic, retain) NSString * locationDate;
@property (nonatomic, retain) NSNumber * longitude;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * phoneNumber;
@property (nonatomic, retain) NSNumber * price;
@property (nonatomic, retain) NSNumber * seat;
@property (nonatomic, retain) NSNumber * tuan;
@property (nonatomic, retain) NSString * uid;
@property (nonatomic, retain) NSNumber * zhekou;
@property (nonatomic, retain) NSNumber * sortID;
@property (nonatomic, retain) KKTVBuyInfo *ktvBuyInfo;
@property (nonatomic, retain) KKTVPriceInfo *ktvPriceInfo;

@end
