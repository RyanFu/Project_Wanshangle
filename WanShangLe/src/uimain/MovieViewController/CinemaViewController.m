//
//  CinemaViewController.m
//  WanShangLe
//
//  Created by stephenliu on 13-6-8.
//  Copyright (c) 2013年 stephenliu. All rights reserved.
//

#import "CinemaViewController.h"
#import "ApiCmdMovie_getAllCinemas.h"
#import "MovieListTableViewDelegate.h"
#import "CinemaListTableViewDelegate.h"
#import "CinemaListFilterTableViewDelegate.h"
#import "CinemaSearchViewController.h"
#import "MovieViewController.h"
#import "MovieDetailViewController.h"
#import "ScheduleViewController.h"
#import "ASIHTTPRequest.h"
#import "MCinema.h"
#import "MMovie.h"
#import "ApiCmd.h"

#define TableView_Y 74

@interface CinemaViewController()<ApiNotify>{
    UIButton *favoriteButton;
    UIButton *nearbyButton;
    UIButton *allButton;
    UIButton *searchButton;
    UIImageView *filterIndicator;
}
@property(nonatomic,retain)UILabel *movieLabel;
@property(nonatomic,retain)UIView *headerView;
@property(nonatomic,retain)CinemaListTableViewDelegate *cinemaDelegate;
@property(nonatomic,retain)CinemaListFilterTableViewDelegate *cinemaFilterDelegate;
@property(nonatomic,retain)CinemaSearchViewController *cinemaSearchViewControlelr;
@property(nonatomic,retain)ScheduleViewController *scheduleViewController;
@end

@implementation CinemaViewController
@synthesize mparentController = _mparentController;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.apiCmdMovie_getAllCinemas = (ApiCmdMovie_getAllCinemas *)[[DataBaseManager sharedInstance] getAllCinemasListFromWeb:self];
        
        //        [[NSNotificationCenter defaultCenter] addObserver:self
        //                                                 selector:@selector(keyboardWillShown:)
        //                                                     name:UIKeyboardWillShowNotification
        //                                                   object:nil];
        //
        //        [[NSNotificationCenter defaultCenter] addObserver:self
        //                                                 selector:@selector(keyboardWasHidden:)
        //                                                     name:UIKeyboardWillHideNotification
        //                                                   object:nil];
    }
    return self;
}

- (void)dealloc{
    self.cinemaDelegate = nil;
    self.cinemaFilterDelegate = nil;
    self.cinemaTableView = nil;
    self.cinemaSearchViewControlelr = nil;
    self.mMovie = nil;
    self.movieDetailButton = nil;
    self.headerView = nil;
    self.movieLabel = nil;
    self.apiCmdMovie_getAllCinemas = nil;
    
    self.searchBar = nil;
    self.strongSearchDisplayController = nil;
    self.filterHeaderView = nil;
    self.filterTableView = nil;
    self.scheduleViewController = nil;
    //    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super dealloc];
}

- (void)viewWillAppear:(BOOL)animated{
    
    [super viewDidAppear:animated];
    
    self.title = _mMovie.name;
    
    self.apiCmdMovie_getAllCinemas = (ApiCmdMovie_getAllCinemas *)[[DataBaseManager sharedInstance] getAllCinemasListFromWeb:self];
    [self.cinemaTableView setContentOffset:CGPointMake(0, 44) animated:NO];
    
    [self updateSettingFilter];
    
#ifdef TestCode
    [self updatData];//测试代码
#endif
}

- (void)updatData{
    for (int i=0; i<10; i++) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            self.apiCmdMovie_getAllCinemas = (ApiCmdMovie_getAllCinemas *)[[DataBaseManager sharedInstance] getAllCinemasListFromWeb:self];
        });
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self initFilterButtonHeaderView];
    
    [self searchBarInit];
    [self tableViewInit];
    [self filterTableViewInit];
    
    [self initBarButtonItem];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        [self clickFilterAllButton:nil];
    });
}

- (void)initBarButtonItem{
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [backButton setFrame:CGRectMake(0, 0, 45, 30)];
    [backButton addTarget:self action:@selector(clickBackButton:) forControlEvents:UIControlEventTouchUpInside];
    [backButton setBackgroundImage:[UIImage imageNamed:@"bt_back_n@2x"] forState:UIControlStateNormal];
    [backButton setBackgroundImage:[UIImage imageNamed:@"bt_back_f@2x"] forState:UIControlStateHighlighted];
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    self.navigationItem.leftBarButtonItem = backItem;
    [backItem release];
    
    self.movieDetailButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _movieDetailButton.frame = CGRectMake(0, 0, 50, 30);
    [_movieDetailButton setBackgroundImage:[UIImage imageNamed:@"btn_barItem_n@2x"] forState:UIControlStateNormal];
    [_movieDetailButton setBackgroundImage:[UIImage imageNamed:@"btn_barItem_f@2x"] forState:UIControlStateHighlighted];
    [_movieDetailButton addTarget:self action:@selector(clickMovieDetail:) forControlEvents:UIControlEventTouchUpInside];
    [_movieDetailButton setTitle:@"详情" forState:UIControlStateNormal];
    UIBarButtonItem *movieDetailIiem = [[UIBarButtonItem alloc] initWithCustomView:_movieDetailButton];
    self.navigationItem.rightBarButtonItem = movieDetailIiem;
    [movieDetailIiem release];
}

