//
//  CinemaMovieViewController.m
//  WanShangLe
//
//  Created by stephenliu on 13-6-14.
//  Copyright (c) 2013年 stephenliu. All rights reserved.
//

#import "CinemaMovieViewController.h"
#import "ApiCmdMovie_getSchedule.h"
#import "ApiCmdMovie_getAllMovies.h"
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
#import "SIAlertView.h"
#import "NSMutableArray+TKCategory.h"
#import "UIImage+Crop.h"

#define CoverFlowItemTag 100
#define TuanViewTag 50

@interface CinemaMovieViewController ()<ApiNotify,iCarouselDataSource,iCarouselDelegate>{
    
}
@property(nonatomic,retain) NSString *todayWeek;
@property(nonatomic,retain) NSString *tomorrowWeek;
@property(nonatomic,retain) ApiCmdMovie_getSchedule *apiCmdMovie_getScheduleToday;
@property(nonatomic,retain) ApiCmdMovie_getSchedule *apiCmdMovie_getScheduleTomorrow;
@property(nonatomic,retain) ApiCmdMovie_getAllMovies *apiCmdMovie_getAllMovies;
@property(nonatomic,retain) CinemaMovieTableViewDelegate *cinemaMovieTableViewDelegate;
@property(nonatomic,retain) NSArray *todaySchedules;
@property(nonatomic,retain) NSArray *tomorrowSchedules;
@property(nonatomic,retain) NSMutableArray *moviesArray;
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
    [self cancelApiCmd];
    
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
    
    self.todayWeek = nil;
    self.tomorrowButton = nil;
    
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc removeObserver:self];
    
    [super dealloc];
}

-(void)cancelApiCmd{
    [self.apiCmdMovie_getScheduleToday.httpRequest clearDelegatesAndCancel];
    [[[ApiClient defaultClient] requestArray] removeObject:_apiCmdMovie_getScheduleToday];
    self.apiCmdMovie_getScheduleToday.delegate = nil;
    self.apiCmdMovie_getScheduleToday = nil;
    
    [self.apiCmdMovie_getScheduleTomorrow.httpRequest clearDelegatesAndCancel];
    [[[ApiClient defaultClient] requestArray] removeObject:_apiCmdMovie_getScheduleTomorrow];
    self.apiCmdMovie_getScheduleTomorrow.delegate = nil;
    self.apiCmdMovie_getScheduleTomorrow = nil;
    
    [self.apiCmdMovie_getAllMovies.httpRequest clearDelegatesAndCancel];
    [[[ApiClient defaultClient] requestArray] removeObject:_apiCmdMovie_getAllMovies];
    self.apiCmdMovie_getAllMovies.delegate = nil;
    self.apiCmdMovie_getAllMovies = nil;
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [[UINavigationBar appearance] setBackgroundImage:[UIImage imageNamed:@"bg_navigationBar"] forBarMetrics:UIBarMetricsDefault];
}

- (void)awakeFromNib{
    [super awakeFromNib];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.view setBackgroundColor:Color4];
    
    self.title = _mCinema.name;
    
    [self initData];
    [self createBarButtonItem];
    [self initTableView];
    
    [_mTableView setTableHeaderView:_headerView];
}

- (void)initData{
    
    DataBaseManager *dbManager = [DataBaseManager sharedInstance];
    self.todayWeek = [dbManager getTodayWeek];
    self.tomorrowWeek = [dbManager getTomorrowWeek];
    
    self.moviesArray = [[[NSMutableArray alloc] initWithCapacity:DataCount] autorelease];
    NSArray *movies = [[DataBaseManager sharedInstance] getAllMoviesListFromCoreData];
    [self.moviesArray addObjectsFromArray:movies];
    
    if (!_cinemaMovieTableViewDelegate) {
        _cinemaMovieTableViewDelegate = [[CinemaMovieTableViewDelegate alloc] init];
    }
    
    [_todayButton setBackgroundColor:[UIColor colorWithRed:0.047 green:0.678 blue:1.000 alpha:1.000]];
    _todayButton.selected =YES;
    
    _coverFlow.type = iCarouselTypeLinear;
//    [_coverFlow reloadData];
    
    self.cinemaName.text = _mCinema.name;
    self.cinemaAddress.text = _mCinema.address;
    self.title = _mCinema.name;
    
    if ([_mCinema.favorite boolValue]) {
        _favoriteButton.selected = YES;
        [_favoriteButton setImage:[UIImage imageNamed:@"btn_favorite_n@2x"] forState:UIControlStateNormal];
    }
    
    //请求服务器获取改影院正在放映的电影列表
    self.apiCmdMovie_getAllMovies = (ApiCmdMovie_getAllMovies *)[[DataBaseManager sharedInstance] getAllMoviesListFromWeb:self cinemaId:_mCinema.uid];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateFavoriteState:) name:MCinemaAddFavoriteNotification object:nil];
}

