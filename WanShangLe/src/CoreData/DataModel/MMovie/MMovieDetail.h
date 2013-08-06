//
//  MMovieDetail.h
//  WanShangLe
//
//  Created by stephenliu on 13-8-6.
//  Copyright (c) 2013年 stephenliu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class MMovie;

@interface MMovieDetail : NSManagedObject

@property (nonatomic, retain) id info;
@property (nonatomic, retain) NSString * language;
@property (nonatomic, retain) NSString * locationDate;
@property (nonatomic, retain) NSString * productarea;
@property (nonatomic, retain) NSString * recommendation;
@property (nonatomic, retain) NSString * uid;
@property (nonatomic, retain) NSString * wantlook;
@property (nonatomic, retain) NSString * webImg;
@property (nonatomic, retain) MMovie *movie;

@end
