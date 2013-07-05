//
//  KTVBuyViewController.h
//  WanShangLe
//
//  Created by stephenliu on 13-7-5.
//  Copyright (c) 2013年 stephenliu. All rights reserved.
//

#import <UIKit/UIKit.h>
@class KKTV;
@interface KTVBuyViewController : UIViewController{
    
}
@property(nonatomic,retain) KKTV *mKTV;
@property(nonatomic,retain) NSArray *mArray;
@property(nonatomic,retain) IBOutlet UIView *headerView;
@property(nonatomic,retain) IBOutlet UITableView *mTableView;
@property(nonatomic,retain) IBOutlet UIButton *favoriteButton;
@property(nonatomic,retain) IBOutlet UIButton *phoneButton;
@property(nonatomic,retain) IBOutlet UIButton *priceButton;
@property(nonatomic,retain) IBOutlet UILabel *ktvNameLabel;
@property(nonatomic,retain) IBOutlet UILabel *ktvAddressLabel;

- (IBAction)clickPhoneButton:(id)sender;
- (IBAction)clickFavoriteButton:(id)sender;
- (IBAction)clickPriceListButton:(id)sender;
@end
