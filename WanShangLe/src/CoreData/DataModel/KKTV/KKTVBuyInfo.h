//
//  KKTVBuyInfo.h
//  WanShangLe
//
//  Created by stephenliu on 13-8-7.
//  Copyright (c) 2013年 stephenliu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class KKTV;

@interface KKTVBuyInfo : NSManagedObject

@property (nonatomic, retain) id buyInfoDic;
@property (nonatomic, retain) NSString * locationDate;
@property (nonatomic, retain) NSString * uid;
@property (nonatomic, retain) KKTV *ktv;

@end
