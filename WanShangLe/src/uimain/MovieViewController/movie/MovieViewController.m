//
//  MovieViewController.m
//  WanShangLe
//
//  Created by stephenliu on 13-6-5.
//  Copyright (c) 2013年 stephenliu. All rights reserved.
//

#import "MovieViewController.h"
#import "MovieTableViewCell.h"
#import "ApiCmdMovie_getAllMovies.h"
#import "MovieListTableViewDelegate.h"
#import "CinemaViewController.h"
#import "EGORefreshTableHeaderView.h"
#import <QuartzCore/QuartzCore.h>
#import "ASIHTTPRequest.h"
#import "ApiCmd.h"
#import "MMovie.h"

#define MovieButtonTag 10
#define CinemaButtonTag 11



@interface MovieViewController ()<ApiNotify>{
    UIButton *movieButton;
    UIButton *cinemaButton;
    UIView *mView;
}
@property(nonatomic,retain)MovieListTableViewDelegate *movieDelegate;
@property(nonatomic,retain)UIView *movieContentView;
@property(nonatomic,retain)UIView *topView;
@property(nonatomic,retain)UILabel *titleLabel;
@end

@implementation MovieViewController
@synthesize movieTableView = _movieTableView;
@synthesize moviesArray = _moviesArray;
@synthesize isMoviePanel,topView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
        [self loadNewData];
        
        [self newCinemaController];
        
        isMoviePanel = YES;
        [CacheManager sharedInstance].isMoviePanel = isMoviePanel;//判断电影列表显示数据类型，从电影-》影院-》排期；从影院-》影院电影排期
    }
    return self;
}

- (void)dealloc{
    
    [[_apiCmdMovie_getAllMovies httpRequest] clearDelegatesAndCancel];
    _apiCmdMovie_getAllMovies.delegate = nil;
    self.apiCmdMovie_getAllMovies = nil;
    
    [MovieListTableViewDelegate cancelPreviousPerformRequestsWithTarget:_movieDelegate];
    self.movieDelegate = nil;
    
    self.moviesArray = nil;
    self.movieTableView = nil;
    
    self.movieContentView = nil;
    self.topView = nil;
    self.titleLabel = nil;
    
    self.refreshHeaderView = nil;
    [super dealloc];
}

#pragma mark -
#pragma mark UIView cycle
- (void)viewWillAppear:(BOOL)animated{
    
    if (_cinemaViewController.view.frame.origin.x == 0) {//当界面处在影院列表的时候才考虑 viewWillAppear
        [_cinemaViewController viewWillAppear:animated];
    }
}

- (void)viewDidAppear:(BOOL)animated{
    if (_cinemaViewController.view.frame.origin.x == 0) {//当界面处在影院列表的时候才考虑 viewWillAppear
        [_cinemaViewController viewDidAppear:animated];
    }
}

- (void)viewWillDisappear:(BOOL)animated{
    [_cinemaViewController viewWillDisappear:animated];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.view setBackgroundColor:[UIColor colorWithRed:0.878 green:0.890 blue:0.910 alpha:1.000]];
    
    [self initTopButtonView];
    
    [self initTableView];
    
    [self initRefreshHeaderView];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        [self updateData:0];
    });
}

