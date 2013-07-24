//
//  CinemaViewController.m
//  WanShangLe
//
//  Created by stephenliu on 13-6-8.
//  Copyright (c) 2013年 stephenliu. All rights reserved.
//

#import "KtvAllViewController.h"
#import "KtvViewController.h"
#import "ApiCmdKTV_getAllKTVs.h"
#import "EGORefreshTableHeaderView.h"
#import "KTVBuyViewController.h"
#import "ASIHTTPRequest.h"
#import "KKTV.h"
#import "ApiCmd.h"

#import "KTVAllListTableViewDelegate.h"

#define TableView_Y 44

@interface KtvAllViewController()<ApiNotify>{
    BOOL isLoadMoreAll;
}
@property(nonatomic,retain)KTVAllListTableViewDelegate *allListDelegate;
@end

@implementation KtvAllViewController

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
    
    
    self.searchBar.delegate = nil;
    self.searchBar = nil;
    self.strongSearchDisplayController.delegate = nil;
    self.strongSearchDisplayController = nil;
    
    self.allListDelegate = nil;
    self.mTableView = nil;
    self.mArray = nil;
    self.mCacheArray = nil;
    
    [super dealloc];
}

#pragma mark -
#pragma mark UIView cycle
- (void)viewWillAppear:(BOOL)animated{

    [self hiddenSearchBar];
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
    
    [self.view addSubview:self.mTableView];
    
    [self loadMoreData];//初始化加载
}
#pragma mark -
#pragma mark 初始化TableView

- (UITableView *)mTableView
{
    if (_mTableView != nil) {
        return _mTableView;
    }
    
    [self initTableView];
    
    return _mTableView;
}

- (void)initTableView{
    if (_mTableView==nil) {
        self.mTableView = [self createTableView];
    }
    
    if (_searchBar==nil) {
        [self initSearchBarDisplay];
        _mTableView.tableHeaderView = self.searchBar;
    }
    
    [self hiddenSearchBar];
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
    if (_allListDelegate==nil) {
        _allListDelegate = [[KTVAllListTableViewDelegate alloc] init];
        _allListDelegate.parentViewController = self;
    }
    _mTableView.dataSource = _allListDelegate;
    _mTableView.delegate = _allListDelegate;
    _allListDelegate.mTableView = _mTableView;
    _allListDelegate.mArray = _mArray;
}

-(void)hiddenSearchBar{
    [_mTableView setContentOffset:CGPointMake(0, TableView_Y)];
    [self hiddenRefreshTailerView];
}

- (void)hiddenRefreshTailerView{
    if (_mArray==nil || [_mArray count]<=0) {
        _refreshTailerView.hidden = YES;
    }
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
        
        self.searchBar.delegate = _allListDelegate;
        self.strongSearchDisplayController = [[[UISearchDisplayController alloc] initWithSearchBar:self.searchBar contentsController:_mParentController] autorelease];
        _mParentController.searchDisplayController.searchResultsDataSource = _allListDelegate;
        _mParentController.searchDisplayController.searchResultsDelegate = _allListDelegate;
        _mParentController.searchDisplayController.delegate = _allListDelegate;
    }
    
}

- (void)initRefreshHeaderView{
    
    [self setTableViewDelegate];
    
    if (_refreshHeaderView == nil) {
        EGORefreshTableHeaderView *view = [[EGORefreshTableHeaderView alloc] initWithFrame: CGRectMake(0.0f, _mTableView.bounds.size.height, _mTableView.frame.size.width, _mTableView.bounds.size.height)];
		view.delegate = self.allListDelegate;
        view.tag = EGOBottomView;
        view.backgroundColor = [UIColor clearColor];
		[_mTableView addSubview:view];
		self.refreshTailerView = view;
		[view release];
        
        view = [[EGORefreshTableHeaderView alloc] initWithFrame: CGRectMake(0.0f, - _mTableView.bounds.size.height, _mTableView.frame.size.width, _mTableView.bounds.size.height)];
        view.delegate = self.allListDelegate;
        view.tag = EGOHeaderView;
        view.backgroundColor = [UIColor clearColor];
        [_mTableView addSubview:view];
        self.refreshHeaderView = view;
        [view release];
    }
    _allListDelegate.refreshHeaderView = self.refreshHeaderView;
    _allListDelegate.refreshTailerView = self.refreshTailerView;
    [_refreshHeaderView refreshLastUpdatedDate];
}



