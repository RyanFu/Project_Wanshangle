//
//  BuyInfoTableViewDelegate.h
//  WanShangLe
//
//  Created by liu on 6/13/13.
//  Copyright (c) 2013 stephenliu. All rights reserved.
//

#import <Foundation/Foundation.h>
@class BuyInfoViewController;

@interface BuyInfoTableViewDelegate : NSObject<UITableViewDataSource,UITableViewDelegate>
@property(nonatomic,assign) BuyInfoViewController *parentViewController;
@end
