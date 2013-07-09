//
//  CinemaViewController.m
//  WanShangLe
//
//  Created by stephenliu on 13-6-8.
//  Copyright (c) 2013年 stephenliu. All rights reserved.
//

#import "KtvViewController.h"
#import "ApiCmdKTV_getAllKTVs.h"
#import "EGORefreshTableHeaderView.h"
#import "KTVBuyViewController.h"
#import "ASIHTTPRequest.h"
#import "KKTV.h"
#import "ApiCmd.h"

#import "KTVAllListTableViewDelegate.h"
#import "KTVFavoriteListTableViewDelegate.h"
#import "KTVNearByListTableViewDelegate.h"

#define TableView_Y 74
#define MArray @"MArray"
#define CacheArray @"CacheArray"

@interface KtvViewController()<ApiNotify>{
    UIButton *favoriteButton;
    UIButton *nearbyButton;
    UIButton *allButton;
    BOOL isLoadMoreAll;
    BOOL isLoadMoreNearBy;
    int mCount;//分页数据
}
@property(nonatomic,retain)UIView *filterIndicator;
@property(nonatomic,retain)UIView *filterHeaderView;

@property(nonatomic,retain)KTVBuyViewController *ktvBuyViewController;
@property(nonatomic,retain)KTVAllListTableViewDelegate *allListDelegate;
@property(nonatomic,retain)KTVFavoriteListTableViewDelegate *favoriteListDelegate;
@property(nonatomic,retain)KTVNearByListTableViewDelegate *nearByListDelegate;
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
    
    [_apiCmdKTV_getAllKTVs.httpRequest clearDelegatesAndCancel];
    _apiCmdKTV_getAllKTVs.delegate = nil;
    [[[ApiClient defaultClient] requestArray] removeObject:_apiCmdKTV_getAllKTVs];
    self.apiCmdKTV_getAllKTVs = nil;
    
    _refreshHeaderView.delegate = nil;
    _refreshTailerView.delegate = nil;
    [_refreshHeaderView removeFromSuperview];
    [_refreshTailerView removeFromSuperview];
    self.refreshHeaderView = nil;
    self.refreshTailerView = nil;
    
    self.refreshNearByHeaderView = nil;
    self.refreshNearByTailerView = nil;
    
    self.searchBar.delegate = nil;
    self.searchBar = nil;
    self.strongSearchDisplayController.delegate = nil;
    self.strongSearchDisplayController = nil;
    
    self.filterHeaderView = nil;
    self.filterIndicator = nil;
    self.ktvBuyViewController = nil;
    
    self.dataManagerDic = nil;
    
    self.allListDelegate = nil;
    self.nearByListDelegate = nil;
    self.favoriteListDelegate = nil;
    
    self.allTableView = nil;
    self.favoriteTableView = nil;
    self.nearByTableView = nil;
    
    self.allArray = nil;
    self.allCache = nil;
    self.nearByArray = nil;
    self.nearByCache = nil;
    self.favoriteArray = nil;
    
    [super dealloc];
}

#pragma mark -
#pragma mark UIView cycle
- (void)viewWillAppear:(BOOL)animated{
    
    if (_filterKTVListType==NSFilterKTVListTypeFavorite) {//判断是否是一条数据
        _filterKTVListType = NSFilterKTVListTypeNone;
        [self clickFilterFavoriteButton:nil];
    }
    
#ifdef TestCode
    [self updatData];//测试代码
#endif
    
}

- (void)updatData{
    for (int i=0; i<10; i++) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            self.apiCmdKTV_getAllKTVs = (ApiCmdKTV_getAllKTVs *)[[DataBaseManager sharedInstance] getAllKTVsListFromWeb:self];
        });
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self initBarButtonItem];
    [self initFilterButtonHeaderView];
    
    [self updateSettingFilter];
    [self loadMoreData];//初始化加载
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
    _filterHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 40)];
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
#pragma mark 初始化TableView

- (UITableView *)allTableView
{
    if (_allTableView != nil) {
        return _allTableView;
    }
    
    [self initAllTableView];
    
    return _allTableView;
}

- (UITableView *)nearByTableView
{
    if (_nearByTableView != nil) {
        return _nearByTableView;
    }
    
    [self initNearByTableView];
    
    return _nearByTableView;
}

