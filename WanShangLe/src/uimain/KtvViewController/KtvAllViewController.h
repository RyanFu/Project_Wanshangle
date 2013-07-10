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
@class KtvViewController;
@interface KtvAllViewController : UIViewController{
    
}
@property(nonatomic,assign) KtvViewController *mParentController;
@property(nonatomic,retain) ApiCmdKTV_getAllKTVs *apiCmdKTV_getAllKTVs;
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
