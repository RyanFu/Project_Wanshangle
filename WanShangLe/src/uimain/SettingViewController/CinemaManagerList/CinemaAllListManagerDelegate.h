//
//  MovieListTableViewDelegate.h
//  WanShangLe
//
//  Created by stephenliu on 13-6-8.
//  Copyright (c) 2013年 stephenliu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EGORefreshTableHeaderView.h"

@class CinemaManagerViewController;
@interface CinemaAllListManagerDelegate: NSObject<UISearchBarDelegate,UISearchDisplayDelegate,EGORefreshTableHeaderDelegate,UITableViewDataSource,UITableViewDelegate>{
   
}
@property(nonatomic,assign) EGORefreshTableHeaderView *refreshTailerView;
@property(nonatomic,assign) CinemaManagerViewController  *parentViewController;
@property(nonatomic,assign) UISearchDisplayController *msearchDisplayController;
@property(nonatomic,assign) UITableView *mTableView;
@property(nonatomic,assign) NSArray *mArray;
@property(nonatomic,assign) NSMutableArray *mFavoriteArray;
@property(nonatomic,assign) NSMutableArray *mSearchArray;
@property(nonatomic,readwrite)BOOL reloading;

- (void)doneLoadingTableViewData;
@end