- (UITableView *)favoriteTableView
{
    if (_favoriteTableView != nil) {
        return _favoriteTableView;
    }
    
    [self initFavoriteTableView];
    
    return _favoriteTableView;
}

- (void)initAllTableView{
    if (_allTableView==nil) {
        self.allTableView = [self createTableView];
    }
    if (_searchBar==nil) {
        [self initSearchBarDisplay];
        _allTableView.tableHeaderView = self.searchBar;
    }
    [self initRefreshHeaderView];
    [_allTableView setBackgroundColor:[UIColor clearColor]];
    [self.view addSubview:_allTableView];
    
    if (_allArray==nil) {
        _allArray = [[NSMutableArray alloc] initWithCapacity:10];
    }
    if (_allCache==nil) {
        _allCache = [[NSMutableArray alloc] initWithCapacity:10];
    }

_allTableView.frame = CGRectMake(0, _filterHeaderView.bounds.size.height, iPhoneAppFrame.size.width, self.view.bounds.size.height-44);
}

- (void)initNearByTableView{
    if (_nearByTableView==nil) {
        self.nearByTableView = [self createTableView];
    }
    [self initNearByRefreshHeaderView];
    [_nearByTableView setBackgroundColor:[UIColor blueColor]];
    [self.view addSubview:_nearByTableView];
    
    if (_nearByArray==nil) {
        _nearByArray = [[NSMutableArray alloc] initWithCapacity:10];
    }
    if (_nearByCache==nil) {
        _nearByCache = [[NSMutableArray alloc] initWithCapacity:10];
    }
    
    _nearByTableView.frame = CGRectMake(0, _filterHeaderView.bounds.size.height, iPhoneAppFrame.size.width, self.view.bounds.size.height-44);
}

- (void)initFavoriteTableView {
    if (_favoriteTableView==nil) {
        self.favoriteTableView = [self createTableView];
    }
    [self setFavoriteTableViewDelegate];
    [_favoriteTableView setBackgroundColor:[UIColor greenColor]];
    [self.view addSubview:_favoriteTableView];
    
    if (_favoriteArray==nil) {
        _favoriteArray = [[NSMutableArray alloc] initWithCapacity:10];
    }
    
    _favoriteTableView.frame = CGRectMake(0, _filterHeaderView.bounds.size.height, iPhoneAppFrame.size.width, self.view.bounds.size.height-44);
}

- (UITableView *)createTableView{
    UITableView *tbView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    tbView.backgroundColor = [UIColor whiteColor];
    tbView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    
    tbView.tableFooterView = [[[UIView alloc] initWithFrame:CGRectZero] autorelease];
    
    return [tbView autorelease];
}

#pragma mark -
#pragma mark 初始化UISearchBar and PullRefresh
- (void)initSearchBarDisplay{
    
    if (_searchBar==nil) {
        _searchBar = [[UISearchBar alloc] initWithFrame:CGRectZero];
        
        [self.searchBar sizeToFit];
        self.searchBar.autocorrectionType = UITextAutocorrectionTypeNo;
        self.searchBar.autocapitalizationType = UITextAutocapitalizationTypeNone;
        self.searchBar.keyboardType = UIKeyboardTypeDefault;
        self.searchBar.backgroundColor=[UIColor colorWithRed:0.784 green:0.800 blue:0.835 alpha:1.000];
        self.searchBar.translucent=YES;
        self.searchBar.placeholder=@"输入KTV名称搜索";
        self.searchBar.barStyle=UIBarStyleDefault;
        
        [[self.searchBar.subviews objectAtIndex:0]removeFromSuperview];
        for (UIView *subview in self.searchBar.subviews)
        {
            if ([subview isKindOfClass:NSClassFromString(@"UISearchBarBackground")])
            {
                [subview removeFromSuperview];
                break;
            }
        }
        
        [self setAllTableViewDelegate];
        
        self.searchBar.delegate = _allListDelegate;
        self.strongSearchDisplayController = [[[UISearchDisplayController alloc] initWithSearchBar:self.searchBar contentsController:self] autorelease];
        self.searchDisplayController.searchResultsDataSource = _allListDelegate;
        self.searchDisplayController.searchResultsDelegate = _allListDelegate;
        self.searchDisplayController.delegate = _allListDelegate;
    }
    
}

