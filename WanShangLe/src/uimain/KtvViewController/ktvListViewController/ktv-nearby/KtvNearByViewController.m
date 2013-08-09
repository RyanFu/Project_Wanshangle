//
//  CinemaViewController.m
//  WanShangLe
//
//  Created by stephenliu on 13-6-8.
//  Copyright (c) 2013年 stephenliu. All rights reserved.
//

#import "KtvNearByViewController.h"
#import "ApiCmdKTV_getAllKTVs.h"
#import "EGORefreshTableHeaderView.h"
#import "ASIHTTPRequest.h"
#import "KKTV.h"
#import "ApiCmd.h"
#import "KTVNearByListTableViewDelegate.h"

@interface KtvNearByViewController()<ApiNotify>{
    BOOL isLoadMore;
}
@property(nonatomic,retain)KTVNearByListTableViewDelegate *nearByListDelegate;
@end

@implementation KtvNearByViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
    }
    return self;
}

- (void)dealloc{
    
    [_apiCmdKTV_getAllKTVs.httpRequest clearDelegatesAndCancel];
    _apiCmdKTV_getAllKTVs.delegate = nil;
    [[[ApiClient defaultClient] requestArray] removeObject:_apiCmdKTV_getAllKTVs];
    self.apiCmdKTV_getAllKTVs = nil;
    
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
    for (int i=0; i<DataCount; i++) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            self.apiCmdKTV_getAllKTVs = (ApiCmdKTV_getAllKTVs *)[[DataBaseManager sharedInstance] getAllKTVsListFromWeb:self];
        });
    }
}

- (void)viewDidLoad
{
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
    tbView.backgroundColor = [UIColor whiteColor];
    tbView.separatorStyle = UITableViewCellSeparatorStyleNone;
    tbView.tableFooterView = [[[UIView alloc] initWithFrame:CGRectZero] autorelease];
    return [tbView autorelease];
}

#pragma mark 设置 TableView Delegate
- (void)setTableViewDelegate{
    if (_nearByListDelegate==nil) {
        _nearByListDelegate = [[KTVNearByListTableViewDelegate alloc] init];
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
        
        NSMutableArray *dataArray = [[DataBaseManager sharedInstance] insertTemporaryKTVsIntoCoreDataFromObject:[apiCmd responseJSONObject] withApiCmd:apiCmd];
         NSMutableArray *removieArray = [NSMutableArray arrayWithCapacity:10];
        for (KKTV *tKTV in dataArray) {
            CLLocationDegrees latitude = [tKTV.latitude doubleValue];
            CLLocationDegrees longitude = [tKTV.longitude doubleValue];
            double distance = [[LocationManager defaultLocationManager] distanceBetweenUserToLatitude:latitude longitude:longitude];
            if (distance<0) {
                [removieArray addObject:tKTV];
                _isLoadDone = YES;
                _refreshNearByTailerView.hidden = YES;
            }else{
                tKTV.distance = [NSNumber numberWithDouble:distance];
            }

        }
        [dataArray removeObjectsInArray:removieArray];
        
//        dataArray = [dataArray sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
//            double first =  [[(KKTV*)a distance] doubleValue];
//            double second = [[(KKTV*)b distance] doubleValue];
//            
//            if (first>second) {
//                return NSOrderedDescending;
//            }else if(first<second){
//                return NSOrderedAscending;
//            }else{
//                return NSOrderedSame;
//            }
//        }];
        
        ABLoggerDebug(@"距离 排序 测试");
        for (KKTV *tKTV in dataArray) {
            ABLoggerDebug(@"距离 === %d",[[tKTV distance] intValue]);
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
        [self updateData:API_KKTVNearByCmd withData:[self getCacheData]];
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
        case API_KKTVNearByCmd:
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
    ABLoggerWarn(@" 附近 影院");
    
    ABLoggerInfo(@"附近 KTV count=== %d",[dataArray count]);
    
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
        ABLoggerDebug(@"ktv 数组 number ==  %d",number);
        
        LocationManager *lm = [LocationManager defaultLocationManager];
        double latitude = lm.userLocation.coordinate.latitude;
        double longitude = lm.userLocation.coordinate.longitude;
        NSString *dataType = [NSString stringWithFormat:@"%d",API_KKTVNearByCmd];
        
        if (!isLoadMore || lm.userLocation==nil ||
            latitude==0.0f || longitude==0.0f) {//重新更新附近KTV列表
            number = 0;
            [lm getUserGPSLocationWithCallBack:^(BOOL isEnableGPS,BOOL isSuccess) {
                if (isSuccess) {
                    self.apiCmdKTV_getAllKTVs = (ApiCmdKTV_getAllKTVs *)[[DataBaseManager sharedInstance]
                                                                         getNearbyKTVListFromCoreDataWithCallBack:self
                                                                         Latitude:latitude
                                                                         longitude:longitude
                                                                         offset:number
                                                                         limit:DataLimit
                                                                         dataType:dataType
                                                                         isNewData:YES];
                }else{
                    [self displayNOGPS:YES];
                }
            }];
            
        }else{//加载更多KTV附近
            self.apiCmdKTV_getAllKTVs = (ApiCmdKTV_getAllKTVs *)[[DataBaseManager sharedInstance]
                                                                 getNearbyKTVListFromCoreDataWithCallBack:self
                                                                 Latitude:latitude
                                                                 longitude:longitude
                                                                 offset:number
                                                                 limit:DataLimit
                                                                 dataType:dataType
                                                                 isNewData:NO];
        }
        
        return  nil;
    }
    
    ABLoggerInfo(@"_cacheArray count == %d",[_mCacheArray count]);
    int count = DataCount; //取DataCount条数据
    if ([_mCacheArray count]<DataCount) {
        count = [_mCacheArray count];//取小于DataCount条数据
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
