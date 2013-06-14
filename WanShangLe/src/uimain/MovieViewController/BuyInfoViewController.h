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
@property(nonatomic,retain) MMovie *mMovie;
@property(nonatomic,retain) MCinema *mCinema;
@property(nonatomic,retain) NSString *schedule;
@property(nonatomic,retain) NSArray *marray;
@end
