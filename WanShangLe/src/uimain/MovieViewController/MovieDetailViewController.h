//
//  MovieDetailViewController.h
//  WanShangLe
//
//  Created by stephenliu on 13-6-21.
//  Copyright (c) 2013年 stephenliu. All rights reserved.
//

#import <UIKit/UIKit.h>
@class MMovie;
@interface MovieDetailViewController : UIViewController
@property(nonatomic,retain) MMovie *mMovie;

@property(nonatomic,retain) IBOutlet UIImageView *imgView;
@property(nonatomic,retain) IBOutlet UILabel *directorLabel;
@property(nonatomic,retain) IBOutlet UILabel *actorLabel;
@property(nonatomic,retain) IBOutlet UILabel *typeLabel;
@property(nonatomic,retain) IBOutlet UILabel *durationLabel;
@property(nonatomic,retain) IBOutlet UILabel *startdayLabel;
@property(nonatomic,retain) IBOutlet UILabel *recommendLabel;
@property(nonatomic,retain) IBOutlet UILabel *wantLookLabel;
@property(nonatomic,retain) IBOutlet UILabel *descriptionLabel;
@property(nonatomic,retain) IBOutlet UILabel *addOneLabel;
@property(nonatomic,retain) IBOutlet UIButton *recommendButton;
@property(nonatomic,retain) IBOutlet UIButton *wantLookButton;
-(IBAction)clickRecommendButton:(id)sender;
-(IBAction)clickWantLookButton:(id)sender;
@end
