//
//  CinemaListTableViewDelegate.h
//  WanShangLe
//
//  Created by stephenliu on 13-6-8.
//  Copyright (c) 2013年 stephenliu. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CinemaViewController;
@interface CinemaListTableViewDelegate : NSObject<UISearchBarDelegate,UISearchDisplayDelegate,UITableViewDelegate,UITableViewDataSource>{
    
}
@property(nonatomic,assign) UISearchBar *mSearchBar;
@property(nonatomic,assign) CinemaViewController *parentViewController;
@end
