//
//  BBar.h
//  WanShangLe
//
//  Created by stephenliu on 13-7-23.
//  Copyright (c) 2013年 stephenliu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class BBarDetail;

@interface BBar : NSManagedObject

@property (nonatomic, retain) NSString * address;
@property (nonatomic, retain) NSString * barId;
@property (nonatomic, retain) NSString * barName;
@property (nonatomic, retain) NSString * begintime;
@property (nonatomic, retain) NSString * cityId;
@property (nonatomic, retain) NSString * dataType;
@property (nonatomic, retain) NSNumber * juan;
@property (nonatomic, retain) NSNumber * latitude;
@property (nonatomic, retain) NSString * locationDate;
@property (nonatomic, retain) NSNumber * longitude;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * phoneNumber;
@property (nonatomic, retain) NSNumber * popular;
@property (nonatomic, retain) NSNumber * seat;
@property (nonatomic, retain) NSNumber * tuan;
@property (nonatomic, retain) NSString * uid;
@property (nonatomic, retain) NSNumber * zhekou;
@property (nonatomic, retain) BBarDetail *barDetail;
@property (nonatomic, retain) NSString * discountInfo;


@end