#pragma mark -
#pragma mark 初始化数据
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
    [_filterHeaderView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"btn_filter_bts"]]];
    favoriteButton = bt1;
    nearbyButton = bt2;
    allButton = bt3;
    
    UIImageView *imgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"btn_filter_indicator"]];
    imgView.frame = CGRectMake(46, 34, 13, 6);
    [_filterHeaderView addSubview:imgView];
    filterIndicator = imgView;
    [imgView release];
    
    [self.view addSubview:_filterHeaderView];
}

- (void)tableViewInit {
    
    //create movie tableview and init
    _cinemaTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, _filterHeaderView.bounds.size.height, iPhoneAppFrame.size.width, self.view.bounds.size.height-TableView_Y)
                                                    style:UITableViewStylePlain];
    _cinemaTableView.backgroundColor = [UIColor whiteColor];
    _cinemaTableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    _cinemaTableView.tableHeaderView = self.searchBar;
    _cinemaTableView.tableFooterView = [[[UIView alloc] initWithFrame:CGRectZero] autorelease];
}
- (void)filterTableViewInit {
    
    //create movie tableview and init
    _filterTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, _filterHeaderView.bounds.size.height, iPhoneAppFrame.size.width, self.view.bounds.size.height-TableView_Y)
                                                    style:UITableViewStylePlain];
    _filterTableView.backgroundColor = [UIColor whiteColor];
    _filterTableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    _filterTableView.tableFooterView = [[[UIView alloc] initWithFrame:CGRectZero] autorelease];
}

- (void)searchBarInit{
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
    
    if (!_cinemaDelegate) {
        _cinemaDelegate = [[CinemaListTableViewDelegate alloc] init];
        _cinemaDelegate.parentViewController = self;
    }
    
    self.searchBar.delegate = _cinemaDelegate;
    _cinemaDelegate.mSearchBar = self.searchBar;
    self.strongSearchDisplayController = [[[UISearchDisplayController alloc] initWithSearchBar:self.searchBar contentsController:_mparentController] autorelease];
    _mparentController.searchDisplayController.searchResultsDataSource = _cinemaDelegate;
    _mparentController.searchDisplayController.searchResultsDelegate = _cinemaDelegate;
    _mparentController.searchDisplayController.delegate = _cinemaDelegate;
}

#pragma mark 设置 TableView Delegate
- (void)setTableViewFilterAllDelegate{
    
    if (!_cinemaDelegate) {
        _cinemaDelegate = [[CinemaListTableViewDelegate alloc] init];
        _cinemaDelegate.parentViewController = self;
    }
    _cinemaTableView.dataSource = _cinemaDelegate;
    _cinemaTableView.delegate = _cinemaDelegate;
    
    [_filterTableView removeFromSuperview];
    [self.view insertSubview:_cinemaTableView belowSubview:_filterHeaderView];
}

- (void)setTableViewFilterDelegate:(BOOL)isFavorite{
    
    if (!_cinemaFilterDelegate) {
        _cinemaFilterDelegate = [[CinemaListFilterTableViewDelegate alloc] init];
        _cinemaFilterDelegate.parentViewController = self;
    }
    _filterTableView.dataSource = _cinemaFilterDelegate;
    _filterTableView.delegate = _cinemaFilterDelegate;
    _cinemaFilterDelegate.isFavoriteList = isFavorite;
    
    [_cinemaTableView removeFromSuperview];
    [self.view insertSubview:_filterTableView belowSubview:_filterHeaderView];
}

#pragma mark UIButton Event

- (void)clickBackButton:(id)sender{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)clickMovieDetail:(id)sender{
    MovieDetailViewController *movieDetailController = [[MovieDetailViewController alloc] initWithNibName:@"MovieDetailViewController" bundle:nil];
    movieDetailController.mMovie = self.mMovie;
    [_mparentController.navigationController pushViewController:movieDetailController animated:YES];
}

