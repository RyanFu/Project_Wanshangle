//
//  MovieListTableViewDelegate.h
//  WanShangLe
//
//  Created by stephenliu on 13-6-8.
//  Copyright (c) 2013年 stephenliu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EGORefreshTableHeaderView.h"

@class MovieViewController;

@interface MovieListTableViewDelegate : NSObject<EGORefreshTableHeaderDelegate,UITableViewDataSource,UITableViewDelegate>{
    EGORefreshTableHeaderView *_refreshHeaderView;
    BOOL _reloading;
    UITableView *mTableView;
}

@property(nonatomic,assign) EGORefreshTableHeaderView *refreshHeaderView;
@property(nonatomic,assign) UITableView *mTableView;
@property(nonatomic,assign) MovieViewController *parentViewController;
@end
