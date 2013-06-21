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
#import "CinemaSearchViewController.h"
#import "MovieViewController.h"
#import "MovieDetailViewController.h"
#import "ASIHTTPRequest.h"
#import "MCinema.h"
#import "MMovie.h"
#import "ApiCmd.h"

@interface CinemaViewController()<ApiNotify>{
    UIButton *favoriteButton;
    UIButton *nearbyButton;
    UIButton *allButton;
    UIButton *searchButton;
}
@property(nonatomic,retain)UILabel *movieLabel;
@property(nonatomic,retain)UIView *headerView;
@property(nonatomic,retain)CinemaListTableViewDelegate *cinemaDelegate;
@property(nonatomic,retain)CinemaSearchViewController *cinemaSearchViewControlelr;
@end

@implementation CinemaViewController
@synthesize mparentController = _mparentController;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.apiCmdMovie_getAllCinemas = [[DataBaseManager sharedInstance] getAllCinemasListFromWeb:self];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(keyboardWillShown:)
                                                     name:UIKeyboardWillShowNotification
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(keyboardWasHidden:)
                                                     name:UIKeyboardWillHideNotification
                                                   object:nil];
    }
    return self;
}

- (void)dealloc{
    self.cinemaDelegate = nil;
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
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super dealloc];
}

- (void)viewWillAppear:(BOOL)animated{
    [self.navigationController setNavigationBarHidden:NO];
    
    [self initMovieCinemaView];
    
    self.apiCmdMovie_getAllCinemas = [[DataBaseManager sharedInstance] getAllCinemasListFromWeb:self];
    //    [self updateData:0];
    
    [super viewDidAppear:animated];
    
    if (animated) {
        [self.cinemaTableView flashScrollIndicators];
    }
    [self.cinemaTableView setContentOffset:CGPointMake(0, 44) animated:NO];
    
#ifdef TestCode
    [self updatData];//测试代码
#endif
    
    _cinemaDelegate.isOpen = NO;
    _cinemaDelegate.selectIndex = nil;
    [_cinemaTableView reloadData];
}

- (void)updatData{
    for (int i=0; i<10; i++) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            self.apiCmdMovie_getAllCinemas = [[DataBaseManager sharedInstance] getAllCinemasListFromWeb:self];
        });
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[CacheManager sharedInstance] setCinemaViewController:self];
    
    [self initFilterButtonHeaderView];
    
    _cinemaDelegate = [[CinemaListTableViewDelegate alloc] init];
    _cinemaDelegate.parentViewController = self;
    
    [self searchBarInit];
    [self tableViewInit];
    
    [self setTableViewDelegate];
    
    self.movieDetailButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _movieDetailButton.frame = CGRectMake(0, 0, 50, 30);
    [_movieDetailButton setBackgroundColor:[UIColor colorWithRed:0.801 green:1.000 blue:0.777 alpha:1.000]];
    [_movieDetailButton addTarget:self action:@selector(clickMovieDetail:) forControlEvents:UIControlEventTouchUpInside];
    [_movieDetailButton setTitle:@"详情" forState:UIControlStateNormal];
    _movieDetailButton.hidden = YES;
    UIBarButtonItem *movieDetailIiem = [[UIBarButtonItem alloc] initWithCustomView:_movieDetailButton];
    _mparentController.navigationItem.rightBarButtonItem = movieDetailIiem;
    [movieDetailIiem release];
    
    [self initMovieCinemaView];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        [self updateData:0];
    });
}