- (void)clickSearchBar:(id)sender{
    
    CinemaSearchViewController *searchController= [[CinemaSearchViewController alloc] initWithNibName:nil bundle:nil];
    
    if ([[DataBaseManager sharedInstance] getCountOfCinemasListFromCoreData]) {
        _cinemaSearchViewControlelr.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
        [self.mparentController.navigationController pushViewController:searchController animated:YES];
    }else{
        ABLoggerWarn(@"======== 还没有电影院");
    }
}

#pragma mark-
#pragma mark 搜索
-(void)beginSearch{
    
    CGRect frame1 = _filterHeaderView.frame;
    frame1.origin.y = -_filterHeaderView.bounds.size.height;
    _filterHeaderView.frame = frame1;
    
    CGRect frame2 = _cinemaTableView.frame;
    frame2.origin.y = 0;
    _cinemaTableView.frame = frame2;
}

-(void)endSearch{
    
    [UIView animateWithDuration:0.2 animations:^{
        CGRect frame1 = _filterHeaderView.frame;
        frame1.origin.y = 0;
        _filterHeaderView.frame = frame1;
        
        CGRect frame2 = _cinemaTableView.frame;
        frame2.origin.y = _filterHeaderView.bounds.size.height;
        _cinemaTableView.frame = frame2;
    } completion:^(BOOL finished) {
        
    }];
}

#pragma mark-
#pragma mark IBAction Event
- (IBAction)addFavoriteButtonClick:(id)sender{
    ABLoggerMethod();
}

#pragma mark-
#pragma mark Button Event
- (void)updateSettingFilter{
    
    if (!_mparentController.isMoviePanel) {
        [self cleanFavoriteSchedule];
    }
    
    switch (_cinemaFilterType) {
        case MMFilterCinemaListTypeFavorite:{
            _cinemaFilterType=MMFilterCinemaListTypeNone;
            [self clickFilterFavoriteButton:nil];
        }
            break;
        case MMFilterCinemaListTypeNearby:{
            _cinemaFilterType=MMFilterCinemaListTypeNone;
            [self clickFilterNearbyButton:nil];
        }
            break;
            
        case MMFilterCinemaListTypeAll:{
            _cinemaFilterType=MMFilterCinemaListTypeNone;
            [self clickFilterAllButton:nil];
        }
            break;
        default:
            break;
    }
}

- (void)userSettingFilter{
    
    switch (_cinemaFilterType) {
        case MMFilterCinemaListTypeFavorite:{
            [self setTableViewFilterDelegate:YES];
            
        }
            break;
        case MMFilterCinemaListTypeNearby:{
            [self setTableViewFilterDelegate:NO];
            
        }
            break;
            
        case MMFilterCinemaListTypeAll:{
            [self setTableViewFilterAllDelegate];
        }
            break;
        default:
            break;
    }
}

- (void)clickFilterFavoriteButton:(id)sender{
    if (_cinemaFilterType==MMFilterCinemaListTypeFavorite) {
        return;
    }
    _cinemaFilterType = MMFilterCinemaListTypeFavorite;
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:_cinemaFilterType] forKey:MMovie_CinemaFilterType];
    [self userSettingFilter];
    [self formatCinemaDataFilterFavorite];
    [self stratAnimationFilterButton:_cinemaFilterType];
}
- (void)clickFilterNearbyButton:(id)sender{
    if (_cinemaFilterType==MMFilterCinemaListTypeNearby) {
        return;
    }
    _cinemaFilterType = MMFilterCinemaListTypeNearby;
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:_cinemaFilterType] forKey:MMovie_CinemaFilterType];
    [self userSettingFilter];
    [self formatCinemaDataFilterNearby];
    [self stratAnimationFilterButton:_cinemaFilterType];
}
- (void)clickFilterAllButton:(id)sender{
    if (_cinemaFilterType==MMFilterCinemaListTypeAll) {
        return;
    }
    _cinemaFilterType = MMFilterCinemaListTypeAll;
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:_cinemaFilterType] forKey:MMovie_CinemaFilterType];
    [self userSettingFilter];
    [self formatCinemaDataFilterAll];
    [self stratAnimationFilterButton:_cinemaFilterType];
}
- (void)stratAnimationFilterButton:(MMFilterCinemaListType)type{
     
    UIButton *bt = (UIButton *)[_filterHeaderView viewWithTag:type];
    CGRect oldFrame = filterIndicator.frame;
    oldFrame.origin.y = 34;
    filterIndicator.frame = oldFrame;
    
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
        filterIndicator.frame = newFrame;
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
        
        [[DataBaseManager sharedInstance] insertCinemasIntoCoreDataFromObject:[apiCmd responseJSONObject] withApiCmd:apiCmd];
        
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
    return _apiCmdMovie_getAllCinemas;
}

