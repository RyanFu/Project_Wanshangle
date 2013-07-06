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

@class ApiCmdKTV_getAllKTVs;
@class EGORefreshTableHeaderView;
@interface KtvViewController : UIViewController{
    
}
@property(nonatomic,retain) UISearchBar *searchBar;
@property(nonatomic,retain) UISearchDisplayController *strongSearchDisplayController;
@property(nonatomic,retain) UITableView *mTableView;
@property(nonatomic,retain) NSArray *ktvsArray;
@property(nonatomic,retain) ApiCmdKTV_getAllKTVs *apiCmdKTV_getAllKTVs;
@property(nonatomic,readwrite) NSFilterKTVListType filterKTVListType;
@property(nonatomic,retain)EGORefreshTableHeaderView *refreshHeaderView;
@property(nonatomic,retain)EGORefreshTableHeaderView *refreshTailerView;

@property(nonatomic,retain) IBOutlet UIView *addFavoriteFooterView;
@property(nonatomic,retain) IBOutlet UIView *noFavoriteFooterView;
@property(nonatomic,retain) IBOutlet UIView *noGPSView;

- (void)beginSearch;
- (void)endSearch;

@end
