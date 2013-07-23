//
//  BBarDetail.h
//  WanShangLe
//
//  Created by stephenliu on 13-7-23.
//  Copyright (c) 2013年 stephenliu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class BBar;

@interface BBarDetail : NSManagedObject

@property (nonatomic, retain) id detailInfo;
@property (nonatomic, retain) NSString * locationDate;
@property (nonatomic, retain) NSString * phone;
@property (nonatomic, retain) NSString * uid;
@property (nonatomic, retain) NSString * recommendation;
@property (nonatomic, retain) NSString * wantlook;
@property (nonatomic, retain) BBar *bar;

@end
