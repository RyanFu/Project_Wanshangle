//
//  KTVBuyCell.h
//  WanShangLe
//
//  Created by stephenliu on 13-7-5.
//  Copyright (c) 2013年 stephenliu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface KTVBuyCell : UITableViewCell
@property(nonatomic,retain) IBOutlet UIImageView *tuan_imgView;
@property(nonatomic,retain) IBOutlet UIImageView *lowPriceImg;
@property(nonatomic,retain) IBOutlet UILabel *vendor_name;
@property(nonatomic,retain) IBOutlet UILabel *price;
@property(nonatomic,retain) IBOutlet UIButton *bg_button;
@end
