//
//  CinemaViewController.h
//  WanShangLe
//
//  Created by stephenliu on 13-6-8.
//  Copyright (c) 2013年 stephenliu. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MMovie;
@class ApiCmdMovie_getAllCinemas;
@class MovieViewController;

typedef NS_ENUM(NSInteger, MMFilterCinemaListType) {
    MMFilterCinemaListTypeFavorite = 0,          
    MMFilterCinemaListTypeNearby,          
    MMFilterCinemaListTypeAll,
};

@interface CinemaViewController : UIViewController{
    
}
@property (nonatomic,retain) UISearchBar *searchBar;
@property(nonatomic, retain) UISearchDisplayController *strongSearchDisplayController;
@property(nonatomic,retain) UIView *filterHeaderView;
@property(nonatomic,assign) MovieViewController *mparentController;
@property(nonatomic,retain) MMovie *mMovie;
@property(nonatomic,retain) UITableView *cinemaTableView;
@property(nonatomic,retain) UIButton *movieDetailButton;
@property(nonatomic,retain) NSArray *cinemasArray;
@property(nonatomic,retain) ApiCmdMovie_getAllCinemas *apiCmdMovie_getAllCinemas;
@property(nonatomic,assign) MMFilterCinemaListType cinemaFilterType;

-(void)beginSearch;
-(void)endSearch;
@end
