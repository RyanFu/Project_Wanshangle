//
//  CinemaMovieViewController.h
//  WanShangLe
//
//  Created by stephenliu on 13-6-14.
//  Copyright (c) 2013年 stephenliu. All rights reserved.
//

#import <UIKit/UIKit.h>

@class iCarousel;

@interface CinemaMovieViewController : UIViewController

@property(nonatomic,retain) IBOutlet UIButton *todayButton;
@property(nonatomic,retain) IBOutlet UIButton *tomorrowButton;
@property(nonatomic,retain) IBOutlet UILabel *cinemaInfo;
@property(nonatomic,retain) IBOutlet iCarousel *coverFlow;
@property(nonatomic,retain) IBOutlet UILabel *movieName;
@property(nonatomic,retain) IBOutlet UILabel *movieActor;
@property(nonatomic,retain) IBOutlet UILabel *movieRating;
@property(nonatomic,retain) IBOutlet UILabel *movieTimeLong;
@property(nonatomic,retain) IBOutlet UITableView *mTableView;
@property(nonatomic,retain) MCinema *mCinema;
@property(nonatomic,retain) MMovie *mMovie;
@property(nonatomic,retain) NSArray *schedulesArray;

- (IBAction)clickTodayButton:(id)sender;
- (IBAction)clickTomorrowButton:(id)sender;
- (IBAction)clickMovieInfo:(id)sender;
@end