#pragma mark -
#pragma mark 初始化数据
- (void)initTopButtonView{
    //创建TopView
    topView = [[UIView alloc] initWithFrame:CGRectMake(0, 7, 150, 30)];
    UIImageView *bgImg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bg_M_switch_C@2x"]];
    bgImg.frame = CGRectMake(0, 0, 150, 30);
    [topView addSubview:bgImg];
    [bgImg release];
    
    UIButton *moviebt = [UIButton buttonWithType:UIButtonTypeCustom];
    UIButton *cinemabt = [UIButton buttonWithType:UIButtonTypeCustom];
    movieButton = moviebt;
    cinemaButton = cinemabt;
    [moviebt setTitle:@"电影" forState:UIControlStateNormal];
    [moviebt setExclusiveTouch:YES];
    [cinemabt setTitle:@"影院" forState:UIControlStateNormal];
    moviebt.tag = MovieButtonTag;
    cinemabt.tag = CinemaButtonTag;
    [moviebt setBackgroundColor:[UIColor clearColor]];
    [cinemabt setBackgroundColor:[UIColor clearColor]];
    [moviebt setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [cinemabt setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [moviebt addTarget:self action:@selector(clickMovieButtonUp:) forControlEvents:UIControlEventTouchUpInside];
    [cinemabt addTarget:self action:@selector(clickCinemaButtonUp:) forControlEvents:UIControlEventTouchUpInside];
    [moviebt addTarget:self action:@selector(clickMovieButtonDown:) forControlEvents:UIControlEventTouchDown];
    [cinemabt addTarget:self action:@selector(clickCinemaButtonDown:) forControlEvents:UIControlEventTouchDown];
    [moviebt setBackgroundImage:[UIImage imageNamed:@"btn_switch@2x"] forState:UIControlStateNormal];
    [moviebt setFrame:CGRectMake(0, 0, 75, 30)];
    [cinemabt setFrame:CGRectMake(75, 0, 75, 30)];
    [topView addSubview:moviebt];
    [topView addSubview:cinemabt];
    self.navigationItem.titleView = topView;
    
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [backButton setFrame:CGRectMake(0, 0, 45, 32)];
    [backButton addTarget:self action:@selector(clickBackButton:) forControlEvents:UIControlEventTouchUpInside];
    [backButton setBackgroundImage:[UIImage imageNamed:@"bt_back_n@2x"] forState:UIControlStateNormal];
    [backButton setBackgroundImage:[UIImage imageNamed:@"bt_back_f@2x"] forState:UIControlStateHighlighted];
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    self.navigationItem.leftBarButtonItem = backItem;
    [backItem release];
}

- (void)initTableView{
    _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 44)];
    _titleLabel.backgroundColor = [UIColor clearColor];
    _titleLabel.textColor = [UIColor whiteColor];
    _titleLabel.font = [UIFont boldSystemFontOfSize:20];
    _titleLabel.shadowColor = [UIColor colorWithWhite:0.298 alpha:1.000];
    [_titleLabel setTextAlignment:UITextAlignmentCenter];
    
    _movieContentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, iPhoneAppFrame.size.width, iPhoneAppFrame.size.height-44)];
    //create movie tableview and init
    _movieTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, iPhoneAppFrame.size.width, iPhoneAppFrame.size.height-44)
                                                   style:UITableViewStylePlain];
    
    _movieDelegate = [[MovieListTableViewDelegate alloc] init];
    _movieDelegate.parentViewController = self;
    
    [self setTableViewDelegate];
    
    _movieTableView.backgroundColor = [UIColor clearColor];
    _movieTableView.tableFooterView = [[[UIView alloc] initWithFrame:CGRectZero] autorelease];
    UIImageView *headerView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tableView_shadow@2x"]];
    headerView.frame = CGRectMake(0, -12, self.view.bounds.size.width, 12);
//    _movieTableView.tableHeaderView = headerView; 
    [_movieTableView addSubview:headerView];
    [headerView release];
    
    _movieTableView.tableFooterView = [[[UIView alloc] initWithFrame:CGRectZero] autorelease];
    _movieTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    [_movieContentView addSubview:_movieTableView];
    [self.view addSubview:_movieContentView];
}

- (void)initRefreshHeaderView{
    if (_refreshHeaderView == nil) {

        /*
        mView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
        [mView setBackgroundColor:[UIColor clearColor]];
        [_movieTableView insertSubview:mView atIndex:0];
        [self showShadow:YES];
        [mView release];*/
        
        EGORefreshTableHeaderView *view = [[EGORefreshTableHeaderView alloc] initWithFrame: CGRectMake(0.0f, - _movieTableView.bounds.size.height, _movieTableView.frame.size.width, _movieTableView.bounds.size.height)];
        
        view.delegate = _movieDelegate;
        view.tag = EGOHeaderView;
        view.backgroundColor = [UIColor clearColor];
        [_movieTableView addSubview:view];
        self.refreshHeaderView = view;
        [view release];
        view = nil;
    }
    
    [_refreshHeaderView refreshLastUpdatedDate];
    _movieDelegate.mTableView = self.movieTableView;
    _movieDelegate.refreshHeaderView = self.refreshHeaderView;
}

