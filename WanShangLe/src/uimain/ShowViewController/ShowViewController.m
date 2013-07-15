//
//  ShowViewController.m
//  WanShangLe
//
//  Created by stephenliu on 13-6-5.
//  Copyright (c) 2013年 stephenliu. All rights reserved.
//

#import "ShowViewController.h"
#import "ApiCmdShow_getAllShows.h"
#import "ShowTableViewDelegate.h"
#import "EGORefreshTableHeaderView.h"
#import "ASIHTTPRequest.h"

@interface ShowViewController ()<ApiNotify>
@property(nonatomic,retain) ShowTableViewDelegate *showTableViewDelegate;
@property(nonatomic,retain) UIControl *maskView;

@end

@implementation ShowViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
        self.title = @"演出";
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            self.apiCmdShow_getAllShows = (ApiCmdShow_getAllShows *)[[DataBaseManager sharedInstance] getAllShowsListFromWeb:self];
        });
    }
    return self;
}

- (void)dealloc{
    
    [_apiCmdShow_getAllShows.httpRequest clearDelegatesAndCancel];
    _apiCmdShow_getAllShows.delegate = nil;
    [[[ApiClient defaultClient] requestArray] removeObject:_apiCmdShow_getAllShows];
    self.apiCmdShow_getAllShows = nil;
    
    self.typeButton = nil;
    self.timeButton = nil;
    self.orderButton = nil;
    
    self.typeView = nil;
    self.timeView = nil;
    self.orderView = nil;
    self.apiCmdShow_getAllShows = nil;
    self.showsArray = nil;
    self.maskView = nil;
    
    _refreshHeaderView.delegate = nil;
    _refreshTailerView.delegate = nil;
    [_refreshHeaderView removeFromSuperview];
    [_refreshTailerView removeFromSuperview];
    self.refreshHeaderView = nil;
    self.refreshTailerView = nil;
    
    self.showTableViewDelegate = nil;
    _mTableView.delegate = nil;
    _mTableView.dataSource = nil;
    self.mTableView = nil;
    
    [super dealloc];
}

#pragma mark -
#pragma mark UIView Cycle
- (void)viewWillAppear:(BOOL)animated{
    [self.navigationController setNavigationBarHidden:NO];
    
    self.apiCmdShow_getAllShows = (ApiCmdShow_getAllShows *)[[DataBaseManager sharedInstance] getAllShowsListFromWeb:self];
}

- (void)viewWillDisappear:(BOOL)animated{
    
    //保存用户的选项
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    NSString *selectedTypeData = [NSString stringWithFormat:@"%d#%d#%d",_selectedType,_selectedTime,_selectedOrder];
    [userDefault setObject:selectedTypeData forKey:SShow_FilterType];
    [userDefault synchronize];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        [self updateData:0];
    });
    
    [self initUIBarItem];
    [self initData];
    [self initRefreshHeaderView];
    [self setTableViewDelegate];
}

#pragma mark -
#pragma mark 初始化数据
- (void)initUIBarItem{
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [backButton setFrame:CGRectMake(0, 0, 45, 30)];
    [backButton addTarget:self action:@selector(clickBackButton:) forControlEvents:UIControlEventTouchUpInside];
    [backButton setBackgroundImage:[UIImage imageNamed:@"bt_back_n@2x"] forState:UIControlStateNormal];
    [backButton setBackgroundImage:[UIImage imageNamed:@"bt_back_f@2x"] forState:UIControlStateHighlighted];
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    self.navigationItem.leftBarButtonItem = backItem;
    [backItem release];
    
}

- (void)initData{
    if (_mArray==nil) {
        _mArray = [[NSMutableArray alloc] initWithCapacity:10];
    }
    if (_mCacheArray==nil) {
        _mCacheArray = [[NSMutableArray alloc] initWithCapacity:10];
    }
    
    _maskView = [[UIControl alloc] initWithFrame:self.view.bounds];
    [_maskView setBackgroundColor:[UIColor colorWithWhite:0.000 alpha:0.680]];
    [_maskView addTarget:self action:@selector(clickMarkView:) forControlEvents:UIControlEventTouchUpInside];
    
    _showTableViewDelegate = [[ShowTableViewDelegate alloc] init];
    _showTableViewDelegate.parentViewController = self;
    
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    NSString *selectedTypeData = [userDefault objectForKey:SShow_FilterType];
    if (!isEmpty(selectedTypeData)) {
        NSArray *typeArray = [selectedTypeData componentsSeparatedByString:@"#"];
        for (int i=0;i<[typeArray count];i++) {
            int index = [[typeArray objectAtIndex:i] intValue];
            switch (i) {
                case 0:
                    [(UIButton *)[_typeBts objectAtIndex:index] setSelected:YES];
                    _selectedType = index;
                    break;
                case 1:
                    [(UIButton *)[_timeBts objectAtIndex:index] setSelected:YES];
                    _selectedTime = index;
                    break;
                default:
                    [(UIButton *)[_orderBts objectAtIndex:index] setSelected:YES];
                    _selectedOrder = index;
                    break;
            }
        }
    }else{
        [(UIButton *)[_typeBts objectAtIndex:0] setSelected:YES];
        [(UIButton *)[_timeBts objectAtIndex:0] setSelected:YES];
        [(UIButton *)[_orderBts objectAtIndex:0] setSelected:YES];
    }
}

