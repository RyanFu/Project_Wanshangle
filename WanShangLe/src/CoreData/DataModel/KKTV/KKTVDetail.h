//
//  KKTVDetail.h
//  WanShangLe
//
//  Created by stephenliu on 13-6-18.
//  Copyright (c) 2013年 stephenliu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class KKTV;

@interface KKTVDetail : NSManagedObject

@property (nonatomic, retain) NSString * uid;
@property (nonatomic, retain) id schedule;
@property (nonatomic, retain) KKTV *ktv;

@end
