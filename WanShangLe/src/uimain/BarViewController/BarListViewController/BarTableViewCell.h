//
//  MovieTableViewCell.h
//  WanShangLe
//
//  Created by stephenliu on 13-6-6.
//  Copyright (c) 2013年 stephenliu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BarTableViewCell : UITableViewCell{

}
@property(nonatomic,retain) IBOutlet UILabel *bar_event_name;
@property(nonatomic,retain) IBOutlet UILabel *bar_popular;
@property(nonatomic,retain) IBOutlet UILabel *bar_name;
@property(nonatomic,retain) IBOutlet UILabel *bar_date;
@property(nonatomic,retain) IBOutlet UILabel *bar_distance;
@property(nonatomic,retain) IBOutlet UIImageView *bar_image_location;
@property(nonatomic,retain) IBOutlet UIImageView *bar_image_tuan;
@property(nonatomic,retain) IBOutlet UIImageView *bar_image_juan;
@property(nonatomic,retain) IBOutlet UIImageView *bar_image_zhekou;
@property(nonatomic,retain) IBOutlet UIImageView *bar_image_seat;
@end
