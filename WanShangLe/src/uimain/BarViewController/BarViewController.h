//
//  ShowViewController.h
//  WanShangLe
//
//  Created by stephenliu on 13-6-5.
//  Copyright (c) 2013年 stephenliu. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, MMFilterBarListType) {
    MMFilterBarListTypeNone = 0,
    MMFilterBarListTypePopular,
    MMFilterBarListTypeNearby,
    MMFilterBarListTypeTime,
};

@class EGORefreshTableHeaderView;
@class ApiCmdBar_getAllBars;

@interface BarViewController : UIViewController{
    
}
@property(nonatomic,retain) IBOutletCollection(UIButton) NSArray *mButtons;
@property(nonatomic,retain) IBOutlet UITableView* mTableView;
@property(nonatomic,retain) NSArray *barsArray;
@property(nonatomic,retain) ApiCmdBar_getAllBars *apiCmdBar_getAllBars;
@property(nonatomic,assign) MMFilterBarListType barFilterType;
@property(nonatomic,retain)EGORefreshTableHeaderView *refreshHeaderView;
@property(nonatomic,retain)EGORefreshTableHeaderView *refreshTailerView;

- (IBAction)clickTimeButton:(id)sender;
- (IBAction)clickNearByButton:(id)sender;
- (IBAction)clickPopularButton:(id)sender;
@end
