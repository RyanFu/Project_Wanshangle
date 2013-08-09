//
//  MCinemaDiscount.h
//  WanShangLe
//
//  Created by stephenliu on 13-8-7.
//  Copyright (c) 2013年 stephenliu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface MCinemaDiscount : NSManagedObject

@property (nonatomic, retain) NSString * uid;
@property (nonatomic, retain) id discountInfo;
@property (nonatomic, retain) NSString * locationDate;

@end