- (void)updateFavoriteState:(NSNotification *)notification {
    if ([_mCinema.favorite boolValue]) {
        _favoriteButton.selected = YES;
        [_favoriteButton setImage:[UIImage imageNamed:@"btn_favorite_n@2x"] forState:UIControlStateNormal];
    }
}

- (void)createBarButtonItem{
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [backButton setFrame:CGRectMake(0, 0, 45, 32)];
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

- (void)initTableView{
    if (_mTableView==nil) {
        _mTableView = [[UITableView alloc] initWithFrame:self.view.frame style:UITableViewStylePlain];
        [self.view addSubview:_mTableView];
    }
    [self setTableViewDelegate];
}

- (void)setTableViewDelegate{
    _mTableView.delegate = _cinemaMovieTableViewDelegate;
    _mTableView.dataSource = _cinemaMovieTableViewDelegate;
    _cinemaMovieTableViewDelegate.parentViewController = self;
    _coverFlow.delegate = self;
    _coverFlow.dataSource = self;
}
#pragma mark -
#pragma mark Button Event
- (void)clickBackButton:(id)sender{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)clickMovieInfo:(id)sender{
    ABLoggerInfo(@"");
    MovieDetailViewController *movieDetailController = [[MovieDetailViewController alloc] initWithNibName:(iPhone5?@"MovieDetailViewController_5":@"MovieDetailViewController") bundle:nil];
    movieDetailController.mMovie = self.mMovie;
    [self.navigationController pushViewController:movieDetailController animated:YES];
    [movieDetailController release];
}

- (void)cleanUpButtonBackground{
    [_tomorrowButton setBackgroundColor:[UIColor clearColor]];
    [_todayButton setBackgroundColor:[UIColor clearColor]];
}

- (IBAction)clickTodayButton:(id)sender{
    if (_todayButton.selected)return;
    
    [self cleanUpButtonBackground];
    _tomorrowButton.selected = NO;
    _todayButton.selected = YES;
    [_todayButton setBackgroundColor:[UIColor colorWithRed:0.047 green:0.678 blue:1.000 alpha:1.000]];
    
    self.apiCmdMovie_getScheduleToday =  (ApiCmdMovie_getSchedule *)[[DataBaseManager sharedInstance] getScheduleFromWebWithaMovie:_mMovie andaCinema:_mCinema timedistance:ScheduleToday delegate:self];//每次视图加载刷新排期数据}
}

- (void)refreshTodaySchedule{
    
//    self.todaySchedules = [[DataBaseManager sharedInstance] deleteUnavailableSchedules:_todaySchedules];
    self.schedulesArray = self.todaySchedules;
    if (isNull(self.schedulesArray) || [self.schedulesArray count]==0) {
        [_mTableView setTableFooterView:_footerView];
    }else{
        [_mTableView setTableFooterView:[[[UIView alloc] initWithFrame:CGRectZero] autorelease]];
    }

    [self refreshTodayButtonTitle];
    [_mTableView reloadData];
}

- (IBAction)clickTomorrowButton:(id)sender{
    if (_tomorrowButton.selected)return;
    
    [self cleanUpButtonBackground];
    _tomorrowButton.selected = YES;
    _todayButton.selected = NO;
    [_tomorrowButton setBackgroundColor:[UIColor colorWithRed:0.047 green:0.678 blue:1.000 alpha:1.000]];
    
    self.apiCmdMovie_getScheduleTomorrow =  (ApiCmdMovie_getSchedule *)[[DataBaseManager sharedInstance] getScheduleFromWebWithaMovie:_mMovie andaCinema:_mCinema timedistance:ScheduleTomorrow delegate:self];//每次视图加载刷新排期数据
}

- (void)refreshTomorrowSchedule{
    
    self.schedulesArray = self.tomorrowSchedules;
    if (isNull(self.schedulesArray) || [self.schedulesArray count]==0) {
        [_mTableView setTableFooterView:_footerView];
    }else{
        [_mTableView setTableFooterView:[[[UIView alloc] initWithFrame:CGRectZero] autorelease]];
    }

    [self refreshTomorrowButtonTitle];
    [_mTableView reloadData];
}

- (void)refreshTodayButtonTitle{
    
    [_todayButton setTitle:[NSString stringWithFormat:@"今天(%@)%d场",_todayWeek,[_todaySchedules count]] forState:UIControlStateSelected];
    [_todayButton setTitle:[NSString stringWithFormat:@"今天(%@)%d场",_todayWeek,[_todaySchedules count]] forState:UIControlStateNormal];
}

- (void)refreshTomorrowButtonTitle{
    
    [_tomorrowButton setTitle:[NSString stringWithFormat:@"明天(%@)%d场",_tomorrowWeek,[_tomorrowSchedules count]] forState:UIControlStateSelected];
    [_tomorrowButton setTitle:[NSString stringWithFormat:@"明天(%@)%d场",_tomorrowWeek,[_tomorrowSchedules count]] forState:UIControlStateNormal];
}

- (IBAction)clickFavoriteButton:(id)sender{
    
    if (_favoriteButton.isSelected) {
        [_favoriteButton setSelected:NO];
        [[DataBaseManager sharedInstance] deleteFavoriteCinemaWithId:_mCinema.uid];
        [_favoriteButton setImage:[UIImage imageNamed:@"btn_unFavorite_n@2x"] forState:UIControlStateNormal];
    }else{
        [_favoriteButton setSelected:YES];
        [_favoriteButton setImage:[UIImage imageNamed:@"btn_favorite_n@2x"] forState:UIControlStateNormal];
        [[DataBaseManager sharedInstance] addFavoriteCinemaWithId:_mCinema.uid];
    }
    
}
- (IBAction)clickPhoneButton:(id)sender{
    
    NSString *message = @"";
    NSString *phoneNumber = nil;
    
    if (isEmpty(_mCinema.phoneNumber)) {
        message = @"该影院暂时没有电话号码";
    }else{
        phoneNumber = _mCinema.phoneNumber;
    }
    
    SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:@"电话号码" andMessage:message];
    
    if (!isEmpty(phoneNumber)) {
        [alertView addButtonWithTitle:phoneNumber
                                 type:SIAlertViewButtonTypeDefault
                              handler:^(SIAlertView *alertView) {
                                  [[LocationManager defaultLocationManager] callPhoneNumber:phoneNumber];
                              }];
    }
    
    [alertView addButtonWithTitle:@"取消"
                             type:SIAlertViewButtonTypeCancel
                          handler:^(SIAlertView *alertView) {
                          }];
    [alertView show];
    [alertView release];
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
    
    int moviesCount = [_moviesArray count];
    if (carousel.currentItemIndex>moviesCount || carousel.currentItemIndex<0) {
        return;
    }
    MMovie *aMovie = [_moviesArray objectAtIndex:carousel.currentItemIndex];
    self.mMovie = aMovie;
    
    //change today tomorrow button title
    
    [_todayButton setTitle:[NSString stringWithFormat:@"今天(%@)",_todayWeek] forState:UIControlStateNormal];
    [_todayButton setTitle:[NSString stringWithFormat:@"今天(%@)",_todayWeek] forState:UIControlStateSelected];
    [_tomorrowButton setTitle:[NSString stringWithFormat:@"明天(%@)",_tomorrowWeek] forState:UIControlStateNormal];
    [_tomorrowButton setTitle:[NSString stringWithFormat:@"明天(%@)",_tomorrowWeek] forState:UIControlStateSelected];
    
    _movieName.text =aMovie.name;
    int ratingCount = [aMovie.ratingpeople intValue];
    NSString *countLevel = @"人";
    if (ratingCount>10000) {
        ratingCount = ratingCount/10000;
        countLevel = @"万人";
    }
    _movieRating.text = [NSString stringWithFormat:@"%@评分:%0.1f",aMovie.ratingFrom,[aMovie.rating floatValue]];
//    _movieRating.text = [NSString stringWithFormat:@"%@评分:%0.1f(%d%@)",aMovie.ratingFrom,[aMovie.rating floatValue],ratingCount,countLevel];
    
    [self changeMovieDisplayData:aMovie];
    
    [_mTableView setTableFooterView:nil];
    self.schedulesArray = nil;
    [_mTableView reloadData];
    
    _tomorrowButton.selected = NO;
    _todayButton.selected = NO;
    [self cancelApiCmd];
    [self clickTomorrowButton:nil];
    [self clickTodayButton:nil];
}

