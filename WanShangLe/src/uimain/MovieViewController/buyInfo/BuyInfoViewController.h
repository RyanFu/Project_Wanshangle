//
//  BuyInfoViewController.h
//  WanShangLe
//
//  Created by liu on 6/13/13.
//  Copyright (c) 2013 stephenliu. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MMovie,MCinema;

@interface BuyInfoViewController : UIViewController

@property(nonatomic,retain) IBOutlet UITableView *mTableView;
@property(nonatomic,retain) IBOutlet UIView *mHeaderView;
@property(nonatomic,retain) IBOutlet UILabel *cinema_name_label;
@property(nonatomic,retain) IBOutlet UILabel *cinema_address_label;
@property(nonatomic,retain) IBOutlet UILabel *schedule_label;
@property(nonatomic,retain) IBOutlet UILabel *price_label;
@property(nonatomic,retain) IBOutlet UILabel *discountNum;

@property(nonatomic,retain) MMovie *mMovie;
@property(nonatomic,retain) MCinema *mCinema;
@property(nonatomic,retain) NSString *mSchedule;
@property(nonatomic,retain) NSString *mPrice;
@property(nonatomic,retain) NSArray *marray;

- (IBAction)clickDiscountButton:(id)sender;
@end
