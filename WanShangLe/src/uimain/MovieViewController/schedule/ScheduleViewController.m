//
//  ScheduleViewController.m
//  WanShangLe
//
//  Created by liu on 6/13/13.
//  Copyright (c) 2013 stephenliu. All rights reserved.
//

#import "ScheduleViewController.h"
#import "ApiCmdMovie_getSchedule.h"
#import "ScheduleTableViewDelegate.h"
#import "CinemaViewController.h"
#import "CinemaMovieViewController.h"
#import "MovieViewController.h"
#import "MMovie.h"
#import "MCinema.h"
#import "MSchedule.h"
#import "ASIHTTPRequest.h"
#import "ApiCmd.h"
#import "AppDelegate.h"
#import <ShareSDK/ShareSDK.h>

#define EmBedFooterView 100

@interface ScheduleViewController ()<ApiNotify>{
    
}
@property(nonatomic,retain) NSString *todayWeek;
@property(nonatomic,retain) NSString *tomorrowWeek;
@property(nonatomic,retain) ApiCmdMovie_getSchedule *apiCmdMovie_getSchedule;
@property(nonatomic,retain) ScheduleTableViewDelegate *scheduleTableViewDelegate;
@property(nonatomic,retain) NSArray *todaySchedules;
@property(nonatomic,retain) NSArray *tomorrowSchedules;
@property(nonatomic,retain) MSchedule *mSchedule;

@end

@implementation ScheduleViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
    }
    return self;
}

- (void)dealloc{
    
    [self cancelApiCmd];
    
    
    self.todayButton = nil;
    self.tomorrowButton = nil;
    self.cinemaButton = nil;
    
    self.scheduleTableViewDelegate = nil;
    self.mTableView = nil;
    self.mTableView.delegate = nil;
    self.mTableView.dataSource = nil;

    self.mMovie = nil;
    self.mCinema = nil;
    
    self.todaySchedules = nil;
    self.tomorrowSchedules = nil;
    self.schedulesArray = nil;
    
    self.todayWeek = nil;
    self.tomorrowButton = nil;
    self.mSchedule = nil;
    
    self.apiCmdMovie_getSchedule = nil;
    [super dealloc];
}

-(void)cancelApiCmd{
    [self.apiCmdMovie_getSchedule.httpRequest clearDelegatesAndCancel];
    [[[ApiClient defaultClient] requestArray] removeObject:_apiCmdMovie_getSchedule];
    self.apiCmdMovie_getSchedule.delegate = nil;
}

#pragma mark -
#pragma mark view cycle
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [_todayButton setSelected:NO];
    [self clickTodayButton:nil];
}

- (void)awakeFromNib{
    [super awakeFromNib];
}

- (void)setTableViewDelegate{
    _mTableView.delegate = _scheduleTableViewDelegate;
    _mTableView.dataSource = _scheduleTableViewDelegate;
    _scheduleTableViewDelegate.parentViewController = self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self initData];
    [self createBarButtonItem];
    
    if (!_scheduleTableViewDelegate) {
        _scheduleTableViewDelegate = [[ScheduleTableViewDelegate alloc] init];
    }
    [self setTableViewDelegate];
    
    [_todayButton setBackgroundColor:[UIColor colorWithRed:0.047 green:0.678 blue:1.000 alpha:1.000]];

}

