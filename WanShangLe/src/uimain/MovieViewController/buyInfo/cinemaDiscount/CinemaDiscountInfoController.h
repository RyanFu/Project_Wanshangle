//
//  BuyInfoViewController.h
//  WanShangLe
//
//  Created by liu on 6/13/13.
//  Copyright (c) 2013 stephenliu. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MCinema;

@interface CinemaDiscountInfoController : UIViewController{
    
}
@property(nonatomic,retain) IBOutlet UILabel *cinema_name_label;
@property(nonatomic,retain) IBOutlet UILabel *cinema_address_label;

@property(nonatomic,retain)IBOutlet UIScrollView *mScrollView;
@property(nonatomic,retain)IBOutlet UILabel *cinema_introduce;
@property(nonatomic,retain)IBOutlet UIImageView *cinema_introBgImgView;

@property(nonatomic,retain) MCinema *mCinema;
@end
