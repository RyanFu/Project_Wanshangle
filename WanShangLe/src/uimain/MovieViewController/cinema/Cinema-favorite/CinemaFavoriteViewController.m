//
//  CinemaViewController.m
//  WanShangLe
//
//  Created by stephenliu on 13-6-8.
//  Copyright (c) 2013年 stephenliu. All rights reserved.
//

#import "MCinema.h"
#import "CinemaFavoriteViewController.h"
#import "CinemaFavoriteListTableViewDelegate.h"
#import "ScheduleViewController.h"
#import "CinemaViewController.h"
#import "CinemaManagerViewController.h"
#import "MovieCinemaFavoriteListDelegate.h"


@interface CinemaFavoriteViewController(){
}
@property(nonatomic,retain)ScheduleViewController *scheduleViewController;
@property(nonatomic,retain)CinemaFavoriteListTableViewDelegate *cinemaDelegate;
@property(nonatomic,retain)MovieCinemaFavoriteListDelegate *movieDelegate;
@end

@implementation CinemaFavoriteViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)dealloc{

    self.cinemaDelegate = nil;
    self.movieDelegate = nil;
    
    self.scheduleViewController = nil;

    self.mTableView = nil;
    self.mArray = nil;
    
    [super dealloc];
}

#pragma mark -
#pragma mark UIView cycle
- (void)viewWillAppear:(BOOL)animated{
    
   [self formatCinemaDataFilterFavorite];//判断是否是一条数据
    
    if (_scheduleViewController!=nil){
        [_scheduleViewController viewWillAppear:NO];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.view addSubview:self.mTableView];
    
    //第一次调用
//    [self formatCinemaDataFilterFavorite];
}


#pragma mark -
#pragma mark 初始化数据

- (UITableView *)mTableView
{
    if (_mTableView != nil) {
        return _mTableView;
    }
    
    [self initTableView];
    
    return _mTableView;
}

- (void)initTableView {
    if (_mTableView==nil) {
        self.mTableView = [self createTableView];
    }
    [self setTableViewDelegate];    
    
    if (_mArray==nil) {
        _mArray = [[NSMutableArray alloc] initWithCapacity:10];
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
//    if (_cinemaDelegate==nil) {
//        _cinemaDelegate = [[CinemaFavoriteListTableViewDelegate alloc] init];
//        _cinemaDelegate.parentViewController = self;
//    }
//    _mTableView.dataSource = _cinemaDelegate;
//    _mTableView.delegate = _cinemaDelegate;
//    _cinemaDelegate.mArray = _mArray;
//    _cinemaDelegate.mTableView = _mTableView;
    
    BOOL isMoviePanel = [CacheManager sharedInstance].isMoviePanel;
    if (isMoviePanel) {
        self.cinemaDelegate = nil;
        if (_movieDelegate==nil) {
            _movieDelegate = [[MovieCinemaFavoriteListDelegate alloc] init];
        }
        
        _mTableView.dataSource = _movieDelegate;
        _mTableView.delegate = _movieDelegate;
        
        _movieDelegate.mTableView = _mTableView;
        _movieDelegate.mArray = _mArray;
        
        _movieDelegate.parentViewController = self;
    }else{
        self.movieDelegate = nil;
        if (_cinemaDelegate==nil) {
            _cinemaDelegate = [[CinemaFavoriteListTableViewDelegate alloc] init];
            
        }
        
        _mTableView.dataSource = _cinemaDelegate;
        _mTableView.delegate = _cinemaDelegate;
        
        _cinemaDelegate.mTableView = _mTableView;
        _cinemaDelegate.mArray = _mArray;
        
        _cinemaDelegate.parentViewController = self;
    }
    
}

#pragma mark -
#pragma mark UIButton Event
- (IBAction)clickAddFavoriteButton:(id)sender{
    CinemaManagerViewController *CinemaManager = [[CinemaManagerViewController alloc] initWithNibName:@"CinemaManagerViewController" bundle:nil];
    [[CacheManager sharedInstance].rootNavController pushViewController:CinemaManager animated:YES];
    [CinemaManager release];
}

#pragma mark -
#pragma mark 格式化数据
- (void)formatCinemaDataFilterFavorite{
    NSArray *array_coreData = [[DataBaseManager sharedInstance] getFavoriteCinemasListFromCoreData];
    ABLoggerDebug(@"收藏 电影院count ==== %d",[array_coreData count]);
    
    [self.mArray removeAllObjects];
    [self.mArray addObjectsFromArray:array_coreData];
    
    BOOL isMoviePanel = [CacheManager sharedInstance].isMoviePanel;
    
    if ([array_coreData count]==1 && isMoviePanel) {
        
        if (_scheduleViewController==nil) {
            _scheduleViewController = [[ScheduleViewController alloc]
                                     initWithNibName:(iPhone5?@"ScheduleViewController_5":@"ScheduleViewController")
                                     bundle:nil];
        }
        _scheduleViewController.mCinema = [array_coreData lastObject];
        _scheduleViewController.mMovie = [_mParentController mMovie];
        _scheduleViewController.view.frame = _mTableView.frame;
        [self.view addSubview:_scheduleViewController.view];
        _scheduleViewController.mTableView.tableFooterView=_scheduleViewController.addFavoriteFooterView;
        [_scheduleViewController.addFavoriteButton addTarget:self action:@selector(clickAddFavoriteButton:) forControlEvents:UIControlEventTouchUpInside];
    }else{
        [self cleanFavoriteCinemaBuyViewController];
    }
    
    if ([array_coreData count]>0) {
        _mTableView.tableFooterView = _addFavoriteFooterView;
    }else{
        _mTableView.tableFooterView = _noFavoriteFooterView;
    }
    
    [self setTableViewDelegate];
    dispatch_async(dispatch_get_main_queue(), ^{
        [_mTableView reloadData];
    });
}

- (void)cleanFavoriteCinemaBuyViewController{
    if (_scheduleViewController) {
        [_scheduleViewController.view removeFromSuperview];
        self.scheduleViewController = nil;
    }
}

#pragma mark -
#pragma mark 内存警告
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    ABLoggerWarn(@"接收到内存警告了");
}

@end
