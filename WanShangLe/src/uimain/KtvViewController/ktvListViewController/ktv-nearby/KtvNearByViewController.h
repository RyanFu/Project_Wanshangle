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
@interface KtvNearByViewController : UIViewController{
    
}
@property(nonatomic,retain) ApiCmdKTV_getAllKTVs *apiCmdKTV_getAllKTVs;

@property(nonatomic,retain)EGORefreshTableHeaderView *refreshNearByHeaderView;
@property(nonatomic,retain)EGORefreshTableHeaderView *refreshNearByTailerView;

@property(nonatomic,retain) IBOutlet UIView *noGPSView;
@property(nonatomic,retain) UITableView *mTableView;
@property(nonatomic,retain) NSMutableArray *mArray;;
@property(nonatomic,retain) NSMutableArray *mCacheArray;

- (void)loadMoreData;
- (void)loadNewData;
@end
