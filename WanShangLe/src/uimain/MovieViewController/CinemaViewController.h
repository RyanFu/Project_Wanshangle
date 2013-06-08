//
//  CinemaViewController.h
//  WanShangLe
//
//  Created by stephenliu on 13-6-8.
//  Copyright (c) 2013年 stephenliu. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, NSFilterCinemaListType) {
    NSFilterCinemaListTypeFavorite = 0,          
    NSFilterCinemaListTypeNearby,          
    NSFilterCinemaListTypeAll,
};

@interface CinemaViewController : UIViewController
@property(nonatomic,retain)UITableView *cinemaTableView;
@property(nonatomic,retain)NSArray *cinemasArray;
@end
