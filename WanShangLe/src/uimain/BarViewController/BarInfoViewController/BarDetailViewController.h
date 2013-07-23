//
//  MovieDetailViewController.h
//  WanShangLe
//
//  Created by stephenliu on 13-6-21.
//  Copyright (c) 2013年 stephenliu. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BBar;
@interface BarDetailViewController : UIViewController<UIActionSheetDelegate,UIAlertViewDelegate>
@property(nonatomic,retain) BBar *mBar;
@property(nonatomic,retain) IBOutlet UIScrollView *mScrollView;
@property(nonatomic,retain) IBOutlet UILabel *bar_event;
@property(nonatomic,retain) IBOutlet UILabel *bar_name;
@property(nonatomic,retain) IBOutlet UILabel *bar_address;
@property(nonatomic,retain) IBOutlet UILabel *bar_yes;
@property(nonatomic,retain) IBOutlet UILabel *bar_introduce;
@property(nonatomic,retain) IBOutlet UIImageView *barDetailImg;
@property(nonatomic,retain) IBOutlet UIButton *bar_yesButton;
-(IBAction)clickYESButton:(id)sender;
-(IBAction)clickPhoneButton:(id)sender;
@end
