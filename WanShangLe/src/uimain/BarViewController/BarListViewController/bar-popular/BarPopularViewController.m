//
//  CinemaViewController.m
//  WanShangLe
//
//  Created by stephenliu on 13-6-8.
//  Copyright (c) 2013年 stephenliu. All rights reserved.
//

#import "BBar.h"
#import "BarPopularViewController.h"
#import "BarDetailViewController.h"
#import "BarPopularListTableViewDelegate.h"
#import "EGORefreshTableHeaderView.h"
#import "ApiCmdBar_getPopularBars.h"

#import "ASIHTTPRequest.h"
#import "ApiCmd.h"

#define MArray @"MArray"
#define CacheArray @"CacheArray"

@interface BarPopularViewController()<ApiNotify>{
     BOOL isLoadMoreAll;
}
@property(nonatomic,retain)BarPopularListTableViewDelegate *favoriteListDelegate;
@end

@implementation BarPopularViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)dealloc{

    [_apiCmdBar_getPopularBars.httpRequest clearDelegatesAndCancel];
    _apiCmdBar_getPopularBars.delegate = nil;
    [[[ApiClient defaultClient] requestArray] removeObject:_apiCmdBar_getPopularBars];
    self.apiCmdBar_getPopularBars = nil;
    
    _refreshHeaderView.delegate = nil;
    _refreshTailerView.delegate = nil;
    [_refreshHeaderView removeFromSuperview];
    [_refreshTailerView removeFromSuperview];
    self.refreshHeaderView = nil;
    self.refreshTailerView = nil;
    
    self.favoriteListDelegate = nil;
    self.mTableView = nil;
    self.mArray = nil;
    self.mCacheArray = nil;
    
    [super dealloc];
}

#pragma mark -
#pragma mark UIView cycle
- (void)viewWillAppear:(BOOL)animated{
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.view addSubview:self.mTableView];
    
    //第一次调用
//    [self formatKTVDataFilterFavorite];
}


#pragma mark -
#pragma mark 初始化数据

- (UITableView *)mTableView
{
    if (_mTableView != nil) {
        return _mTableView;
    }
    
    [self initTableView];
    
    return _mTableView;
}

- (void)initTableView {
    if (_mTableView==nil) {
        self.mTableView = [self createTableView];
    }
    
    [self initRefreshHeaderView];
    
    if (_mArray==nil) {
        _mArray = [[NSMutableArray alloc] initWithCapacity:10];
    }
    if (_mCacheArray==nil) {
        _mCacheArray = [[NSMutableArray alloc] initWithCapacity:10];
    }
}

- (UITableView *)createTableView{
    UITableView *tbView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height) style:UITableViewStylePlain];
    tbView.backgroundColor = [UIColor whiteColor];
    tbView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    tbView.tableFooterView = [[[UIView alloc] initWithFrame:CGRectZero] autorelease];
    return [tbView autorelease];
}

#pragma mark 设置 TableView Delegate
- (void)setTableViewDelegate{
    if (_favoriteListDelegate==nil) {
        _favoriteListDelegate = [[BarPopularListTableViewDelegate alloc] init];
        _favoriteListDelegate.parentViewController = self;
    }
    _mTableView.dataSource = _favoriteListDelegate;
    _mTableView.delegate = _favoriteListDelegate;
    _favoriteListDelegate.mArray = _mArray;
    _favoriteListDelegate.mTableView = _mTableView;
}

#pragma mark -
#pragma mark PullRefresh
- (void)initRefreshHeaderView{
    
    [self setTableViewDelegate];
    
    if (_refreshHeaderView == nil) {
        EGORefreshTableHeaderView *view = [[EGORefreshTableHeaderView alloc] initWithFrame: CGRectMake(0.0f, _mTableView.bounds.size.height, _mTableView.frame.size.width, _mTableView.bounds.size.height)];
		view.delegate = self.favoriteListDelegate;
        view.tag = EGOBottomView;
        view.backgroundColor = [UIColor clearColor];
		[_mTableView addSubview:view];
		self.refreshTailerView = view;
		[view release];
        
        view = [[EGORefreshTableHeaderView alloc] initWithFrame: CGRectMake(0.0f, - _mTableView.bounds.size.height, _mTableView.frame.size.width, _mTableView.bounds.size.height)];
        view.delegate = self.favoriteListDelegate;
        view.tag = EGOHeaderView;
        view.backgroundColor = [UIColor clearColor];
        [_mTableView addSubview:view];
        self.refreshHeaderView = view;
        [view release];
    }
    _favoriteListDelegate.refreshHeaderView = self.refreshHeaderView;
    _favoriteListDelegate.refreshTailerView = self.refreshTailerView;
    [_refreshHeaderView refreshLastUpdatedDate];
}

#pragma mark -
#pragma mark 格式化数据
- (void)formatKTVDataFilterFavorite{
    
}

#pragma mark -
#pragma mark 内存警告
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    ABLoggerWarn(@"接收到内存警告了");
}

@end
