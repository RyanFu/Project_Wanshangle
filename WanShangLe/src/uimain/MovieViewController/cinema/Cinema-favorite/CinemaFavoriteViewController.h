//
//  CinemaViewController.h
//  WanShangLe
//
//  Created by stephenliu on 13-6-8.
//  Copyright (c) 2013年 stephenliu. All rights reserved.
//

#import <UIKit/UIKit.h>
@class CinemaViewController;
@interface CinemaFavoriteViewController : UIViewController{
    
}
@property(nonatomic,assign) CinemaViewController *mParentController;
@property(nonatomic,retain) IBOutlet UIView *addFavoriteFooterView;
@property(nonatomic,retain) IBOutlet UIButton *addFavoriteButton;
@property(nonatomic,retain) IBOutlet UIView *noFavoriteFooterView;
@property(nonatomic,retain) UITableView *mTableView;
@property(nonatomic,retain) NSMutableArray *mArray;
- (IBAction)clickAddFavoriteButton:(id)sender;
@end
