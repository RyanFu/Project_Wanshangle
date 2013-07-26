//
//  MovieTableViewCell.h
//  WanShangLe
//
//  Created by stephenliu on 13-6-6.
//  Copyright (c) 2013年 stephenliu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MovieCinemaCell : UITableViewCell{

}
@property(nonatomic,retain)IBOutlet UILabel *cinema_name;
@property(nonatomic,retain)IBOutlet UILabel *cinema_address;
@property(nonatomic,retain)IBOutlet UILabel *cinema_distance;
@property(nonatomic,retain)IBOutlet UILabel *cinema_scheduleCount;
@property(nonatomic,retain)IBOutlet UILabel *cinema_price;

@property(nonatomic,retain)IBOutlet UIImageView *cinema_image_tuan;
@property(nonatomic,retain)IBOutlet UIImageView *cinema_image_juan;
@property(nonatomic,retain)IBOutlet UIImageView *cinema_image_zhekou;
@property(nonatomic,retain)IBOutlet UIImageView *cinema_image_seat;
@property(nonatomic,retain)IBOutlet UIImageView *cinema_image_location;
@end