#pragma mark -
#pragma mark 初始化数据
- (void)initFilterButtonHeaderView{
    //创建TopView
    _filterHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 30)];
    UIButton *bt1 = [UIButton buttonWithType:UIButtonTypeCustom];
    UIButton *bt2 = [UIButton buttonWithType:UIButtonTypeCustom];
    UIButton *bt3 = [UIButton buttonWithType:UIButtonTypeCustom];
    [bt1 setTitle:@"常去" forState:UIControlStateNormal];
    [bt2 setTitle:@"附近" forState:UIControlStateNormal];
    [bt3 setTitle:@"全部" forState:UIControlStateNormal];
    [bt1 setExclusiveTouch:YES];
    [bt1 setBackgroundColor:[UIColor colorWithRed:0.601 green:0.896 blue:1.000 alpha:1.000]];
    [bt2 setBackgroundColor:[UIColor colorWithRed:0.601 green:0.896 blue:1.000 alpha:1.000]];
    [bt3 setBackgroundColor:[UIColor colorWithRed:0.601 green:0.896 blue:1.000 alpha:1.000]];
    [bt1 addTarget:self action:@selector(clickFilterFavoriteButton:) forControlEvents:UIControlEventTouchUpInside];
    [bt2 addTarget:self action:@selector(clickFilterNearbyButton:) forControlEvents:UIControlEventTouchUpInside];
    [bt3 addTarget:self action:@selector(clickFilterAllButton:) forControlEvents:UIControlEventTouchUpInside];
    [bt1 setFrame:CGRectMake(0, 0, 105, 30)];
    [bt2 setFrame:CGRectMake(105, 0, 110, 30)];
    [bt3 setFrame:CGRectMake(215, 0, 105, 30)];
    [_filterHeaderView addSubview:bt1];
    [_filterHeaderView addSubview:bt2];
    [_filterHeaderView addSubview:bt3];
    favoriteButton = bt1;
    nearbyButton = bt2;
    allButton = bt3;
    [favoriteButton setBackgroundColor:[UIColor colorWithRed:0.047 green:0.678 blue:1.000 alpha:1.000]];
    [self.view addSubview:_filterHeaderView];
}

- (void)tableViewInit {
    
    //create movie tableview and init
    _cinemaTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 30, iPhoneAppFrame.size.width, self.view.bounds.size.height-30)
                                                    style:UITableViewStylePlain];
    _cinemaTableView.backgroundColor = [UIColor colorWithRed:0.752 green:0.963 blue:0.931 alpha:1.000];
    _cinemaTableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    _cinemaDelegate.isOpen = NO;
    _cinemaTableView.tableHeaderView = self.searchBar;
    _cinemaTableView.tableFooterView = [[[UIView alloc] initWithFrame:CGRectZero] autorelease];
    
    [self.view addSubview:_cinemaTableView];
}
- (void)searchBarInit{
    _searchBar = [[UISearchBar alloc] initWithFrame:CGRectZero];
    
    [self.searchBar sizeToFit];
    self.searchBar.autocorrectionType = UITextAutocorrectionTypeNo;
	self.searchBar.autocapitalizationType = UITextAutocapitalizationTypeNone;
	self.searchBar.keyboardType = UIKeyboardTypeDefault;
	self.searchBar.backgroundColor=[UIColor clearColor];
	self.searchBar.translucent=YES;
	self.searchBar.placeholder=@"搜索";
	self.searchBar.delegate = _cinemaDelegate;
	self.searchBar.barStyle=UIBarStyleDefault;
    
    self.searchBar.backgroundColor=[UIColor clearColor];
    [[self.searchBar.subviews objectAtIndex:0]removeFromSuperview];
    for (UIView *subview in self.searchBar.subviews)
    {
        if ([subview isKindOfClass:NSClassFromString(@"UISearchBarBackground")])
        {
            [subview removeFromSuperview];
            break;
        }
    }
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"searchBarBackground"]];
    imageView.frame = CGRectMake(0, 0, 320, 44);
    [self.searchBar insertSubview:imageView atIndex:0];
    
    self.strongSearchDisplayController = [[[UISearchDisplayController alloc] initWithSearchBar:self.searchBar contentsController:_mparentController] autorelease];
    _mparentController.searchDisplayController.searchResultsDataSource = _cinemaDelegate;
    _mparentController.searchDisplayController.searchResultsDelegate = _cinemaDelegate;
    _mparentController.searchDisplayController.delegate = _cinemaDelegate;
}

