//
//  BBarDetail.h
//  WanShangLe
//
//  Created by stephenliu on 13-7-16.
//  Copyright (c) 2013年 stephenliu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class BBar;

@interface BBarDetail : NSManagedObject

@property (nonatomic, retain) id detailInfo;
@property (nonatomic, retain) NSString * locationDate;
@property (nonatomic, retain) NSString * uid;
@property (nonatomic, retain) NSNumber * like;
@property (nonatomic, retain) NSString * phone;
@property (nonatomic, retain) BBar *bar;

@end
