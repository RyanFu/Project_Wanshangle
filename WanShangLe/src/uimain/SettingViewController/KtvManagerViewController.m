//
//  CinemaViewController.m
//  WanShangLe
//
//  Created by stephenliu on 13-6-8.
//  Copyright (c) 2013年 stephenliu. All rights reserved.
//

#import "KtvManagerViewController.h"
#import "ApiCmdKTV_getAllKTVs.h"
#import "EGORefreshTableHeaderView.h"
#import "ASIHTTPRequest.h"
#import "KKTV.h"
#import "ApiCmd.h"

#import "KTVAllListManagerDelegate.h"

#define MArray @"MArray"
#define CacheArray @"CacheArray"

@interface KtvManagerViewController()<ApiNotify>{
    
}
@property(nonatomic,retain)KTVAllListManagerDelegate *tableViewDelegate;
@end

@implementation KtvManagerViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
        self.title = @"KTV店";
    }
    return self;
}

- (void)dealloc{
    
    [_apiCmdKTV_getAllKTVs.httpRequest clearDelegatesAndCancel];
    _apiCmdKTV_getAllKTVs.delegate = nil;
    [[[ApiClient defaultClient] requestArray] removeObject:_apiCmdKTV_getAllKTVs];
    self.apiCmdKTV_getAllKTVs = nil;
    
    _refreshTailerView.delegate = nil;
    [_refreshTailerView removeFromSuperview];
    self.refreshTailerView = nil;
    
    self.mArray = nil;
    self.mCacheArray = nil;
    self.tableViewDelegate = nil;
    
    self.searchBar = nil;
    self.strongSearchDisplayController = nil;
    
    [super dealloc];
}

#pragma mark -
#pragma mark UIView cycle
- (void)viewWillAppear:(BOOL)animated{
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self initBarButtonItem];
    [self initTableView];
    
    [self loadMoreData];
}

- (void)viewWillDisappear:(BOOL)animated{
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

#pragma mark -
#pragma mark 初始化TableView
- (void)initTableView{
    
    if (_mTableView==nil) {
        self.mTableView = [self createTableView];
    }
    
    if (_searchBar==nil) {
        [self initSearchBarDisplay];
        _mTableView.tableHeaderView = self.searchBar;
    }
    
    [self initRefreshHeaderView];
    [self.view addSubview:_mTableView];
    
    [self initArrayData];
}

- (void)initArrayData{
    if (_mArray==nil) {
        _mArray = [[NSMutableArray alloc] initWithCapacity:10];
    }
    if (_mCacheArray==nil) {
        _mCacheArray = [[NSMutableArray alloc] initWithCapacity:10];
    }
    if (_mFavoriteArray==nil) {
         _mFavoriteArray = [[NSMutableArray alloc] initWithCapacity:10];
    }
}

- (UITableView *)createTableView{
    
    UITableView *tbView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 504.0f) style:UITableViewStylePlain];
    tbView.backgroundColor = [UIColor whiteColor];
    tbView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    
    tbView.tableHeaderView = [[[UIView alloc] initWithFrame:CGRectZero] autorelease];
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
        
        [self setTableViewDelegate];
        
        self.searchBar.delegate = _tableViewDelegate;
        self.strongSearchDisplayController = [[[UISearchDisplayController alloc] initWithSearchBar:self.searchBar contentsController:self] autorelease];
        self.searchDisplayController.searchResultsDataSource = _tableViewDelegate;
        self.searchDisplayController.searchResultsDelegate = _tableViewDelegate;
        self.searchDisplayController.delegate = _tableViewDelegate;
    }
    
}

- (void)initRefreshHeaderView{
    
    [self setTableViewDelegate];
    
    if (_refreshTailerView == nil) {
        EGORefreshTableHeaderView *view = [[EGORefreshTableHeaderView alloc] initWithFrame: CGRectMake(0.0f, _mTableView.bounds.size.height, _mTableView.frame.size.width, _mTableView.bounds.size.height)];
		view.delegate = self.tableViewDelegate;
        view.tag = EGOBottomView;
        view.backgroundColor = [UIColor clearColor];
		[_mTableView addSubview:view];
		self.refreshTailerView = view;
		[view release];
    }
    _tableViewDelegate.mTableView = self.mTableView;
    _tableViewDelegate.refreshTailerView = self.refreshTailerView;
    [_refreshTailerView refreshLastUpdatedDate];
}

#pragma mark 设置 TableView Delegate
- (void)setTableViewDelegate{
    if (_tableViewDelegate==nil) {
        _tableViewDelegate = [[KTVAllListManagerDelegate alloc] init];
        _tableViewDelegate.parentViewController = self;
    }
    _mTableView.dataSource = _tableViewDelegate;
    _mTableView.delegate = _tableViewDelegate;
    _tableViewDelegate.mArray = _mArray;
    _tableViewDelegate.mTableView = _mTableView;
    _tableViewDelegate.mFavoriteArray = _mFavoriteArray;
}

