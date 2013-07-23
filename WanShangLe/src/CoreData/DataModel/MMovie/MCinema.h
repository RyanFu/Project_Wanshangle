//
//  MCinema.h
//  WanShangLe
//
//  Created by stephenliu on 13-7-15.
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
@property (nonatomic, retain) NSString * district;
@property (nonatomic, retain) NSNumber * favorite;
@property (nonatomic, retain) NSNumber * juan;
@property (nonatomic, retain) NSNumber * latitude;
@property (nonatomic, retain) NSString * locationDate;
@property (nonatomic, retain) NSNumber * longitue;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * nearby;
@property (nonatomic, retain) NSString * phoneNumber;
@property (nonatomic, retain) NSNumber * seat;
@property (nonatomic, retain) NSNumber * tuan;
@property (nonatomic, retain) NSString * uid;
@property (nonatomic, retain) NSNumber * zhekou;
@property (nonatomic, retain) NSSet *movie_cinemas;
@property (nonatomic, retain) NSNumber * districtId;

@end

@interface MCinema (CoreDataGeneratedAccessors)

- (void)addMovie_cinemasObject:(MMovie_Cinema *)value;
- (void)removeMovie_cinemasObject:(MMovie_Cinema *)value;
- (void)addMovie_cinemas:(NSSet *)values;
- (void)removeMovie_cinemas:(NSSet *)values;

@end
