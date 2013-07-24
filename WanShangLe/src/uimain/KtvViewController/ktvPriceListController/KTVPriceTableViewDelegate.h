//
//  KTVPriceTableViewDelegate.h
//  WanShangLe
//
//  Created by stephenliu on 13-7-5.
//  Copyright (c) 2013年 stephenliu. All rights reserved.
//

#import <Foundation/Foundation.h>

@class KTVPriceListViewController;
@interface KTVPriceTableViewDelegate : NSObject<UITableViewDataSource,UITableViewDelegate>{
    
}
@property (assign)BOOL isOpen;
@property (nonatomic,retain)NSIndexPath *selectIndex;
@property(nonatomic,assign) NSMutableArray *mArray;
@property(nonatomic,assign) IBOutlet UITableView *mTableView;
@property(nonatomic,assign) KTVPriceListViewController *parentViewController;
@end
