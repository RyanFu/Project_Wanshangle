//
//  CinemaViewController.m
//  WanShangLe
//
//  Created by stephenliu on 13-6-8.
//  Copyright (c) 2013年 stephenliu. All rights reserved.
//

#import "KtvViewController.h"
#import "ApiCmdKTV_getAllKTVs.h"
#import "KTVListTableViewDelegate.h"
#import "EGORefreshTableHeaderView.h"
#import "KTVBuyViewController.h"
#import "ASIHTTPRequest.h"
#import "KKTV.h"
#import "ApiCmd.h"

#define TableView_Y 74

@interface KtvViewController()<ApiNotify>{
    UIButton *favoriteButton;
    UIButton *nearbyButton;
    UIButton *allButton;
}
@property(nonatomic,retain)UIView *filterIndicator;
@property(nonatomic,retain)UIView *filterHeaderView;
@property(nonatomic,retain)KTVListTableViewDelegate *ktvListTableViewDelegate;
@property(nonatomic,retain)KTVBuyViewController *ktvBuyViewController;
@end

@implementation KtvViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = @"KTV";
        self.apiCmdKTV_getAllKTVs = (ApiCmdKTV_getAllKTVs *)[[DataBaseManager sharedInstance] getAllKTVsListFromWeb:self];
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
    
    self.searchBar.delegate = nil;
    self.searchBar = nil;
    self.strongSearchDisplayController.delegate = nil;
    self.strongSearchDisplayController = nil;
    
    self.ktvListTableViewDelegate = nil;
    self.filterHeaderView = nil;
    self.filterIndicator = nil;
    self.mTableView = nil;
    self.ktvBuyViewController = nil;
    
    [super dealloc];
}

#pragma mark -
#pragma mark UIView cycle
- (void)viewWillAppear:(BOOL)animated{
    
    self.apiCmdKTV_getAllKTVs = (ApiCmdKTV_getAllKTVs *)[[DataBaseManager sharedInstance] getAllKTVsListFromWeb:self];
    //    [self updateData:0];
    
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
    [self initSearchBarDisplay];
    [self initTableView];
    [self initRefreshHeaderView];
    
    [self clickFilterFavoriteButton:nil];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        [self updateData:0];
    });
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

- (void)initTableView {
    
    //create movie tableview and init
    _mTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, _filterHeaderView.bounds.size.height, iPhoneAppFrame.size.width, self.view.bounds.size.height-TableView_Y)
                                               style:UITableViewStylePlain];
    _mTableView.backgroundColor = [UIColor whiteColor];
    _mTableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    _mTableView.tableHeaderView = self.searchBar;
    _mTableView.tableFooterView = [[[UIView alloc] initWithFrame:CGRectZero] autorelease];
    [self.view addSubview:_mTableView];
}

- (void)initSearchBarDisplay{
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
    
    [self setTableViewDelegate];
    
    self.searchBar.delegate = _ktvListTableViewDelegate;
    self.strongSearchDisplayController = [[[UISearchDisplayController alloc] initWithSearchBar:self.searchBar contentsController:self] autorelease];
    self.searchDisplayController.searchResultsDataSource = _ktvListTableViewDelegate;
    self.searchDisplayController.searchResultsDelegate = _ktvListTableViewDelegate;
    self.searchDisplayController.delegate = _ktvListTableViewDelegate;
}

- (void)initRefreshHeaderView{
    
    [self setTableViewDelegate];
    
    if (_refreshHeaderView == nil) {
        EGORefreshTableHeaderView *view = [[EGORefreshTableHeaderView alloc] initWithFrame: CGRectMake(0.0f, _mTableView.contentSize.height, _mTableView.frame.size.width, _mTableView.bounds.size.height)];
		view.delegate = self.ktvListTableViewDelegate;
        view.tag = EGOBottomView;
        view.backgroundColor = [UIColor clearColor];
		[_mTableView addSubview:view];
		self.refreshTailerView = view;
		[view release];
        
        view = [[EGORefreshTableHeaderView alloc] initWithFrame: CGRectMake(0.0f, - _mTableView.bounds.size.height, _mTableView.frame.size.width, _mTableView.bounds.size.height)];
        view.delegate = self.ktvListTableViewDelegate;
        view.tag = EGOHeaderView;
        view.backgroundColor = [UIColor clearColor];
        [_mTableView addSubview:view];
        self.refreshHeaderView = view;
        [view release];
    }
    
    _ktvListTableViewDelegate.mTableView = self.mTableView;
    _ktvListTableViewDelegate.refreshHeaderView = self.refreshHeaderView;
    _ktvListTableViewDelegate.refreshTailerView = self.refreshTailerView;
    [_refreshHeaderView refreshLastUpdatedDate];
}

