//
//  CinemaViewController.h
//  WanShangLe
//
//  Created by stephenliu on 13-6-8.
//  Copyright (c) 2013年 stephenliu. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ApiCmdKTV_getAllKTVs;
@class EGORefreshTableHeaderView;

@interface KtvManagerViewController : UIViewController{
    
}
@property(nonatomic,retain) UISearchBar *searchBar;
@property(nonatomic,retain) UISearchDisplayController *msearchDisplayController;

@property(nonatomic,retain) ApiCmdKTV_getAllKTVs *apiCmdKTV_getAllKTVs;
@property(nonatomic,retain) EGORefreshTableHeaderView *refreshTailerView;

@property(nonatomic,retain) UITableView *mTableView;
@property(nonatomic,retain) NSMutableArray *mArray;
@property(nonatomic,retain) NSMutableArray *mFavoriteArray;
@property(nonatomic,retain) NSMutableArray *mCacheArray;

- (void)loadMoreData;
- (void)loadNewData;
- (void)formatKTVDataFilterFavorite;
- (void)formatKTVDataFilterAll:(NSArray*)pageArray;
@end
