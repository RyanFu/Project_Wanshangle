//
//  City.h
//  WanShangLe
//
//  Created by stephenliu on 13-6-7.
//  Copyright (c) 2013年 stephenliu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class MCinema;

@interface City : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * uid;
@property (nonatomic, retain) NSSet *cinemas;
@property (nonatomic, retain) NSSet *movie_citys;
@end

@interface City (CoreDataGeneratedAccessors)

- (void)addCinemasObject:(MCinema *)value;
- (void)removeCinemasObject:(MCinema *)value;
- (void)addCinemas:(NSSet *)values;
- (void)removeCinemas:(NSSet *)values;

- (void)addMovie_cityObject:(NSManagedObject *)value;
- (void)removeMovie_cityObject:(NSManagedObject *)value;
- (void)addMovie_city:(NSSet *)values;
- (void)removeMovie_city:(NSSet *)values;

@end