- (void)initRefreshHeaderView{
    
    [self setAllTableViewDelegate];
    
    if (_refreshHeaderView == nil) {
        EGORefreshTableHeaderView *view = [[EGORefreshTableHeaderView alloc] initWithFrame: CGRectMake(0.0f, _allTableView.bounds.size.height, _allTableView.frame.size.width, _allTableView.bounds.size.height)];
		view.delegate = self.allListDelegate;
        view.tag = EGOBottomView;
        view.backgroundColor = [UIColor clearColor];
		[_allTableView addSubview:view];
		self.refreshTailerView = view;
		[view release];
        
        view = [[EGORefreshTableHeaderView alloc] initWithFrame: CGRectMake(0.0f, - _allTableView.bounds.size.height, _allTableView.frame.size.width, _allTableView.bounds.size.height)];
        view.delegate = self.allListDelegate;
        view.tag = EGOHeaderView;
        view.backgroundColor = [UIColor clearColor];
        [_allTableView addSubview:view];
        self.refreshHeaderView = view;
        [view release];
    }
    _allListDelegate.mTableView = self.allTableView;
    _allListDelegate.refreshHeaderView = self.refreshHeaderView;
    _allListDelegate.refreshTailerView = self.refreshTailerView;
    [_refreshHeaderView refreshLastUpdatedDate];
}

- (void)initNearByRefreshHeaderView{
    
    [self setNearByTableViewDelegate];
    
    if (_refreshNearByHeaderView == nil) {
        EGORefreshTableHeaderView *view = [[EGORefreshTableHeaderView alloc] initWithFrame: CGRectMake(0.0f, _nearByTableView.bounds.size.height, _nearByTableView.frame.size.width, _nearByTableView.bounds.size.height)];
		view.delegate = self.nearByListDelegate;
        view.tag = EGOBottomView;
        view.backgroundColor = [UIColor clearColor];
		[_nearByTableView addSubview:view];
		self.refreshNearByTailerView = view;
		[view release];
        
        view = [[EGORefreshTableHeaderView alloc] initWithFrame: CGRectMake(0.0f, - _nearByTableView.bounds.size.height, _nearByTableView.frame.size.width, _nearByTableView.bounds.size.height)];
        view.delegate = self.nearByListDelegate;
        view.tag = EGOHeaderView;
        view.backgroundColor = [UIColor clearColor];
        [_nearByTableView addSubview:view];
        self.refreshNearByHeaderView = view;
        [view release];
    }
    _nearByListDelegate.mTableView = self.nearByTableView;
    _nearByListDelegate.refreshHeaderView = self.refreshNearByHeaderView;
    _nearByListDelegate.refreshTailerView = self.refreshNearByTailerView;
    [_refreshNearByHeaderView refreshLastUpdatedDate];
}

#pragma mark 设置 TableView Delegate
- (void)setAllTableViewDelegate{
    if (_allListDelegate==nil) {
        _allListDelegate = [[KTVAllListTableViewDelegate alloc] init];
        _allListDelegate.parentViewController = self;
    }
    _allTableView.dataSource = _allListDelegate;
    _allTableView.delegate = _allListDelegate;
}

- (void)setNearByTableViewDelegate{
    if (_nearByListDelegate==nil) {
        _nearByListDelegate = [[KTVNearByListTableViewDelegate alloc] init];
        _nearByListDelegate.parentViewController = self;
    }
    _nearByTableView.dataSource = _nearByListDelegate;
    _nearByTableView.delegate = _nearByListDelegate;
}

- (void)setFavoriteTableViewDelegate{
    if (_favoriteListDelegate==nil) {
        _favoriteListDelegate = [[KTVFavoriteListTableViewDelegate alloc] init];
        _favoriteListDelegate.parentViewController = self;
    }
    _favoriteTableView.dataSource = _favoriteListDelegate;
    _favoriteTableView.delegate = _favoriteListDelegate;
}

