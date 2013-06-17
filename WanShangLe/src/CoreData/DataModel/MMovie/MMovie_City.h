//
//  MMovie_City.h
//  WanShangLe
//
//  Created by stephenliu on 13-6-7.
//  Copyright (c) 2013年 stephenliu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class City, MMovie;

@interface MMovie_City : NSManagedObject

@property (nonatomic, retain) NSString * uid;
@property (nonatomic, retain) MMovie *movie;
@property (nonatomic, retain) City *city;

@end
