//
//  MovieTableViewCell.h
//  WanShangLe
//
//  Created by stephenliu on 13-6-6.
//  Copyright (c) 2013年 stephenliu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CinemaTableViewCell : UITableViewCell{
    IBOutlet UILabel *cinema_name;
    IBOutlet UILabel *cinema_address;
    IBOutlet UILabel *cinema_count;
    IBOutlet UILabel *cinema_price;
    IBOutlet UILabel *cinema_tuan;
}
@property(nonatomic,retain) UILabel *cinema_name;
@property(nonatomic,retain) UILabel *cinema_address;
@property(nonatomic,retain) UILabel *cinema_count;
@property(nonatomic,retain) UILabel *cinema_price;
@property(nonatomic,retain) UILabel *cinema_tuan;
@end
