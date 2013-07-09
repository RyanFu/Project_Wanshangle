//
//  MovieListTableViewDelegate.h
//  WanShangLe
//
//  Created by stephenliu on 13-6-8.
//  Copyright (c) 2013年 stephenliu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EGORefreshTableHeaderView.h"

@class KtvManagerViewController;
@interface KTVAllListManagerDelegate: NSObject<UISearchBarDelegate,UISearchDisplayDelegate,EGORefreshTableHeaderDelegate,UITableViewDataSource,UITableViewDelegate>{
   
}
@property(nonatomic,assign) EGORefreshTableHeaderView *refreshTailerView;
@property(nonatomic,assign) KtvManagerViewController *parentViewController;
@property(nonatomic,assign) UITableView *mTableView;
@property(nonatomic,assign) NSArray *mArray;
@property(nonatomic,assign) NSArray *mFavoriteArray;
@property(nonatomic,readwrite)BOOL reloading;

- (void)doneLoadingTableViewData;
@end
