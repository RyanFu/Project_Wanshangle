//
//  CinemaViewController.m
//  WanShangLe
//
//  Created by stephenliu on 13-6-8.
//  Copyright (c) 2013年 stephenliu. All rights reserved.
//

#import "BarNearByViewController.h"
#import "ApiCmdBar_getAllBars.h"
#import "EGORefreshTableHeaderView.h"
#import "ASIHTTPRequest.h"
#import "BBar.h"
#import "ApiCmd.h"
#import "BarViewController.h"
#import "BarNearByListTableViewDelegate.h"

@interface BarNearByViewController()<ApiNotify>{
    BOOL isLoadMore;
}
@property(nonatomic,retain)BarNearByListTableViewDelegate *nearByListDelegate;
@end

@implementation BarNearByViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _isLoadDone = NO;
    }
    return self;
}

- (void)dealloc{
    
    [_apiCmdBar_getAllBars.httpRequest clearDelegatesAndCancel];
    _apiCmdBar_getAllBars.delegate = nil;
    [[[ApiClient defaultClient] requestArray] removeObject:_apiCmdBar_getAllBars];
    self.apiCmdBar_getAllBars = nil;
    
    self.refreshNearByHeaderView = nil;
    self.refreshNearByTailerView = nil;
    
    self.nearByListDelegate = nil;
    
    self.mTableView = nil;
    self.mArray = nil;
    self.mCacheArray = nil;
    
    [super dealloc];
}

#pragma mark -
#pragma mark UIView cycle
- (void)viewWillAppear:(BOOL)animated{
    
    if ([self checkGPS]) {
        if (_mArray==nil || [_mArray count]<=0) {
            [self loadNewData];//初始化加载
        }
    }
}

- (void)updatData{
    for (int i=0; i<10; i++) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            //            self.apiCmdKTV_getAllKTVs = (ApiCmdKTV_getAllKTVs *)[[DataBaseManager sharedInstance] getAllKTVsListFromWeb:self];
        });
    }
}

- (void)viewDidLoad
{
    [self.view setBackgroundColor:Color4];
    [super viewDidLoad];
    [self.view addSubview:self.mTableView];
    
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
    
    [self initNearByRefreshHeaderView];
    
    if (_mArray==nil) {
        _mArray = [[NSMutableArray alloc] initWithCapacity:DataCount];
    }
    if (_mCacheArray==nil) {
        _mCacheArray = [[NSMutableArray alloc] initWithCapacity:DataCount];
    }
}

- (UITableView *)createTableView{
    UITableView *tbView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height) style:UITableViewStylePlain];
    tbView.backgroundColor = Color4;
    tbView.separatorStyle = UITableViewCellSeparatorStyleNone;
    tbView.tableFooterView = [[[UIView alloc] initWithFrame:CGRectZero] autorelease];
    return [tbView autorelease];
}

#pragma mark 设置 TableView Delegate
- (void)setTableViewDelegate{
    if (_nearByListDelegate==nil) {
        _nearByListDelegate = [[BarNearByListTableViewDelegate alloc] init];
    }
    _nearByListDelegate.parentViewController = self;
    _mTableView.dataSource = _nearByListDelegate;
    _mTableView.delegate = _nearByListDelegate;
    _nearByListDelegate.mTableView = _mTableView;
    _nearByListDelegate.mArray = _mArray;
    _nearByListDelegate.refreshHeaderView = self.refreshNearByHeaderView;
    _nearByListDelegate.refreshTailerView = self.refreshNearByTailerView;
}

#pragma mark -
#pragma mark PullRefresh

