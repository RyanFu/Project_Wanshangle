//
//  KTVPriceListViewController.h
//  WanShangLe
//
//  Created by stephenliu on 13-7-5.
//  Copyright (c) 2013年 stephenliu. All rights reserved.
//

#import <UIKit/UIKit.h>

@class KKTV;
@interface KTVPriceListViewController : UIViewController{
    
}
@property(nonatomic,retain) IBOutlet UIView *mTableHeaderView;
@property(nonatomic,retain) IBOutlet UIView *mHeaderTailerView;
@property(nonatomic,retain) IBOutlet UILabel *ktv_name;
@property(nonatomic,retain) IBOutlet UILabel *ktv_address;
@property(nonatomic,retain) IBOutlet UIButton *todayButton;
@property(nonatomic,retain) IBOutlet UIButton *tomorrowButton;
@property(nonatomic,retain) IBOutlet UITableView *mTableView;
@property(nonatomic,retain) IBOutlet UITableView *mDiscountTableView;
@property(nonatomic,retain) IBOutlet UIView *discountFooterView;
@property(nonatomic,retain) IBOutlet UIView *discountHeaderView;
@property(nonatomic,retain) IBOutlet UIImageView* arrowImg;

@property(nonatomic,retain) NSMutableArray *mTodayArray;
@property(nonatomic,retain) NSMutableArray *mTomorrowArray;
@property(nonatomic,retain) NSMutableArray *mArray;
@property(nonatomic,retain) NSArray *mDiscountArray;
@property(nonatomic,retain) KKTV *mKTV;

-(IBAction)clickTodayButton:(id)sender;
-(IBAction)clickTomorrowButton:(id)sender;
-(IBAction)clickIntroduceButton:(id)sender;
- (void)expandDiscountTableView;
@end
