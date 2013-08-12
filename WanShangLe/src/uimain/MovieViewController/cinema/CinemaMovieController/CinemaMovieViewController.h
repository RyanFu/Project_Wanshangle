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

@property(nonatomic,retain) IBOutlet UIButton *favoriteButton;
@property(nonatomic,retain) IBOutlet UIButton *phoneButton;
@property(nonatomic,retain) IBOutlet UIButton *todayButton;
@property(nonatomic,retain) IBOutlet UIButton *tomorrowButton;
@property(nonatomic,retain) IBOutlet UIControl *movieDetailControl;
@property(nonatomic,retain) IBOutlet UILabel *cinemaName;
@property(nonatomic,retain) IBOutlet UILabel *cinemaAddress;
@property(nonatomic,retain) IBOutlet iCarousel *coverFlow;
@property(nonatomic,retain) IBOutlet UILabel *movieName;
@property(nonatomic,retain) IBOutlet UILabel *movieRating;
@property(nonatomic,retain) IBOutlet UIImageView *whiteTriangle;
@property(nonatomic,retain) UITableView *mTableView;
@property(nonatomic,retain) MCinema *mCinema;
@property(nonatomic,retain) MMovie *mMovie;
@property(nonatomic,retain) NSArray *schedulesArray;

@property(nonatomic,retain)IBOutlet UIImageView *movie_image_new;
@property(nonatomic,retain)IBOutlet UIImageView *movie_image_hot;
@property(nonatomic,retain)IBOutlet UIImageView *movie_image_3dimx;
@property(nonatomic,retain)IBOutlet UIImageView *movie_image_imx;
@property(nonatomic,retain)IBOutlet UIImageView *movie_image_3d;
@property(nonatomic,retain)IBOutlet UIView *headerView;
@property(nonatomic,retain)IBOutlet UIView *footerView;

- (IBAction)clickTodayButton:(id)sender;
- (IBAction)clickTomorrowButton:(id)sender;
- (IBAction)clickMovieInfo:(id)sender;

- (IBAction)clickFavoriteButton:(id)sender;
- (IBAction)clickPhoneButton:(id)sender;
@end
