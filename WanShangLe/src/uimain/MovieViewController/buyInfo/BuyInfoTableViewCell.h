//
//  BuyInfoTableViewCell.h
//  TestExpansionTableView
//
//  Created by liu on 6/13/13.
//  Copyright (c) 2013 liu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BuyInfoTableViewCell : UITableViewCell
@property(nonatomic,retain) IBOutlet UIImageView *tuan_imgView;
@property(nonatomic,retain) IBOutlet UIImageView *lowPriceImg;
@property(nonatomic,retain) IBOutlet UIButton *bg_button;
@property(nonatomic,retain) IBOutlet UILabel *vendor_name;
@property(nonatomic,retain) IBOutlet UILabel *price;

@end
