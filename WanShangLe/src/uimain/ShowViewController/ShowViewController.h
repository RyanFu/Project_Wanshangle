//
//  ShowViewController.h
//  WanShangLe
//
//  Created by stephenliu on 13-6-5.
//  Copyright (c) 2013年 stephenliu. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ApiCmdShow_getAllShows;
@class EGORefreshTableHeaderView;

@interface ShowViewController : UIViewController{

}
@property(nonatomic,retain) IBOutletCollection(UIButton) NSArray *typeBts;
@property(nonatomic,retain) IBOutletCollection(UIButton) NSArray *timeBts;
@property(nonatomic,retain) IBOutletCollection(UIButton) NSArray *orderBts;

@property(nonatomic,retain) IBOutlet UIButton* typeButton;
@property(nonatomic,retain) IBOutlet UIButton* timeButton;
@property(nonatomic,retain) IBOutlet UIButton* orderButton;
@property(nonatomic,retain) IBOutlet UITableView* mTableView;
@property(nonatomic,retain) IBOutlet UIView* typeView;
@property(nonatomic,retain) IBOutlet UIView* timeView;
@property(nonatomic,retain) IBOutlet UIView* orderView;
@property(nonatomic,retain) NSArray *showsArray;
@property(nonatomic,retain) ApiCmdShow_getAllShows *apiCmdShow_getAllShows;
@property(nonatomic,retain)EGORefreshTableHeaderView *refreshHeaderView;
@property(nonatomic,retain)EGORefreshTableHeaderView *refreshTailerView;

- (IBAction)clickTypeButton:(id)sender;
- (IBAction)clickTimeButton:(id)sender;
- (IBAction)clickOrderButton:(id)sender;
- (IBAction)clickTypeSubButtonDown:(id)sender;
- (IBAction)clickTypeSubButtonUp:(id)sender;
- (IBAction)clickTimeSubButtonDown:(id)sender;
- (IBAction)clickTimeSubButtonUp:(id)sender;
- (IBAction)clickOrderSubButtonDown:(id)sender;
- (IBAction)clickOrderSubButtonUp:(id)sender;
@end
