//
//  ActionState.h
//  WanShangLe
//
//  Created by stephenliu on 13-7-16.
//  Copyright (c) 2013年 stephenliu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface ActionState : NSManagedObject

@property (nonatomic, retain) NSNumber * like;
@property (nonatomic, retain) NSString * locationDate;
@property (nonatomic, retain) NSNumber * recommend;
@property (nonatomic, retain) NSString * type;
@property (nonatomic, retain) NSString * uid;
@property (nonatomic, retain) NSNumber * vote;
@property (nonatomic, retain) NSNumber * wantLook;
@property (nonatomic, retain) NSString * beginTime;
@property (nonatomic, retain) NSString * endTime;

@end
