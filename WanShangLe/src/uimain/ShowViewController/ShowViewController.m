//
//  ShowViewController.m
//  WanShangLe
//
//  Created by stephenliu on 13-6-5.
//  Copyright (c) 2013年 stephenliu. All rights reserved.
//

#import "ShowViewController.h"
#import "ApiCmdShow_getAllShows.h"
#import "ShowTableViewDelegate.h"
#import "EGORefreshTableHeaderView.h"
#import "ASIHTTPRequest.h"

@interface ShowViewController ()<ApiNotify>{
    BOOL isLoadMoreAll;
}
@property(nonatomic,retain) ShowTableViewDelegate *showTableViewDelegate;
@property(nonatomic,retain) UIControl *maskView;

@end

@implementation ShowViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
        self.title = @"演出";
    }
    return self;
}

- (void)dealloc{
    
    [self cleanApiCmd];
    
    self.typeButton = nil;
    self.timeButton = nil;
    self.orderButton = nil;
    
    self.typeView = nil;
    self.timeView = nil;
    self.orderView = nil;
    self.apiCmdShow_getAllShows = nil;
    self.maskView = nil;
    
    _refreshHeaderView.delegate = nil;
    _refreshTailerView.delegate = nil;
    [_refreshHeaderView removeFromSuperview];
    [_refreshTailerView removeFromSuperview];
    self.refreshHeaderView = nil;
    self.refreshTailerView = nil;
    
    self.showTableViewDelegate = nil;
    _mTableView.delegate = nil;
    _mTableView.dataSource = nil;
    self.mTableView = nil;
    self.mArray = nil;
    self.mCacheArray = nil;
    
    [super dealloc];
}

- (void)cleanApiCmd{
    [_apiCmdShow_getAllShows.httpRequest clearDelegatesAndCancel];
    _apiCmdShow_getAllShows.delegate = nil;
    [[[ApiClient defaultClient] requestArray] removeObject:_apiCmdShow_getAllShows];
    self.apiCmdShow_getAllShows = nil;
}

#pragma mark -
#pragma mark UIView Cycle
- (void)viewWillAppear:(BOOL)animated{
    
    if (_selectedOrder==API_SShow_Oreder_Distance_Cmd) {
        if([self checkGPS] && (_mArray==nil || [_mArray count]<=0))
            [self loadNewData];//初始化加载
    }
}

- (void)viewWillDisappear:(BOOL)animated{
    
    //保存用户的选项
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    NSString *selectedTypeData = [NSString stringWithFormat:@"%d#%d#%d",_selectedType,_selectedTime,_selectedOrder];
    [userDefault setObject:selectedTypeData forKey:SShow_FilterType];
    [userDefault synchronize];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self initUIBarItem];
    [self initData];
    [self initRefreshHeaderView];
    [self setTableViewDelegate];
    
    [self loadMoreData];
}

#pragma mark -
#pragma mark 初始化数据
- (void)initUIBarItem{
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [backButton setFrame:CGRectMake(0, 0, 45, 30)];
    [backButton addTarget:self action:@selector(clickBackButton:) forControlEvents:UIControlEventTouchUpInside];
    [backButton setBackgroundImage:[UIImage imageNamed:@"bt_back_n@2x"] forState:UIControlStateNormal];
    [backButton setBackgroundImage:[UIImage imageNamed:@"bt_back_f@2x"] forState:UIControlStateHighlighted];
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    self.navigationItem.leftBarButtonItem = backItem;
    [backItem release];
    
}