#pragma mark-
#pragma mark 搜索
-(void)beginSearch{
    
    CGRect frame1 = _filterHeaderView.frame;
    frame1.origin.y = -_filterHeaderView.bounds.size.height;
    _filterHeaderView.frame = frame1;
    
    switch (_filterKTVListType) {
        case NSFilterKTVListTypeNearby:{
            CGRect frame2 = _nearByTableView.frame;
            frame2.origin.y = 0;
            _nearByTableView.frame = frame2;
        }
            break;
            
        default:{
            CGRect frame2 = _allTableView.frame;
            frame2.origin.y = 0;
            _allTableView.frame = frame2;
        }
            break;
    }
}

-(void)endSearch{
    
    [UIView animateWithDuration:0.2 animations:^{
        
        CGRect frame1 = _filterHeaderView.frame;
        frame1.origin.y = 0;
        _filterHeaderView.frame = frame1;
        
        switch (_filterKTVListType) {
            case NSFilterKTVListTypeNearby:{
                CGRect frame2 = _nearByTableView.frame;
                frame2.origin.y = _filterHeaderView.bounds.size.height;
                _nearByTableView.frame = frame2;
            }
                break;
                
            default:{
                CGRect frame2 = _allTableView.frame;
                frame2.origin.y = _filterHeaderView.bounds.size.height;
                _allTableView.frame = frame2;
            }
                break;
        }
        
    } completion:^(BOOL finished) {
        
    }];
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

- (void)changeDataTypeState{
    
    //    switch (_filterKTVListType) {
    //        case NSFilterKTVListTypeFavorite:{
    //            [_mTableView setContentOffset:CGPointMake(0, 0) animated:NO];
    //
    //            _mTableView.tableHeaderView = nil;
    //            _refreshTailerView.hidden = YES;
    //            _refreshHeaderView.hidden = YES;
    //        }
    //            break;
    //        case NSFilterKTVListTypeNearby:{
    //            [_mTableView setContentOffset:CGPointMake(0, 0) animated:NO];
    //
    //            _mTableView.tableHeaderView = nil;
    //            _refreshTailerView.hidden = NO;
    //            _refreshHeaderView.hidden = NO;
    //        }
    //            break;
    //
    //        case NSFilterKTVListTypeAll:{
    //            _mTableView.tableHeaderView = nil;
    //            [_mTableView setTableHeaderView:self.searchBar];
    //            [_mTableView setContentOffset:CGPointMake(0, 44) animated:NO];
    //
    //            _mTableView.tableFooterView = nil;
    //            _refreshTailerView.hidden = NO;
    //            _refreshHeaderView.hidden = NO;
    //        }
    //            break;
    //        default:
    //            break;
    //    }
    
    switch (_filterKTVListType) {
        case NSFilterKTVListTypeFavorite:{
            
            [self.view bringSubviewToFront:self.favoriteTableView];
            self.favoriteListDelegate.mArray = self.favoriteArray;
        }
            break;
        case NSFilterKTVListTypeNearby:{
            [self.view bringSubviewToFront:self.nearByTableView];
            self.nearByListDelegate.mArray = self.nearByArray;
        }
            break;
        default:{
            [self.view bringSubviewToFront:self.allTableView];
            self.allListDelegate.mArray = self.allArray;
        }
            break;
    }
}

//- (void)getCurrentDataArray{
//    NSMutableDictionary *tDic = [_dataManagerDic objectForKey:[NSNumber numberWithInt:_filterKTVListType]];
//    if (!tDic) {
//        tDic = [NSMutableDictionary dictionaryWithCapacity:2];
//        NSMutableArray *t_mArray = [NSMutableArray arrayWithCapacity:10];
//        NSMutableArray *t_cacheArray = [NSMutableArray arrayWithCapacity:10];
//        [tDic setObject:t_cacheArray forKey:CacheArray];
//        [tDic setObject:t_mArray forKey:MArray];
//        [_dataManagerDic setObject:tDic forKey:[NSNumber numberWithInt:_filterKTVListType]];
//    }
//
//    self.ktvsArray = (NSMutableArray *)[tDic objectForKey:MArray];
//    self.cacheArray = (NSMutableArray *)[tDic objectForKey:CacheArray];
//    ABLoggerDebug(@"ktvsArray ===== %d",[(NSMutableArray *)[tDic objectForKey:MArray] count]);
//}

- (void)clickFilterFavoriteButton:(id)sender{
    if (_filterKTVListType==NSFilterKTVListTypeFavorite) {
        return;
    }
    _filterKTVListType=NSFilterKTVListTypeFavorite;
    [self changeDataTypeState];
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:_filterKTVListType] forKey:KKTV_FilterType];
    [self formatKTVDataFilterFavorite];
    [self stratAnimationFilterButton:_filterKTVListType];
    
    [self cleanUpTableView];
    _favoriteTableView.hidden = NO;
}

