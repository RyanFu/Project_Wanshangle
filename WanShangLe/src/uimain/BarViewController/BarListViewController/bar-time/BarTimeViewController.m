//
//  CinemaViewController.m
//  WanShangLe
//
//  Created by stephenliu on 13-6-8.
//  Copyright (c) 2013年 stephenliu. All rights reserved.
//

#import "BarTimeViewController.h"
#import "BarViewController.h"

#import "EGORefreshTableHeaderView.h"
#import "ApiCmdBar_getAllBars.h"
#import "BarTimeListTableViewDelegate.h"

#import "ASIHTTPRequest.h"
#import "ApiCmd.h"
#import "BBar.h"

#define MArray @"MArray"
#define CacheArray @"CacheArray"

@interface BarTimeViewController()<ApiNotify>{
    BOOL isLoadMoreAll;
}
@property(nonatomic,retain)BarTimeListTableViewDelegate *allListDelegate;
@end

@implementation BarTimeViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
        self.title = @"Bar";
    }
    return self;
}

- (void)dealloc{
    
    [_apiCmdBar_getAllBars.httpRequest clearDelegatesAndCancel];
    _apiCmdBar_getAllBars.delegate = nil;
    [[[ApiClient defaultClient] requestArray] removeObject:_apiCmdBar_getAllBars];
    self.apiCmdBar_getAllBars = nil;
    
    _refreshHeaderView.delegate = nil;
    _refreshTailerView.delegate = nil;
    [_refreshHeaderView removeFromSuperview];
    [_refreshTailerView removeFromSuperview];
    self.refreshHeaderView = nil;
    self.refreshTailerView = nil;
    
    self.allListDelegate = nil;
    self.mTableView = nil;
    self.mArray = nil;
    self.mCacheArray = nil;
    
    [super dealloc];
}

#pragma mark -
#pragma mark UIView cycle
- (void)viewWillAppear:(BOOL)animated{
    
#ifdef TestCode
    [self updatData];//测试代码
#endif
    
}
- (void)updatData{
    for (int i=0; i<10; i++) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            //            self.apiCmdBar_getAllBars = (ApiCmdKTV_getAllKTVs *)[[DataBaseManager sharedInstance] getAllKTVsListFromWeb:self];
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
    
    [self initRefreshHeaderView];
    
    if (_mArray==nil) {
        _mArray = [[NSMutableArray alloc] initWithCapacity:10];
        
        NSMutableDictionary *tDic = [[NSMutableDictionary alloc] initWithCapacity:2];
        [tDic setObject:[NSMutableArray arrayWithCapacity:1] forKey:ListKey];
        [tDic setObject:TodayKey forKey:@"name"];
        [_mArray addObject:tDic];
        [tDic release];
        
        tDic = [[NSMutableDictionary alloc] initWithCapacity:2];
        [tDic setObject:[NSMutableArray arrayWithCapacity:1] forKey:ListKey];
        [tDic setObject:TomorrowKey forKey:@"name"];
        [_mArray addObject:tDic];
        [tDic release];
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
        _allListDelegate = [[BarTimeListTableViewDelegate alloc] init];
    }
    _allListDelegate.parentViewController = self;
    _mTableView.dataSource = _allListDelegate;
    _mTableView.delegate = _allListDelegate;
    _allListDelegate.mTableView = _mTableView;
    _allListDelegate.mArray = _mArray;
}

#pragma mark -
#pragma mark PullRefresh
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

#pragma mark -
#pragma mark apiNotiry
-(void)apiNotifyResult:(id)apiCmd error:(NSError *)error{
    
    if (error!=nil) {
        [self reloadPullRefreshData];
        return;
    }
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSArray *dataArray = [[DataBaseManager sharedInstance] insertBarsIntoCoreDataFromObject:[apiCmd responseJSONObject] withApiCmd:apiCmd];
        
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
        [self updateData:API_BBarTimeCmd withData:[self getCacheData]];
    });
}

- (ApiCmd *)apiGetDelegateApiCmd{
    return _apiCmdBar_getAllBars;
}

- (void)updateData:(int)tag withData:(NSArray*)dataArray
{
    if (dataArray==nil || [dataArray count]<=0) {
        return;
    }
    
    ABLogger_int(tag);
    switch (tag) {
        case 0:
        case API_BBarTimeCmd:
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
    ABLoggerDebug(@"酒吧店 count ==== %d",[array_coreData count]);
    
    NSMutableArray *todayArray = [[_mArray objectAtIndex:0] objectForKey:ListKey];
    NSMutableArray *tomorrowArray = [[_mArray objectAtIndex:1] objectForKey:ListKey];
    
    for (BBar *tBar in array_coreData) {
        if ([[DataBaseManager sharedInstance] isToday:tBar.begintime]) {//今天
            [todayArray addObject:tBar];
        }else{
            [tomorrowArray addObject:tBar];
        }
    }
    
    _refreshTailerView.hidden = NO;
    if ([_mArray count]<=0 || _mArray==nil) {
        _refreshTailerView.hidden = YES;
        
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
    [[[_mArray objectAtIndex:0] objectForKey:ListKey] removeAllObjects];
    [[[_mArray objectAtIndex:1] objectForKey:ListKey] removeAllObjects];
    
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
        ABLoggerDebug(@"酒吧 数组 number ==  %d",number);
        
        if (!isLoadMoreAll) {
            number = 0;
        }
        self.apiCmdBar_getAllBars = (ApiCmdBar_getAllBars *)[[DataBaseManager sharedInstance] getBarsListFromWeb:self
                                                                                                          offset:number
                                                                                                           limit:DataLimit
                                                                                                        Latitude:-1
                                                                                                       longitude:-1
                                                                                                        dataType:OrderTime
                                                                                                       isNewData:!isLoadMoreAll];
        return  nil;
    }
    
    ABLoggerInfo(@"_cacheArray count == %d",[_mCacheArray count]);
    int count = 10; //取10条数据
    if ([_mCacheArray count]<10) {
        count = [_mCacheArray count];//取小于10条数据
    }
    
    NSMutableArray *aPageData = [NSMutableArray arrayWithCapacity:count];
    for (int i=0; i<count; i++) {
        BBar *object = [_mCacheArray objectAtIndex:i];
        [aPageData addObject:object];
    }
    
    if (count>0) {
        [_mCacheArray removeObjectsInRange:NSMakeRange(0, count)];
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

