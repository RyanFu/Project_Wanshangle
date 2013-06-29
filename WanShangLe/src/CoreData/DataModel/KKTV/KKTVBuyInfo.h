//
//  KKTVBuyInfo.h
//  WanShangLe
//
//  Created by stephenliu on 13-6-18.
//  Copyright (c) 2013年 stephenliu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface KKTVBuyInfo : NSManagedObject

@property (nonatomic, retain) NSString * uid;
@property (nonatomic, retain) id discountInfo;
@property (nonatomic, retain) NSManagedObject *ktv;

@end
