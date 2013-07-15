//
//  MSchedule.h
//  WanShangLe
//
//  Created by stephenliu on 13-7-15.
//  Copyright (c) 2013年 stephenliu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class MMovie_Cinema;

@interface MSchedule : NSManagedObject

@property (nonatomic, retain) NSNumber * date;
@property (nonatomic, retain) NSNumber * isToday;
@property (nonatomic, retain) NSString * locationDate;
@property (nonatomic, retain) NSNumber * lowPrice;
@property (nonatomic, retain) NSNumber * movieCount;
@property (nonatomic, retain) id scheduleInfo;
@property (nonatomic, retain) NSNumber * seatPrice;
@property (nonatomic, retain) NSString * uid;
@property (nonatomic, retain) MMovie_Cinema *movie_cinema;

@end
