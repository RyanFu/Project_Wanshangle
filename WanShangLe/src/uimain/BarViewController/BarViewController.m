//
//  ShowViewController.m
//  WanShangLe
//
//  Created by stephenliu on 13-6-5.
//  Copyright (c) 2013年 stephenliu. All rights reserved.
//

#import "BarViewController.h"
#import "ApiCmdShow_getAllShows.h"
#import "BarTableViewDelegate.h"
#import "EGORefreshTableHeaderView.h"
#import "ASIHTTPRequest.h"

@interface BarViewController ()<ApiNotify>
@property(nonatomic,retain) BarTableViewDelegate *barTableViewDelegate;
@property(nonatomic,retain) UIView *filterHeaderView;
@property(nonatomic,retain) UIImageView *filterIndicator;
@property(nonatomic,retain) IBOutlet UIButton *timeButton;
@property(nonatomic,retain) IBOutlet UIButton *nearByButton;
@property(nonatomic,retain) IBOutlet UIButton *popularButton;

@end

@implementation BarViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
            self.apiCmdBar_getAllBars = (ApiCmdBar_getAllBars*)[[DataBaseManager sharedInstance] getAllBarsListFromWeb:self];
    }
    return self;
}

- (void)dealloc{
    
    [[_apiCmdBar_getAllBars httpRequest] clearDelegatesAndCancel];
    [_apiCmdBar_getAllBars setDelegate:nil];
    self.apiCmdBar_getAllBars = nil;
    
    self.mTableView = nil;
    self.barsArray = nil;
    self.apiCmdBar_getAllBars = nil;
    self.barTableViewDelegate= nil;
    self.filterHeaderView = nil;
    self.filterIndicator = nil;
    
    self.refreshTailerView = nil;
    self.refreshHeaderView = nil;
    
    [super dealloc];
}

- (void)viewWillAppear:(BOOL)animated{
    
    self.apiCmdBar_getAllBars = (ApiCmdBar_getAllBars*)[[DataBaseManager sharedInstance] getAllBarsListFromWeb:self];
    
#ifdef TestCode
    [self updatData];//测试代码
#endif
    
}

- (void)updatData{
    for (int i=0; i<10; i++) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            self.apiCmdBar_getAllBars = (ApiCmdBar_getAllBars*)[[DataBaseManager sharedInstance] getAllBarsListFromWeb:self];
        });
    }
}

- (void)viewWillDisappear:(BOOL)animated{
    ABLoggerMethod();
    [super viewWillDisappear:animated];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self initBarItem];
    [self initFilterButtonHeaderView];
    [self setTableViewDelegate];
    [self initRefreshHeaderView];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        [self updateData:0];
    });
}

#pragma mark -
#pragma mark 初始化数据
- (void)initBarItem{
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [backButton setFrame:CGRectMake(0, 0, 45, 30)];
    [backButton addTarget:self action:@selector(clickBackButton:) forControlEvents:UIControlEventTouchUpInside];
    [backButton setBackgroundImage:[UIImage imageNamed:@"bt_back_n@2x"] forState:UIControlStateNormal];
    [backButton setBackgroundImage:[UIImage imageNamed:@"bt_back_f@2x"] forState:UIControlStateHighlighted];
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    self.navigationItem.leftBarButtonItem = backItem;
    [backItem release];
}

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
    [bt1 addTarget:self action:@selector(clickPopularButton:) forControlEvents:UIControlEventTouchUpInside];
    [bt2 addTarget:self action:@selector(clickNearByButton:) forControlEvents:UIControlEventTouchUpInside];
    [bt3 addTarget:self action:@selector(clickTimeButton:) forControlEvents:UIControlEventTouchUpInside];
    [bt3 setFrame:CGRectMake(0, 0, 105, _filterHeaderView.bounds.size.height)];
    [bt2 setFrame:CGRectMake(105, 0, 110, _filterHeaderView.bounds.size.height)];
    [bt1 setFrame:CGRectMake(215, 0, 105, _filterHeaderView.bounds.size.height)];
    [_filterHeaderView addSubview:bt1];
    [_filterHeaderView addSubview:bt2];
    [_filterHeaderView addSubview:bt3];
    [_filterHeaderView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"bar_btn_filter_bts"]]];
    _popularButton = bt1;
    _nearByButton = bt2;
    _timeButton = bt3;
    
    UIImageView *imgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"btn_filter_indicator"]];
    imgView.frame = CGRectMake(46, 34, 13, 6);
    [_filterHeaderView addSubview:imgView];
    _filterIndicator = imgView;
    [imgView release];
    
    [self.view addSubview:_filterHeaderView];
}

- (void)initRefreshHeaderView{
    
    if (_refreshHeaderView == nil) {
        EGORefreshTableHeaderView *view = [[EGORefreshTableHeaderView alloc] initWithFrame: CGRectMake(0.0f, _mTableView.contentSize.height, _mTableView.frame.size.width, _mTableView.bounds.size.height)];
		view.delegate = _barTableViewDelegate;
        view.tag = EGOBottomView;
        view.backgroundColor = [UIColor clearColor];
		[_mTableView addSubview:view];
		_refreshTailerView = view;
		[view release];
        
        view = [[EGORefreshTableHeaderView alloc] initWithFrame: CGRectMake(0.0f, - _mTableView.bounds.size.height, _mTableView.frame.size.width, _mTableView.bounds.size.height)];
        view.delegate = _barTableViewDelegate;
        view.tag = EGOHeaderView;
        view.backgroundColor = [UIColor clearColor];
        [_mTableView addSubview:view];
        self.refreshHeaderView = view;
        [view release];
    }
    
    [_refreshHeaderView refreshLastUpdatedDate];
    _barTableViewDelegate.mTableView = self.mTableView;
    _barTableViewDelegate.refreshHeaderView = self.refreshHeaderView;
    _barTableViewDelegate.refreshTailerView = self.refreshTailerView;
}