- (void)showShadow:(BOOL)val {
    
    mView.layer.shadowOpacity = val ? 0.3f : 0.0f;
    if (val) {
        
        NSMutableArray *shadowPoints = nil;
        if (shadowPoints==nil) {
            shadowPoints = [[NSMutableArray alloc] initWithObjects:
                            [NSValue valueWithCGPoint:CGPointMake(-40 ,-1)],
                            [NSValue valueWithCGPoint:CGPointMake(0   ,-2)],
                            [NSValue valueWithCGPoint:CGPointMake(40  ,-3)],
                            [NSValue valueWithCGPoint:CGPointMake(80  ,-4)],
                            [NSValue valueWithCGPoint:CGPointMake(120 ,-5)],
                            [NSValue valueWithCGPoint:CGPointMake(160 ,-5)],
                            [NSValue valueWithCGPoint:CGPointMake(200 ,-5)],
                            [NSValue valueWithCGPoint:CGPointMake(240 ,-4)],
                            [NSValue valueWithCGPoint:CGPointMake(280 ,-3)],
                            [NSValue valueWithCGPoint:CGPointMake(320 ,-2)],
                            [NSValue valueWithCGPoint:CGPointMake(360 ,-1)],
                            nil];
        }
        
        CGMutablePathRef path = CGPathCreateMutable();
        if (shadowPoints && shadowPoints.count > 0) {
            CGPoint p = [(NSValue *)[shadowPoints objectAtIndex:0] CGPointValue];
            CGPathMoveToPoint(path, nil, p.x, p.y);
            for (int i = 1; i < shadowPoints.count; i++) {
                p = [(NSValue *)[shadowPoints objectAtIndex:i] CGPointValue];
                CGPathAddLineToPoint(path, nil, p.x, p.y);
            }
        }
        mView.layer.shadowOffset = CGSizeMake(0, 0);
        mView.layer.shadowRadius = 2.0f;
        mView.layer.shadowPath = path;
        mView.layer.shadowColor = [UIColor blackColor].CGColor;
        
        CFRelease(path);
        [shadowPoints release];
    }
    
}

- (void)setTableViewDelegate{
    self.movieTableView.dataSource = _movieDelegate;
    self.movieTableView.delegate = _movieDelegate;
}

- (void)newCinemaController{
    
    if (!_cinemaViewController) {
        _cinemaViewController = [[CinemaViewController alloc] initWithNibName:(iPhone5?@"CinemaViewController_5":@"CinemaViewController") bundle:nil];
        _cinemaViewController.mparentController = self;
    }
    _cinemaViewController.view.frame = CGRectMake(self.view.bounds.size.width, 0, self.view.bounds.size.width, self.view.bounds.size.height);
    [self.view addSubview:_cinemaViewController.view];
}

#pragma mark -
#pragma mark 【电影-影院】Button Event
- (void)clickMovieButtonUp:(id)sender{
    
    if (isMoviePanel)return;
    isMoviePanel = YES;
    [self switchMovieCinemaAnimation];
}

- (void)clickMovieButtonDown:(id)sender{
    [self cleanUpButtonBackground];
    [movieButton setBackgroundImage:[UIImage imageNamed:@"btn_switch@2x"] forState:UIControlStateNormal];
}

- (void)clickCinemaButtonUp:(id)sender{
    
    _cinemaViewController.movieDetailButton.hidden = YES;
    if (!isMoviePanel)return;
    isMoviePanel = NO;
    
    if (_cinemaViewController.view.superview==nil) {
        [self newCinemaController];
    }
    [self switchMovieCinemaAnimation];
}

- (void)clickCinemaButtonDown:(id)sender{
    
    [self cleanUpButtonBackground];
    [cinemaButton setBackgroundImage:[UIImage imageNamed:@"btn_switch@2x"] forState:UIControlStateNormal];
}

- (void)cleanUpButtonBackground{
    [movieButton setBackgroundImage:nil forState:UIControlStateNormal];
    [cinemaButton setBackgroundImage:nil forState:UIControlStateNormal];
}

- (void)clickBackButton:(id)sender{
    
//    [self.navigationController popViewControllerAnimated:YES];
    
    if (_cinemaViewController.movieDetailButton.hidden) {
        [self.navigationController popViewControllerAnimated:YES];
    }else{
        _cinemaViewController.movieDetailButton.hidden = YES;
        [self pushMovieCinemaAnimation];
    }
}