- (void)clickFilterNearbyButton:(id)sender{
    if (_filterKTVListType==NSFilterKTVListTypeNearby) {
        return;
    }
    _filterKTVListType=NSFilterKTVListTypeNearby;
    [self changeDataTypeState];
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:_filterKTVListType] forKey:KKTV_FilterType];
    [self formatKTVDataFilterNearby];
    [self stratAnimationFilterButton:_filterKTVListType];
    
    [self cleanUpTableView];
    _nearByTableView.hidden = NO;
}

- (void)clickFilterAllButton:(id)sender{
    if (_filterKTVListType==NSFilterKTVListTypeAll) {
        return;
    }
    _filterKTVListType=NSFilterKTVListTypeAll;
    [self changeDataTypeState];
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:_filterKTVListType] forKey:KKTV_FilterType];
    [self stratAnimationFilterButton:_filterKTVListType];
    
    [self cleanUpTableView];
    _allTableView.hidden = NO;
}

- (void)cleanUpTableView{
    _allTableView.hidden = YES;
    _nearByTableView.hidden = YES;
    _favoriteTableView.hidden = YES;
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
        //        [_filterHeaderView setUserInteractionEnabled:YES];
    }];
}

#pragma mark -
#pragma mark apiNotiry
-(void)apiNotifyResult:(id)apiCmd error:(NSError *)error{
    
    if (error) {
        return;
    }
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSArray *dataArray = [[DataBaseManager sharedInstance] insertKTVsIntoCoreDataFromObject:[apiCmd responseJSONObject] withApiCmd:apiCmd];
        
        if (dataArray==nil || [dataArray count]<=0) {
            return;
        }
        int tag = [[apiCmd httpRequest] tag];
        [self addDataIntoCacheData:dataArray];
        [self updateData:tag withData:[self getCacheData]];
        
    });
}

- (void) apiNotifyLocationResult:(id)apiCmd cacheData:(NSArray*)cacheData{
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self addDataIntoCacheData:cacheData];
        [self updateData:API_KKTVCmd withData:[self getCacheData]];
    });
}

- (ApiCmd *)apiGetDelegateApiCmd{
    return _apiCmdKTV_getAllKTVs;
}

- (void)updateData:(int)tag withData:(NSArray*)dataArray
{
    if (dataArray==nil || [dataArray count]<=0) {
        return;
    }
    
    ABLogger_int(tag);
    switch (tag) {
        case 0:
        case API_KKTVCmd:
        {
            [self formatCinemaData:dataArray];
        }
            break;
        default:
        {
            NSAssert(0, @"没有从网络抓取到数据");
        }
            break;
    }
}

#pragma mark -
#pragma mark FormateData
- (void)formatCinemaData:(NSArray*)dataArray{
    switch (_filterKTVListType) {
        case NSFilterKTVListTypeFavorite:{
            [self formatKTVDataFilterFavorite];
        }
            break;
        case NSFilterKTVListTypeNearby:{
            [self formatKTVDataFilterNearby];
        }
            break;
            
        case NSFilterKTVListTypeAll:
        default:{
            [self formatKTVDataFilterAll:dataArray];
        }
            break;
    }
}