- (void)setTableViewDelegate{
    _mTableView.dataSource = _showTableViewDelegate;
    _mTableView.delegate = _showTableViewDelegate;
}

- (void)initRefreshHeaderView{
    if (_refreshHeaderView == nil) {
        
        
        EGORefreshTableHeaderView *view = [[EGORefreshTableHeaderView alloc] initWithFrame: CGRectMake(0.0f, _mTableView.contentSize.height, _mTableView.frame.size.width, _mTableView.bounds.size.height)];
		view.delegate = _showTableViewDelegate;
        view.tag = EGOBottomView;
        view.backgroundColor = [UIColor clearColor];
		[_mTableView addSubview:view];
		self.refreshTailerView = view;
		[view release];
        view=nil;
        
        view = [[EGORefreshTableHeaderView alloc] initWithFrame: CGRectMake(0.0f, - _mTableView.bounds.size.height, _mTableView.frame.size.width, _mTableView.bounds.size.height)];
        view.delegate = _showTableViewDelegate;
        view.tag = EGOHeaderView;
        view.backgroundColor = [UIColor clearColor];
        [_mTableView addSubview:view];
        self.refreshHeaderView = view;
        [view release];
        view=nil;
    }
    
    [_refreshHeaderView refreshLastUpdatedDate];
    _showTableViewDelegate.mTableView = self.mTableView;
    _showTableViewDelegate.refreshHeaderView = self.refreshHeaderView;
    _showTableViewDelegate.refreshTailerView = self.refreshTailerView;
}

#pragma mark -
#pragma mark UIButton event

- (void)clickBackButton:(id)sender{
    
    [self.navigationController popViewControllerAnimated:YES];
}