- (void)initData{
    self.title = _mMovie.name;
    
    [_mTableView setTableHeaderView:_headerView];
    
    //change today tomorrow button title
    DataBaseManager *dbManager = [DataBaseManager sharedInstance];
    if (isEmpty(_todayWeek)) {
        self.todayWeek = [dbManager getTodayWeek];
    }
    
    if (isEmpty(_tomorrowWeek)) {
        self.tomorrowWeek = [dbManager getTomorrowWeek];
    }
    
    [_todayButton setTitle:[NSString stringWithFormat:@"今天(%@)",_todayWeek] forState:UIControlStateNormal];
    [_tomorrowButton setTitle:[NSString stringWithFormat:@"明天(%@)",_tomorrowWeek] forState:UIControlStateNormal];
    
    _todayButton.selected = YES;
    [_mTableView setTableFooterView:[[[UIView alloc] initWithFrame:CGRectZero] autorelease]];
    
    _cinemaNameLabel.text = _mCinema.name;
    _cinemaAddreLabel.text = _mCinema.address;
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:4];
    if ([_mCinema.zhekou boolValue]) {
        [array addObject:_cinema_image_zhekou];
    }
    if ([_mCinema.juan boolValue]) {
        [array addObject:_cinema_image_juan];
    }
    if ([_mCinema.seat boolValue]) {
        [array addObject:_cinema_image_seat];
    }
    if ([_mCinema.tuan boolValue]) {
        [array addObject:_cinema_image_tuan];
    }
    
    int twidth = 0;
    UIView *view = [[UIView alloc] init];
    for (int i=0;i<[array count];i++) {
        
        UIView *tview = [array objectAtIndex:i];
        CGRect tframe = tview.frame;
        
        tframe.origin.x = twidth;
        twidth += tframe.size.width + 5;
        
        tview.frame = tframe;
        [view addSubview:tview];
    }
    
    CGRect tFrame = [(UIView *)[array lastObject] frame];
    int width = (int)tFrame.origin.x+ tFrame.size.width;
    [_cinemaButton addSubview:view];
    [view release];
    
    int nameSize_width = (_cinemaButton.bounds.size.width-width-_cinemaNameLabel.frame.origin.x);
    
    CGSize nameSize = [_mCinema.name sizeWithFont:_cinemaNameLabel.font
                                constrainedToSize:CGSizeMake(nameSize_width,MAXFLOAT)];
    
    CGRect cell_newFrame = _cinemaNameLabel.frame;
    cell_newFrame.size.width = nameSize.width;
    _cinemaNameLabel.frame = cell_newFrame;
    
    int view_x = _cinemaNameLabel.frame.origin.x+_cinemaNameLabel.frame.size.width +10;
    [view setFrame:CGRectMake(view_x, 0, width, 15)];
    CGPoint newCenter = view.center;
    newCenter.y = _cinemaNameLabel.center.y;
    view.center = newCenter;
}

