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
    UIButton *cityBtn;
}
@property(nonatomic,retain)KTVAllListManagerDelegate *tableViewDelegate;
@end

@implementation KtvManagerViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
        self.title = @"管理常去KTV";
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
    self.msearchDisplayController = nil;
    self.tableViewDelegate = nil;
    self.searchBar = nil;
    
    [super dealloc];
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
        _tableViewDelegate = [[KTVAllListManagerDelegate alloc] init];
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

#pragma mark -
#pragma mark apiNotiry
-(void)apiNotifyResult:(id)apiCmd error:(NSError *)error{
    
    if (error!=nil) {
        [self reloadPullRefreshData];
        return;
    }
    
    NSArray *dataArray = [[DataBaseManager sharedInstance] insertKTVsIntoCoreDataFromObject:[apiCmd responseJSONObject] withApiCmd:apiCmd];
    
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
    [self updateData:API_KKTVCmd withData:[self getCacheData]];
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

- (void)clickCityButton:(id)sender{
    
}
#pragma mark -
#pragma mark FilterCinema FormatData
- (void)formatKTVDataFilterAll:(NSArray*)pageArray{
    
    NSArray *array_coreData = pageArray;
    ABLoggerDebug(@"KTV店 count ==== %d",[array_coreData count]);
    
    NSArray *regionOrder = [[DataBaseManager sharedInstance] getRegionOrder];
    
    NSMutableDictionary *districtDic = [[NSMutableDictionary alloc] initWithCapacity:DataCount];
    NSMutableDictionary *district_id_Dic = [[NSMutableDictionary alloc] initWithCapacity:DataCount];
    
    for (KKTV *tKTV in array_coreData) {
        NSString *key = tKTV.district;
        NSNumber *districtId = tKTV.districtid;
        
        if (![districtDic objectForKey:key]) {
            ABLoggerInfo(@"key === %@",key);
            ABLoggerInfo(@"districtId === %d",[districtId intValue]);
            NSMutableArray *tarray = [[NSMutableArray alloc] initWithCapacity:DataCount];
            [districtDic setObject:tarray forKey:key];
            [districtDic setObject:key forKey:@"districtId"];
            [tarray release];
            
            [district_id_Dic setObject:districtId forKey:key];
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
//                [tarray addObjectsFromArray:[districtDic objectForKey:key]];
                
                /*===============防止数组tarray加入重复的KTV，根据KTV.uid 来筛选判断===================*/
                NSMutableArray *addedArray = [districtDic objectForKey:key];
                for (int i=0;i<[addedArray count];i++) {
                    KKTV *ktv1 = [addedArray objectAtIndex:i];
                    
                    BOOL isadd = YES;
                    for (int j=0;j<[tarray count];j++) {
                        KKTV *ktv2 = [tarray objectAtIndex:j];
                        if ([ktv1.uid intValue]==[ktv2.uid intValue]) {
                            isadd = NO;
                            break;
                        }
                    }
                    
                    if (isadd) {
                        [tarray addObject:ktv1];
                    }
                }
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

- (void)loadNewData{
    
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
        
        NSString *dataType = [NSString stringWithFormat:@"%d",API_KKTVCmd];
        self.apiCmdKTV_getAllKTVs = (ApiCmdKTV_getAllKTVs *)[[DataBaseManager sharedInstance] getKTVsListFromWeb:self
                                                                                                          offset:number
                                                                                                           limit:DataLimit
                                                                                                        dataType:dataType
                                                                                                       isNewData:NO];
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
