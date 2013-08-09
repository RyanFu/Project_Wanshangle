//
//  CinemaViewController.m
//  WanShangLe
//
//  Created by stephenliu on 13-6-8.
//  Copyright (c) 2013年 stephenliu. All rights reserved.
//

#import "CinemaViewController.h"

#import "CinemaAllViewController.h"
#import "CinemaFavoriteViewController.h"
#import "CinemaNearByViewController.h"

#import "MMovie.h"
#import "MovieViewController.h"
#import "MovieDetailViewController.h"

#define CinemaVIEW 300
#define CinemaVIEW_Y 40

@interface CinemaViewController(){
    UIButton *favoriteButton;
    UIButton *nearbyButton;
    UIButton *allButton;
}
@property(nonatomic,retain)CinemaFavoriteViewController *favoriteController;
@property(nonatomic,retain)CinemaNearByViewController *nearByController;
@property(nonatomic,retain)CinemaAllViewController *allController;
@end

@implementation CinemaViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
        self.title = @"影院";
    }
    return self;
}

- (void)dealloc{
    self.filterHeaderView = nil;
    self.filterIndicator = nil;
    
    self.favoriteController = nil;
    self.nearByController = nil;
    self.allController = nil;
    
    self.mMovie = nil;
    self.movieDetailButton = nil;
    [super dealloc];
}

#pragma mark -
#pragma mark UIView cycle
- (void)viewWillAppear:(BOOL)animated{
    [_mSelectedController viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated{
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:_filterCinemaListType] forKey:MMovie_CinemaFilterType];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [_mSelectedController viewWillDisappear:animated];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self initBarButtonItem];
    [self initFilterButtonHeaderView];
    [self updateSettingFilter];
}
#pragma mark -
#pragma mark 初始化数据
- (void)initBarButtonItem{
    //    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    //    [backButton setFrame:CGRectMake(0, 0, 45, 32)];
    //    [backButton addTarget:self action:@selector(clickBackButton:) forControlEvents:UIControlEventTouchUpInside];
    //    [backButton setBackgroundImage:[UIImage imageNamed:@"bt_back_n@2x"] forState:UIControlStateNormal];
    //    [backButton setBackgroundImage:[UIImage imageNamed:@"bt_back_f@2x"] forState:UIControlStateHighlighted];
    //    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    //    self.navigationItem.leftBarButtonItem = backItem;
    //    [backItem release];
    
    self.movieDetailButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _movieDetailButton.frame = CGRectMake(0, 0, 50, 30);
    [_movieDetailButton setBackgroundImage:[UIImage imageNamed:@"btn_barItem_n@2x"] forState:UIControlStateNormal];
    [_movieDetailButton setBackgroundImage:[UIImage imageNamed:@"btn_barItem_f@2x"] forState:UIControlStateHighlighted];
    [_movieDetailButton addTarget:self action:@selector(clickMovieDetail:) forControlEvents:UIControlEventTouchUpInside];
    [_movieDetailButton setTitle:@"详情" forState:UIControlStateNormal];
    _movieDetailButton.hidden = YES;
    UIBarButtonItem *movieDetailIiem = [[UIBarButtonItem alloc] initWithCustomView:_movieDetailButton];
    _mparentController.navigationItem.rightBarButtonItem = movieDetailIiem;
    [movieDetailIiem release];
}

- (void)initFilterButtonHeaderView{
    //创建TopView
    _filterHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 40)];
    UIButton *bt1 = [UIButton buttonWithType:UIButtonTypeCustom];
    UIButton *bt2 = [UIButton buttonWithType:UIButtonTypeCustom];
    UIButton *bt3 = [UIButton buttonWithType:UIButtonTypeCustom];
    bt1.tag = 1;
    bt2.tag = 2;
    bt3.tag = 3;
    [bt3 setExclusiveTouch:YES];
    [bt1 addTarget:self action:@selector(clickFilterFavoriteButton:) forControlEvents:UIControlEventTouchUpInside];
    [bt2 addTarget:self action:@selector(clickFilterNearbyButton:) forControlEvents:UIControlEventTouchUpInside];
    [bt3 addTarget:self action:@selector(clickFilterAllButton:) forControlEvents:UIControlEventTouchUpInside];
    [bt3 setFrame:CGRectMake(0, 0, 105, _filterHeaderView.bounds.size.height)];
    [bt2 setFrame:CGRectMake(105, 0, 110, _filterHeaderView.bounds.size.height)];
    [bt1 setFrame:CGRectMake(215, 0, 105, _filterHeaderView.bounds.size.height)];
    [_filterHeaderView addSubview:bt1];
    [_filterHeaderView addSubview:bt2];
    [_filterHeaderView addSubview:bt3];
    [_filterHeaderView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"btn_filter_bts"]]];
    favoriteButton = bt1;
    nearbyButton = bt2;
    allButton = bt3;
    
    UIImageView *imgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"btn_filter_indicator"]];
    imgView.frame = CGRectMake(46, 34, 13, 6);
    [_filterHeaderView addSubview:imgView];
    _filterIndicator = imgView;
    [imgView release];
    
    [self.view addSubview:_filterHeaderView];
}

#pragma mark -
#pragma mark 切换 TableView

