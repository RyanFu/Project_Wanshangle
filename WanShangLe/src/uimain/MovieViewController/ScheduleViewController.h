//
//  ScheduleViewController.h
//  WanShangLe
//
//  Created by liu on 6/13/13.
//  Copyright (c) 2013 stephenliu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"

@class MMovie,MCinema;

@interface ScheduleViewController : BaseViewController{
    
}
@property(nonatomic,retain) MMovie *mMovie;
@property(nonatomic,retain) MCinema *mCinema;
@property(nonatomic,retain) IBOutlet UIControl *cinemaButton;
@property(nonatomic,retain) IBOutlet UIButton *todayButton;
@property(nonatomic,retain) IBOutlet UIButton *tomorrowButton;
@property(nonatomic,retain) IBOutlet UITableView *mTableView;
@property(nonatomic,retain) IBOutlet UIView *headerView;
@property(nonatomic,retain) IBOutlet UIView *footerView;
@property(nonatomic,retain) NSArray *schedulesArray;

@property(nonatomic,retain)IBOutlet UILabel *cinemaNameLabel;
@property(nonatomic,retain)IBOutlet UILabel *cinemaAddreLabel;

@property(nonatomic,retain)IBOutlet UIImageView *cinema_image_tuan;
@property(nonatomic,retain)IBOutlet UIImageView *cinema_image_juan;
@property(nonatomic,retain)IBOutlet UIImageView *cinema_image_zhekou;
@property(nonatomic,retain)IBOutlet UIImageView *cinema_image_seat;

- (IBAction)clickCinemaButton:(id)sender;
- (IBAction)clickTodayButton:(id)sender;
- (IBAction)clickTomorrowButton:(id)sender;
@end
