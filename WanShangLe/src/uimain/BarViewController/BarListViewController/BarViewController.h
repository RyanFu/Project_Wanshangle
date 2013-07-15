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

#define OrderTime @"1"
#define OrderPopular @"2"
#define OrderNearBy @"3"

@interface BarViewController : UIViewController{
    
}
@property(nonatomic,readwrite) MMFilterBarListType filterBarListType;
@property(nonatomic,retain) UIView *filterIndicator;
@property(nonatomic,retain) UIView *filterHeaderView;
@property(nonatomic,retain) UIViewController *mSelectedController;
@property(nonatomic,assign) UITableView *mTableView;
@property(nonatomic,assign) NSMutableArray *mArray;;
@end
