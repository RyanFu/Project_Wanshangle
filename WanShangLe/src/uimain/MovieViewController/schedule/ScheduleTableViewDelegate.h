//
//  MovieListTableViewDelegate.h
//  WanShangLe
//
//  Created by stephenliu on 13-6-8.
//  Copyright (c) 2013年 stephenliu. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ScheduleViewController;
@interface ScheduleTableViewDelegate : NSObject<UITableViewDataSource,UITableViewDelegate>{
    
}
@property(nonatomic,assign) ScheduleViewController *parentViewController;
@end
