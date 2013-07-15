//
//  SShow.h
//  WanShangLe
//
//  Created by stephenliu on 13-7-15.
//  Copyright (c) 2013年 stephenliu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class SShowDetail;

@interface SShow : NSManagedObject

@property (nonatomic, retain) NSString * address;
@property (nonatomic, retain) NSString * cityId;
@property (nonatomic, retain) NSString * dataType;
@property (nonatomic, retain) NSString * date;
@property (nonatomic, retain) NSNumber * latitude;
@property (nonatomic, retain) NSString * locationDate;
@property (nonatomic, retain) NSNumber * longitude;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) id price;
@property (nonatomic, retain) NSNumber * rating;
@property (nonatomic, retain) NSString * ratingfrom;
@property (nonatomic, retain) NSNumber * ratingpeople;
@property (nonatomic, retain) NSNumber * type;
@property (nonatomic, retain) NSString * uid;
@property (nonatomic, retain) NSString * webImg;
@property (nonatomic, retain) NSString * where;
@property (nonatomic, retain) SShowDetail *showDetail;

@end