#pragma mark -
#pragma mark FilterCinema FormatData
- (void)formatKTVDataFilterAll:(NSArray*)pageArray{
    
    NSArray *array_coreData = pageArray;
    ABLoggerDebug(@"KTV店 count ==== %d",[array_coreData count]);
    
    NSArray *regionOrder = [[DataBaseManager sharedInstance] getRegionOrder];
    
    NSMutableDictionary *districtDic = [[NSMutableDictionary alloc] initWithCapacity:10];
    
    for (KKTV *tKTV in array_coreData) {
        NSString *key = tKTV.district;
        
        if (![districtDic objectForKey:key]) {
            ABLoggerInfo(@"key === %@",key);
            NSMutableArray *tarray = [[NSMutableArray alloc] initWithCapacity:10];
            [districtDic setObject:tarray forKey:key];
            [tarray release];
        }
        [[districtDic objectForKey:key] addObject:tKTV];
    }
    
    for (NSString *key in regionOrder) {
        
        if (![districtDic objectForKey:key]) {
            continue;
        }
        
        NSMutableDictionary *dic = nil;
        
        BOOL isContinue = NO;
        
        for (NSMutableDictionary *tDic in _allArray) {
            if ([[tDic objectForKey:@"name"] isEqualToString:key]) {
                dic = tDic;
                NSMutableArray *tarray = [tDic objectForKey:@"list"];
                [tarray addObjectsFromArray:[districtDic objectForKey:key]];
                isContinue = YES;
                continue;
            }
        }
        
        if (isContinue) {
            continue;
        }
        
        if (dic==nil) {
            dic = [NSMutableDictionary dictionaryWithCapacity:10];
        }
        
        [dic setObject:key forKey:@"name"];
        [dic setObject:[districtDic objectForKey:key] forKey:@"list"];
        
        [_allArray addObject:dic];
    }
    
    [districtDic release];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self reloadPullRefreshData];
    });
}

- (void)formatKTVDataFilterNearby{
    ABLoggerWarn(@" 附近 影院");
    
    [[DataBaseManager sharedInstance] getNearbyKTVListFromCoreDataWithCallBack:^(NSArray *ktvs) {
        
        ABLoggerInfo(@"附近 KTV count=== %d",[ktvs count]);
        [self.nearByArray addObjectsFromArray:ktvs];
        
        _nearByTableView.tableFooterView = nil;
        if ([ktvs count]<=0) {
            _nearByTableView.tableFooterView = _noGPSView;
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
        });
    }];
    
    [_nearByTableView reloadData];
}

- (void)formatKTVDataFilterFavorite{
    NSArray *array_coreData = [[DataBaseManager sharedInstance] getFavoriteKTVListFromCoreData];
    ABLoggerDebug(@"常去 KTV count ==== %d",[array_coreData count]);
    
    [self.favoriteArray removeAllObjects];
    [self.favoriteArray addObjectsFromArray:array_coreData];
    
    if ([array_coreData count]==1) {
        
        if (_ktvBuyViewController==nil) {
            _ktvBuyViewController = [[KTVBuyViewController alloc]
                                     initWithNibName:(iPhone5?@"KTVBuyViewController_5":@"KTVBuyViewController")
                                     bundle:nil];
            
        }
        _ktvBuyViewController.mKTV = [array_coreData lastObject];
        _ktvBuyViewController.view.frame = _favoriteTableView.frame;
        [self.view addSubview:_ktvBuyViewController.view];
        
    }
    
    if ([array_coreData count]>0) {
        _favoriteTableView.tableFooterView = _addFavoriteFooterView;
    }else{
        _favoriteTableView.tableFooterView = _noFavoriteFooterView;
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [_favoriteTableView reloadData];
    });
}

- (void)cleanFavoriteKTVBuyViewController{
    if (_ktvBuyViewController) {
        [_ktvBuyViewController.view removeFromSuperview];
        self.ktvBuyViewController = nil;
    }
}

#pragma mark -
#pragma mark 刷新和加载更多
- (void)loadMoreData{
    switch (_filterKTVListType) {
        case NSFilterKTVListTypeNearby:{
            isLoadMoreNearBy = YES;
        }
            break;
        default:{
            isLoadMoreAll = YES;
        }
            break;
    }
    
    [self updateData:0 withData:[self getCacheData]];
}

- (void)loadNewData{
    switch (_filterKTVListType) {
        case NSFilterKTVListTypeNearby:{
            isLoadMoreNearBy = NO;
        }
            break;
        default:{
            isLoadMoreAll = NO;
        }
            break;
    }
    
    NSMutableDictionary *tDic = [_dataManagerDic objectForKey:[NSNumber numberWithInt:_filterKTVListType]];
    if (!tDic) {
        tDic = [NSMutableDictionary dictionaryWithCapacity:2];
        NSMutableArray *t_mArray = [NSMutableArray arrayWithCapacity:10];
        NSMutableArray *t_cacheArray = [NSMutableArray arrayWithCapacity:10];
        [tDic setObject:t_cacheArray forKey:CacheArray];
        [tDic setObject:t_mArray forKey:MArray];
        [_dataManagerDic setObject:tDic forKey:[NSNumber numberWithInt:_filterKTVListType]];
    }
    
    [[tDic objectForKey:MArray] removeAllObjects];
    [[tDic objectForKey:CacheArray] removeAllObjects];
    
    [self updateData:0 withData:[self getCacheData]];
}

