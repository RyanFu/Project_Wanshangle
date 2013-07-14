//
//  SettingViewController.h
//  WanShangLe
//
//  Created by stephenliu on 13-6-21.
//  Copyright (c) 2013年 stephenliu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SettingViewController : UIViewController{
    
}
@property(nonatomic,retain) IBOutlet UIScrollView *mScrollView;
@property(nonatomic,retain) IBOutletCollection(UIButton) NSArray *distanceFilterBtns;
@property(nonatomic,retain) IBOutlet UILabel *cacheLabel;
@property(nonatomic,retain) IBOutlet UILabel *versionLabel;

-(IBAction)clickCinemaManager:(id)sender;
-(IBAction)clickKTVManager:(id)sender;
-(IBAction)clickDistanceFilter:(id)sender;
-(IBAction)clickUserSettingSwitchButton:(id)sender;
-(IBAction)clickCleanDataBaseCache:(id)sender;
-(IBAction)clickRecommendFriends:(id)sender;
-(IBAction)clickRatingUs:(id)sender;
-(IBAction)clickSuggestionButton:(id)sender;
-(IBAction)clickVersionCheck:(id)sender;
@end