- (void)initData{
    if (_mArray==nil) {
        _mArray = [[NSMutableArray alloc] initWithCapacity:10];
    }
    if (_mCacheArray==nil) {
        _mCacheArray = [[NSMutableArray alloc] initWithCapacity:10];
    }
    
    _maskView = [[UIControl alloc] initWithFrame:CGRectMake(0, 40, self.view.frame.size.width, self.view.frame.size.height)];
    [_maskView setBackgroundColor:[UIColor colorWithWhite:0.000 alpha:0.680]];
    [_maskView addTarget:self action:@selector(clickMarkView:) forControlEvents:UIControlEventTouchUpInside];
    
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    NSString *selectedTypeData = [userDefault objectForKey:SShow_FilterType];
    if (!isEmpty(selectedTypeData)) {
        NSArray *typeArray = [selectedTypeData componentsSeparatedByString:@"#"];
        for (int i=0;i<[typeArray count];i++) {
            int index = [[typeArray objectAtIndex:i] intValue];
            switch (i) {
                case 0:
                    [(UIButton *)[_typeBts objectAtIndex:index] setSelected:YES];
                    _selectedType = index;
                    _oldSelectedType = index;
                    break;
                case 1:
                    [(UIButton *)[_timeBts objectAtIndex:index] setSelected:YES];
                    _selectedTime = index;
                    _oldSelectedTime = index;
                    break;
                default:
                    [(UIButton *)[_orderBts objectAtIndex:index] setSelected:YES];
                    _selectedOrder = index;
                    _oldSelectedOrder = index;
                    break;
            }
        }
    }else{
        [(UIButton *)[_typeBts objectAtIndex:0] setSelected:YES];
        [(UIButton *)[_timeBts objectAtIndex:0] setSelected:YES];
        [(UIButton *)[_orderBts objectAtIndex:0] setSelected:YES];
    }
    
    [_mTableView setTableFooterView:[[[UIView alloc] initWithFrame:CGRectZero]autorelease]];
}

- (void)setTableViewDelegate{
    if (_showTableViewDelegate==nil) {
        _showTableViewDelegate = [[ShowTableViewDelegate alloc] init];
    }
    _mTableView.dataSource = _showTableViewDelegate;
    _mTableView.delegate = _showTableViewDelegate;
    _showTableViewDelegate.parentViewController = self;
    _showTableViewDelegate.mTableView = self.mTableView;
    _showTableViewDelegate.mArray = self.mArray;
    _showTableViewDelegate.refreshHeaderView = self.refreshHeaderView;
    _showTableViewDelegate.refreshTailerView = self.refreshTailerView;
}

- (void)initRefreshHeaderView{
    if (_refreshHeaderView == nil) {
        
        [self setTableViewDelegate];
        
        EGORefreshTableHeaderView *view = [[EGORefreshTableHeaderView alloc] initWithFrame: CGRectMake(0.0f, _mTableView.contentSize.height, _mTableView.frame.size.width, _mTableView.bounds.size.height)];
		view.delegate = _showTableViewDelegate;
        view.tag = EGOBottomView;
        view.backgroundColor = [UIColor clearColor];
		[_mTableView addSubview:view];
		self.refreshTailerView = view;
		[view release];
        view=nil;
        
        view = [[EGORefreshTableHeaderView alloc] initWithFrame: CGRectMake(0.0f, - _mTableView.bounds.size.height, _mTableView.frame.size.width, _mTableView.bounds.size.height)];
        view.delegate = _showTableViewDelegate;
        view.tag = EGOHeaderView;
        view.backgroundColor = [UIColor clearColor];
        [_mTableView addSubview:view];
        self.refreshHeaderView = view;
        [view release];
        view=nil;
    }
    
    [_refreshHeaderView refreshLastUpdatedDate];
    _showTableViewDelegate.mTableView = self.mTableView;
    _showTableViewDelegate.refreshHeaderView = self.refreshHeaderView;
    _showTableViewDelegate.refreshTailerView = self.refreshTailerView;
}

#pragma mark -
#pragma mark UIButton event

- (void)clickBackButton:(id)sender{
    
    [self.navigationController popViewControllerAnimated:YES];
}

