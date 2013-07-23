//
//  CinemaMovieViewController.m
//  WanShangLe
//
//  Created by stephenliu on 13-6-14.
//  Copyright (c) 2013年 stephenliu. All rights reserved.
//

#import "CinemaMovieViewController.h"
#import "ApiCmdMovie_getSchedule.h"
#import "CinemaMovieTableViewDelegate.h"
#import "CinemaViewController.h"
#import "ASIHTTPRequest.h"
#import "MovieViewController.h"
#import "MovieDetailViewController.h"
#import "AppDelegate.h"
#import "MMovie.h"
#import "MCinema.h"
#import "MSchedule.h"
#import "iCarousel.h"
#import "ReflectionView.h"
#import "UIImageView+WebCache.h"
#import <ShareSDK/ShareSDK.h>

#define CoverFlowItemTag 100

@interface CinemaMovieViewController ()<ApiNotify,iCarouselDataSource,iCarouselDelegate>{
    
}
@property(nonatomic,retain) NSString *todayWeek;
@property(nonatomic,retain) NSString *tomorrowWeek;
@property(nonatomic,retain) ApiCmdMovie_getSchedule *apiCmdMovie_getSchedule;
@property(nonatomic,retain) CinemaMovieTableViewDelegate *cinemaMovieTableViewDelegate;
@property(nonatomic,retain) MSchedule *mSchedule;
@property(nonatomic,retain) NSArray *todaySchedules;
@property(nonatomic,retain) NSArray *tomorrowSchedules;
@property(nonatomic,retain) NSArray *moviesArray;
@end

@implementation CinemaMovieViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
    }
    return self;
}

- (void)dealloc{
    
    self.todayButton = nil;
    self.tomorrowButton = nil;
    self.mTableView = nil;
    self.coverFlow = nil;
    self.movieName = nil;
    self.movieRating = nil;
    self.mMovie = nil;
    self.mCinema = nil;
    
    self.todaySchedules = nil;
    self.todaySchedules = nil;
    self.schedulesArray = nil;
    self.moviesArray = nil;
    self.cinemaMovieTableViewDelegate = nil;
    self.apiCmdMovie_getSchedule = nil;
    
    self.todayWeek = nil;
    self.tomorrowButton = nil;
    
    self.mSchedule = nil;
    
    [super dealloc];
}

-(void)cancelApiCmd{
    [[self.apiCmdMovie_getSchedule httpRequest] clearDelegatesAndCancel];
    [self.apiCmdMovie_getSchedule setDelegate:nil];
    self.apiCmdMovie_getSchedule = nil;
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
}

- (void)awakeFromNib{
    [super awakeFromNib];
}

- (void)setTableViewDelegate{
    _mTableView.delegate = _cinemaMovieTableViewDelegate;
    _mTableView.dataSource = _cinemaMovieTableViewDelegate;
    _cinemaMovieTableViewDelegate.parentViewController = self;
    _coverFlow.delegate = self;
    _coverFlow.dataSource = self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = _mCinema.name;
    
    self.moviesArray = [[DataBaseManager sharedInstance] getAllMoviesListFromCoreData];
    
    if (!_cinemaMovieTableViewDelegate) {
        _cinemaMovieTableViewDelegate = [[CinemaMovieTableViewDelegate alloc] init];
    }
    [self setTableViewDelegate];
    
    [_todayButton setBackgroundColor:[UIColor colorWithRed:0.047 green:0.678 blue:1.000 alpha:1.000]];
    _todayButton.selected =YES;
    
    _coverFlow.type = iCarouselTypeLinear;
    [_coverFlow reloadData];
    
    [self initData];
    [self createBarButtonItem];
    
    [_mTableView setTableHeaderView:_headerView];
}

- (void)initData{
    self.cinemaName.text = _mCinema.name;
    self.cinemaAddress.text = _mCinema.address;
    self.title = _mCinema.name;    
}

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
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)clickMovieInfo:(id)sender{
    ABLoggerInfo(@"");
    MovieDetailViewController *movieDetailController = [[MovieDetailViewController alloc] initWithNibName:@"MovieDetailViewController" bundle:nil];
    movieDetailController.mMovie = self.mMovie;
    [self.navigationController pushViewController:movieDetailController animated:YES];
    [movieDetailController release];
}

