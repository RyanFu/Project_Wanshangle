//
//  ScheduleViewController.h
//  WanShangLe
//
//  Created by liu on 6/13/13.
//  Copyright (c) 2013 stephenliu. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MMovie,MCinema;

@interface ScheduleViewController : UIViewController{
    
}
@property(nonatomic,retain) MMovie *mMovie;
@property(nonatomic,retain) MCinema *mCinema;
@property(nonatomic,retain) IBOutlet UIButton *cinemaButton;
@property(nonatomic,retain) IBOutlet UIButton *todayButton;
@property(nonatomic,retain) IBOutlet UIButton *tomorrowButton;
@property(nonatomic,retain) IBOutlet UITableView *mTableView;
@property(nonatomic,retain) NSArray *schedulesArray;

- (IBAction)clickCinemaButton:(id)sender;
- (IBAction)clickTodayButton:(id)sender;
- (IBAction)clickTomorrowButton:(id)sender;
@end
