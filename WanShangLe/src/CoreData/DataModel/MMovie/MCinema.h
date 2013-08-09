//
//  MCinema.h
//  WanShangLe
//
//  Created by stephenliu on 13-8-7.
//  Copyright (c) 2013年 stephenliu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class MMovie_Cinema;

@interface MCinema : NSManagedObject

@property (nonatomic, retain) NSString * address;
@property (nonatomic, retain) NSString * cityId;
@property (nonatomic, retain) NSString * cityName;
@property (nonatomic, retain) NSString * dataType;
@property (nonatomic, retain) NSNumber * distance;
@property (nonatomic, retain) NSString * district;
@property (nonatomic, retain) NSNumber * districtId;
@property (nonatomic, retain) NSNumber * favorite;
@property (nonatomic, retain) NSNumber * juan;
@property (nonatomic, retain) NSNumber * latitude;
@property (nonatomic, retain) NSString * locationDate;
@property (nonatomic, retain) NSNumber * longitude;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * phoneNumber;
@property (nonatomic, retain) NSNumber * seat;
@property (nonatomic, retain) NSNumber * tuan;
@property (nonatomic, retain) NSString * uid;
@property (nonatomic, retain) NSNumber * zhekou;
@property (nonatomic, retain) NSNumber * sortID;
@property (nonatomic, retain) NSSet *movie_cinemas;
@end

@interface MCinema (CoreDataGeneratedAccessors)

- (void)addMovie_cinemasObject:(MMovie_Cinema *)value;
- (void)removeMovie_cinemasObject:(MMovie_Cinema *)value;
- (void)addMovie_cinemas:(NSSet *)values;
- (void)removeMovie_cinemas:(NSSet *)values;

@end