#pragma mark 设置 TableView Delegate
- (void)setTableViewDelegate{
    if (_ktvListTableViewDelegate==nil) {
        _ktvListTableViewDelegate = [[KTVListTableViewDelegate alloc] init];
        _ktvListTableViewDelegate.parentViewController = self;
    }
    _mTableView.dataSource = _ktvListTableViewDelegate;
    _mTableView.delegate = _ktvListTableViewDelegate;
}

#pragma mark-
#pragma mark 搜索
-(void)beginSearch{
    
    CGRect frame1 = _filterHeaderView.frame;
    frame1.origin.y = -_filterHeaderView.bounds.size.height;
    _filterHeaderView.frame = frame1;
    
    CGRect frame2 = _mTableView.frame;
    frame2.origin.y = 0;
    _mTableView.frame = frame2;
}

-(void)endSearch{
    
    [UIView animateWithDuration:0.2 animations:^{
        CGRect frame1 = _filterHeaderView.frame;
        frame1.origin.y = 0;
        _filterHeaderView.frame = frame1;
        
        CGRect frame2 = _mTableView.frame;
        frame2.origin.y = _filterHeaderView.bounds.size.height;
        _mTableView.frame = frame2;
    } completion:^(BOOL finished) {
        
    }];
}

#pragma mark-
#pragma mark UIButton Event
- (void)clickBackButton:(id)sender{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)updateSettingFilter{
    
    switch (_filterKTVListType) {
        case NSFilterKTVListTypeFavorite:{
            _filterKTVListType=NSFilterKTVListTypeFavorite;
            [self clickFilterFavoriteButton:nil];
        }
            break;
        case NSFilterKTVListTypeNearby:{
            _filterKTVListType=NSFilterKTVListTypeNearby;
            [self clickFilterNearbyButton:nil];
        }
            break;
            
        case NSFilterKTVListTypeAll:{
            _filterKTVListType=NSFilterKTVListTypeAll;
            [self clickFilterAllButton:nil];
        }
            break;
        default:
            break;
    }
}

- (void)changeSearchBarState{
    
    switch (_filterKTVListType) {
        case NSFilterKTVListTypeFavorite:{
            _mTableView.tableHeaderView = nil;
            [_mTableView setContentOffset:CGPointMake(0, 0) animated:NO];
            _refreshTailerView.hidden = YES;
        }
            break;
        case NSFilterKTVListTypeNearby:{
            _mTableView.tableHeaderView = nil;
            [_mTableView setContentOffset:CGPointMake(0, 0) animated:NO];
            _refreshTailerView.hidden = NO;
        }
            break;
            
        case NSFilterKTVListTypeAll:{
            _mTableView.tableHeaderView = nil;
            [_mTableView setTableHeaderView:self.searchBar];
            [_mTableView setContentOffset:CGPointMake(0, 44) animated:NO];
            _mTableView.tableFooterView = nil;
            _refreshTailerView.hidden = NO;
        }
            break;
        default:
            break;
    }
}

- (void)clickFilterFavoriteButton:(id)sender{
    if (_filterKTVListType==NSFilterKTVListTypeFavorite) {
        return;
    }
    _filterKTVListType=NSFilterKTVListTypeFavorite;
    [self changeSearchBarState];
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:_filterKTVListType] forKey:KKTV_FilterType];
    [self formatKTVDataFilterFavorite];
    [self stratAnimationFilterButton:_filterKTVListType];
}

- (void)clickFilterNearbyButton:(id)sender{
    if (_filterKTVListType==NSFilterKTVListTypeNearby) {
        return;
    }
    _filterKTVListType=NSFilterKTVListTypeNearby;
     [self changeSearchBarState];
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:_filterKTVListType] forKey:KKTV_FilterType];
    [self formatKTVDataFilterNearby];
    [self stratAnimationFilterButton:_filterKTVListType];
}

- (void)clickFilterAllButton:(id)sender{
    if (_filterKTVListType==NSFilterKTVListTypeAll) {
        return;
    }
    _filterKTVListType=NSFilterKTVListTypeAll;
     [self changeSearchBarState];
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:_filterKTVListType] forKey:KKTV_FilterType];
    [self formatKTVDataFilterAll];
    [self stratAnimationFilterButton:_filterKTVListType];
}

- (void)stratAnimationFilterButton:(NSFilterKTVListType)type{
    
    UIButton *bt = (UIButton *)[_filterHeaderView viewWithTag:type];
    CGRect oldFrame = _filterIndicator.frame;
    oldFrame.origin.y = 34;
    _filterIndicator.frame = oldFrame;
    
    [UIView animateWithDuration:0.2 animations:^{
        [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
        
        //         [_filterHeaderView setUserInteractionEnabled:NO];
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
        [_filterHeaderView setUserInteractionEnabled:YES];
    }];
}

#pragma mark -
#pragma mark apiNotiry
-(void)apiNotifyResult:(id)apiCmd error:(NSError *)error{
    
    if (error) {
        return;
    }
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        [[DataBaseManager sharedInstance] insertKTVsIntoCoreDataFromObject:[apiCmd responseJSONObject] withApiCmd:apiCmd];
        
        int tag = [[apiCmd httpRequest] tag];
        [self updateData:tag];
        
    });
    
    
}

