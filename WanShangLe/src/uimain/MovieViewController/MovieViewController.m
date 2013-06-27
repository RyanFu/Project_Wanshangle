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
#import "ASIHTTPRequest.h"
#import "ApiCmd.h"
#import "MMovie.h"

#define MovieButtonTag 10
#define CinemaButtonTag 11

@interface MovieViewController ()<ApiNotify>{
    UIButton *movieButton;
    UIButton *cinemaButton;
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
        
        self.apiCmdMovie_getAllMovies = (ApiCmdMovie_getAllMovies *)[[DataBaseManager sharedInstance] getAllMoviesListFromWeb:self];
        
        [self newCinemaController];
        
        isMoviePanel = YES;
        
        //        self.navigationItem.hidesBackButton= YES;
    }
    return self;
}

- (void)dealloc{
    
    self.moviesArray = nil;
    self.movieTableView = nil;
    self.movieDelegate = nil;
    
    self.apiCmdMovie_getAllMovies = nil;
    self.movieContentView = nil;
    self.topView = nil;
    self.titleLabel = nil;
    
    [super dealloc];
}

- (void)viewWillAppear:(BOOL)animated{
    
    [_cinemaViewController viewWillAppear:animated];
    
    self.apiCmdMovie_getAllMovies =  (ApiCmdMovie_getAllMovies *)[[DataBaseManager sharedInstance] getAllMoviesListFromWeb:self];
    
#ifdef TestCode
    [self updatData];//测试代码
#endif
    
}

- (void)viewDidAppear:(BOOL)animated{
    
}

- (void)updatData{
    for (int i=0; i<10; i++) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            //            self.apiCmdMovie_getAllMovies = [[DataBaseManager sharedInstance] getAllMoviesListFromWeb:self];
        });
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
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
    [backButton setFrame:CGRectMake(0, 0, 45, 30)];
    [backButton addTarget:self action:@selector(clickBackButton:) forControlEvents:UIControlEventTouchUpInside];
    [backButton setBackgroundImage:[UIImage imageNamed:@"bt_back_n@2x"] forState:UIControlStateNormal];
    [backButton setBackgroundImage:[UIImage imageNamed:@"bt_back_f@2x"] forState:UIControlStateHighlighted];
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    self.navigationItem.leftBarButtonItem = backItem;
    
    _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 44)];
    _titleLabel.backgroundColor = [UIColor clearColor];
    [_titleLabel setTextAlignment:UITextAlignmentCenter];
    
    _movieContentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, iPhoneAppFrame.size.width, iPhoneAppFrame.size.height-44)];
    //create movie tableview and init
    _movieTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, iPhoneAppFrame.size.width, iPhoneAppFrame.size.height-44)
                                                   style:UITableViewStylePlain];
    
    _movieDelegate = [[MovieListTableViewDelegate alloc] init];
    _movieDelegate.parentViewController = self;
    
    [self setTableViewDelegate];
    
    _movieTableView.backgroundColor = [UIColor colorWithRed:0.880 green:0.963 blue:0.925 alpha:1.000];
    _movieTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    [_movieContentView addSubview:_movieTableView];
    [self.view addSubview:_movieContentView];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        [self updateData:0];
    });
}

- (void)setTableViewDelegate{
    _movieTableView.dataSource = _movieDelegate;
    _movieTableView.delegate = _movieDelegate;
}

- (void)newCinemaController{
    
    if (!_cinemaViewController) {
        _cinemaViewController = [[CinemaViewController alloc] initWithNibName:nil bundle:nil];
        _cinemaViewController.mparentController = self;
    }
    _cinemaViewController.view.frame = CGRectMake(self.view.bounds.size.width, 0, self.view.bounds.size.width, self.view.bounds.size.height);
    [self.view addSubview:_cinemaViewController.view];
}

#pragma mark -
#pragma mark 【电影-影院】Button Event
- (void)clickMovieButtonUp:(id)sender{
    
    isMoviePanel = YES;
    [self switchMovieCinemaAnimation];
}

- (void)clickMovieButtonDown:(id)sender{
    [self cleanUpButtonBackground];
    [movieButton setBackgroundImage:[UIImage imageNamed:@"btn_switch@2x"] forState:UIControlStateNormal];
}

- (void)clickCinemaButtonUp:(id)sender{
    
    _cinemaViewController.movieDetailButton.hidden = YES;
    
    isMoviePanel = NO;
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
    
    ABLoggerInfo(@"_cinemaViewController.view.frame.origin.x == %f",_cinemaViewController.view.frame.origin.x);
    [UIView animateWithDuration:0.4 animations:^{
        [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
        
        if (isMoviePanel && _movieContentView.frame.origin.x != 0) {
            
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
        
        if (!isMoviePanel) {
            _movieContentView.hidden = YES;
        }
    }];
}

- (void)pushMovieCinemaAnimation{
    
    topView.hidden = !_cinemaViewController.movieDetailButton.hidden;
    
    if (topView.hidden) {
        ABLoggerInfo(@"_cinemaViewController.mMovie.name === %@",_cinemaViewController.mMovie.name);
        _titleLabel.text = _cinemaViewController.mMovie.name;
        self.navigationItem.titleView = _titleLabel;
    }else{
        self.navigationItem.titleView = topView;
    }
    
    [self switchMovieCinemaAnimation];
}

#pragma mark -
#pragma mark apiNotiry
-(void)apiNotifyResult:(id)apiCmd error:(NSError *)error{
    
    if (error) {
        return;
    }
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        [[DataBaseManager sharedInstance] insertMoviesIntoCoreDataFromObject:[apiCmd responseJSONObject] withApiCmd:apiCmd];
        
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
    return _apiCmdMovie_getAllMovies;
}

- (void)updateData:(int)tag
{
    ABLogger_int(tag);
    switch (tag) {
        case 0:
        case API_MMovieCmd:
        {
            NSArray *array = [[DataBaseManager sharedInstance] getAllMoviesListFromCoreData];
            self.moviesArray = array;
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
