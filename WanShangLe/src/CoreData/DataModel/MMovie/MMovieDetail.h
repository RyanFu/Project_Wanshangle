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

@property (nonatomic, retain) NSString * recommendadded;
@property (nonatomic, retain) NSString * wantedadded;
@property (nonatomic, retain) NSNumber * doneLook;
@property (nonatomic, retain) NSNumber * doneRec;

@property (nonatomic, retain) id info;

@property (nonatomic, retain) MMovie *movie;

@end