- (void) apiNotifyLocationResult:(id) apiCmd  error:(NSError*) error{
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        int tag = [[apiCmd httpRequest] tag];
        [self updateData:tag];
    });
}

- (ApiCmd *)apiGetDelegateApiCmd{
    return _apiCmdKTV_getAllKTVs;
}

- (void)updateData:(int)tag
{
    ABLogger_int(tag);
    switch (tag) {
        case 0:
        case API_KKTVCmd:
        {
            [self formatCinemaData];
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
- (void)formatCinemaData{
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
            [self formatKTVDataFilterAll];
        }
        break;
    }
}

- (void)isDisplayRefreshTailerView{
    if (isNull(_ktvsArray) || [_ktvsArray count]==0) {
        _refreshTailerView.hidden = YES;
    }else{
        _refreshTailerView.hidden = NO;
    }
}

#pragma mark -
#pragma mark FilterCinema FormatData
- (void)formatKTVDataFilterAll{
    
    NSArray *array_coreData = [[DataBaseManager sharedInstance] getAllKTVsListFromCoreData];
    ABLoggerDebug(@"KTV店 count ==== %d",[array_coreData count]);
    
    NSArray *regionOrder = [[DataBaseManager sharedInstance] getRegionOrder];
    
    NSMutableDictionary *districtDic = [[NSMutableDictionary alloc] initWithCapacity:10];
    NSMutableArray *dataArray = [[NSMutableArray alloc] initWithCapacity:10];
    
    for (KKTV *tKTV in array_coreData) {
        NSString *key = tKTV.district;
        
        if (![districtDic objectForKey:key]) {
            
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
        
        NSDictionary *dic = [[NSDictionary alloc] initWithObjectsAndKeys:
                             [districtDic objectForKey:key],@"list",
                             key,@"name",nil];
        [dataArray addObject:dic];
        [dic release];
    }
    self.ktvsArray = dataArray;
    [dataArray release];
    [districtDic release];
    
    [self isDisplayRefreshTailerView];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [_mTableView reloadData];
    });
}

- (void)formatKTVDataFilterNearby{
    ABLoggerWarn(@" 附近 影院");
    self.ktvsArray = nil;
    _mTableView.tableFooterView = nil;
    
    [[DataBaseManager sharedInstance] getNearbyKTVListFromCoreDataWithCallBack:^(NSArray *ktvs) {
        
        ABLoggerInfo(@"附近 KTV count=== %d",[ktvs count]);
        self.ktvsArray = ktvs;
        [self isDisplayRefreshTailerView];
        
        _mTableView.tableFooterView = nil;
        if ([ktvs count]<=0) {
            _mTableView.tableFooterView = _noGPSView;
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [_mTableView reloadData];
        });
    }];
    
    [_mTableView reloadData];
}

- (void)formatKTVDataFilterFavorite{
    NSArray *array_coreData = [[DataBaseManager sharedInstance] getFavoriteKTVListFromCoreData];
    ABLoggerDebug(@"常去 KTV count ==== %d",[array_coreData count]);
    
    if ([array_coreData count]==1) {
        self.ktvsArray = nil;
        
        if (_ktvBuyViewController==nil) {
            _ktvBuyViewController = [[KTVBuyViewController alloc]
                                     initWithNibName:(iPhone5?@"KTVBuyViewController_5":@"KTVBuyViewController")
                                     bundle:nil];
            
        }
        _ktvBuyViewController.mKTV = [array_coreData lastObject];
        _ktvBuyViewController.view.frame = _mTableView.frame;
        [self.view addSubview:_ktvBuyViewController.view];
        
    }else{
        self.ktvsArray = array_coreData;
    }
    
    [self isDisplayRefreshTailerView];
    
    if ([array_coreData count]>0) {
        _mTableView.tableFooterView = _addFavoriteFooterView;
    }else{
        _mTableView.tableFooterView = _noFavoriteFooterView;
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [_mTableView reloadData];
    });
}

- (void)cleanFavoriteKTVBuyViewController{
    if (_ktvBuyViewController) {
        [_ktvBuyViewController.view removeFromSuperview];
        self.ktvBuyViewController = nil;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    ABLoggerWarn(@"接收到内存警告了");
    // Dispose of any resources that can be recreated.
}

@end
