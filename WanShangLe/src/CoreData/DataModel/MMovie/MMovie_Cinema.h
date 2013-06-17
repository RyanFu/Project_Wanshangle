//
//  MMovie_Cinema.h
//  WanShangLe
//
//  Created by stephenliu on 13-6-7.
//  Copyright (c) 2013年 stephenliu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class MCinema, MMovie, MSchedule;

@interface MMovie_Cinema : NSManagedObject

@property (nonatomic, retain) NSString * uid;
@property (nonatomic, retain) MCinema *cinema;
@property (nonatomic, retain) MMovie *movie;
@property (nonatomic, retain) MSchedule *schedule;

@end
