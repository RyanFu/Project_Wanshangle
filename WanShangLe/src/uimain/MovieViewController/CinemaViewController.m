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
@property(nonatomic,retain)UIButton *movieDetailButton;
@property(nonatomic,retain)CinemaListTableViewDelegate *cinemaDelegate;
@property(nonatomic,retain)CinemaSearchViewController *cinemaSearchViewControlelr;
@end

@implementation CinemaViewController
@synthesize isMovie_Cinema;
@synthesize mparentController = _mparentController;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.apiCmdMovie_getAllCinemas = [[DataBaseManager sharedInstance] getAllCinemasListFromWeb:self];
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
    [super dealloc];
}

- (void)viewWillAppear:(BOOL)animated{
    [self.navigationController setNavigationBarHidden:NO];
    
    [self initMovieCinemaView];
    
    self.apiCmdMovie_getAllCinemas = [[DataBaseManager sharedInstance] getAllCinemasListFromWeb:self];
    //    [self updateData:0];
    
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
    
    //创建TopView
    UIView *topView = [[UIView alloc] initWithFrame:CGRectMake(0, 7, 150, 30)];
    UIButton *bt1 = [UIButton buttonWithType:UIButtonTypeCustom];
    UIButton *bt2 = [UIButton buttonWithType:UIButtonTypeCustom];
    UIButton *bt3 = [UIButton buttonWithType:UIButtonTypeCustom];
    [bt1 setTitle:@"常去" forState:UIControlStateNormal];
    [bt2 setTitle:@"附近" forState:UIControlStateNormal];
    [bt3 setTitle:@"全部" forState:UIControlStateNormal];
    [bt1 setExclusiveTouch:YES];
    [bt1 setBackgroundColor:[UIColor clearColor]];
    [bt2 setBackgroundColor:[UIColor clearColor]];
    [bt3 setBackgroundColor:[UIColor clearColor]];
    [bt1 addTarget:self action:@selector(clickFilterFavoriteButton:) forControlEvents:UIControlEventTouchUpInside];
    [bt2 addTarget:self action:@selector(clickFilterNearbyButton:) forControlEvents:UIControlEventTouchUpInside];
    [bt3 addTarget:self action:@selector(clickFilterAllButton:) forControlEvents:UIControlEventTouchUpInside];
    [bt1 setFrame:CGRectMake(0, 0, 50, 30)];
    [bt2 setFrame:CGRectMake(50, 0, 50, 30)];
    [bt3 setFrame:CGRectMake(100, 0, 50, 30)];
    [topView addSubview:bt1];
    [topView addSubview:bt2];
    [topView addSubview:bt3];
    favoriteButton = bt1;
    nearbyButton = bt2;
    allButton = bt3;
    self.navigationItem.titleView = topView;
    [topView release];
    
    //create movie tableview and init
    _cinemaTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 70, iPhoneAppFrame.size.width, iPhoneAppFrame.size.height-70)
                                                    style:UITableViewStylePlain];
    
    _cinemaDelegate = [[CinemaListTableViewDelegate alloc] init];
    _cinemaDelegate.parentViewController = self;
    
    [self setTableViewDelegate];
    _cinemaTableView.backgroundColor = [UIColor colorWithRed:0.880 green:0.963 blue:0.925 alpha:1.000];
    _cinemaTableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    _cinemaTableView.sectionFooterHeight = 0;
    _cinemaTableView.sectionHeaderHeight = 0;
    _cinemaDelegate.isOpen = NO;
    
    _headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 40)];
    
    UIButton *searchBt = [UIButton buttonWithType:UIButtonTypeCustom];
    searchButton = searchBt;
    searchBt.frame = CGRectMake(0, 0, 320, 40);
    [searchBt setBackgroundColor:[UIColor colorWithRed:1.000 green:0.329 blue:0.663 alpha:1.000]];
    [searchBt setTitle:@"搜索" forState:UIControlStateNormal];
    [searchBt addTarget:self action:@selector(clickSearchBar:) forControlEvents:UIControlEventTouchUpInside];
    
    self.movieDetailButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _movieDetailButton.frame = CGRectMake(0, 0, 320, 70);
    [_movieDetailButton setBackgroundColor:[UIColor colorWithRed:0.801 green:1.000 blue:0.777 alpha:1.000]];
    [_movieDetailButton addTarget:self action:@selector(clickMovieDetail:) forControlEvents:UIControlEventTouchUpInside];
    _movieLabel = [[UILabel alloc] initWithFrame:_movieDetailButton.bounds];
    [_movieLabel setBackgroundColor:[UIColor clearColor]];
    [_movieLabel setTextAlignment:UITextAlignmentLeft];
    [_movieLabel setNumberOfLines:3];
    [_movieLabel setText:@"电影:钢铁侠   豆瓣评分:8.9 (12万人) \n\n 主演:范冰冰，唐尼        120分钟"];
    [_movieDetailButton addSubview:_movieLabel];
    
    [_headerView addSubview:searchBt];
    _cinemaTableView.tableHeaderView = _headerView;
    
    [self.view addSubview:_movieDetailButton];
    [self.view addSubview:_cinemaTableView];
    [self initMovieCinemaView];
    
    [favoriteButton setBackgroundColor:[UIColor colorWithRed:0.047 green:0.678 blue:1.000 alpha:1.000]];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        [self updateData:0];
    });
}

- (void)setTableViewDelegate{
    _cinemaTableView.dataSource = _cinemaDelegate;
    _cinemaTableView.delegate = _cinemaDelegate;
}

- (void)initMovieCinemaView{
    
    
    if (!_cinemaTableView.tableHeaderView) {
        return;
    }
    
    if (isMovie_Cinema) {
        _movieDetailButton.hidden = NO;
        _cinemaTableView.frame = CGRectMake(0, 70, self.view.bounds.size.width, self.view.bounds.size.height-70);
        NSString *info = [NSString stringWithFormat:@"电影:%@   豆瓣评分:%@ (%d万人) \n\n 主演:范冰冰，唐尼        120分钟",
                          _mMovie.name,[_mMovie.rating stringValue],[_mMovie.ratingpeople integerValue]/10000];
        _movieLabel.text = info;
    }else{
        _movieDetailButton.hidden = YES;
        _cinemaTableView.frame = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height);
    }
}

- (void)clickMovieDetail:(id)sender{
    
}

- (void)clickSearchBar:(id)sender{
    
    if (!_cinemaSearchViewControlelr) {
        _cinemaSearchViewControlelr = [[CinemaSearchViewController alloc] initWithNibName:nil bundle:nil];
    }
    
    if ([[DataBaseManager sharedInstance] getCountOfCinemasListFromCoreData]) {
        _cinemaSearchViewControlelr.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
        [self.mparentController.navigationController pushViewController:_cinemaSearchViewControlelr animated:YES];
    }else{
        ABLoggerWarn(@"======== 还没有电影院");
    }
    
    //    [self presentModalViewController:_cinemaSearchViewControlelr animated:YES];
    //    CinemaSearchViewController *searchController = [[CinemaSearchViewController alloc] initWithNibName:nil bundle:nil];
    //    [searchController release];
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
    [favoriteButton setBackgroundColor:[UIColor clearColor]];
    [nearbyButton setBackgroundColor:[UIColor clearColor]];
    [allButton setBackgroundColor:[UIColor clearColor]];
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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    ABLoggerWarn(@"接收到内存警告了");
    // Dispose of any resources that can be recreated.
}

@end