#pragma mark -
#pragma mark init Data
- (void)createBarButtonItem{
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [backButton setFrame:CGRectMake(0, 0, 45, 30)];
    [backButton addTarget:self action:@selector(clickBackButton:) forControlEvents:UIControlEventTouchUpInside];
    [backButton setBackgroundImage:[UIImage imageNamed:@"bt_back_n@2x"] forState:UIControlStateNormal];
    [backButton setBackgroundImage:[UIImage imageNamed:@"bt_back_f@2x"] forState:UIControlStateHighlighted];
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    self.navigationItem.leftBarButtonItem = backItem;
    [backItem release];
    
    UIButton *shareBt = [UIButton buttonWithType:UIButtonTypeCustom];
    [shareBt setFrame:CGRectMake(0, 0, 45, 32)];
    [shareBt addTarget:self action:@selector(shareButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [shareBt setBackgroundImage:[UIImage imageNamed:@"btn_share_n@2x"] forState:UIControlStateNormal];
    [shareBt setBackgroundImage:[UIImage imageNamed:@"btn_share_f@2x"] forState:UIControlStateHighlighted];
    UIBarButtonItem *shareItem = [[UIBarButtonItem alloc] initWithCustomView:shareBt];
    self.navigationItem.rightBarButtonItem = shareItem;
    [shareItem release];
}

#pragma mark -
#pragma mark Button Event
- (void)clickBackButton:(id)sender{
    
    [[CacheManager sharedInstance].rootNavController popViewControllerAnimated:YES];
}

- (IBAction)clickCinemaButton:(id)sender{
    CinemaMovieViewController *cinemaMovieController = [[CinemaMovieViewController alloc]
                                                        initWithNibName:(iPhone5?@"CinemaMovieViewController_5":@"CinemaMovieViewController")
                                                        bundle:nil];
    cinemaMovieController.mCinema = self.mCinema;
    cinemaMovieController.mMovie = self.mMovie;
    
    [[CacheManager sharedInstance].rootNavController pushViewController:cinemaMovieController animated:YES];
    
    [cinemaMovieController release];
}

- (void)cleanUpButtonBackground{
    [_tomorrowButton setBackgroundColor:[UIColor clearColor]];
    [_todayButton setBackgroundColor:[UIColor clearColor]];
}

- (IBAction)clickTodayButton:(id)sender{
    
    if (_todayButton.selected)return;
    
    [self cancelApiCmd];
    [self cleanUpButtonBackground];
    _tomorrowButton.selected = NO;
    _todayButton.selected = YES;
    [_todayButton setBackgroundColor:[UIColor colorWithRed:0.047 green:0.678 blue:1.000 alpha:1.000]];
    
    self.apiCmdMovie_getSchedule =  (ApiCmdMovie_getSchedule *)[[DataBaseManager sharedInstance] getScheduleFromWebWithaMovie:_mMovie andaCinema:_mCinema timedistance:ScheduleToday delegate:self];//每次视图加载刷新排期数据
    
    [self refreshTodaySchedule];
}

- (void)refreshTodaySchedule{
    
    self.todaySchedules = [[DataBaseManager sharedInstance] deleteUnavailableSchedules:_todaySchedules];
    self.schedulesArray = self.todaySchedules;
    if (isNull(self.schedulesArray) || [self.schedulesArray count]==0) {
        [self setTableViewFooterViewHaveData:NO];
    }else{
        [self setTableViewFooterViewHaveData:YES];
    }
    
    [_todayButton setTitle:[NSString stringWithFormat:@"今天(%@)%d场",_todayWeek,[_schedulesArray count]] forState:UIControlStateNormal];
    [_mTableView reloadData];
}

- (IBAction)clickTomorrowButton:(id)sender{
    
    if (_tomorrowButton.selected)return;
    
    [self cancelApiCmd];
    [self cleanUpButtonBackground];
    _tomorrowButton.selected = YES;
    _todayButton.selected = NO;
    [_tomorrowButton setBackgroundColor:[UIColor colorWithRed:0.047 green:0.678 blue:1.000 alpha:1.000]];
    
    self.apiCmdMovie_getSchedule =  (ApiCmdMovie_getSchedule *)[[DataBaseManager sharedInstance] getScheduleFromWebWithaMovie:_mMovie andaCinema:_mCinema timedistance:ScheduleTomorrow delegate:self];//每次视图加载刷新排期数据
    
    [self refreshTomorrowSchedule];
}

- (void)refreshTomorrowSchedule{
    self.tomorrowSchedules = [[DataBaseManager sharedInstance] deleteUnavailableSchedules:_tomorrowSchedules];
    self.schedulesArray = self.tomorrowSchedules;
    if (isNull(self.schedulesArray) || [self.schedulesArray count]==0) {
        [self setTableViewFooterViewHaveData:NO];
    }else{
        [self setTableViewFooterViewHaveData:YES];
    }
    
    [_tomorrowButton setTitle:[NSString stringWithFormat:@"明天(%@)%d场",_tomorrowWeek,[_schedulesArray count]] forState:UIControlStateNormal];
    [_mTableView reloadData];
}

- (void)setTableViewFooterViewHaveData:(BOOL)haveData{
    
    UIView *tableViewFooter = nil;
    if (_mTableView.tableFooterView.tag==100) {
        tableViewFooter = [[[UIView alloc] init] autorelease];
        [tableViewFooter setBackgroundColor:[UIColor redColor]];
        tableViewFooter.tag = EmBedFooterView;
        _mTableView.tableFooterView = nil;
        if (!haveData) {
            CGRect newFrame = _footerView.frame;
            newFrame.origin.y = 0;
            _footerView.frame = newFrame;
            [tableViewFooter addSubview:_footerView];
            
            newFrame = _addFavoriteFooterView.frame;
            newFrame.origin.y = _footerView.frame.size.height;
            _addFavoriteFooterView.frame = newFrame;
            tableViewFooter.frame = CGRectMake(0, 0, self.view.bounds.size.width, _footerView.bounds.size.height+_addFavoriteFooterView.bounds.size.height);
            [tableViewFooter addSubview:_addFavoriteFooterView];
            _mTableView.tableFooterView = tableViewFooter;
        }else{
            [_footerView removeFromSuperview];
            CGRect newFrame = _addFavoriteFooterView.frame;
            newFrame.origin.y = 0;
            _addFavoriteFooterView.frame = newFrame;
            tableViewFooter.frame = CGRectMake(0, 0, self.view.bounds.size.width, _addFavoriteFooterView.bounds.size.height);
            [tableViewFooter addSubview:_addFavoriteFooterView];
            _mTableView.tableFooterView = tableViewFooter;
        }
    }else{
        if (!haveData) {
            [_mTableView setTableFooterView:_footerView];
        }else{
            [_mTableView setTableFooterView:[[[UIView alloc] initWithFrame:CGRectZero] autorelease]];
        }
    }
}
#pragma mark -
#pragma mark apiNotiry
-(void)apiNotifyResult:(id)apiCmd error:(NSError *)error{
    
    if (error){
        return;
    }
    
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    
        self.mSchedule = [[DataBaseManager sharedInstance] insertScheduleIntoCoreDataFromObject:[apiCmd responseJSONObject]
                                                                    withApiCmd:apiCmd
                                                                    withaMovie:_mMovie
                                                                    andaCinema:_mCinema];
        int tag = [[apiCmd httpRequest] tag];
         NSString *timedistance = [[[(ApiCmdMovie_getSchedule *)apiCmd timedistance] retain] autorelease];
        [self updateData:tag timeDistance:timedistance];
        
//    });
    
}

- (ApiCmd *)apiGetDelegateApiCmd{
    return _apiCmdMovie_getSchedule;
}

- (void)apiNotifyLocationResult:(id)apiCmd cacheOneData:(id)cacheData{
    
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        int tag = [[apiCmd httpRequest] tag];
        self.mSchedule = (MSchedule *)cacheData;
        NSString *timedistance = [[[(ApiCmdMovie_getSchedule *)apiCmd timedistance] retain] autorelease];
        [self updateData:tag timeDistance:timedistance];
//    });
}

- (void)updateData:(int)tag timeDistance:(NSString *)timedistance
{
    ABLogger_int(tag);
    switch (tag) {
        case 0:
        case API_MScheduleCmd:
        {
            NSDictionary *responseDic = _mSchedule.scheduleInfo;
            [self formatCinemaData:responseDic timeDistance:timedistance];
        }
            break;
        default:
        {
            NSAssert(0, @"没有从网络抓取到数据");
        }
            break;
    }
}

- (void)formatCinemaData:(NSDictionary *)responseDic  timeDistance:(NSString *)timedistance{
    ABLoggerMethod();
    NSDictionary *schedules = [responseDic objectForKey:@"scheduling"];
    NSArray *resultArray = [schedules objectForKey:@"starts"];
    
    if ([timedistance intValue]==0) {
        self.todaySchedules = resultArray;
    }else{
        self.tomorrowSchedules = resultArray;
    }
    
    [self setTableViewDelegate];
    
//    dispatch_sync(dispatch_get_main_queue(), ^{
        if (_todayButton.selected) {
            [self refreshTodaySchedule];
        }else if(_tomorrowButton.selected){
            [self refreshTomorrowSchedule];
        }
//    });
}

- (void)shareButtonClick:(id)sender{
    
    AppDelegate *_appDelegate = [AppDelegate appDelegateInstance];
    
    //定义菜单分享列表
    NSArray *shareList = [ShareSDK getShareListWithType:ShareTypeWeixiTimeline, ShareTypeWeixiSession, ShareTypeSMS,nil];
    
    //创建分享内容
    NSString *imagePath = [[NSBundle mainBundle] pathForResource:IMAGE_NAME ofType:IMAGE_EXT];
    id<ISSContent> publishContent = [ShareSDK content:CONTENT
                                       defaultContent:@"hello"
                                                image:[ShareSDK imageWithPath:imagePath]
                                                title:@"ShareSDK"
                                                  url:@"http://www.sharesdk.cn"
                                          description:@"这是一条测试信息"
                                            mediaType:SSPublishContentMediaTypeNews];
    
    //定制微信好友信息
    [publishContent addWeixinSessionUnitWithType:INHERIT_VALUE
                                         content:INHERIT_VALUE
                                           title:@"Hello 微信好友!"
                                             url:INHERIT_VALUE
                                           image:INHERIT_VALUE
                                    musicFileUrl:nil
                                         extInfo:nil
                                        fileData:nil
                                    emoticonData:nil];
    
    //定制微信朋友圈信息
    [publishContent addWeixinTimelineUnitWithType:[NSNumber numberWithInteger:SSPublishContentMediaTypeMusic]
                                          content:INHERIT_VALUE
                                            title:@"Hello 微信朋友圈!"
                                              url:@"http://y.qq.com/i/song.html#p=7B22736F6E675F4E616D65223A22E4BDA0E4B88DE698AFE79C9FE6ADA3E79A84E5BFABE4B990222C22736F6E675F5761704C69766555524C223A22687474703A2F2F74736D7573696332342E74632E71712E636F6D2F586B303051563558484A645574315070536F4B7458796931667443755A68646C2F316F5A4465637734356375386355672B474B304964794E6A3770633447524A574C48795333383D2F3634363232332E6D34613F7569643D32333230303738313038266469723D423226663D312663743D3026636869643D222C22736F6E675F5769666955524C223A22687474703A2F2F73747265616D31382E71716D757369632E71712E636F6D2F33303634363232332E6D7033222C226E657454797065223A2277696669222C22736F6E675F416C62756D223A22E5889BE980A0EFBC9AE5B08FE5B7A8E89B8B444E414C495645EFBC81E6BC94E594B1E4BC9AE5889BE7BAAAE5BD95E99FB3222C22736F6E675F4944223A3634363232332C22736F6E675F54797065223A312C22736F6E675F53696E676572223A22E4BA94E69C88E5A4A9222C22736F6E675F576170446F776E4C6F616455524C223A22687474703A2F2F74736D757369633132382E74632E71712E636F6D2F586C464E4D31354C5569396961495674593739786D436534456B5275696879366A702F674B65356E4D6E684178494C73484D6C6A307849634A454B394568572F4E3978464B316368316F37636848323568413D3D2F33303634363232332E6D70333F7569643D32333230303738313038266469723D423226663D302663743D3026636869643D2673747265616D5F706F733D38227D"
                                            image:INHERIT_VALUE
                                     musicFileUrl:@"http://mp3.mwap8.com/destdir/Music/2009/20090601/ZuiXuanMinZuFeng20090601119.mp3"
                                          extInfo:nil
                                         fileData:nil
                                     emoticonData:nil];
    
    //创建容器
    id<ISSContainer> container = [ShareSDK container];
    [container setIPadContainerWithView:sender arrowDirect:UIPopoverArrowDirectionUp];
    
    id<ISSAuthOptions> authOptions = [ShareSDK authOptionsWithAutoAuth:YES
                                                         allowCallback:YES
                                                         authViewStyle:SSAuthViewStyleFullScreenPopup
                                                          viewDelegate:nil
                                               authManagerViewDelegate:_appDelegate.viewDelegate];
    
    //在授权页面中添加关注官方微博
    [authOptions setFollowAccounts:[NSDictionary dictionaryWithObjectsAndKeys:
                                    [ShareSDK userFieldWithType:SSUserFieldTypeName value:@"ShareSDK"],
                                    SHARE_TYPE_NUMBER(ShareTypeSinaWeibo),
                                    [ShareSDK userFieldWithType:SSUserFieldTypeName value:@"ShareSDK"],
                                    SHARE_TYPE_NUMBER(ShareTypeTencentWeibo),
                                    nil]];
    
    //显示分享菜单
    [ShareSDK showShareActionSheet:container
                         shareList:shareList
                           content:publishContent
                     statusBarTips:YES
                       authOptions:authOptions
                      shareOptions:[ShareSDK defaultShareOptionsWithTitle:nil
                                                          oneKeyShareList:[NSArray defaultOneKeyShareList]
                                                           qqButtonHidden:NO
                                                    wxSessionButtonHidden:NO
                                                   wxTimelineButtonHidden:NO
                                                     showKeyboardOnAppear:NO
                                                        shareViewDelegate:_appDelegate.viewDelegate
                                                      friendsViewDelegate:_appDelegate.viewDelegate
                                                    picViewerViewDelegate:nil]
                            result:^(ShareType type, SSPublishContentState state, id<ISSStatusInfo> statusInfo, id<ICMErrorInfo> error, BOOL end) {
                                if (state == SSPublishContentStateSuccess)
                                {
                                    NSLog(@"分享成功");
                                }
                                else if (state == SSPublishContentStateFail)
                                {
                                    NSLog(@"分享失败,错误码:%d,错误描述:%@", [error errorCode], [error errorDescription]);
                                }
                            }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
}

@end