//点击类型按钮
- (IBAction)clickTypeButton:(id)sender{
    
    if (_filterShowListType == NSFilterShowListTypeData) {
        return;
    }
    
    _filterShowListType = NSFilterShowListTypeData;
    
    [self cleanUpPanelView];
    
    _typeButton.selected = YES;
    [_typeView setAlpha:0];
    
    [self.view addSubview:_typeView];
    
    CGRect newFrame = _typeView.frame;
    newFrame.origin = CGPointMake(_typeButton.frame.origin.x, _typeButton.frame.origin.y);
    _typeView.frame = newFrame;
    
    [UIView animateWithDuration:0.2 animations:^{
        [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
        [_typeView setAlpha:1];
        CGRect newFrame = _typeView.frame;
        newFrame.origin = CGPointMake(_typeButton.frame.origin.x, _typeButton.frame.origin.y+_typeButton.frame.size.height);
        _typeView.frame = newFrame;
        _typeArrowImg.transform = CGAffineTransformMakeRotation(DEGREES_TO_RADIANS(180));
    } completion:^(BOOL finished) {
        
    }];
}

//点击时间按钮
- (IBAction)clickTimeButton:(id)sender{
    
    if (_filterShowListType == NSFilterShowListTimeData) {
        return;
    }
    
    _filterShowListType = NSFilterShowListTimeData;
    
    [self cleanUpPanelView];
    [_timeView setAlpha:0];
    _timeButton.selected = YES;
    
    [self.view addSubview:_timeView];
    
    CGRect newFrame = _timeView.frame;
    newFrame.origin = CGPointMake(_timeButton.frame.origin.x - (_timeView.frame.size.width-_timeButton.frame.size.width)/2,
                                  _timeButton.frame.origin.y);
    _timeView.frame = newFrame;
    
    [UIView animateWithDuration:0.2 animations:^{
        [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
        [_timeView setAlpha:1];
        CGRect newFrame = _timeView.frame;
        newFrame.origin = CGPointMake(_timeButton.frame.origin.x - (_timeView.frame.size.width-_timeButton.frame.size.width)/2,
                                      _timeButton.frame.origin.y+_timeButton.frame.size.height);
        _timeView.frame = newFrame;
        _timeArrowImg.transform = CGAffineTransformMakeRotation(DEGREES_TO_RADIANS(180));
    } completion:^(BOOL finished) {
        
    }];
}

//点击顺序按钮
- (IBAction)clickOrderButton:(id)sender{
    
    if (_filterShowListType == NSFilterShowListOrderData) {
        return;
    }
    
    _filterShowListType = NSFilterShowListOrderData;
    
    [self cleanUpPanelView];
    [_orderView setAlpha:0];
    _orderButton.selected = YES;
    
    [self.view addSubview:_orderView];
    
    CGRect newFrame = _orderView.frame;
    newFrame.origin = CGPointMake(_orderButton.frame.origin.x - (_orderView.frame.size.width-_orderButton.frame.size.width),
                                  _orderButton.frame.origin.y);
    _orderView.frame = newFrame;
    
    [UIView animateWithDuration:0.2 animations:^{
        [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
        [_orderView setAlpha:1];
        CGRect newFrame = _orderView.frame;
        newFrame.origin = CGPointMake(_orderButton.frame.origin.x - (_orderView.frame.size.width-_orderButton.frame.size.width),
                                      _orderButton.frame.origin.y+_orderButton.frame.size.height);
        _orderView.frame = newFrame;
        _orderArrowImg.transform = CGAffineTransformMakeRotation(DEGREES_TO_RADIANS(180));
    } completion:^(BOOL finished) {
        
    }];
}

#pragma mark 重置状态
- (void)cleanUpPanelView{
    [_timeView removeFromSuperview];
    [_orderView removeFromSuperview];
    [_typeView removeFromSuperview];
    
    _timeButton.selected = NO;
    _orderButton.selected = NO;
    _typeButton.selected = NO;
    
    [self.view addSubview:_maskView];
    
    _typeArrowImg.transform = CGAffineTransformIdentity;
    _timeArrowImg.transform = CGAffineTransformIdentity;
    _orderArrowImg.transform = CGAffineTransformIdentity;
}

- (IBAction)clickMarkView:(id)sender{
    [self cleanUpPanelView];
    _filterShowListType = NSFilterShowListNoneData;
    [_maskView removeFromSuperview];
    
    if (_oldSelectedOrder != _selectedOrder ||
        _oldSelectedTime != _selectedTime ||
        _oldSelectedType != _selectedType) {
        
        _oldSelectedOrder = _selectedOrder;
        _oldSelectedTime = _selectedTime;
        _oldSelectedType = _selectedType;
        
        [_mCacheArray removeAllObjects];
        [_mArray removeAllObjects];
        [self loadMoreData];
        
        [_mTableView setContentOffset:CGPointMake(0, 0) animated:NO];
    }
}

#pragma mark 筛选子按钮 Event
- (IBAction)clickTypeSubButtonDown:(id)sender{
    UIButton *bt = (UIButton *)sender;
    int tag = [bt tag];
    
    [self cleanUpTypeSubButton];
     bt.selected = YES;
    [bt setTitleColor:[UIColor colorWithRed:0.230 green:0.705 blue:1.000 alpha:1.000] forState:UIControlStateNormal];
    
    _oldSelectedType = _selectedType;
    _selectedType = tag-1;
}

- (void)cleanUpTypeSubButton{
    for (UIButton *bt in _typeBts) {
        bt.selected = NO;
        [bt setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    }
}

- (IBAction)clickTimeSubButtonDown:(id)sender{
    UIButton *bt = (UIButton *)sender;
    int tag = [bt tag];
    
    [self cleanUpTimeSubButton];
     bt.selected = YES;
    [bt setTitleColor:[UIColor colorWithRed:0.230 green:0.705 blue:1.000 alpha:1.000] forState:UIControlStateNormal];
    
    _oldSelectedTime = _selectedTime;
    _selectedTime = tag-1;
}

- (void)cleanUpTimeSubButton{
    for (UIButton *bt in _timeBts) {
        bt.selected = NO;
        [bt setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    }
}

- (IBAction)clickOrderSubButtonDown:(id)sender{
    UIButton *bt = (UIButton *)sender;
    int tag = [bt tag];
    
    [self cleanUpOrderSubButton];
    bt.selected = YES;
    [bt setTitleColor:[UIColor colorWithRed:0.230 green:0.705 blue:1.000 alpha:1.000] forState:UIControlStateNormal];
    
    _oldSelectedOrder = _selectedOrder;
    _selectedOrder = tag-1;
}

- (void)cleanUpOrderSubButton{
    for (UIButton *bt in _orderBts) {
        bt.selected = NO;
        [bt setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    }
}
#pragma mark -
#pragma mark apiNotiry
-(void)apiNotifyResult:(id)apiCmd error:(NSError *)error{
    
    if (error!=nil) {
        [self reloadPullRefreshData];
        return;
    }
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSArray *dataArray = [[DataBaseManager sharedInstance] insertShowsIntoCoreDataFromObject:[apiCmd responseJSONObject] withApiCmd:apiCmd];
        
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
        [self updateData:0 withData:[self getCacheData]];
    });
}

- (ApiCmd *)apiGetDelegateApiCmd{
    return _apiCmdShow_getAllShows;
}

- (void)updateData:(int)tag withData:(NSArray*)dataArray
{
    if (dataArray==nil || [dataArray count]<=0) {
        return;
    }

    [self formatKTVData:dataArray];

}

#pragma mark -
#pragma mark FormateData
- (void)formatKTVData:(NSArray*)dataArray{
    
    [self formatKTVDataFilterAll:dataArray];
}

#pragma mark -
#pragma mark FilterCinema FormatData
- (void)formatKTVDataFilterAll:(NSArray*)pageArray{
    
    ABLoggerDebug(@"演出 人气 count ==== %d",[pageArray count]);
    [_mArray addObjectsFromArray:pageArray];
    
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
    
    if (_selectedOrder==API_SShow_Oreder_Distance_Cmd) {
        if(![self checkGPS]){
            return;
        }
    }
    
    [self updateData:0 withData:[self getCacheData]];
}

- (void)loadNewData{
    
    isLoadMoreAll = NO;
    [_mCacheArray removeAllObjects];
    [_mArray removeAllObjects];
    
    if (_selectedOrder==API_SShow_Oreder_Distance_Cmd) {
        if(![self checkGPS]){
            return;
        }
    }
    
    [self updateData:0 withData:[self getCacheData]];
}

- (BOOL)checkGPS{

    BOOL b = [[LocationManager defaultLocationManager] checkGPSEnable];
    [self displayNOGPS:!b];
    return b;
}

- (void)displayNOGPS:(BOOL)noGPS{
    
    _mTableView.tableFooterView = noGPS?_noGPSView:[[[UIView alloc] initWithFrame:CGRectZero]autorelease];
    _refreshHeaderView.hidden = noGPS;
    _refreshTailerView.hidden = noGPS;
    
    if (noGPS) {//没有GPS
        [_mCacheArray removeAllObjects];
        [_mArray removeAllObjects];
        [self reloadPullRefreshData];
    }
}

- (void)reloadPullRefreshData{
    
    [self setTableViewDelegate];
    if (isLoadMoreAll) {
        [_showTableViewDelegate doneLoadingTableViewData];
    }else{
        [_showTableViewDelegate doneReLoadingTableViewData];
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
        
        int number = (_mArray==nil)?0:[_mArray count];
        ABLoggerDebug(@"演出 数组 number ==  %d",number);
        
        
        if (_selectedOrder==API_SShow_Oreder_Distance_Cmd) {//4代表的是距离筛选
            LocationManager *lm = [LocationManager defaultLocationManager];
            double latitude = lm.userLocation.coordinate.latitude;
            double longitude = lm.userLocation.coordinate.longitude;
            
            if (!isLoadMoreAll || lm.userLocation==nil ||
                latitude==0.0f || longitude==0.0f) {//重新更新附近演出列表
                number = 0;
                [lm getUserGPSLocationWithCallBack:^(BOOL isEnableGPS,BOOL isSuccess) {
                    if (isSuccess) {
                        
                        [self cleanApiCmd];
                        
                        NSString *selectedTypeData = [NSString stringWithFormat:@"%d#%d#%d",_selectedType,_selectedTime,_selectedOrder];
                        self.apiCmdShow_getAllShows = (ApiCmdShow_getAllShows *)[[DataBaseManager sharedInstance]
                                                                                 getShowsListFromWeb:self
                                                                                 offset:number
                                                                                 limit:DataLimit
                                                                                 Latitude:latitude
                                                                                 longitude:longitude
                                                                                 dataType:selectedTypeData
                                                                                 isNewData:!isLoadMoreAll];
                    }else{
                        [self displayNOGPS:YES];
                    }
                }];
                
            }else{//加载更多KTV附近
                NSString *selectedTypeData = [NSString stringWithFormat:@"%d#%d#%d",_selectedType,_selectedTime,_selectedOrder];
                self.apiCmdShow_getAllShows = (ApiCmdShow_getAllShows *)[[DataBaseManager sharedInstance]
                                                                         getShowsListFromWeb:self
                                                                         offset:number
                                                                         limit:DataLimit
                                                                         Latitude:latitude
                                                                         longitude:longitude
                                                                         dataType:selectedTypeData
                                                                         isNewData:!isLoadMoreAll];
            }
        }else{
            if ([_mCacheArray count]<=0) {
                int number = [_mArray count];
                ABLoggerDebug(@"演出 数组 number ==  %d",number);
                
                if (!isLoadMoreAll) {
                    number = 0;
                    [self cleanApiCmd];
                }
                NSString *selectedTypeData = [NSString stringWithFormat:@"%d#%d#%d",_selectedType,_selectedTime,_selectedOrder];
                self.apiCmdShow_getAllShows = (ApiCmdShow_getAllShows *)[[DataBaseManager sharedInstance]
                                                                         getShowsListFromWeb:self
                                                                         offset:number
                                                                         limit:DataLimit
                                                                         Latitude:-1
                                                                         longitude:-1
                                                                         dataType:selectedTypeData
                                                                         isNewData:!isLoadMoreAll];
                return  nil;
            }
        }
        
        return  nil;
    }
    
    
    ABLoggerInfo(@"_cacheArray count == %d",[_mCacheArray count]);
    int count = 10; //取10条数据
    if ([_mCacheArray count]<10) {
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

- (void)didReceiveMemoryWarning
{
    ABLoggerWarn(@"接收到内存警告了");
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
