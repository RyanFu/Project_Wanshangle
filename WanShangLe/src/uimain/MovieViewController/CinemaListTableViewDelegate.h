//
//  CinemaListTableViewDelegate.h
//  WanShangLe
//
//  Created by stephenliu on 13-6-8.
//  Copyright (c) 2013年 stephenliu. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CinemaViewController;
@interface CinemaListTableViewDelegate : NSObject<UITableViewDataSource,UITableViewDelegate>{
    
}
@property (assign)BOOL isOpen;
@property(nonatomic,assign) CinemaViewController *parentViewController;
@end