#pragma mark -
#pragma mark 【电影-影院】 Transition
- (void)switchMovieCinemaAnimation{
    
    [self.view setUserInteractionEnabled:NO];
    
    if (isMoviePanel) {
        _movieContentView.hidden = NO;
    }
    
    [CacheManager sharedInstance].isMoviePanel = isMoviePanel;//判断电影列表显示数据类型，从电影-》影院-》排期；从影院-》影院电影排期
    
    ABLoggerInfo(@"_cinemaViewController.view.frame.origin.x == %f",_cinemaViewController.view.frame.origin.x);
    [UIView animateWithDuration:0.4 animations:^{
        [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
        
        if (isMoviePanel && _movieContentView.frame.origin.x != 0) {
            
            [_cinemaViewController viewWillDisappear:NO];
            
            CGRect movieFrame =  _movieContentView.frame;
            movieFrame.origin.x = 0;
            _movieContentView.frame = movieFrame;
            
            CGRect cinemaFrame =  _cinemaViewController.view.frame;
            cinemaFrame.origin.x = self.view.bounds.size.width;
            _cinemaViewController.view.frame = cinemaFrame;
            
        }else if (_cinemaViewController.view.frame.origin.x != 0){
            
            CGRect movieFrame =  _movieContentView.frame;
            movieFrame.origin.x = -self.view.bounds.size.width;
            _movieContentView.frame = movieFrame;
            
            CGRect cinemaFrame =  _cinemaViewController.view.frame;
            cinemaFrame.origin.x = 0;
            _cinemaViewController.view.frame = cinemaFrame;
            
            [_cinemaViewController viewWillAppear:NO];
        }
        
    } completion:^(BOOL finished) {
        [self.view setUserInteractionEnabled:YES];
        
        if (isMoviePanel) {
            
        }else{
            _movieContentView.hidden = YES;
        }
    }];
}

- (void)pushMovieCinemaAnimation{
    
    topView.hidden = !_cinemaViewController.movieDetailButton.hidden;
    
    if (topView.hidden) {
        _titleLabel.text = _cinemaViewController.mMovie.name;
        self.navigationItem.titleView = _titleLabel;
    }else{
        self.navigationItem.titleView = topView;
    }

    [self switchMovieCinemaAnimation];
}

#pragma mark -
#pragma mark 刷新和加载更多
- (void)loadNewData{
    self.apiCmdMovie_getAllMovies =  (ApiCmdMovie_getAllMovies *)[[DataBaseManager sharedInstance] getAllMoviesListFromWeb:self cinemaId:nil];
}

#pragma mark -
#pragma mark apiNotiry
-(void)apiNotifyResult:(id)apiCmd error:(NSError *)error{
    
    if (error) {
        return;
    }
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
         self.moviesArray = [[DataBaseManager sharedInstance] insertMoviesIntoCoreDataFromObject:[apiCmd responseJSONObject] withApiCmd:apiCmd];
        
        int tag = [[apiCmd httpRequest] tag];
        [self updateData:tag];
    });
    
}

- (void) apiNotifyLocationResult:(id)apiCmd cacheOneData:(id)cacheData{
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        self.moviesArray = cacheData;
        int tag = [[apiCmd httpRequest] tag];
        [self updateData:tag];

        
    });
}

- (ApiCmd *)apiGetDelegateApiCmd{
    return _apiCmdMovie_getAllMovies;
}

- (void)updateData:(int)tag
{
    ABLogger_int(tag);
    switch (tag) {
        case 0:
        case API_MMovieCmd:
        {
//            NSArray *array = [[DataBaseManager sharedInstance] getAllMoviesListFromCoreData];
//            self.moviesArray = array;
            ABLoggerDebug(@"电影 count ==== %d",[self.moviesArray count]);
            
            [self setTableViewDelegate];
            dispatch_sync(dispatch_get_main_queue(), ^{
                
                [self.movieTableView reloadData];
            });
        }
            break;
            
        case API_MCinemaCmd:
        {
            NSArray *array = [[DataBaseManager sharedInstance] getAllCinemasListFromCoreData];
            ABLoggerDebug(@"影院 count ==== %d",[array count]);
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
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    ABLoggerWarn(@"接收到内存警告了");
    // Dispose of any resources that can be recreated.
}

@end
