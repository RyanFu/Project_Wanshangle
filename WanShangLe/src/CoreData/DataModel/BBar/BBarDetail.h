//
//  BBarDetail.h
//  WanShangLe
//
//  Created by stephenliu on 13-6-17.
//  Copyright (c) 2013年 stephenliu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class BBar;

@interface BBarDetail : NSManagedObject

@property (nonatomic, retain) NSString * uid;
@property (nonatomic, retain) NSString * introduce;
@property (nonatomic, retain) NSNumber * wantLook;
@property (nonatomic, retain) NSNumber * recommendation;
@property (nonatomic, retain) BBar *bar;

@end
