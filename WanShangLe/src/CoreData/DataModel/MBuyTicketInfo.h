//
//  MBuyTicketInfo.h
//  WanShangLe
//
//  Created by stephenliu on 13-6-7.
//  Copyright (c) 2013年 stephenliu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class MSchedule;

@interface MBuyTicketInfo : NSManagedObject

@property (nonatomic, retain) NSString * uid;
@property (nonatomic, retain) id groupBuyInfo;
@property (nonatomic, retain) MSchedule *schedule;

@end
