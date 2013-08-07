//
//  MBuyTicketInfo.h
//  WanShangLe
//
//  Created by stephenliu on 13-8-7.
//  Copyright (c) 2013年 stephenliu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface MBuyTicketInfo : NSManagedObject

@property (nonatomic, retain) id groupBuyInfo;
@property (nonatomic, retain) NSString * locationDate;
@property (nonatomic, retain) NSString * uid;

@end