- (void)changeMovieDisplayData:(MMovie*)aMovie{
    
    [[_movieDetailControl viewWithTag:TuanViewTag] removeFromSuperview];
    
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:3];
    if ([aMovie.isHot boolValue]) {
        [array addObject:_movie_image_hot];
    }
    if ([aMovie.isNew boolValue]) {
        [array addObject:_movie_image_new];
    }
    if ([aMovie.iMAX3D boolValue]) {
        [array addObject:_movie_image_3dimx];
    }
    if ([aMovie.iMAX boolValue]) {
        [array addObject:_movie_image_imx];
    }
    if ([aMovie.v3D boolValue]) {
        [array addObject:_movie_image_3d];
    }
    
    int twidth = 0;
    UIView *tuanView = [[UIView alloc] initWithFrame:CGRectZero];
    for (int i=0;i<[array count];i++) {
        
        UIView *tview = [array objectAtIndex:i];
        CGRect tframe = tview.frame;
        
        tframe.origin.x = twidth;
        twidth += tframe.size.width + 5;
        
        tview.frame = tframe;
        [tuanView addSubview:tview];
    }
    
    CGRect tFrame = [(UIView *)[array lastObject] frame];
    int tuanWidth = tFrame.origin.x+ tFrame.size.width;
    
    [_movieDetailControl addSubview:tuanView];
    tuanView.tag = TuanViewTag;
    [tuanView release];
    
    CGSize nameSize = [aMovie.name sizeWithFont:[_movieName font]
                              constrainedToSize:CGSizeMake(
                                                           (_movieDetailControl.bounds.size.width-tuanWidth-_movieName.frame.origin.x),
                                                           MAXFLOAT)];
    
    ABLoggerDebug(@"nameSize == 111%@",NSStringFromCGSize(nameSize));
    
    int tuanGap = 0;
    if (nameSize.height<=_movieName.bounds.size.height) {
        tuanGap = 10;
    }
    
    CGRect cell_newFrame = _movieName.frame;
    cell_newFrame.size.width = nameSize.width;
    _movieName.frame = cell_newFrame;
    
    int view_x = _movieName.frame.origin.x+nameSize.width +tuanGap;
    int tuanHeight = 15;
    [tuanView setFrame:CGRectMake(view_x, 0, tuanWidth, tuanHeight)];
    ABLoggerInfo(@"view frame ===== 222%@",NSStringFromCGRect(tuanView.frame));
    CGPoint newCenter = tuanView.center;
    newCenter.y = _movieName.center.y;
    tuanView.center = newCenter;
}


