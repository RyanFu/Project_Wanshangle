//
//  CinemaViewController.m
//  WanShangLe
//
//  Created by stephenliu on 13-6-8.
//  Copyright (c) 2013年 stephenliu. All rights reserved.
//

#import "ApiCmdMovie_getAllCinemas.h"
#import "CinemaManagerViewController.h"
#import "EGORefreshTableHeaderView.h"
#import "ASIHTTPRequest.h"
#import "MCinema.h"
#import "ApiCmd.h"
#import "JSButton.h"

#import "CinemaAllListManagerDelegate.h"

#define MArray @"MArray"
#define CacheArray @"CacheArray"

@interface CinemaManagerViewController()<ApiNotify>{
    UIButton *cityBtn;
}
@property(nonatomic,retain) UIView *cityPanel;
@property(nonatomic,retain) UIControl *cityPanelMask;
@property(nonatomic,retain) CinemaAllListManagerDelegate *tableViewDelegate;
@end

@implementation CinemaManagerViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
        self.title = @"管理常去影院";
    }
    return self;
}

- (void)dealloc{
    [self cancelApiCmd];
    
    _refreshTailerView.delegate = nil;
    [_refreshTailerView removeFromSuperview];
    self.refreshTailerView = nil;
    
    self.mArray = nil;
    self.mCacheArray = nil;
    self.msearchDisplayController = nil;
    self.tableViewDelegate = nil;
    self.searchBar = nil;
    
    self.cityPanel = nil;
    self.cityPanelMask = nil;
    
    [super dealloc];
}

- (void)cancelApiCmd{
    [_apiCmdMovie_getAllCinemas.httpRequest clearDelegatesAndCancel];
    _apiCmdMovie_getAllCinemas.delegate = nil;
    [[[ApiClient defaultClient] requestArray] removeObject:_apiCmdMovie_getAllCinemas];
    self.apiCmdMovie_getAllCinemas = nil;
}

#pragma mark -
#pragma mark UIView cycle
- (void)viewWillAppear:(BOOL)animated{
    [self hiddenRefreshTailerView];
}

- (void)viewWillDisappear:(BOOL)animated{
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self initBarButtonItem];
    [self initTableView];
    [self updateCityDisplayState];
    
    [self loadMoreData];
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
    
    cityBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [cityBtn setFrame:CGRectMake(0, 0, 45, 32)];
    [cityBtn addTarget:self action:@selector(clickCityButton:) forControlEvents:UIControlEventTouchUpInside];
    [cityBtn setBackgroundImage:[UIImage imageNamed:@"btn_Blue_BarButtonItem_n@2x"] forState:UIControlStateNormal];
    [cityBtn setBackgroundImage:[UIImage imageNamed:@"btn_Blue_BarButtonItem_f@2x"] forState:UIControlStateHighlighted];
    [cityBtn setTitle:@"" forState:UIControlStateNormal];
    [cityBtn setTintColor:[UIColor whiteColor]];
    UIBarButtonItem *cityBtnItem = [[UIBarButtonItem alloc] initWithCustomView:cityBtn];
    self.navigationItem.rightBarButtonItem = cityBtnItem;
    [cityBtnItem release];
}

- (void)updateCityDisplayState{
    NSString *cityName = [[LocationManager defaultLocationManager] getUserCity];
    [cityBtn setTitle:cityName forState:UIControlStateNormal];
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
        _mArray = [[NSMutableArray alloc] initWithCapacity:DataCount];
    }
    if (_mCacheArray==nil) {
        _mCacheArray = [[NSMutableArray alloc] initWithCapacity:DataCount];
    }
    if (_mFavoriteArray==nil) {
         _mFavoriteArray = [[NSMutableArray alloc] initWithCapacity:DataCount];
    }
}

- (UITableView *)createTableView{
    
    UITableView *tbView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, iPhoneAppFrame.size.height-navigationBarHeight) style:UITableViewStylePlain];
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
        self.searchBar.placeholder=@"输入影院名称搜索";
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
        self.msearchDisplayController = [[[UISearchDisplayController alloc] initWithSearchBar:self.searchBar contentsController:self] autorelease];
        self.msearchDisplayController.searchResultsDataSource = _tableViewDelegate;
        self.msearchDisplayController.searchResultsDelegate = _tableViewDelegate;
        self.msearchDisplayController.delegate = _tableViewDelegate;
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
        _tableViewDelegate = [[CinemaAllListManagerDelegate alloc] init];
        _tableViewDelegate.parentViewController = self;
    }
    _mTableView.dataSource = _tableViewDelegate;
    _mTableView.delegate = _tableViewDelegate;
    _tableViewDelegate.mArray = _mArray;
    _tableViewDelegate.mTableView = _mTableView;
    _tableViewDelegate.mFavoriteArray = _mFavoriteArray;
    _tableViewDelegate.msearchDisplayController = _msearchDisplayController;
}