- (void)cleanUpButtonBackground{
    [_tomorrowButton setBackgroundColor:[UIColor clearColor]];
    [_todayButton setBackgroundColor:[UIColor clearColor]];
}

- (IBAction)clickTodayButton:(id)sender{
    [self cleanUpButtonBackground];
    _tomorrowButton.selected = NO;
    _todayButton.selected = YES;
    [_todayButton setBackgroundColor:[UIColor colorWithRed:0.047 green:0.678 blue:1.000 alpha:1.000]];
    
    [self refreshTodaySchedule];
}

- (void)refreshTodaySchedule{
    
    self.todaySchedules = [[DataBaseManager sharedInstance] deleteUnavailableSchedules:_todaySchedules];
    self.schedulesArray = self.todaySchedules;
    if (isNull(self.schedulesArray) || [self.schedulesArray count]==0) {
      [_mTableView setTableFooterView:_footerView];
    }else{
      [_mTableView setTableFooterView:[[[UIView alloc] initWithFrame:CGRectZero] autorelease]];
    }
    
    [_todayButton setTitle:[NSString stringWithFormat:@"今天(%@)%d场",_todayWeek,[_schedulesArray count]] forState:UIControlStateNormal];
    [_mTableView reloadData];
}

- (IBAction)clickTomorrowButton:(id)sender{
    [self cleanUpButtonBackground];
    _tomorrowButton.selected = YES;
    _todayButton.selected = NO;
    [_tomorrowButton setBackgroundColor:[UIColor colorWithRed:0.047 green:0.678 blue:1.000 alpha:1.000]];

    [self refreshTomorrowSchedule];
}

- (void)refreshTomorrowSchedule{
    self.tomorrowSchedules = [[DataBaseManager sharedInstance] deleteUnavailableSchedules:_tomorrowSchedules];
    self.schedulesArray = self.tomorrowSchedules;
    if (isNull(self.schedulesArray) || [self.schedulesArray count]==0) {
        [_mTableView setTableFooterView:_footerView];
    }else{
        [_mTableView setTableFooterView:[[[UIView alloc] initWithFrame:CGRectZero] autorelease]];
    }
    
    [_tomorrowButton setTitle:[NSString stringWithFormat:@"明天(%@)%d场",_tomorrowWeek,[_schedulesArray count]] forState:UIControlStateNormal];
    [_mTableView reloadData];
}

#pragma mark -
#pragma mark iCarousel methods

- (NSUInteger)numberOfItemsInCarousel:(iCarousel *)carousel
{
    return [_moviesArray count];
}

- (UIView *)carousel:(iCarousel *)carousel viewForItemAtIndex:(NSUInteger)index reusingView:(UIView *)view
{
    UIImageView *view2 = nil;
	
	//create new view if no view is available for recycling
	if (view == nil)
	{
        //set up reflection view
		view = [[[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 80, 120)] autorelease];
        
        view2 = [[[UIImageView alloc] initWithFrame:view.bounds] autorelease];
        view2.backgroundColor = [UIColor clearColor];
        [view addSubview:view2];
        [view2 setTag:CoverFlowItemTag];
	}
	else
	{
        view2 = (UIImageView *)[view viewWithTag:CoverFlowItemTag];
	}
    
    ABLoggerDebug(@"%@",[[_moviesArray objectAtIndex:index] webImg]);
    [view2 setImageWithURL:[NSURL URLWithString:[[_moviesArray objectAtIndex:index] webImg]]
          placeholderImage:[UIImage imageNamed:@"movie_placeholder@2x"]
                   options:SDWebImageRetryFailed
                 completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
                     //                     [[view2 superview] update];
                 }];
    
	return view;
}

- (CGFloat)carousel:(iCarousel *)carousel valueForOption:(iCarouselOption)option withDefault:(CGFloat)value
{
    //customize carousel display
    switch (option)
    {
        case iCarouselOptionWrap:
        {
            //normally you would hard-code this to YES or NO
            return NO;
        }
        case iCarouselOptionSpacing:
        {
            //add a bit of spacing between the item views
            //            return value * 1.1f;
            return value * 1.1f;
        }
        default:
        {
            return value;
        }
    }
}