- (void)updateData:(int)tag
{
    ABLogger_int(tag);
    switch (tag) {
        case 0:
        case API_MCinemaCmd:
        {
            [self userSettingFilter];
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
#pragma mark FilterCinema FormatData
- (void)formatCinemaDataFilterAll{
    
    NSArray *array_coreData = [[DataBaseManager sharedInstance] getAllCinemasListFromCoreData];
    ABLoggerDebug(@"主电影院count ==== %d",[array_coreData count]);
    
    NSArray *regionOrder = [[DataBaseManager sharedInstance] getRegionOrder];
    
    NSMutableDictionary *districtDic = [[NSMutableDictionary alloc] initWithCapacity:10];
    NSMutableArray *dataArray = [[NSMutableArray alloc] initWithCapacity:10];
    
    for (MCinema *tcinema in array_coreData) {
        NSString *key = tcinema.district;
        
        if (![districtDic objectForKey:key]) {
            
            NSMutableArray *tarray = [[NSMutableArray alloc] initWithCapacity:10];
            [districtDic setObject:tarray forKey:key];
            [tarray release];
        }
        
        [[districtDic objectForKey:key] addObject:tcinema];
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
    self.cinemasArray = dataArray;
    [dataArray release];
    [districtDic release];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [_cinemaTableView reloadData];
    });
}

- (void)formatCinemaDataFilterNearby{
    ABLoggerWarn(@" 附近 影院");
    self.cinemasArray = nil;
    _filterTableView.tableFooterView = nil;
    
    [[DataBaseManager sharedInstance] getNearbyCinemasListFromCoreDataWithCallBack:^(NSArray *cinemas) {
        
        ABLoggerInfo(@"nearby cinema count=== %d",[cinemas count]);
        self.cinemasArray = cinemas;
        
        _filterTableView.tableFooterView = nil;
        if ([cinemas count]<=0) {
            _filterTableView.tableFooterView = _noGPSView;
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [_filterTableView reloadData];
        });
    }];
    
    [_filterTableView reloadData];
}

- (void)formatCinemaDataFilterFavorite{
    NSArray *array_coreData = [[DataBaseManager sharedInstance] getFavoriteCinemasListFromCoreData];
    ABLoggerDebug(@"收藏 电影院count ==== %d",[array_coreData count]);
    
    if (_mparentController.isMoviePanel && [array_coreData count]==1) {
        self.cinemasArray = nil;
        
        if (_scheduleViewController==nil) {
            _scheduleViewController = [[ScheduleViewController alloc]
                                       initWithNibName:(iPhone5?@"ScheduleViewController_5":@"ScheduleViewController")
                                       bundle:nil];
            
        }
        _scheduleViewController.mCinema = [array_coreData lastObject];
        _scheduleViewController.mMovie = _mMovie;
        _scheduleViewController.view.frame = _filterTableView.frame;
        [self.view addSubview:_scheduleViewController.view];
        
    }else{
        self.cinemasArray = array_coreData;
    }
    
    if ([array_coreData count]>0) {
        _filterTableView.tableFooterView = _addFavoriteFooterView;
    }else{
        _filterTableView.tableFooterView = _noFavoriteFooterView;
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [_filterTableView reloadData];
    });
}

- (void)cleanFavoriteSchedule{
    if (_scheduleViewController) {
        [_scheduleViewController.view removeFromSuperview];
        self.scheduleViewController = nil;
    }
}

#pragma mark -
#pragma mark UIKeyboardNotification methods
- (void) keyboardWillShown:(NSNotification*) aNotification
{
	NSDictionary* info = [aNotification userInfo];
    float durationTime = [[info objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
	
	// Get the size of the keyboard.
	CGSize keyboardSize = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
	
	CGRect newFrame = _cinemaTableView.frame;
	newFrame.size.height = iPhoneAppFrame.size.height-keyboardSize.height;
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationCurve:UIViewAnimationCurveLinear];
    [UIView setAnimationDuration:durationTime];
    _cinemaTableView.frame = newFrame;
    [UIView commitAnimations];
}

- (void)keyboardWasHidden:(NSNotification*)aNotification
{
    NSDictionary * info = [aNotification userInfo];
    float durationTime = [[info objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    
    CGRect newFrame = _cinemaTableView.frame;
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationCurve:UIViewAnimationCurveLinear];
    [UIView setAnimationDuration:durationTime];
    //newFrame.size.height = iPhoneAppFrame.size.height-self.searchBar.frame.size.height;
    newFrame.size.height = self.view.bounds.size.height-TableView_Y;
    _cinemaTableView.frame = newFrame;
    [UIView commitAnimations];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    ABLoggerWarn(@"接收到内存警告了");
    // Dispose of any resources that can be recreated.
}

@end