- (void)setTableViewDelegate{
    _cinemaTableView.dataSource = _cinemaDelegate;
    _cinemaTableView.delegate = _cinemaDelegate;
}

- (void)initMovieCinemaView{

}

- (void)clickMovieDetail:(id)sender{
    MovieDetailViewController *movieDetailController = [[MovieDetailViewController alloc] initWithNibName:@"MovieDetailViewController" bundle:nil];
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
    frame1.origin.y = -30;
    _filterHeaderView.frame = frame1;
    
    CGRect frame2 = _cinemaTableView.frame;
    frame2.origin.y = 0;
    _cinemaTableView.frame = frame2;
}

-(void)endSearch{
    CGRect frame1 = _filterHeaderView.frame;
    frame1.origin.y = 0;
    _filterHeaderView.frame = frame1;
    
    CGRect frame2 = _cinemaTableView.frame;
    frame2.origin.y = 30;
    _cinemaTableView.frame = frame2;
}

#pragma mark-
#pragma mark Filter Movie List
- (void)clickFilterFavoriteButton:(id)sender{
    [self cleanUpFilterButtonBackground];
    [favoriteButton setBackgroundColor:[UIColor colorWithRed:0.047 green:0.678 blue:1.000 alpha:1.000]];
}
- (void)clickFilterNearbyButton:(id)sender{
    [self cleanUpFilterButtonBackground];
    [nearbyButton setBackgroundColor:[UIColor colorWithRed:0.047 green:0.678 blue:1.000 alpha:1.000]];
}
- (void)clickFilterAllButton:(id)sender{
    [self cleanUpFilterButtonBackground];
    [allButton setBackgroundColor:[UIColor colorWithRed:0.047 green:0.678 blue:1.000 alpha:1.000]];
}
- (void)cleanUpFilterButtonBackground{
    [favoriteButton setBackgroundColor:[UIColor colorWithRed:0.601 green:0.896 blue:1.000 alpha:1.000]];
    [nearbyButton setBackgroundColor:[UIColor colorWithRed:0.601 green:0.896 blue:1.000 alpha:1.000]];
    [allButton setBackgroundColor:[UIColor colorWithRed:0.601 green:0.896 blue:1.000 alpha:1.000]];
}

#pragma mark -
#pragma mark apiNotiry
-(void)apiNotifyResult:(id)apiCmd error:(NSError *)error{
    
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

- (void)updateData:(int)tag
{
    ABLogger_int(tag);
    switch (tag) {
        case 0:
        case API_MCinemaCmd:
        {
            [self formatCinemaData];
            //            [[[CacheManager sharedInstance] mUserDefaults] setObject:@"0" forKey:UpdatingCinemasList];
            //            ABLoggerWarn(@"可以请求 影院列表数据 === %d",[[[[CacheManager sharedInstance] mUserDefaults] objectForKey:UpdatingCinemasList] intValue]);
        }
            break;
        default:
        {
            NSAssert(0, @"没有从网络抓取到数据");
        }
            break;
    }
}

- (void)formatCinemaData{
    
    NSArray *array_coreData = [[DataBaseManager sharedInstance] getAllCinemasListFromCoreData];
    ABLoggerDebug(@"主电影院count ==== %d",[array_coreData count]);
    
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
    
    for (NSString *key in [districtDic allKeys]) {
        NSDictionary *dic = [[NSDictionary alloc] initWithObjectsAndKeys:
                             [districtDic objectForKey:key],@"list",
                             key,@"name",nil];
        [dataArray addObject:dic];
        [dic release];
    }
    self.cinemasArray = dataArray;
    [dataArray release];
    [districtDic release];
    
    dispatch_sync(dispatch_get_main_queue(), ^{
        [self setTableViewDelegate];
        [self.cinemaTableView reloadData];
    });
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
    newFrame.size.height = iPhoneAppFrame.size.height;
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
