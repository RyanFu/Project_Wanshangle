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
@class CinemaViewController;
@interface CinemaAllViewController : UIViewController{
    
}
@property(nonatomic,assign) CinemaViewController *mParentController;
@property(nonatomic,retain) ApiCmdMovie_getAllCinemas *apiCmdMovie_getAllCinemas;
@property(nonatomic,retain) EGORefreshTableHeaderView *refreshHeaderView;
@property(nonatomic,retain) EGORefreshTableHeaderView *refreshTailerView;

@property(nonatomic,retain) UISearchBar *searchBar;
@property(nonatomic,retain) UISearchDisplayController *strongSearchDisplayController;

@property(nonatomic,retain) UITableView *mTableView;
@property(nonatomic,retain) NSMutableArray *mArray;
@property(nonatomic,retain) NSMutableArray *mCacheArray;

- (void)beginSearch;
- (void)endSearch;

- (void)loadMoreData;
- (void)loadNewData;
@end
