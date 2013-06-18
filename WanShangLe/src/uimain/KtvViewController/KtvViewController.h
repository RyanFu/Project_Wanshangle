//
//  CinemaViewController.h
//  WanShangLe
//
//  Created by stephenliu on 13-6-8.
//  Copyright (c) 2013年 stephenliu. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ApiCmdKTV_getAllKTVs;

typedef NS_ENUM(NSInteger, NSFilterKTVListType) {
    NSFilterKTVListTypeFavorite = 0,
    NSFilterKTVListTypeNearby,
    NSFilterKTVListTypeAll,
};

@interface KtvViewController : UIViewController{
    
}
@property(nonatomic,retain)UITableView *mTableView;
@property(nonatomic,retain)NSArray *ktvsArray;
@property(nonatomic,retain)ApiCmdKTV_getAllKTVs *apiCmdKTV_getAllKTVs;
@end