- (void)hiddenRefreshTailerView{
    if (_mArray==nil || [_mArray count]<=0) {
        _refreshTailerView.hidden = YES;
    }else{
        _refreshTailerView.hidden = NO;
    }
}
#pragma mark-
#pragma mark UIButton Event
- (void)clickBackButton:(id)sender{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)clickCityButton:(id)sender{
    if (!self.cityPanel) {
        [self popupCityPanel];
    }else{
        [self stopAnimationCityPanel];
    }
}

- (void)popupCityPanel{
    
    _cityPanelMask = [[UIControl alloc] initWithFrame:self.view.bounds];
    _cityPanelMask.backgroundColor = [UIColor colorWithWhite:0.000 alpha:0.650];
    [_cityPanelMask addTarget:self action:@selector(dismissCityPanel) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_cityPanelMask];
    [_cityPanelMask release];
    
    self.cityPanel = [[[UIView alloc] initWithFrame:CGRectMake(0, -120, 320, 119)] autorelease];
    
    
    UIImageView *bgImg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bg_city_panel@2x"]];
    bgImg.frame = CGRectMake(0, 0, 320, 119);
    [self.cityPanel addSubview:bgImg];
    [bgImg release];
    
    JSButton *bt1 = [[JSButton alloc] initWithFrame:CGRectMake(5,30,70,35)];
    [bt1 setTitle:@"北京" forState:UIControlStateNormal];
    [bt1 setTag:1];
    [bt1 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [_cityPanel addSubview:bt1];
    
    [bt1 performBlock:^(JSButton *sender) {
        [[LocationManager defaultLocationManager] setUserCity:@"北京市" CallBack:^{
            [self setSelectedButton:bt1];
        }];
        [cityBtn setTitle:@"北京" forState:UIControlStateNormal];
        ABLoggerInfo(@"手动选择城市 北京");
    } forEvents:UIControlEventTouchUpInside];
    
    JSButton *bt2 = [[JSButton alloc] initWithFrame:CGRectMake(85,30,70,35)];
    [bt2 setTitle:@"上海" forState:UIControlStateNormal];
    [bt2 setTag:2];
    [bt2 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [_cityPanel addSubview:bt2];
    [bt2 performBlock:^(JSButton *sender) {
        [[LocationManager defaultLocationManager] setUserCity:@"上海市" CallBack:^{
            [self setSelectedButton:bt2];
        }];
        [cityBtn setTitle:@"上海" forState:UIControlStateNormal];
        ABLoggerInfo(@"手动选择城市 上海");
    } forEvents:UIControlEventTouchUpInside];
    
    JSButton *bt3 = [[JSButton alloc] initWithFrame:CGRectMake(165,30,70,35)];
    [bt3 setTitle:@"广州" forState:UIControlStateNormal];
    [bt3 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [_cityPanel addSubview:bt3];
    [bt3 setTag:3];
    [bt3 performBlock:^(JSButton *sender) {
        [[LocationManager defaultLocationManager] setUserCity:@"广州市" CallBack:^{
            [self setSelectedButton:bt3];
        }];
        [cityBtn setTitle:@"广州" forState:UIControlStateNormal];
        ABLoggerInfo(@"手动选择城市 广州");
    } forEvents:UIControlEventTouchUpInside];
    
    
    JSButton *bt4 = [[JSButton alloc] initWithFrame:CGRectMake(245,30,70,35)];
    [bt4 setTitle:@"深圳" forState:UIControlStateNormal];
    [bt4 setTag:4];
    [bt4 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [_cityPanel addSubview:bt4];
    
    [bt4 performBlock:^(JSButton *sender) {
        [[LocationManager defaultLocationManager] setUserCity:@"深圳市" CallBack:^{
            [self setSelectedButton:bt4];
        }];
        [cityBtn setTitle:@"深圳" forState:UIControlStateNormal];
        ABLoggerInfo(@"手动选择城市 深圳");
    } forEvents:UIControlEventTouchUpInside];
    
    [self cleanCityButtonStateWithPanel:_cityPanel];
    [self selectedCityButtonInPanel:_cityPanel];
    [self startAnimationCityPanel];
    [_cityPanel release];
    [bt4 release];
    [bt3 release];
    [bt2 release];
    [bt1 release];
}

- (void)dismissCityPanel{
    [self clickCityButton:nil];
}

- (void)cleanCityButtonStateWithPanel:(UIView *)panel{
    for (int i=1;i<5;i++) {
        UIButton *bt = (UIButton*)[panel viewWithTag:i];
        [bt setBackgroundImage:[UIImage imageNamed:@"btn_city_n@2x"] forState:UIControlStateNormal];
        [bt setBackgroundImage:[UIImage imageNamed:@"btn_city_f@2x"] forState:UIControlStateHighlighted];
    }
}

- (void)selectedCityButtonInPanel:(UIView*)panel{
    NSArray *array = [NSArray arrayWithObjects:@"北京",@"上海",@"广州",@"深圳", nil];
    UIButton *bt = (UIButton *)[panel viewWithTag:(1+[array indexOfObject:[[LocationManager defaultLocationManager] getUserCity]])];
    [bt setBackgroundImage:[UIImage imageNamed:@"btn_city_f@2x"] forState:UIControlStateNormal];
    [self addLocationIconWithPanel:panel andButton:bt];
}

- (void)setSelectedButton:(UIButton *)sender{
    
    [self cleanCityButtonStateWithPanel:_cityPanel];
    [sender setBackgroundImage:[UIImage imageNamed:@"btn_city_f@2x"] forState:UIControlStateNormal];
    [self addLocationIconWithPanel:_cityPanel andButton:sender];
    [self stopAnimationCityPanel];
    [self refreshChangeCityData];
}

- (void)addLocationIconWithPanel:(UIView *)panel andButton:(UIButton*)bt{
    
    NSString *locationCity = [LocationManager defaultLocationManager].locationCity;
    locationCity = [[DataBaseManager sharedInstance] validateCity:locationCity];
    
    if (!isEmpty(locationCity)) {
        UIImage *img = nil;
        if ([locationCity isEqualToString:bt.currentTitle]) {
            img = [UIImage imageNamed:@"btn_location_icon@2x"];
        }else{
            img = [UIImage imageNamed:@"btn_location_icon_black@2x"];
            NSArray *array = [NSArray arrayWithObjects:@"北京",@"上海",@"广州",@"深圳", nil];
            bt = (UIButton *)[panel viewWithTag:(1+[array indexOfObject:locationCity])];
            
        }
        UIImageView *locationImg = [[UIImageView alloc] initWithImage:img];
        locationImg.frame = CGRectMake(2, 11, 12, 12);
        [bt addSubview:locationImg];
        [locationImg release];
    }
}


- (void)startAnimationCityPanel{
    [self.view addSubview:_cityPanel];
    [UIView animateWithDuration:0.3 animations:^{
        [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
        _cityPanel.frame = CGRectMake(0, 0, 320, 119);
    } completion:^(BOOL finished) {
        
    }];
}

- (void)stopAnimationCityPanel{
    
    [UIView animateWithDuration:0.3 animations:^{
        [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
        _cityPanel.frame = CGRectMake(0, -120, 320, 119);
    } completion:^(BOOL finished) {
        [self.cityPanelMask removeFromSuperview];
        [self.cityPanel removeFromSuperview];
        self.cityPanel = nil;
    }];
}

- (void)refreshChangeCityData{
    [self loadNewData];
}
#pragma mark -
#pragma mark apiNotiry
-(void)apiNotifyResult:(id)apiCmd error:(NSError *)error{
    
    if (error!=nil) {
        [self reloadPullRefreshData];
        return;
    }
    
    NSArray *dataArray = [[DataBaseManager sharedInstance] insertCinemasIntoCoreDataFromObject:[apiCmd responseJSONObject] withApiCmd:apiCmd];
    
    if (dataArray==nil || [dataArray count]<=0) {
//        _refreshTailerView.hidden = YES;
        [self reloadPullRefreshData];
        return;
    }
//    _refreshTailerView.hidden = NO;
    int tag = [[apiCmd httpRequest] tag];
    [self addDataIntoCacheData:dataArray];
    [self updateData:tag withData:[self getCacheData]];
}

- (void) apiNotifyLocationResult:(id)apiCmd cacheData:(NSArray*)cacheData{
    [self addDataIntoCacheData:cacheData];
    [self updateData:API_MCinemaCmd withData:[self getCacheData]];
}

- (ApiCmd *)apiGetDelegateApiCmd{
    return _apiCmdMovie_getAllCinemas;
}

- (void)updateData:(int)tag withData:(NSArray*)dataArray
{
    if (dataArray==nil || [dataArray count]<=0) {
        return;
    }
    
    switch (tag) {
        case 0:
        case API_MCinemaCmd:{
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
    [self formatCinemaDataFilterAll:dataArray];
}

#pragma mark -
#pragma mark FilterCinema FormatData
- (void)formatCinemaDataFilterAll:(NSArray*)pageArray{
    
    NSArray *array_coreData = pageArray;
    ABLoggerDebug(@"影院 count ==== %d",[array_coreData count]);
    
//    NSArray *regionOrder = [[DataBaseManager sharedInstance] getRegionOrder];
    
    NSMutableDictionary *districtDic = [[NSMutableDictionary alloc] initWithCapacity:DataCount];
    NSMutableDictionary *district_id_Dic = [[NSMutableDictionary alloc] initWithCapacity:DataCount];
    
    for (MCinema *tCinema in array_coreData) {
        NSString *key = tCinema.district;
        NSNumber *districtId = tCinema.districtId;
        
        if (![districtDic objectForKey:key]) {
            ABLoggerInfo(@"key === %@",key);
            ABLoggerInfo(@"districtId === %d",[districtId intValue]);
            NSMutableArray *tarray = [[NSMutableArray alloc] initWithCapacity:DataCount];
            [districtDic setObject:tarray forKey:key];
//            [districtDic setObject:key forKey:@"districtId"];
            [tarray release];
            
            [district_id_Dic setObject:districtId forKey:key];
        }
        [[districtDic objectForKey:key] addObject:tCinema];
    }
    
    for (NSString *key in [districtDic allKeys]) {
        
//        if (![districtDic objectForKey:key]) {
//            continue;
//        }
        
        NSMutableDictionary *dic = nil;
        
        BOOL isContinue = NO;
        
        for (NSMutableDictionary *tDic in _mArray) {
            if ([[tDic objectForKey:@"name"] isEqualToString:key]) {
                dic = tDic;
                NSMutableArray *tarray = [tDic objectForKey:@"list"];
                [tarray addObjectsFromArray:[districtDic objectForKey:key]];
                
                /*===============防止数组tarray加入重复的KTV，根据KTV.uid 来筛选判断===================*/
//                NSMutableArray *addedArray = [districtDic objectForKey:key];
//                for (int i=0;i<[addedArray count];i++) {
//                    MCinema *cinema1 = [addedArray objectAtIndex:i];
//                    
//                    BOOL isadd = YES;
//                    for (int j=0;j<[tarray count];j++) {
//                        MCinema *cinema2 = [tarray objectAtIndex:j];
//                        if ([cinema1.uid intValue]==[cinema2.uid intValue]) {
//                            isadd = NO;
//                            break;
//                        }
//                    }
//                    
//                    if (isadd) {
//                        [tarray addObject:cinema1];
//                    }
//                }
                /*========================================================*/
                
//                returnArray = (NSMutableArray *)[returnArray sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
//                    NSString *first =  [(MMovie*)a name];
//                    NSString *second = [(MMovie*)b name];
//                    return [first compare:second];
//                }];
                
                [tDic setObject:[district_id_Dic objectForKey:key] forKey:@"districtId"];
                
                isContinue = YES;
                continue;
            }
        }
        
        if (isContinue) {
            continue;
        }
        
        if (dic==nil) {
            dic = [NSMutableDictionary dictionaryWithCapacity:DataCount];
        }
        
        [dic setObject:key forKey:@"name"];
        [dic setObject:[district_id_Dic objectForKey:key] forKey:@"districtId"];
        [dic setObject:[districtDic objectForKey:key] forKey:@"list"];
        
        [_mArray addObject:dic];
    }
    
    [districtDic release];
    [district_id_Dic release];
    
    _refreshTailerView.hidden = NO;
    if ([_mArray count]<=0 || _mArray==nil) {
        _refreshTailerView.hidden = YES;
        
    }
    
    [self formatKTVDataFilterFavorite];
    
//    dispatch_async(dispatch_get_main_queue(), ^{

        [self reloadPullRefreshData];
//    });
}

- (void)formatKTVDataFilterFavorite{
    
    NSArray *array_coreData = [[DataBaseManager sharedInstance] getFavoriteCinemasListFromCoreData];
    ABLoggerDebug(@"常去 影院 count ==== %d",[array_coreData count]);
    [_mFavoriteArray removeAllObjects];
    [_mFavoriteArray addObjectsFromArray:array_coreData];
}

#pragma mark -
#pragma mark 刷新和加载更多
- (void)loadMoreData{
    [self updateData:API_MCinemaCmd withData:[self getCacheData]];
}

- (void)loadNewData{
    [self cancelApiCmd];
    [_mArray removeAllObjects];
    [_mCacheArray removeAllObjects];
    [_mFavoriteArray removeAllObjects];
    [_mTableView reloadData];
    
    [self updateData:API_MCinemaCmd withData:[self getCacheData]];
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
        
        NSString *dataType = [NSString stringWithFormat:@"%d",API_MCinemaCmd];
        self.apiCmdMovie_getAllCinemas = (ApiCmdMovie_getAllCinemas *)[[DataBaseManager sharedInstance] getCinemasListFromWeb:self
                                                                                                                       offset:number
                                                                                                                        limit:DataLimit
                                                                                                                     dataType:dataType
                                                                                                                    isNewData:NO];
        return  nil;
    }
    
    ABLoggerInfo(@"_cacheArray count == %d",[_mCacheArray count]);
    int count = DataCount; //取DataCount条数据
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
