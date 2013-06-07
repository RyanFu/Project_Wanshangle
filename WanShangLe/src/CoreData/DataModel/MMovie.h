//
//  MMovie.h
//  WanShangLe
//
//  Created by stephenliu on 13-6-7.
//  Copyright (c) 2013年 stephenliu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class MMovieDetail, MMovie_Cinema;

@interface MMovie : NSManagedObject

@property (nonatomic, retain) NSString * aword;
@property (nonatomic, retain) NSNumber * iMaxD;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * newMovie;
@property (nonatomic, retain) NSNumber * rating;
@property (nonatomic, retain) NSString * ratingFrom;
@property (nonatomic, retain) NSNumber * ratingpeople;
@property (nonatomic, retain) NSNumber * threeD;
@property (nonatomic, retain) NSNumber * twoD;
@property (nonatomic, retain) NSNumber * uid;
@property (nonatomic, retain) NSString * webImg;
@property (nonatomic, retain) NSSet *movie_cinemas;
@property (nonatomic, retain) MMovieDetail *movieDetail;
@property (nonatomic, retain) NSSet *movie_city;
@end

@interface MMovie (CoreDataGeneratedAccessors)

- (void)addMovie_cinemasObject:(MMovie_Cinema *)value;
- (void)removeMovie_cinemasObject:(MMovie_Cinema *)value;
- (void)addMovie_cinemas:(NSSet *)values;
- (void)removeMovie_cinemas:(NSSet *)values;

- (void)addMovie_cityObject:(NSManagedObject *)value;
- (void)removeMovie_cityObject:(NSManagedObject *)value;
- (void)addMovie_city:(NSSet *)values;
- (void)removeMovie_city:(NSSet *)values;

@end
