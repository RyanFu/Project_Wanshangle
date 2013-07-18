//
//  MovieDetailViewController.h
//  WanShangLe
//
//  Created by stephenliu on 13-6-21.
//  Copyright (c) 2013年 stephenliu. All rights reserved.
//

#import <UIKit/UIKit.h>
@class MMovie;
@interface MovieDetailViewController : UIViewController<UIActionSheetDelegate,UIAlertViewDelegate>
@property(nonatomic,retain) MMovie *mMovie;

@property(nonatomic,retain)IBOutlet UIScrollView *mScrollView;
@property(nonatomic,retain)IBOutlet UILabel *movie_director;
@property(nonatomic,retain)IBOutlet UILabel *movie_actor;
@property(nonatomic,retain)IBOutlet UILabel *movie_type;
@property(nonatomic,retain)IBOutlet UILabel *movie_district;
@property(nonatomic,retain)IBOutlet UILabel *movie_timeLong;
@property(nonatomic,retain)IBOutlet UILabel *movie_uptime;
@property(nonatomic,retain)IBOutlet UILabel *movie_introduce;
@property(nonatomic,retain)IBOutlet UILabel *movie_rating;
@property(nonatomic,retain)IBOutlet UIImageView *movie_introBgImgView;

@property(nonatomic,retain)IBOutlet UILabel *movie_yes;
@property(nonatomic,retain)IBOutlet UILabel *movie_wantLook;
@property(nonatomic,retain)IBOutlet UIButton *movie_yesButton;
@property(nonatomic,retain)IBOutlet UIButton *movie_wantLookButton;
@property(nonatomic,retain) UIImageView *movie_portImgView;

- (IBAction)clickYesButton:(id)sender;
- (IBAction)clickWantLookButton:(id)sender;
@end
