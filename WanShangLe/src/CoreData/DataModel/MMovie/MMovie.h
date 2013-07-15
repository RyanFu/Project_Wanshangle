//
//  MMovie.h
//  WanShangLe
//
//  Created by stephenliu on 13-7-15.
//  Copyright (c) 2013年 stephenliu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class MMovieDetail, MMovie_Cinema;

@interface MMovie : NSManagedObject

@property (nonatomic, retain) NSString * aword;
@property (nonatomic, retain) NSString * duration;
@property (nonatomic, retain) NSNumber * iMaxD;
@property (nonatomic, retain) NSString * locationDate;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * newMovie;
@property (nonatomic, retain) NSString * rating;
@property (nonatomic, retain) NSString * ratingFrom;
@property (nonatomic, retain) NSString * ratingpeople;
@property (nonatomic, retain) NSNumber * threeD;
@property (nonatomic, retain) NSNumber * twoD;
@property (nonatomic, retain) NSString * uid;
@property (nonatomic, retain) NSString * webImg;
@property (nonatomic, retain) NSSet *movie_cinemas;
@property (nonatomic, retain) MMovieDetail *movieDetail;
@end

@interface MMovie (CoreDataGeneratedAccessors)

- (void)addMovie_cinemasObject:(MMovie_Cinema *)value;
- (void)removeMovie_cinemasObject:(MMovie_Cinema *)value;
- (void)addMovie_cinemas:(NSSet *)values;
- (void)removeMovie_cinemas:(NSSet *)values;

@end