- (void)initNearByRefreshHeaderView{
    
    [self setTableViewDelegate];
    
    if (_refreshNearByHeaderView == nil) {
        EGORefreshTableHeaderView *view = [[EGORefreshTableHeaderView alloc] initWithFrame: CGRectMake(0.0f, _mTableView.bounds.size.height, _mTableView.frame.size.width, _mTableView.bounds.size.height)];
		view.delegate = self.nearByListDelegate;
        view.tag = EGOBottomView;
        view.backgroundColor = [UIColor clearColor];
		[_mTableView addSubview:view];
		self.refreshNearByTailerView = view;
		[view release];
        
        view = [[EGORefreshTableHeaderView alloc] initWithFrame: CGRectMake(0.0f, - _mTableView.bounds.size.height, _mTableView.frame.size.width, _mTableView.bounds.size.height)];
        view.delegate = self.nearByListDelegate;
        view.tag = EGOHeaderView;
        view.backgroundColor = [UIColor clearColor];
        [_mTableView addSubview:view];
        self.refreshNearByHeaderView = view;
        [view release];
    }
    _nearByListDelegate.refreshHeaderView = self.refreshNearByHeaderView;
    _nearByListDelegate.refreshTailerView = self.refreshNearByTailerView;
    [_refreshNearByHeaderView refreshLastUpdatedDate];
}

#pragma mark -
#pragma mark apiNotiry
-(void)apiNotifyResult:(id)apiCmd error:(NSError *)error{
    
    if (error!=nil) {
        [self reloadPullRefreshData];
        return;
    }
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
       NSMutableArray *dataArray  = [[DataBaseManager sharedInstance] insertBarsIntoCoreDataFromObject:[apiCmd responseJSONObject] withApiCmd:apiCmd];
        
        if (isNull(dataArray) || [dataArray count]==0) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self reloadPullRefreshData];
            });
            return ;
        }
        
        NSMutableArray *removieArray = [NSMutableArray arrayWithCapacity:10];
        for (BBar *tBar in dataArray) {
            CLLocationDegrees latitude = [tBar.latitude doubleValue];
            CLLocationDegrees longitude = [tBar.longitude doubleValue];
            double distance = [[LocationManager defaultLocationManager] distanceBetweenUserToLatitude:latitude longitude:longitude];
            if (distance<0) {
                [removieArray addObject:tBar];
                _isLoadDone = YES;
                _refreshNearByTailerView.hidden = YES;
            }else{
                tBar.distance = [NSNumber numberWithDouble:distance];
            }
        }
        
        [dataArray removeObjectsInArray:removieArray];
        
        //按照由近到远进行排序
        dataArray = (NSMutableArray *)[dataArray sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
            double first =  [[(MCinema*)a distance] doubleValue];
            double second = [[(MCinema*)b distance] doubleValue];
            
            if (first>second) {
                return NSOrderedDescending;
            }else if(first<second){
                return NSOrderedAscending;
            }else{
                return NSOrderedSame;
            }
        }];
        
        ABLoggerDebug(@"距离 排序 测试");
        for (MCinema *tcinema in dataArray) {
            ABLoggerDebug(@"距离 === %d",[[tcinema distance] intValue]);
        }
        
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
        [self updateData:API_BBarNearByCmd withData:[self getCacheData]];
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
        case API_BBarNearByCmd:
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
    
    [self formatKTVDataFilterNearby:dataArray];
}

- (void)formatKTVDataFilterNearby:(NSArray *)dataArray{
    ABLoggerWarn(@" 附近 酒吧");
    
    ABLoggerInfo(@"附近 酒吧 count=== %d",[dataArray count]);
    
    [self.mArray addObjectsFromArray:dataArray];
    
    BOOL isNoGPS = ((int)[_mArray count]<=0);
    [self displayNOGPS:isNoGPS];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self reloadPullRefreshData];
    });
}

#pragma mark -
#pragma mark 刷新和加载更多
- (void)loadMoreData{
    isLoadMore = YES;
    
    if (![self checkGPS]) {
        return;
    }
    
    if (_isLoadDone) {
        [self reloadPullRefreshData];
        return;
    }
    
    [self updateData:0 withData:[self getCacheData]];
}

