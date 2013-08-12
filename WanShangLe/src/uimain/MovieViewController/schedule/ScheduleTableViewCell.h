//
//  MovieTableViewCell.h
//  WanShangLe
//
//  Created by stephenliu on 13-6-6.
//  Copyright (c) 2013年 stephenliu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ScheduleTableViewCell : UITableViewCell{
    IBOutlet UILabel *schedule_time;
    IBOutlet UILabel *schedule_view;
    IBOutlet UILabel *schedule_price;
    IBOutlet UILabel *schedule_timeLong;
   
}
@property(nonatomic,retain) UILabel *schedule_time;
@property(nonatomic,retain) UILabel *schedule_view;
@property(nonatomic,retain) UILabel *schedule_price;
@property(nonatomic,retain) UILabel *schedule_timeLong;
@property(nonatomic,retain)  IBOutlet UIImageView *tuan_seat_imgView;
@end
