//
//  CinemaViewController.m
//  WanShangLe
//
//  Created by stephenliu on 13-6-8.
//  Copyright (c) 2013年 stephenliu. All rights reserved.
//

#import "KtvViewController.h"

#import "KtvFavoriteViewController.h"
#import "KtvNearByViewController.h"
#import "KtvAllViewController.h"

#define KTVVIEW 300
#define KTVVIEW_Y 40

@interface KtvViewController(){
    UIButton *favoriteButton;
    UIButton *nearbyButton;
    UIButton *allButton;
}
@property(nonatomic,retain)KtvFavoriteViewController *favoriteController;
@property(nonatomic,retain)KtvNearByViewController *nearByController;
@property(nonatomic,retain)KtvAllViewController *allController;
@end

@implementation KtvViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
        self.title = @"KTV";
    }
    return self;
}

- (void)dealloc{
    self.filterHeaderView = nil;
    self.filterIndicator = nil;
    
    self.favoriteController = nil;
    self.nearByController = nil;
    self.allController = nil;
    
    [super dealloc];
}

#pragma mark -
#pragma mark UIView cycle
- (void)viewWillAppear:(BOOL)animated{
    
}
- (void)viewWillDisappear:(BOOL)animated{
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:_filterKTVListType] forKey:KKTV_FilterType];
    [[NSUserDefaults standardUserDefaults] synchronize];
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
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [backButton setFrame:CGRectMake(0, 0, 45, 30)];
    [backButton addTarget:self action:@selector(clickBackButton:) forControlEvents:UIControlEventTouchUpInside];
    [backButton setBackgroundImage:[UIImage imageNamed:@"bt_back_n@2x"] forState:UIControlStateNormal];
    [backButton setBackgroundImage:[UIImage imageNamed:@"bt_back_f@2x"] forState:UIControlStateHighlighted];
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    self.navigationItem.leftBarButtonItem = backItem;
    [backItem release];
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
    [_filterHeaderView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"ktv_btn_filter_bts"]]];
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
        _allController = [[KtvAllViewController alloc] initWithNibName:@"KtvAllViewController" bundle:nil];
        _allController.mParentController = self;
    }
    UIView *currentActiveView = [self.view viewWithTag:KTVVIEW];
    [currentActiveView removeFromSuperview];
    
    _allController.view.frame = CGRectMake(0, KTVVIEW_Y, self.view.bounds.size.width, self.view.bounds.size.height-KTVVIEW_Y);
    _allController.view.tag = KTVVIEW;
    
    [self.view addSubview:_allController.view];
}

- (void)switchToNearByTableView{
    if (_nearByController==nil) {
        _nearByController = [[KtvNearByViewController alloc] initWithNibName:@"KtvNearByViewController" bundle:nil];
    }
    UIView *currentActiveView = [self.view viewWithTag:KTVVIEW];
    [currentActiveView removeFromSuperview];
    
    _nearByController.view.frame = CGRectMake(0, KTVVIEW_Y, self.view.bounds.size.width, self.view.bounds.size.height-KTVVIEW_Y);
    _nearByController.view.tag = KTVVIEW;
    
    [self.view addSubview:_nearByController.view];
}

- (void)switchToFavoriteTableView {
    if (_favoriteController==nil) {
        _favoriteController = [[KtvFavoriteViewController alloc] initWithNibName:@"KtvFavoriteViewController" bundle:nil];
    }
    UIView *currentActiveView = [self.view viewWithTag:KTVVIEW];
    [currentActiveView removeFromSuperview];

    _favoriteController.view.frame = CGRectMake(0, KTVVIEW_Y, self.view.bounds.size.width, self.view.bounds.size.height-KTVVIEW_Y);
    _favoriteController.view.tag = KTVVIEW;
    
    [self.view addSubview:_favoriteController.view];
}

#pragma mark-
#pragma mark UIButton Event
- (void)clickBackButton:(id)sender{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)updateSettingFilter{
    int type = [[[NSUserDefaults standardUserDefaults] objectForKey:KKTV_FilterType] intValue];
    switch (type) {
        case NSFilterKTVListTypeFavorite:{
            [self clickFilterFavoriteButton:nil];
        }
            break;
        case NSFilterKTVListTypeNearby:{
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
    if (_filterKTVListType==NSFilterKTVListTypeFavorite) {
        return;
    }
    _filterKTVListType=NSFilterKTVListTypeFavorite;
    [self stratAnimationFilterButton:_filterKTVListType];
    
    [self switchToFavoriteTableView];
}

- (void)clickFilterNearbyButton:(id)sender{
    if (_filterKTVListType==NSFilterKTVListTypeNearby) {
        return;
    }
    _filterKTVListType=NSFilterKTVListTypeNearby;
    [self stratAnimationFilterButton:_filterKTVListType];
    [self switchToNearByTableView];
}

- (void)clickFilterAllButton:(id)sender{
    if (_filterKTVListType==NSFilterKTVListTypeAll) {
        return;
    }
    _filterKTVListType=NSFilterKTVListTypeAll;
    [self stratAnimationFilterButton:_filterKTVListType];
    [self switchToAllTableView];
}

- (void)stratAnimationFilterButton:(NSFilterKTVListType)type{
    
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
    
    switch (_filterKTVListType) {
        case NSFilterKTVListTypeFavorite:{
            self.allController = nil;
            self.nearByController = nil;
        }
            break;
        case NSFilterKTVListTypeNearby:{
            self.allController = nil;
            self.favoriteController = nil;
        }
            break;
        default:{
            self.favoriteController = nil;
            self.nearByController = nil;
        }
            break;
    }
}

@end