- (void)switchToAllTableView{
    if (_allController==nil) {
        _allController = [[CinemaAllViewController alloc] initWithNibName:(iPhone5?@"CinemaAllViewController_5":@"CinemaAllViewController") bundle:nil];
        _allController.mParentController = self;
    }
    self.mSelectedController = _allController;
    UIView *currentActiveView = [self.view viewWithTag:CinemaVIEW];
    [currentActiveView removeFromSuperview];
    _allController.view.tag = CinemaVIEW;
    
    [self.view addSubview:_allController.view];
    [self.view bringSubviewToFront:_allController.view];
    _allController.view.frame = CGRectMake(0, CinemaVIEW_Y, self.view.bounds.size.width, self.view.bounds.size.height-CinemaVIEW_Y);
}

- (void)switchToNearByTableView{
    if (_nearByController==nil) {
        _nearByController = [[CinemaNearByViewController alloc] initWithNibName:(iPhone5?@"CinemaNearByViewController_5":@"CinemaNearByViewController") bundle:nil];
        _nearByController.mParentController = self;
    }
    self.mSelectedController = _nearByController;
    UIView *currentActiveView = [self.view viewWithTag:CinemaVIEW];
    [currentActiveView removeFromSuperview];
    
    _nearByController.view.frame = CGRectMake(0, CinemaVIEW_Y, self.view.bounds.size.width, self.view.bounds.size.height-CinemaVIEW_Y);
    _nearByController.view.tag = CinemaVIEW;
    
    [self.view addSubview:_nearByController.view];
    [self.view bringSubviewToFront:_nearByController.view];
}

- (void)switchToFavoriteTableView {
    if (_favoriteController==nil) {
        _favoriteController = [[CinemaFavoriteViewController alloc] initWithNibName:(iPhone5?@"CinemaFavoriteViewController_5":@"CinemaFavoriteViewController") bundle:nil];
        _favoriteController.mParentController = self;
    }
    self.mSelectedController = _favoriteController;
    UIView *currentActiveView = [self.view viewWithTag:CinemaVIEW];
    [currentActiveView removeFromSuperview];
    
    _favoriteController.view.frame = CGRectMake(0, CinemaVIEW_Y, self.view.bounds.size.width, self.view.bounds.size.height-CinemaVIEW_Y);
    _favoriteController.view.tag = CinemaVIEW;
    
    
    [self.view addSubview:_favoriteController.view];
    [self.view bringSubviewToFront:_favoriteController.view];
}

#pragma mark-
#pragma mark UIButton Event
- (void)clickBackButton:(id)sender{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)clickMovieDetail:(id)sender{
    MovieDetailViewController *movieDetailController = [[MovieDetailViewController alloc] initWithNibName:(iPhone5?@"MovieDetailViewController_5":@"MovieDetailViewController") bundle:nil];
    movieDetailController.mMovie = self.mMovie;
    [_mparentController.navigationController pushViewController:movieDetailController animated:YES];
    [movieDetailController release];
}

- (void)updateSettingFilter{
    int type = [[[NSUserDefaults standardUserDefaults] objectForKey:MMovie_CinemaFilterType] intValue];
    switch (type) {
        case NSFilterCinemaListTypeFavorite:{
            [self clickFilterFavoriteButton:nil];
        }
            break;
        case NSFilterCinemaListTypeNearby:{
            [self clickFilterNearbyButton:nil];
        }
            break;
        default:{
            [self clickFilterAllButton:nil];
        }
            break;
    }
}

- (void)clickFilterFavoriteButton:(id)sender{
    if (_filterCinemaListType==NSFilterCinemaListTypeFavorite) {
        return;
    }
    _filterCinemaListType=NSFilterCinemaListTypeFavorite;
    [self stratAnimationFilterButton:_filterCinemaListType];
    
    [self switchToFavoriteTableView];
}

- (void)clickFilterNearbyButton:(id)sender{
    if (_filterCinemaListType==NSFilterCinemaListTypeNearby) {
        return;
    }
    _filterCinemaListType=NSFilterCinemaListTypeNearby;
    [self stratAnimationFilterButton:_filterCinemaListType];
    [self switchToNearByTableView];
}

- (void)clickFilterAllButton:(id)sender{
    if (_filterCinemaListType==NSFilterCinemaListTypeAll) {
        return;
    }
    _filterCinemaListType=NSFilterCinemaListTypeAll;
    [self stratAnimationFilterButton:_filterCinemaListType];
    [self switchToAllTableView];
}

- (void)stratAnimationFilterButton:(NSFilterCinemaListType)type{
    
    UIButton *bt = (UIButton *)[_filterHeaderView viewWithTag:type];
    CGRect oldFrame = _filterIndicator.frame;
    oldFrame.origin.y = 34;
    _filterIndicator.frame = oldFrame;
    
    [UIView animateWithDuration:0.2 animations:^{
        [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
        
        CGRect newFrame = CGRectZero;
        switch (bt.tag) {
            case 1:
                newFrame = CGRectMake(261, 34, 13, 6);
                break;
            case 2:
                newFrame = CGRectMake(154, 34, 13, 6);
                break;
            case 3:
                newFrame = CGRectMake(46, 34, 13, 6);
                break;
            default:
                break;
        }
        _filterIndicator.frame = newFrame;
    } completion:^(BOOL finished) {
        //[_filterHeaderView setUserInteractionEnabled:YES];
    }];
}


#pragma mark -
#pragma mark 内存警告
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    ABLoggerWarn(@"接收到内存警告了");
    [self cleanUpMemory];
}

- (void)cleanUpMemory{
    self.allController = nil;
    self.favoriteController = nil;
    self.nearByController = nil;
}
@end
