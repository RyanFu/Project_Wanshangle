//
//  SShowDetail.h
//  WanShangLe
//
//  Created by stephenliu on 13-7-16.
//  Copyright (c) 2013年 stephenliu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class SShow;

@interface SShowDetail : NSManagedObject

@property (nonatomic, retain) NSString * introduce;
@property (nonatomic, retain) NSString * locationDate;
@property (nonatomic, retain) NSString * recommendation;
@property (nonatomic, retain) NSString * uid;
@property (nonatomic, retain) NSString * wantLook;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * prices;
@property (nonatomic, retain) SShow *show;
@property (nonatomic, retain) NSString * extpayurl;

@end
