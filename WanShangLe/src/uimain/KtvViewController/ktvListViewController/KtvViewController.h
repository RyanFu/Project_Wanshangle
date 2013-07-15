//
//  CinemaViewController.h
//  WanShangLe
//
//  Created by stephenliu on 13-6-8.
//  Copyright (c) 2013年 stephenliu. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, NSFilterKTVListType) {
    NSFilterKTVListTypeNone = 0,
    NSFilterKTVListTypeFavorite,
    NSFilterKTVListTypeNearby,
    NSFilterKTVListTypeAll,
};
@interface KtvViewController : UIViewController{
    
}
@property(nonatomic,readwrite) NSFilterKTVListType filterKTVListType;
@property(nonatomic,retain) UIView *filterIndicator;
@property(nonatomic,retain) UIView *filterHeaderView;
@property(nonatomic,retain) UIViewController *mSelectedController;
@property(nonatomic,assign) UITableView *mTableView;
@property(nonatomic,assign) NSMutableArray *mArray;;
@end
