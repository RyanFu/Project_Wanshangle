//
//  TimeStamp.h
//  WanShangLe
//
//  Created by stephenliu on 13-6-17.
//  Copyright (c) 2013年 stephenliu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface TimeStamp : NSManagedObject

@property (nonatomic, retain) NSString * localTimeStamp;
@property (nonatomic, retain) NSString * uid;
@property (nonatomic, retain) NSString * webTimeStamp;

@end
