//
//  ShowViewController.h
//  WanShangLe
//
//  Created by stephenliu on 13-6-5.
//  Copyright (c) 2013年 stephenliu. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, NSFilterShowListType) {
    NSFilterShowListNoneData = 0,
    NSFilterShowListTypeData,
    NSFilterShowListTimeData,
    NSFilterShowListOrderData
};

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
@property(nonatomic,retain) IBOutlet UIView* typeView;
@property(nonatomic,retain) IBOutlet UIView* timeView;
@property(nonatomic,retain) IBOutlet UIView* orderView;

@property(nonatomic,retain) IBOutlet UIImageView* typeArrowImg;
@property(nonatomic,retain) IBOutlet UIImageView* timeArrowImg;
@property(nonatomic,retain) IBOutlet UIImageView* orderArrowImg;

@property(nonatomic,retain) IBOutlet UITableView *mTableView;
@property(nonatomic,retain) IBOutlet UIView *noGPSView;
@property(nonatomic,retain) NSMutableArray *mArray;
@property(nonatomic,retain) NSMutableArray *mCacheArray;

@property(nonatomic,retain) ApiCmdShow_getAllShows *apiCmdShow_getAllShows;
@property(nonatomic,retain)EGORefreshTableHeaderView *refreshHeaderView;
@property(nonatomic,retain)EGORefreshTableHeaderView *refreshTailerView;
@property(nonatomic,readwrite)NSFilterShowListType filterShowListType;

@property(nonatomic,readwrite)int selectedType;
@property(nonatomic,readwrite)int selectedTime;
@property(nonatomic,readwrite)int selectedOrder;

@property(nonatomic,readwrite)int oldSelectedType;
@property(nonatomic,readwrite)int oldSelectedTime;
@property(nonatomic,readwrite)int oldSelectedOrder;

- (IBAction)clickTypeButton:(id)sender;
- (IBAction)clickTimeButton:(id)sender;
- (IBAction)clickOrderButton:(id)sender;

- (IBAction)clickTypeSubButtonDown:(id)sender;
- (IBAction)clickTimeSubButtonDown:(id)sender;
- (IBAction)clickOrderSubButtonDown:(id)sender;

- (IBAction)clickMarkView:(id)sender;

- (void)loadMoreData;
- (void)loadNewData;
@end
