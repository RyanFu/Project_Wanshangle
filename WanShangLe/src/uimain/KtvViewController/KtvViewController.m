//
//  CinemaViewController.m
//  WanShangLe
//
//  Created by stephenliu on 13-6-8.
//  Copyright (c) 2013年 stephenliu. All rights reserved.
//

#import "KtvViewController.h"
#import "ApiCmdKTV_getAllKTVs.h"
#import "KTVListTableViewDelegate.h"
#import "ASIHTTPRequest.h"
#import "KKTV.h"
#import "ApiCmd.h"

@interface KtvViewController()<ApiNotify>{
    UIButton *favoriteButton;
    UIButton *nearbyButton;
    UIButton *allButton;
    UIButton *searchButton;
}
@property(nonatomic,retain)UIView *headerView;
@property(nonatomic,retain)KTVListTableViewDelegate *ktvListTableViewDelegate;
@end

@implementation KtvViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.apiCmdKTV_getAllKTVs = [[DataBaseManager sharedInstance] getAllKTVsListFromWeb:self];
    }
    return self;
}

- (void)dealloc{
    self.ktvListTableViewDelegate = nil;
    self.headerView = nil;
    [super dealloc];
}

- (void)viewWillAppear:(BOOL)animated{
    
    [self.navigationController setNavigationBarHidden:NO];
    
    self.apiCmdKTV_getAllKTVs = [[DataBaseManager sharedInstance] getAllKTVsListFromWeb:self];
    //    [self updateData:0];
    
#ifdef TestCode
    [self updatData];//测试代码
#endif
    
}

- (void)updatData{
    for (int i=0; i<10; i++) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            self.apiCmdKTV_getAllKTVs = [[DataBaseManager sharedInstance] getAllKTVsListFromWeb:self];
        });
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
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
    _mTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, iPhoneAppFrame.size.width, iPhoneAppFrame.size.height)
                                                    style:UITableViewStylePlain];
    
    _ktvListTableViewDelegate = [[KTVListTableViewDelegate alloc] init];
    _ktvListTableViewDelegate.parentViewController = self;
    
    _mTableView.backgroundColor = [UIColor colorWithRed:0.880 green:0.963 blue:0.925 alpha:1.000];
    _mTableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    _mTableView.sectionFooterHeight = 0;
    _mTableView.sectionHeaderHeight = 0;
    
    _headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 40)];
    [_headerView setBackgroundColor:[UIColor colorWithRed:1.000 green:0.381 blue:0.668 alpha:1.000]];
    _mTableView.tableHeaderView = _headerView;
    
    [self.view addSubview:_mTableView];
    
    [favoriteButton setBackgroundColor:[UIColor colorWithRed:0.047 green:0.678 blue:1.000 alpha:1.000]];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        [self updateData:0];
    });
}

- (void)setTableViewDelegate{
    _mTableView.dataSource = _ktvListTableViewDelegate;
    _mTableView.delegate = _ktvListTableViewDelegate;
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
        
        [[DataBaseManager sharedInstance] insertKTVsIntoCoreDataFromObject:[apiCmd responseJSONObject] withApiCmd:apiCmd];
        
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
        case API_KKTVCmd:
        {
            [self formatCinemaData];
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
    
    NSArray *array = [[DataBaseManager sharedInstance] getAllKTVsListFromCoreData];
    self.ktvsArray = array;
    ABLoggerDebug(@"KTV count ==== %d",[self.ktvsArray count]);
    [self setTableViewDelegate];
    
    dispatch_sync(dispatch_get_main_queue(), ^{
        [self.mTableView reloadData];
    });
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    ABLoggerWarn(@"接收到内存警告了");
    // Dispose of any resources that can be recreated.
}

@end
