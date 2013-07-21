//
//  ShowDetailViewController.h
//  WanShangLe
//
//  Created by stephenliu on 13-6-17.
//  Copyright (c) 2013年 stephenliu. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SShow;
@interface ShowDetailViewController : UIViewController{
    
}
@property(nonatomic,retain)IBOutlet UIScrollView *mScrollView;
@property(nonatomic,retain)IBOutlet UILabel *show_name;
@property(nonatomic,retain)IBOutlet UILabel *show_rating;
@property(nonatomic,retain)IBOutlet UILabel *show_time;
@property(nonatomic,retain)IBOutlet UILabel *show_address;
@property(nonatomic,retain)IBOutlet UILabel *show_yes;
@property(nonatomic,retain)IBOutlet UILabel *show_wantLook;
@property(nonatomic,retain)IBOutlet UILabel *show_prices;
@property(nonatomic,retain)IBOutlet UILabel *show_introduce;
@property(nonatomic,retain)IBOutlet UIImageView *show_introBgImgView;
@property(nonatomic,retain)IBOutlet UIScrollView *show_priceScrollView;
@property(nonatomic,retain)IBOutlet UIButton *show_yesButton;
@property(nonatomic,retain)IBOutlet UIButton *show_wantLookButton;
@property(nonatomic,retain) UIImageView *show_portImgView;
@property(nonatomic,retain) SShow *mShow;

- (IBAction)clickBuyButton:(id)sender;
- (IBAction)clickYesButton:(id)sender;
- (IBAction)clickWantLookButton:(id)sender;
@end
