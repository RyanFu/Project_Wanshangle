//
//  MovieListTableViewDelegate.h
//  WanShangLe
//
//  Created by stephenliu on 13-6-8.
//  Copyright (c) 2013年 stephenliu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EGORefreshTableHeaderView.h"

@class BarViewController;
@interface BarTableViewDelegate : NSObject<EGORefreshTableHeaderDelegate,UITableViewDataSource,UITableViewDelegate>{
    
    UITableView *mTableView;
    BOOL _reloading;
}
@property(nonatomic,assign) EGORefreshTableHeaderView *refreshHeaderView;
@property(nonatomic,assign) EGORefreshTableHeaderView *refreshTailerView;
@property(nonatomic,assign) BarViewController *parentViewController;
@property(nonatomic,assign) UITableView *mTableView;
@end
