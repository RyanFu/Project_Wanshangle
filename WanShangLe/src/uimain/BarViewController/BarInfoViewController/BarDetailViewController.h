//
//  MovieDetailViewController.h
//  WanShangLe
//
//  Created by stephenliu on 13-6-21.
//  Copyright (c) 2013年 stephenliu. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BBar;
@interface BarDetailViewController : UIViewController<UIActionSheetDelegate,
UIAlertViewDelegate>
@property(nonatomic,retain) BBar *mBar;

@property(nonatomic,retain) IBOutlet UIScrollView *mScrollView;
-(IBAction)clickRecommendButton:(id)sender;
-(IBAction)clickWantLookButton:(id)sender;
@end
