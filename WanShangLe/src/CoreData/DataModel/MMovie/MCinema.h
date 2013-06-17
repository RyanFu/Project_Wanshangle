//
//  MCinema.h
//  WanShangLe
//
//  Created by stephenliu on 13-6-8.
//  Copyright (c) 2013年 stephenliu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class City, MMovie_Cinema;

@interface MCinema : NSManagedObject

@property (nonatomic, retain) NSString * address;
@property (nonatomic, retain) NSNumber * favorite;
@property (nonatomic, retain) NSNumber * longitue;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * phoneNumber;
@property (nonatomic, retain) NSNumber * uid;
@property (nonatomic, retain) NSNumber * latitude;
@property (nonatomic, retain) NSString * district;
@property (nonatomic, retain) City *city;
@property (nonatomic, retain) NSSet *movie_cinemas;

@end

@interface MCinema (CoreDataGeneratedAccessors)

- (void)addMovie_cinemasObject:(MMovie_Cinema *)value;
- (void)removeMovie_cinemasObject:(MMovie_Cinema *)value;
- (void)addMovie_cinemas:(NSSet *)values;
- (void)removeMovie_cinemas:(NSSet *)values;

@end