- (void)loadNewData{
    ABLoggerMethod();
    isLoadMore = NO;
    _isLoadDone = NO;
    [_mCacheArray removeAllObjects];
    [_mArray removeAllObjects];
    
    if (![self checkGPS]) {
        return;
    }
    [self updateData:0 withData:[self getCacheData]];
}

- (BOOL)checkGPS{
    BOOL b = [[LocationManager defaultLocationManager] checkGPSEnable];
    if (!b) {
        [self displayNOGPS:YES];
    }
    
    return b;
}

- (void)displayNOGPS:(BOOL)noGPS{
    
    _mTableView.tableFooterView = noGPS?_noGPSView:[[[UIView alloc] initWithFrame:CGRectZero]autorelease];
    _refreshNearByTailerView.hidden = noGPS;
    _refreshNearByHeaderView.hidden = noGPS;
    
    if (noGPS) {//没有GPS
        [_mCacheArray removeAllObjects];
        [_mArray removeAllObjects];
        [self reloadPullRefreshData];
    }
}

- (void)reloadPullRefreshData{
    [self setTableViewDelegate];
    if (isLoadMore) {
        [_nearByListDelegate doneLoadingTableViewData];
    }else{
        
        [_nearByListDelegate doneReLoadingTableViewData];
    }
    
    _refreshNearByTailerView.frame = CGRectMake(0.0f, _mTableView.contentSize.height, _mTableView.frame.size.width, _mTableView.bounds.size.height);
}

//添加缓存数据
- (void)addDataIntoCacheData:(NSArray *)dataArray{
    
    [self.mCacheArray addObjectsFromArray:dataArray];
}

//获取缓存数据
- (NSArray *)getCacheData{
    
    if ([_mCacheArray count]<=0) {
        
        int number = (_mArray==nil)?0:[_mArray count];
        ABLoggerDebug(@"酒吧 数组 number ==  %d",number);
        
        LocationManager *lm = [LocationManager defaultLocationManager];
        double latitude = lm.userLocation.coordinate.latitude;
        double longitude = lm.userLocation.coordinate.longitude;
        
        if (!isLoadMore || lm.userLocation==nil ||
            latitude<=0.0f || longitude<=0.0f) {//重新更新附近KTV列表
            number = 0;
            [lm getUserGPSLocationWithCallBack:^(BOOL isEnableGPS,BOOL isSuccess) {
                if (isSuccess) {
                    
                    double latitude = lm.userLocation.coordinate.latitude;
                    double longitude = lm.userLocation.coordinate.longitude;
                    self.apiCmdBar_getAllBars = (ApiCmdBar_getAllBars *)[[DataBaseManager sharedInstance]
                                                                         getBarsNearByListFromWeb:self
                                                                         offset:number
                                                                         limit:DataLimit
                                                                         Latitude:latitude
                                                                         longitude:longitude
                                                                         dataType:OrderNearBy
                                                                         isNewData:!isLoadMore];
                }else{
                    [self displayNOGPS:YES];
                }
            }];
            
        }else{//加载更多KTV附近
            self.apiCmdBar_getAllBars = (ApiCmdBar_getAllBars *)[[DataBaseManager sharedInstance]
                                                                 getBarsNearByListFromWeb:self
                                                                 offset:number
                                                                 limit:DataLimit
                                                                 Latitude:latitude
                                                                 longitude:longitude
                                                                 dataType:OrderNearBy
                                                                 isNewData:!isLoadMore];
        }
        
        return  nil;
    }
    
    ABLoggerInfo(@"_cacheArray count == %d",[_mCacheArray count]);
    int count = DataCount; //取10条数据
    if ([_mCacheArray count]<DataCount) {
        count = [_mCacheArray count];//取小于10条数据
    }
    
    NSMutableArray *aPageData = [NSMutableArray arrayWithCapacity:count];
    for (int i=0; i<count; i++) {
        KKTV *object = [_mCacheArray objectAtIndex:i];
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
