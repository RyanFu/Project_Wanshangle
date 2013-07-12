//
//  BBar.h
//  WanShangLe
//
//  Created by stephenliu on 13-7-12.
//  Copyright (c) 2013年 stephenliu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class BBarDetail;

@interface BBar : NSManagedObject

@property (nonatomic, retain) NSString * address;
@property (nonatomic, retain) NSString * date;
@property (nonatomic, retain) NSNumber * latitude;
@property (nonatomic, retain) NSNumber * longitude;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * phoneNumber;
@property (nonatomic, retain) NSNumber * popular;
@property (nonatomic, retain) NSString * uid;
@property (nonatomic, retain) NSString * cityId;
@property (nonatomic, retain) NSString * locationData;
@property (nonatomic, retain) NSString * dataType;
@property (nonatomic, retain) BBarDetail *barDetail;

@end
