//
//  ShowViewController.h
//  WanShangLe
//
//  Created by stephenliu on 13-6-5.
//  Copyright (c) 2013年 stephenliu. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ApiCmdBar_getAllBars;

@interface BarViewController : UIViewController{
    
}
@property(nonatomic,retain) IBOutletCollection(UIButton) NSArray *mButtons;
@property(nonatomic,retain) IBOutlet UITableView* mTableView;
@property(nonatomic,retain) NSArray *barsArray;
@property(nonatomic,retain) ApiCmdBar_getAllBars *apiCmdBar_getAllBars;

- (IBAction)clickTodayButton:(id)sender;
- (IBAction)clickTomorrowButton:(id)sender;
- (IBAction)clickWeekendButton:(id)sender;
@end
