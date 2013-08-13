//
//  CinemaViewController.m
//  WanShangLe
//
//  Created by stephenliu on 13-6-8.
//  Copyright (c) 2013年 stephenliu. All rights reserved.
//

#import "KKTV.h"
#import "KTVBuyViewController.h"
#import "KtvFavoriteViewController.h"
#import "KtvManagerViewController.h"
#import "KTVFavoriteListTableViewDelegate.h"
#import "WSLProgressHUD.h"

@interface KtvFavoriteViewController(){
}
@property(nonatomic,retain)KTVBuyViewController *ktvBuyViewController;
@property(nonatomic,retain)KTVFavoriteListTableViewDelegate *favoriteListDelegate;
@end

@implementation KtvFavoriteViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)dealloc{

    self.ktvBuyViewController = nil;
    self.favoriteListDelegate = nil;

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
    [self.view setBackgroundColor:Color4];
    
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
    tbView.backgroundColor = Color4;
    tbView.separatorStyle = UITableViewCellSeparatorStyleNone;
    tbView.tableFooterView = [[[UIView alloc] initWithFrame:CGRectZero] autorelease];
    return [tbView autorelease];
}

#pragma mark 设置 TableView Delegate
- (void)setTableViewDelegate{
    if (_favoriteListDelegate==nil) {
        _favoriteListDelegate = [[KTVFavoriteListTableViewDelegate alloc] init];
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
    KtvManagerViewController *ktvManager = [[KtvManagerViewController alloc] initWithNibName:@"KtvManagerViewController" bundle:nil];
    [[CacheManager sharedInstance].rootNavController pushViewController:ktvManager animated:YES];
    [ktvManager release];
}

#pragma mark -
#pragma mark 格式化数据
- (void)formatKTVDataFilterFavorite{
    NSArray *array_coreData = [[DataBaseManager sharedInstance] getFavoriteKTVListFromCoreData];
    ABLoggerDebug(@"常去 KTV count ==== %d",[array_coreData count]);
    
    [self.mArray removeAllObjects];
    [self.mArray addObjectsFromArray:array_coreData];
    
    if ([array_coreData count]==1) {
        
        if (_ktvBuyViewController==nil) {
            _ktvBuyViewController = [[KTVBuyViewController alloc]
                                     initWithNibName:(iPhone5?@"KTVBuyViewController_5":@"KTVBuyViewController")
                                     bundle:nil];
        }
        _ktvBuyViewController.mKTV = [array_coreData lastObject];
        [self.view addSubview:_ktvBuyViewController.view];
        _ktvBuyViewController.mTableView.tableFooterView=_ktvBuyViewController.addFavoriteFooterView;
        [_ktvBuyViewController.addFavoriteButton addTarget:self action:@selector(clickAddFavoriteButton:) forControlEvents:UIControlEventTouchUpInside];
        
        //修复了Bug，self.view原本是Height=376，但是在这=322的bug，所以用原始计算来计算ktvbuycontroller的Height
        _ktvBuyViewController.view.frame = CGRectMake(0, 0, self.view.bounds.size.width, iPhoneAppFrame.size.height-navigationBarHeight-40);
        _ktvBuyViewController.mTableView.frame = _ktvBuyViewController.view.frame;
    }else{
        [self cleanFavoriteKTVBuyViewController];
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

- (void)cleanFavoriteKTVBuyViewController{
    if (_ktvBuyViewController) {
        [_ktvBuyViewController.view removeFromSuperview];
        self.ktvBuyViewController = nil;
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
