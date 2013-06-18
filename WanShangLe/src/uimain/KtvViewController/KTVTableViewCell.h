//
//  MovieTableViewCell.h
//  WanShangLe
//
//  Created by stephenliu on 13-6-6.
//  Copyright (c) 2013年 stephenliu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface KTVTableViewCell : UITableViewCell{

}
@property(nonatomic,retain) IBOutlet UILabel *ktv_name;
@property(nonatomic,retain) IBOutlet UILabel *ktv_address;
@property(nonatomic,retain) IBOutlet UILabel *ktv_price;
@property(nonatomic,retain) IBOutlet UILabel *ktv_discounts;
@end