//点击类型按钮
- (IBAction)clickTypeButton:(id)sender{
    
    if (_filterShowListType == NSFilterShowListTypeData) {
        return;
    }
    
    _filterShowListType = NSFilterShowListTypeData;
    
    [self cleanUpPanelView];
    
    _typeButton.selected = YES;
    [_typeView setAlpha:0];
    
    [self.view addSubview:_typeView];
    
    CGRect newFrame = _typeView.frame;
    newFrame.origin = CGPointMake(_typeButton.frame.origin.x, _typeButton.frame.origin.y);
    _typeView.frame = newFrame;
    
    [UIView animateWithDuration:0.2 animations:^{
        [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
        [_typeView setAlpha:1];
        CGRect newFrame = _typeView.frame;
        newFrame.origin = CGPointMake(_typeButton.frame.origin.x, _typeButton.frame.origin.y+_typeButton.frame.size.height);
        _typeView.frame = newFrame;
        _typeArrowImg.transform = CGAffineTransformMakeRotation(DEGREES_TO_RADIANS(180));
    } completion:^(BOOL finished) {
        
    }];
}

//点击时间按钮
- (IBAction)clickTimeButton:(id)sender{
    
    if (_filterShowListType == NSFilterShowListTimeData) {
        return;
    }
    
    _filterShowListType = NSFilterShowListTimeData;
    
    [self cleanUpPanelView];
    [_timeView setAlpha:0];
    _timeButton.selected = YES;
   
    [self.view addSubview:_timeView];
    
    CGRect newFrame = _timeView.frame;
    newFrame.origin = CGPointMake(_timeButton.frame.origin.x - (_timeView.frame.size.width-_timeButton.frame.size.width)/2,
                                  _timeButton.frame.origin.y);
    _timeView.frame = newFrame;
    
    [UIView animateWithDuration:0.2 animations:^{
        [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
        [_timeView setAlpha:1];
        CGRect newFrame = _timeView.frame;
        newFrame.origin = CGPointMake(_timeButton.frame.origin.x - (_timeView.frame.size.width-_timeButton.frame.size.width)/2,
                                      _timeButton.frame.origin.y+_timeButton.frame.size.height);
        _timeView.frame = newFrame;
         _timeArrowImg.transform = CGAffineTransformMakeRotation(DEGREES_TO_RADIANS(180));
    } completion:^(BOOL finished) {
        
    }];
}

//点击顺序按钮
- (IBAction)clickOrderButton:(id)sender{
    
    if (_filterShowListType == NSFilterShowListOrderData) {
        return;
    }
    
    _filterShowListType = NSFilterShowListOrderData;
    
    [self cleanUpPanelView];
    [_orderView setAlpha:0];
    _orderButton.selected = YES;
    
    [self.view addSubview:_orderView];
    
    CGRect newFrame = _orderView.frame;
    newFrame.origin = CGPointMake(_orderButton.frame.origin.x - (_orderView.frame.size.width-_orderButton.frame.size.width),
                                  _orderButton.frame.origin.y);
    _orderView.frame = newFrame;
    
    [UIView animateWithDuration:0.2 animations:^{
        [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
        [_orderView setAlpha:1];
        CGRect newFrame = _orderView.frame;
        newFrame.origin = CGPointMake(_orderButton.frame.origin.x - (_orderView.frame.size.width-_orderButton.frame.size.width),
                                      _orderButton.frame.origin.y+_orderButton.frame.size.height);
        _orderView.frame = newFrame;
        _orderArrowImg.transform = CGAffineTransformMakeRotation(DEGREES_TO_RADIANS(180));
    } completion:^(BOOL finished) {
        
    }];
}

- (void)cleanUpPanelView{
    [_timeView removeFromSuperview];
    [_orderView removeFromSuperview];
    [_typeView removeFromSuperview];
    
    _timeButton.selected = NO;
    _orderButton.selected = NO;
    _typeButton.selected = NO;
    
    [_mTableView setScrollEnabled:NO];
    [_mTableView addSubview:_maskView];
    
    _typeArrowImg.transform = CGAffineTransformIdentity;
    _timeArrowImg.transform = CGAffineTransformIdentity;
    _orderArrowImg.transform = CGAffineTransformIdentity;
}

- (IBAction)clickMarkView:(id)sender{
    [self cleanUpPanelView];
    _filterShowListType = NSFilterShowListNoneData;
    [_maskView removeFromSuperview];
    [_mTableView setScrollEnabled:YES];
}

- (IBAction)clickTypeSubButtonDown:(id)sender{
    UIButton *bt = (UIButton *)sender;
    int tag = [bt tag];
    
    [self cleanUpTypeSubButton];
    [bt setBackgroundColor:[UIColor colorWithRed:0.047 green:0.678 blue:1.000 alpha:1.000]];
    
    _selectedType = tag-1;
}

- (void)cleanUpTypeSubButton{
    for (UIButton *bt in _typeBts) {
        [bt setBackgroundColor:[UIColor clearColor]];
    }
}

- (IBAction)clickTimeSubButtonDown:(id)sender{
    UIButton *bt = (UIButton *)sender;
    int tag = [bt tag];
    
    [self cleanUpTimeSubButton];
    [bt setBackgroundColor:[UIColor colorWithRed:0.047 green:0.678 blue:1.000 alpha:1.000]];
    
    _selectedTime = tag-1;
}

- (void)cleanUpTimeSubButton{
    for (UIButton *bt in _timeBts) {
        [bt setBackgroundColor:[UIColor clearColor]];
    }
}

- (IBAction)clickOrderSubButtonDown:(id)sender{
    UIButton *bt = (UIButton *)sender;
    int tag = [bt tag];
    
    [self cleanUpOrderSubButton];
    [bt setBackgroundColor:[UIColor colorWithRed:0.047 green:0.678 blue:1.000 alpha:1.000]];
    
    _selectedOrder = tag-1;
}

- (void)cleanUpOrderSubButton{
    for (UIButton *bt in _orderBts) {
        [bt setBackgroundColor:[UIColor clearColor]];
    }
}

#pragma mark -
#pragma mark apiNotiry
-(void)apiNotifyResult:(id)apiCmd error:(NSError *)error{
    
    if (error) {
        return;
    }
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        [[DataBaseManager sharedInstance] insertShowsIntoCoreDataFromObject:[apiCmd responseJSONObject] withApiCmd:apiCmd];
        
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
    return _apiCmdShow_getAllShows;
}

- (void)updateData:(int)tag
{
    ABLogger_int(tag);
    switch (tag) {
        case 0:
        case API_SShow_Type_All_Cmd:
        {
            NSArray *array = [[DataBaseManager sharedInstance] getAllShowsListFromCoreData];
            self.showsArray = array;
            ABLoggerDebug(@"演出 count ==== %d",[self.showsArray count]);
            
            [self setTableViewDelegate];
            dispatch_sync(dispatch_get_main_queue(), ^{
                if (isNull(_showsArray)||[_showsArray count]==0) {
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

- (void)didReceiveMemoryWarning
{
    ABLoggerWarn(@"接收到内存警告了");
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
