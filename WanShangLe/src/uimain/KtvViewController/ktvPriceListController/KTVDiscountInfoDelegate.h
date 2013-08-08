//
//  BuyInfoTableViewDelegate.h
//  WanShangLe
//
//  Created by liu on 6/13/13.
//  Copyright (c) 2013 stephenliu. All rights reserved.
//

#import <Foundation/Foundation.h>

@class KTVPriceListViewController;
@interface KTVDiscountInfoDelegate : NSObject<UITableViewDataSource,UITableViewDelegate>
@property(nonatomic,assign) KTVPriceListViewController *parentViewController;
@property(nonatomic,assign) UITableView *mTableView;
@property(nonatomic,assign) NSArray *mArray;
@end