#pragma mark -
#pragma mark apiNotiry
-(void)apiNotifyResult:(id)apiCmd error:(NSError *)error{
    
    if (error) {
        return;
    }
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
         int tag = [[apiCmd httpRequest] tag];
        if (tag==API_MCinemaValidMovies) {
            [self updateData:API_MCinemaValidMovies timeDistance:nil dataDic:[apiCmd responseJSONObject]];
        }else{
            MSchedule *tSchedule = [[DataBaseManager sharedInstance] insertScheduleIntoCoreDataFromObject:[apiCmd responseJSONObject]
                                                                                               withApiCmd:apiCmd
                                                                                               withaMovie:_mMovie
                                                                                               andaCinema:_mCinema
                                                                                             timedistance:[(ApiCmdMovie_getSchedule *)apiCmd timedistance]];
            NSString *timedistance = [[[(ApiCmdMovie_getSchedule *)apiCmd timedistance] retain] autorelease];
            [self updateData:tag timeDistance:timedistance dataDic:tSchedule.scheduleInfo];
        }
    });
}

- (void)apiNotifyLocationResult:(id)apiCmd cacheDictionaryData:(NSDictionary *)cacheData{
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        int tag = [[apiCmd httpRequest] tag];
        MSchedule *tSchedule = [cacheData objectForKey:@"schedule"];
        NSString *timedistance = [cacheData objectForKey:@"timedistance"];
        [self updateData:tag timeDistance:timedistance dataDic:tSchedule.scheduleInfo];
    });
}

