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

@property(nonatomic,retain) NSMutableDictionary *dataManagerDic;

@property(nonatomic,retain) ApiCmdKTV_getAllKTVs *apiCmdKTV_getAllKTVs;
@property(nonatomic,readwrite) NSFilterKTVListType filterKTVListType;

@property(nonatomic,retain)EGORefreshTableHeaderView *refreshHeaderView;
@property(nonatomic,retain)EGORefreshTableHeaderView *refreshTailerView;
@property(nonatomic,retain)EGORefreshTableHeaderView *refreshNearByHeaderView;
@property(nonatomic,retain)EGORefreshTableHeaderView *refreshNearByTailerView;

@property(nonatomic,retain) IBOutlet UIView *addFavoriteFooterView;
@property(nonatomic,retain) IBOutlet UIView *noFavoriteFooterView;
@property(nonatomic,retain) IBOutlet UIView *noGPSView;

@property(nonatomic,retain) IBOutlet UITableView *allTableView;
@property(nonatomic,retain) IBOutlet UITableView *nearByTableView;
@property(nonatomic,retain) IBOutlet UITableView *favoriteTableView;

@property(nonatomic,retain) IBOutlet NSMutableArray *allArray;;
@property(nonatomic,retain) IBOutlet NSMutableArray *allCache;
@property(nonatomic,retain) IBOutlet NSMutableArray *nearByArray;
@property(nonatomic,retain) IBOutlet NSMutableArray *nearByCache;
@property(nonatomic,retain) IBOutlet NSMutableArray *favoriteArray;

- (void)beginSearch;
- (void)endSearch;

- (void)loadMoreData;
- (void)loadNewData;
@end
