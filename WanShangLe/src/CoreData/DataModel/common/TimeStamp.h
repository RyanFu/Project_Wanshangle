//
//  TimeStamp.h
//  WanShangLe
//
//  Created by stephenliu on 13-8-7.
//  Copyright (c) 2013年 stephenliu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface TimeStamp : NSManagedObject

@property (nonatomic, retain) NSString * localTimeStamp;
@property (nonatomic, retain) NSString * locationDate;
@property (nonatomic, retain) NSString * uid;

@end
