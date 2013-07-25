//
//  CinemaViewController.h
//  WanShangLe
//
//  Created by stephenliu on 13-6-8.
//  Copyright (c) 2013年 stephenliu. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ApiCmdMovie_getAllCinemas;
@class EGORefreshTableHeaderView;

@interface CinemaManagerViewController : UIViewController{
    
}
@property(nonatomic,retain) UISearchBar *searchBar;
@property(nonatomic,retain) UISearchDisplayController *msearchDisplayController;

@property(nonatomic,retain) ApiCmdMovie_getAllCinemas *apiCmdMovie_getAllCinemas;
@property(nonatomic,retain) EGORefreshTableHeaderView *refreshTailerView;

@property(nonatomic,retain) UITableView *mTableView;
@property(nonatomic,retain) NSMutableArray *mArray;
@property(nonatomic,retain) NSMutableArray *mFavoriteArray;
@property(nonatomic,retain) NSMutableArray *mCacheArray;

- (void)loadMoreData;
- (void)loadNewData;
- (void)formatCinemaDataFilterFavorite;
- (void)formatCinemaDataFilterAll:(NSArray*)pageArray;
- (void)hiddenRefreshTailerView;
@end