- (void)setTableViewDelegate{
    
    if (_barTableViewDelegate == nil) {
        _barTableViewDelegate = [[BarTableViewDelegate alloc] init];
        _barTableViewDelegate.parentViewController = self;
    }
    _mTableView.dataSource = _barTableViewDelegate;
    _mTableView.delegate = _barTableViewDelegate;
}

#pragma mark-
#pragma mark Button Event
- (void)clickBackButton:(id)sender{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)updateSettingFilter{
    
    switch (_barFilterType) {
        case MMFilterBarListTypeTime:{
            _barFilterType=MMFilterBarListTypeNone;
            [self clickTimeButton:nil];
        }
            break;
        case MMFilterBarListTypeNearby:{
            _barFilterType=MMFilterBarListTypeNone;
            [self clickNearByButton:nil];
        }
            break;
            
        case MMFilterBarListTypePopular:{
            _barFilterType=MMFilterBarListTypeNone;
            [self clickPopularButton:nil];
        }
            break;
        default:
            break;
    }
}

- (void)userSettingFilter{
    
    switch (_barFilterType) {
        case MMFilterBarListTypeTime:{
            [self formatBarDataFilterTime];
        }
            break;
        case MMFilterBarListTypeNearby:{
            [self formatBarDataFilterNearBy];
        }
            break;
            
        case MMFilterBarListTypePopular:{
            [self formatBarDataFilterPopular];
        }
            break;
        default:
            break;
    }
}

- (IBAction)clickTimeButton:(id)sender{
    if (_barFilterType==MMFilterBarListTypeTime) {
        return;
    }
    _barFilterType = MMFilterBarListTypeTime;
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:_barFilterType] forKey:BBar_ActivityFilterType];
    [self userSettingFilter];
    [self stratAnimationFilterButton:_barFilterType];
    
}
- (IBAction)clickNearByButton:(id)sender{
    if (_barFilterType==MMFilterBarListTypeNearby) {
        return;
    }
    _barFilterType = MMFilterBarListTypeNearby;
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:_barFilterType] forKey:BBar_ActivityFilterType];
    [self userSettingFilter];
    [self stratAnimationFilterButton:_barFilterType];
}
- (IBAction)clickPopularButton:(id)sender{
    if (_barFilterType==MMFilterBarListTypePopular) {
        return;
    }
    _barFilterType = MMFilterBarListTypePopular;
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:_barFilterType] forKey:BBar_ActivityFilterType];
    [self userSettingFilter];
    [self stratAnimationFilterButton:_barFilterType];
}

- (void)stratAnimationFilterButton:(MMFilterBarListType)type{
    
    UIButton *bt = (UIButton *)[_filterHeaderView viewWithTag:type];
    CGRect oldFrame = _filterIndicator.frame;
    oldFrame.origin.y = 34;
    _filterIndicator.frame = oldFrame;
    
    [UIView animateWithDuration:0.2 animations:^{
        [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
        
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
        _filterIndicator.frame = newFrame;
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
        
        [[DataBaseManager sharedInstance] insertBarsIntoCoreDataFromObject:[apiCmd responseJSONObject] withApiCmd:apiCmd];
        
        int tag = [[apiCmd httpRequest] tag];
        [self updateData:tag];
    });
    
}

- (void) apiNotifyLocationResult:(id) apiCmd  error:(NSError*) error{
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        ABLoggerMethod();
        int tag = [[apiCmd httpRequest] tag];
        
        CFTimeInterval time1 = Elapsed_Time;
        [self updateData:tag];
        CFTimeInterval time2 = Elapsed_Time;
        ElapsedTime(time2, time1);
        
    });
}

- (ApiCmd *)apiGetDelegateApiCmd{
    return (ApiCmd *)_apiCmdBar_getAllBars;
}

- (void)updateData:(int)tag
{
    ABLogger_int(tag);
    switch (tag) {
        case 0:
        case API_BBarTimeCmd:
        {
            NSArray *array = [[DataBaseManager sharedInstance] getAllBarsListFromCoreData];
            self.barsArray = array;
            ABLoggerDebug(@"酒吧 count ==== %d",[self.barsArray count]);
            
            [self setTableViewDelegate];
            dispatch_sync(dispatch_get_main_queue(), ^{
                if (isNull(_barsArray)||[_barsArray count]==0) {
                    _refreshTailerView.hidden = YES;
                }else{
                    _refreshTailerView.hidden = NO;
                }
                [self.mTableView reloadData];
            });
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
#pragma mark FormatData
- (void)formatBarDataFilterTime{
    
}

- (void)formatBarDataFilterNearBy{
    
}

- (void)formatBarDataFilterPopular{
    
}

- (void)didReceiveMemoryWarning
{
    ABLoggerWarn(@"接收到内存警告了");
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
