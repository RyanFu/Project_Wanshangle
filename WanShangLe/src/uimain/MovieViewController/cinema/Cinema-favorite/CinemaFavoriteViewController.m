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

@interface CinemaFavoriteViewController(){
}
@property(nonatomic,retain)ScheduleViewController *scheduleViewController;
@property(nonatomic,retain)CinemaFavoriteListTableViewDelegate *favoriteListDelegate;
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

    self.favoriteListDelegate = nil;
    self.scheduleViewController = nil;

    self.mTableView = nil;
    self.mArray = nil;
    
    [super dealloc];
}

#pragma mark -
#pragma mark UIView cycle
- (void)viewWillAppear:(BOOL)animated{
    
   [self formatKTVDataFilterFavorite];//判断是否是一条数据
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.view addSubview:self.mTableView];
    
    //第一次调用
//    [self formatKTVDataFilterFavorite];
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
    if (_favoriteListDelegate==nil) {
        _favoriteListDelegate = [[CinemaFavoriteListTableViewDelegate alloc] init];
        _favoriteListDelegate.parentViewController = self;
    }
    _mTableView.dataSource = _favoriteListDelegate;
    _mTableView.delegate = _favoriteListDelegate;
    _favoriteListDelegate.mArray = _mArray;
    _favoriteListDelegate.mTableView = _mTableView;
}

#pragma mark -
#pragma mark UIButton Event
- (IBAction)clickAddFavoriteButton:(id)sender{
//    KtvManagerViewController *ktvManager = [[KtvManagerViewController alloc] initWithNibName:@"KtvManagerViewController" bundle:nil];
//    [[CacheManager sharedInstance].rootNavController pushViewController:ktvManager animated:YES];
//    [ktvManager release];
}

#pragma mark -
#pragma mark 格式化数据
- (void)formatKTVDataFilterFavorite{
    NSArray *array_coreData = [[DataBaseManager sharedInstance] getFavoriteCinemasListFromCoreData];
    ABLoggerDebug(@"收藏 电影院count ==== %d",[array_coreData count]);
    
//    if (_mparentController.isMoviePanel && [array_coreData count]==1) {
//        self.cinemasArray = nil;
//        
//        if (_scheduleViewController==nil) {
//            _scheduleViewController = [[ScheduleViewController alloc]
//                                       initWithNibName:(iPhone5?@"ScheduleViewController_5":@"ScheduleViewController")
//                                       bundle:nil];
//            
//        }
//        _scheduleViewController.mCinema = [array_coreData lastObject];
//        _scheduleViewController.mMovie = _mMovie;
//        _scheduleViewController.view.frame = _filterTableView.frame;
//        [self.view addSubview:_scheduleViewController.view];
//        
//    }else{
//        self.cinemasArray = array_coreData;
//    }
//    
//    if ([array_coreData count]>0) {
//        _filterTableView.tableFooterView = _addFavoriteFooterView;
//    }else{
//        _filterTableView.tableFooterView = _noFavoriteFooterView;
//    }
//    
//    dispatch_async(dispatch_get_main_queue(), ^{
//        [_filterTableView reloadData];
//    });
}

- (void)cleanFavoriteKTVBuyViewController{
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