- (ApiCmd *)apiGetDelegateApiCmdWithTag:(int)cmdTag{
    switch (cmdTag) {
        case 0:
            return _apiCmdMovie_getScheduleToday;
            break;
            
        case 1:
            return _apiCmdMovie_getScheduleTomorrow;
            break;
            
        case API_MCinemaValidMovies:
            return _apiCmdMovie_getAllMovies;
            break;
        default:
        {
            NSAssert(0, @"没有从网络抓取到数据");
        }
    }
    
    return nil;
}

- (void)updateData:(int)tag timeDistance:(NSString *)timedistance dataDic:(NSDictionary *)dataDic
{
    ABLogger_int(tag);
    switch (tag) {
        case 0:
        case API_MScheduleCmdTomorrow:
        case API_MScheduleCmd:
        {
            [self formatCinemaData:dataDic timeDistance:timedistance];
        }
            break;
        case API_MCinemaValidMovies:
        {
            [self filterAvalidateMoviesDataDic:dataDic];
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
        self.todaySchedules = [[DataBaseManager sharedInstance] deleteUnavailableSchedules:resultArray];
    }else{
        self.tomorrowSchedules = resultArray;
    }
    
    [self setTableViewDelegate];
    
    dispatch_sync(dispatch_get_main_queue(), ^{
        
        if ([timedistance intValue]==0) {
            [self refreshTodayButtonTitle];
        }else{
            [self refreshTomorrowButtonTitle];
        }
        
        if (_todayButton.selected) {
            [self refreshTodaySchedule];
        }else if(_tomorrowButton.selected){
            [self refreshTomorrowSchedule];
        }
    });
}

- (void)filterAvalidateMoviesDataDic:(NSDictionary *)dataDic{
    
    NSArray *array = [[dataDic objectForKey:@"data"] objectForKey:@"movies"];
    ABLoggerDebug(@"count 1 == %d",[_moviesArray count]);
    [self.moviesArray filterUsingPredicate:[NSPredicate predicateWithFormat:@"self.uid IN %@", array]];
    
    ABLoggerDebug(@"count 2 == %d",[_moviesArray count]);
    dispatch_sync(dispatch_get_main_queue(), ^{
        [_coverFlow reloadData];
    });
    
}

- (void)shareButtonClick:(id)sender{
    
    AppDelegate *_appDelegate = [AppDelegate appDelegateInstance];
    
    //    AppDelegate *_appDelegate = [AppDelegate appDelegateInstance];
    //    [CacheManager sharedInstance].rootNavController.view
    UIImage *shareImg = [self.view imageWithView:_appDelegate.window];
    
    //定义菜单分享列表
    NSArray *shareList = [ShareSDK getShareListWithType:ShareTypeWeixiTimeline, ShareTypeWeixiSession, ShareTypeSMS,nil];
    
    //创建分享内容
    //    NSString *imagePath = [[NSBundle mainBundle] pathForResource:IMAGE_NAME ofType:IMAGE_EXT];
    id<ISSContent> publishContent = [ShareSDK content:Recommend_SMS_Content
                                       defaultContent:nil
                                                image:[ShareSDK jpegImageWithImage:shareImg quality:1]
                                                title:nil
                                                  url:SHARE_URL
                                          description:nil
                                            mediaType:SSPublishContentMediaTypeImage];
    
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
    [publishContent addWeixinTimelineUnitWithType:INHERIT_VALUE
                                          content:INHERIT_VALUE
                                            title:@"Hello 微信朋友圈!"
                                              url:nil
                                            image:INHERIT_VALUE
                                     musicFileUrl:nil
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
    ABLoggerWarn(@"接收到内存警告了");
    
}

@end