#pragma mark-
#pragma mark UIButton Event
- (void)clickBackButton:(id)sender{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark -
#pragma mark apiNotiry
-(void)apiNotifyResult:(id)apiCmd error:(NSError *)error{
    
    if (error!=nil) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self reloadPullRefreshData];
        });
        return;
    }
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSArray *dataArray = [[DataBaseManager sharedInstance] insertKTVsIntoCoreDataFromObject:[apiCmd responseJSONObject] withApiCmd:apiCmd];
        
        if (dataArray==nil || [dataArray count]<=0) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self reloadPullRefreshData];
            });
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
    [self formatCinemaData:dataArray];
}

#pragma mark -
#pragma mark FormateData
- (void)formatCinemaData:(NSArray*)dataArray{
    [self formatKTVDataFilterAll:dataArray];
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
        
        for (NSMutableDictionary *tDic in _mArray) {
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
        
        [_mArray addObject:dic];
    }
    
    [districtDic release];
    
    _refreshTailerView.hidden = NO;
    if ([_mArray count]<=0 || _mArray==nil) {
        _refreshTailerView.hidden = YES;
        
    }
    
    [self formatKTVDataFilterFavorite];
    
    dispatch_async(dispatch_get_main_queue(), ^{

        [self reloadPullRefreshData];
    });
}

- (void)formatKTVDataFilterFavorite{
    
    NSArray *array_coreData = [[DataBaseManager sharedInstance] getFavoriteKTVListFromCoreData];
    ABLoggerDebug(@"常去 KTV count ==== %d",[array_coreData count]);
    [_mFavoriteArray removeAllObjects];
    [_mFavoriteArray addObjectsFromArray:array_coreData];
}

#pragma mark -
#pragma mark 刷新和加载更多
- (void)loadMoreData{
    [self updateData:0 withData:[self getCacheData]];
}

- (void)reloadPullRefreshData{
    [self setTableViewDelegate];
    [_tableViewDelegate doneLoadingTableViewData];
    
    _refreshTailerView.frame = CGRectMake(0.0f, _mTableView.contentSize.height, _mTableView.frame.size.width, _mTableView.bounds.size.height);
}

//添加缓存数据
- (void)addDataIntoCacheData:(NSArray *)dataArray{
    
    [self.mCacheArray addObjectsFromArray:dataArray];
}

//获取缓存数据
- (NSArray *)getCacheData{
    
    if ([_mCacheArray count]<=0) {
        
        int number = 0;
        for (NSDictionary *dic in self.mArray) {
            number += [[dic objectForKey:@"list"] count];
        }
        ABLoggerDebug(@"ktv 数组 number ==  %d",number);
        
        self.apiCmdKTV_getAllKTVs = (ApiCmdKTV_getAllKTVs *)[[DataBaseManager sharedInstance] getKTVsListFromWeb:self offset:number limit:DataLimit];
        return  nil;
    }
    
    ABLoggerInfo(@"_cacheArray count == %d",[_mCacheArray count]);
    int count = 10; //取10条数据
    if ([_mCacheArray count]<10) {
        count = [_mCacheArray count];//取小于10条数据
    }
    
    for (int i=0;i<[_mCacheArray count] ;i++ ) {
        KKTV *ttktv = [_mCacheArray objectAtIndex:i];
//        ABLoggerDebug(@"2222  coredata district id === %@",ttktv.districtid);
    }
    
    NSMutableArray *aPageData = [NSMutableArray arrayWithCapacity:count];
    for (int i=0; i<count; i++) {
        KKTV *object = [_mCacheArray objectAtIndex:i];
        [aPageData addObject:object];
    }
    
    if (count>0) {
        [_mCacheArray removeObjectsInRange:NSMakeRange(0, count)];
    }
    
    for (int i = 0;i<[aPageData count];i++) {
        KKTV *object = [aPageData objectAtIndex:i];
//        ABLoggerInfo(@"111district id ===== %@",object.districtid);
    }
    
    for (int i = 0;i<[_mCacheArray count];i++) {
        KKTV *object = [_mCacheArray objectAtIndex:i];
//        ABLoggerInfo(@"222 ============== district id ===== %@",object.districtid);
    }
    
    ABLoggerInfo(@"_cacheArray count == %d",[_mCacheArray count]);
    ABLoggerInfo(@"aPageData count == %d",[aPageData count]);
    
    return aPageData;
}

#pragma mark -
#pragma mark 内存警告
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    ABLoggerWarn(@"接收到内存警告了");
}

@end
