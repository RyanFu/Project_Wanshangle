//
//  MovieListTableViewDelegate.h
//  WanShangLe
//
//  Created by stephenliu on 13-6-8.
//  Copyright (c) 2013年 stephenliu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EGORefreshTableHeaderView.h"

@class CinemaFavoriteViewController;
@interface MovieCinemaFavoriteListDelegate : NSObject<UITableViewDataSource,UITableViewDelegate>{
   
}
@property(nonatomic,assign) CinemaFavoriteViewController *parentViewController;
@property(nonatomic,assign) UITableView *mTableView;
@property(nonatomic,assign) NSArray *mArray;
@end
