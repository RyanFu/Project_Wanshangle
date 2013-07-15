//
//  CinemaViewController.h
//  WanShangLe
//
//  Created by stephenliu on 13-6-8.
//  Copyright (c) 2013年 stephenliu. All rights reserved.
//

#import <UIKit/UIKit.h>

#define TodayKey @"今天"
#define TomorrowKey @"明天"
#define ListKey @"list"

@class ApiCmdBar_getAllBars;
@class EGORefreshTableHeaderView;
@class BarViewController;
@interface BarTimeViewController : UIViewController{
    
}
@property(nonatomic,assign) BarViewController *mParentController;
@property(nonatomic,retain) ApiCmdBar_getAllBars *apiCmdBar_getAllBars;
@property(nonatomic,retain) EGORefreshTableHeaderView *refreshHeaderView;
@property(nonatomic,retain) EGORefreshTableHeaderView *refreshTailerView;

@property(nonatomic,retain) UITableView *mTableView;
@property(nonatomic,retain) NSMutableArray *mArray;
@property(nonatomic,retain) NSMutableArray *mCacheArray;

- (void)loadMoreData;
- (void)loadNewData;
@end
