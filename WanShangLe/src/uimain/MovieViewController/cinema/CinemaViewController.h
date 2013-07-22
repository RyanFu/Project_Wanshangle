//
//  CinemaViewController.h
//  WanShangLe
//
//  Created by stephenliu on 13-6-8.
//  Copyright (c) 2013年 stephenliu. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, NSFilterCinemaListType) {
    NSFilterCinemaListTypeNone = 0,
    NSFilterCinemaListTypeFavorite,
    NSFilterCinemaListTypeNearby,
    NSFilterCinemaListTypeAll,
};

@class MMovie;
@class MovieViewController;
@interface CinemaViewController : UIViewController{
    
}
@property(nonatomic,retain) MMovie *mMovie;
@property(nonatomic,assign) MovieViewController *mparentController;

@property(nonatomic,readwrite) NSFilterCinemaListType filterCinemaListType;
@property(nonatomic,retain) UIView *filterIndicator;
@property(nonatomic,retain) UIView *filterHeaderView;
@property(nonatomic,retain) UIViewController *mSelectedController;
@property(nonatomic,assign) UITableView *mTableView;
@property(nonatomic,assign) NSMutableArray *mArray;
@property(nonatomic,retain) UIButton *movieDetailButton;
@end
