//
//  RootViewController.h
//  WanShangLe
//
//  Created by stephenliu on 13-6-5.
//  Copyright (c) 2013年 stephenliu. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, WSLUserClickStyle) {
    WSLUserClickStyleNone = 0,
    WSLUserClickStyleMovie,
    WSLUserClickStyleKTV,
    WSLUserClickStyleShow,
    WSLUserClickStyleBar
};

@interface RootViewController : UIViewController{
    
}
@property(nonatomic,retain) IBOutlet UIButton* movieButton;
@property(nonatomic,retain) IBOutlet UIButton* ktvButton;
@property(nonatomic,retain) IBOutlet UIButton* showButton;
@property(nonatomic,retain) IBOutlet UIButton* barButton;
@property(nonatomic,retain) IBOutlet UIButton* cityButton;

- (IBAction)clickMovieButton:(id)sender;
- (IBAction)clickKTVButton:(id)sender;
- (IBAction)clickShowButton:(id)sender;
- (IBAction)clickBarButton:(id)sender;
- (IBAction)clickCityButton:(id)sender;
@end
