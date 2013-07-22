//
//  CinemaViewController.h
//  WanShangLe
//
//  Created by stephenliu on 13-6-8.
//  Copyright (c) 2013年 stephenliu. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ApiCmdMovie_getNearByCinemas;
@class EGORefreshTableHeaderView;
@interface CinemaNearByViewController : UIViewController{
    
}
@property(nonatomic,retain) ApiCmdMovie_getNearByCinemas *apiCmdMovie_getNearByCinemas;

@property(nonatomic,retain)EGORefreshTableHeaderView *refreshNearByHeaderView;
@property(nonatomic,retain)EGORefreshTableHeaderView *refreshNearByTailerView;

@property(nonatomic,retain) IBOutlet UIView *noGPSView;
@property(nonatomic,retain) UITableView *mTableView;
@property(nonatomic,retain) NSMutableArray *mArray;;
@property(nonatomic,retain) NSMutableArray *mCacheArray;

- (void)loadMoreData;
- (void)loadNewData;
@end
