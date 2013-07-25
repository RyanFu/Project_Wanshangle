//
//  MovieListTableViewDelegate.h
//  WanShangLe
//
//  Created by stephenliu on 13-6-8.
//  Copyright (c) 2013年 stephenliu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EGORefreshTableHeaderView.h"

@class CinemaAllViewController;
@interface CinemaAllListTableViewDelegate : NSObject<EGORefreshTableHeaderDelegate,UISearchBarDelegate,UISearchDisplayDelegate,UITableViewDataSource,UITableViewDelegate>{
   
}
@property(nonatomic,assign) EGORefreshTableHeaderView *refreshHeaderView;
@property(nonatomic,assign) EGORefreshTableHeaderView *refreshTailerView;
@property(nonatomic,assign) CinemaAllViewController *parentViewController;
@property(nonatomic,assign) UISearchDisplayController *msearchDisplayController;
@property(nonatomic,assign) UITableView *mTableView;
@property(nonatomic,assign) NSArray *mArray;
@property(nonatomic,readwrite)BOOL reloading;

- (void)doneReLoadingTableViewData;
- (void)doneLoadingTableViewData;
@end