#pragma mark-
#pragma mark 搜索
//    self.mParentController.filterHeaderView.frame = CGRectMake(0, -40, self.view.bounds.size.width, 40);
-(void)beginSearch{
    
    CGRect frame1 = self.mParentController.filterHeaderView.frame;
    frame1.origin.y = - self.mParentController.filterHeaderView.bounds.size.height;
    self.mParentController.filterHeaderView.frame = frame1;
    
    CGRect frame2 = self.view.frame;
    frame2.origin.y = 0;
    self.view.frame = frame2;
}

-(void)endSearch{
    
    [UIView animateWithDuration:0.2 animations:^{
        
        CGRect frame1 = self.mParentController.filterHeaderView.frame;
        frame1.origin.y = 0;
        self.mParentController.filterHeaderView.frame = frame1;

        CGRect frame2 = self.view.frame;
        frame2.origin.y = self.mParentController.filterHeaderView.bounds.size.height;
        self.view.frame = frame2;
        
    } completion:^(BOOL finished) {
        
    }];
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
    
    ABLogger_int(tag);
    switch (tag) {
        case 0:
        case API_KKTVCmd:
        {
            [self formatKTVData:dataArray];
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
- (void)formatKTVData:(NSArray*)dataArray{
    
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
    
    if (!isLoadMoreAll) {
        [_mArray removeAllObjects];
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
    
    if ([_mArray count]<=0 || _mArray==nil) {
        _refreshTailerView.hidden = YES;
    }else{
        _refreshTailerView.hidden = NO;
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self reloadPullRefreshData];
    });
}

#pragma mark -
#pragma mark 刷新和加载更多
- (void)loadMoreData{
    
    isLoadMoreAll = YES;
    [self setTableViewDelegate];
    
    
    [self updateData:0 withData:[self getCacheData]];
}

- (void)loadNewData{
    
    isLoadMoreAll = NO;
    [_mCacheArray removeAllObjects];
    
    [self updateData:0 withData:[self getCacheData]];
}

- (void)reloadPullRefreshData{
    
    [self setTableViewDelegate];
    if (isLoadMoreAll) {
        [_allListDelegate doneLoadingTableViewData];
    }else{
        [_allListDelegate doneReLoadingTableViewData];
    }
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
        
        if (!isLoadMoreAll) {
            number = 0;
        }
        NSString *dataType = [NSString stringWithFormat:@"%d",API_KKTVCmd];
        self.apiCmdKTV_getAllKTVs = (ApiCmdKTV_getAllKTVs *)[[DataBaseManager sharedInstance] getKTVsListFromWeb:self
                                                                                                          offset:number
                                                                                                           limit:DataLimit
                                                                                                        dataType:dataType
                                                                                                       isNewData:!isLoadMoreAll];
        return  nil;
    }
    
    ABLoggerInfo(@"_cacheArray count == %d",[_mCacheArray count]);
    int count = 10; //取10条数据
    if ([_mCacheArray count]<10) {
        count = [_mCacheArray count];//取小于10条数据
    }
    
    for (int i=0;i<[_mCacheArray count] ;i++ ) {
        KKTV *ttktv = [_mCacheArray objectAtIndex:i];
        ABLoggerInfo(@"1111_cacheArray count == %d",[_mCacheArray count]);
        ABLoggerDebug(@"2222  coredata district id === %d",[ttktv.districtid intValue]);
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
        ABLoggerInfo(@"111district id ===== %d",[object.districtid intValue]);
    }
    
    for (int i = 0;i<[_mCacheArray count];i++) {
        KKTV *object = [_mCacheArray objectAtIndex:i];
        ABLoggerInfo(@"222 ============== district id ===== %d",[object.districtid intValue]);
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

