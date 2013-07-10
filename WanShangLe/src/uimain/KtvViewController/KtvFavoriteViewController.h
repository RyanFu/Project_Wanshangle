//
//  CinemaViewController.h
//  WanShangLe
//
//  Created by stephenliu on 13-6-8.
//  Copyright (c) 2013年 stephenliu. All rights reserved.
//

#import <UIKit/UIKit.h>
@interface KtvFavoriteViewController : UIViewController{
    
}
@property(nonatomic,retain) IBOutlet UIView *addFavoriteFooterView;
@property(nonatomic,retain) IBOutlet UIView *noFavoriteFooterView;
@property(nonatomic,retain) UITableView *mTableView;
@property(nonatomic,retain) NSMutableArray *mArray;;
@end
