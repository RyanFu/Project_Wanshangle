//
//  BuyInfoTableViewCell.h
//  TestExpansionTableView
//
//  Created by liu on 6/13/13.
//  Copyright (c) 2013 liu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface KTVDiscountTableViewCell : UITableViewCell
@property(nonatomic,retain) IBOutlet UIButton *badgeButton;
@property(nonatomic,retain) IBOutlet UILabel *discount_time;
@property(nonatomic,retain) IBOutlet UILabel *discount_info;
@property(nonatomic,retain) IBOutlet UIImageView *bgImgView;
@end
