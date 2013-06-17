//
//  MMovieDetail.h
//  WanShangLe
//
//  Created by stephenliu on 13-6-7.
//  Copyright (c) 2013年 stephenliu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class MMovie;

@interface MMovieDetail : NSManagedObject

@property (nonatomic, retain) NSString * fromCountry;
@property (nonatomic, retain) NSString * movieActor;
@property (nonatomic, retain) NSString * moviePlot;
@property (nonatomic, retain) NSNumber * movieTime;
@property (nonatomic, retain) NSString * movieType;
@property (nonatomic, retain) NSString * releaseDate;
@property (nonatomic, retain) MMovie *movie;

@end
