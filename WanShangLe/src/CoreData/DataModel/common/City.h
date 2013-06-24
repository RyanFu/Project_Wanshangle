//
//  City.h
//  WanShangLe
//
//  Created by stephenliu on 13-6-17.
//  Copyright (c) 2013年 stephenliu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class MCinema, MMovie_City, SShow;

@interface City : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * uid;
@property (nonatomic, retain) NSSet *cinemas;
@property (nonatomic, retain) NSSet *movie_citys;
@property (nonatomic, retain) NSSet *shows;
@end

@interface City (CoreDataGeneratedAccessors)

- (void)addCinemasObject:(MCinema *)value;
- (void)removeCinemasObject:(MCinema *)value;
- (void)addCinemas:(NSSet *)values;
- (void)removeCinemas:(NSSet *)values;

- (void)addMovie_citysObject:(MMovie_City *)value;
- (void)removeMovie_citysObject:(MMovie_City *)value;
- (void)addMovie_citys:(NSSet *)values;
- (void)removeMovie_citys:(NSSet *)values;

- (void)addShowsObject:(SShow *)value;
- (void)removeShowsObject:(SShow *)value;
- (void)addShows:(NSSet *)values;
- (void)removeShows:(NSSet *)values;

@end
