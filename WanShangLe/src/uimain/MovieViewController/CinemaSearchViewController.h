//
//  CinemaSearchViewController.h
//  WanShangLe
//
//  Created by stephenliu on 13-6-8.
//  Copyright (c) 2013年 stephenliu. All rights reserved.
//
#import <UIKit/UIKit.h>

@interface CinemaSearchViewController : UIViewController<UISearchBarDelegate,UITableViewDelegate,UITableViewDataSource> {
}
@property (nonatomic,retain) UITableView *tableView;
@property (nonatomic,retain) UISearchBar *searchBar;

@property (nonatomic,retain) NSMutableDictionary *contactDic;
@property (nonatomic,retain) NSMutableArray *searchByName;
@property (nonatomic,retain) NSMutableArray *searchByPhone;
@end