- (void)carouselDidEndScrollingAnimation:(iCarousel *)carousel{
    ABLoggerDebug(@"carouselDidEndScrollingAnimation ====== %d",carousel.currentItemIndex);
    
    MMovie *aMovie = [_moviesArray objectAtIndex:carousel.currentItemIndex];
    self.mMovie = aMovie;

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

    _movieName.text =aMovie.name;
    int ratingCount = [aMovie.ratingpeople intValue];
    NSString *countLevel = @"人";
    if (ratingCount>10000) {
        ratingCount = ratingCount/10000;
        countLevel = @"万人";
    }
    _movieRating.text = [NSString stringWithFormat:@"%@ : %0.1f (%d%@)",aMovie.ratingFrom,[aMovie.rating floatValue],ratingCount,countLevel];
    
    [self cancelApiCmd];
    self.apiCmdMovie_getSchedule = (ApiCmdMovie_getSchedule *)[[DataBaseManager sharedInstance] getScheduleFromWebWithaMovie:_mMovie andaCinema:_mCinema timedistance:ScheduleToday delegate:self ];
    
    [self changeMovieDisplayData:aMovie];
    
    [_mTableView setTableFooterView:nil];
    self.schedulesArray = nil;
    [_mTableView reloadData];
}

- (void)changeMovieDisplayData:(MMovie*)aMovie{
    
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:4];
    if ([aMovie.newMovie boolValue]) {
        [array addObject:_movie_image_new];
    }
    if ([aMovie.twoD boolValue]) {
        [array addObject:_movie_image_3d];
    }
    if ([aMovie.threeD boolValue]) {
        [array addObject:_movie_image_imx];
    }
    if ([aMovie.iMaxD boolValue]) {
        [array addObject:_movie_image_3dimx];
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
    int width = tFrame.origin.x+ tFrame.size.width;
    ABLoggerInfo(@"view frame ===== %@",NSStringFromCGRect(view.frame));
    [_movieDetailControl addSubview:view];
    [view release];
    
    
    CGSize nameSize = [aMovie.name sizeWithFont:[_movieName font]
                                        constrainedToSize:CGSizeMake((_movieDetailControl.bounds.size.width-width-_movieDetailControl.frame.origin.x-5),
                                                                     _movieName.bounds.size.height)];
    
    CGRect cell_newFrame = _movieName.frame;
    cell_newFrame.size.width = nameSize.width;
    _movieName.frame = cell_newFrame;
    
    int view_x = _movieName.frame.origin.x+nameSize.width +10;
    [view setFrame:CGRectMake(view_x, 0, width, 15)];
    CGPoint newCenter = view.center;
    newCenter.y = _movieName.center.y;
    view.center = newCenter;
}


#pragma mark -
#pragma mark apiNotiry
-(void)apiNotifyResult:(id)apiCmd error:(NSError *)error{
    
    if (error) {
        return;
    }
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        self.mSchedule = [[DataBaseManager sharedInstance] insertScheduleIntoCoreDataFromObject:[apiCmd responseJSONObject]
                                                                    withApiCmd:apiCmd
                                                                    withaMovie:_mMovie
                                                                    andaCinema:_mCinema];
        
        int tag = [[apiCmd httpRequest] tag];
        NSString *timedistance = [[[(ApiCmdMovie_getSchedule *)apiCmd timedistance] retain] autorelease];
        [self updateData:tag timeDistance:timedistance];
        
    });
    
}

- (void)apiNotifyLocationResult:(id)apiCmd cacheOneData:(id)cacheData{
    
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        int tag = [[apiCmd httpRequest] tag];
        self.mSchedule = (MSchedule *)cacheData;
        NSString *timedistance = [[[(ApiCmdMovie_getSchedule *)apiCmd timedistance] retain] autorelease];
        [self updateData:tag timeDistance:timedistance];
//    });
}

- (ApiCmd *)apiGetDelegateApiCmd{
    return (ApiCmd *)_apiCmdMovie_getSchedule;
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