- (void)reloadPullRefreshData{
    switch (_filterKTVListType) {
        case NSFilterKTVListTypeFavorite:{
            [_favoriteTableView reloadData];
        }
            break;
        case NSFilterKTVListTypeNearby:{
            if (isLoadMoreNearBy) {
                [_nearByListDelegate doneLoadingTableViewData];
            }else{
                [_nearByListDelegate doneReLoadingTableViewData];
            }
        }
            break;
        default:{
            if (isLoadMoreAll) {
                [_nearByListDelegate doneLoadingTableViewData];
            }else{
                [_nearByListDelegate doneReLoadingTableViewData];
            }
        }
            break;
    }
}

//添加缓存数据
- (void)addDataIntoCacheData:(NSArray *)dataArray{
    if (_filterKTVListType != NSFilterKTVListTypeAll) {
        return;
    }
    [self.allCache addObjectsFromArray:dataArray];
}

//获取缓存数据
- (NSArray *)getCacheData{
    
    if (_filterKTVListType != NSFilterKTVListTypeAll) {
        return nil;
    }
    
    if ([_allCache count]<=0) {
        
        int number = 0;
        for (NSDictionary *dic in self.allArray) {
            number += [[dic objectForKey:@"list"] count];
        }
        ABLoggerDebug(@"ktv 数组 number ==  %d",number);
        
        self.apiCmdKTV_getAllKTVs = (ApiCmdKTV_getAllKTVs *)[[DataBaseManager sharedInstance] getKTVsListFromWeb:self offset:number limit:DataLimit];
        return  nil;
    }
    
    ABLoggerInfo(@"_cacheArray count == %d",[_allCache count]);
    int count = 10; //取10条数据
    if ([_allCache count]<10) {
        count = [_allCache count];//取小于10条数据
    }
    
    for (int i=0;i<[_allCache count] ;i++ ) {
        KKTV *ttktv = [_allCache objectAtIndex:i];
        ABLoggerInfo(@"1111_cacheArray count == %d",[_allCache count]);
        ABLoggerDebug(@"2222  coredata district id === %@",ttktv.districtid);
    }
    
    NSMutableArray *aPageData = [NSMutableArray arrayWithCapacity:count];
    for (int i=0; i<count; i++) {
        KKTV *object = [_allCache objectAtIndex:i];
        [aPageData addObject:object];
    }
    
    mCount += [aPageData count];
    
    if (count>0) {
        [_allCache removeObjectsInRange:NSMakeRange(0, count)];
    }
    
    for (int i = 0;i<[aPageData count];i++) {
        KKTV *object = [aPageData objectAtIndex:i];
        ABLoggerInfo(@"111district id ===== %@",object.districtid);
    }
    
    for (int i = 0;i<[_allCache count];i++) {
        KKTV *object = [_allCache objectAtIndex:i];
        ABLoggerInfo(@"222 ============== district id ===== %@",object.districtid);
    }
    
    ABLoggerInfo(@"_cacheArray count == %d",[_allCache count]);
    ABLoggerInfo(@"aPageData count == %d",[aPageData count]);
    
    return aPageData;
}

#pragma mark -
#pragma mark 内存警告
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    ABLoggerWarn(@"接收到内存警告了");
    
    // Dispose of any resources that can be recreated.
    for (NSNumber *num in [_dataManagerDic allKeys]) {
        if ([num intValue] != _filterKTVListType) {
            [[[_dataManagerDic objectForKey:num] objectForKey:MArray] removeAllObjects];
            [[[_dataManagerDic objectForKey:num] objectForKey:CacheArray] removeAllObjects];
        }
    }
    
    switch (_filterKTVListType) {
        case NSFilterKTVListTypeFavorite:{
            
        }
            break;
        case NSFilterKTVListTypeNearby:{
            
        }
            break;
        default:{
            
        }
            break;
    }
}

@end
