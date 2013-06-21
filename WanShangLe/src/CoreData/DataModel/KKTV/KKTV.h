//
//  KKTV.h
//  WanShangLe
//
//  Created by stephenliu on 13-6-18.
//  Copyright (c) 2013年 stephenliu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class City, KKTVBuyInfo;

@interface KKTV : NSManagedObject

@property (nonatomic, retain) NSString * uid;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * address;
@property (nonatomic, retain) NSNumber * price;
@property (nonatomic, retain) NSNumber * discounts;
@property (nonatomic, retain) NSNumber * latitude;
@property (nonatomic, retain) NSNumber * longitude;
@property (nonatomic, retain) NSString * phoneNumber;
@property (nonatomic, retain) KKTVBuyInfo *ktvBuyInfo;
@property (nonatomic, retain) NSManagedObject *ktvDetail;
@property (nonatomic, retain) City *city;
@property (nonatomic, retain) NSNumber * favorite;

@end
