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
@property(nonatomic,retain)IBOutlet UIScrollView *mScrollView;

-(IBAction)clickCinemaManager:(id)sender;
-(IBAction)clickKTVManager:(id)sender;
-(IBAction)clickSuggestionButton:(id)sender;
@end
