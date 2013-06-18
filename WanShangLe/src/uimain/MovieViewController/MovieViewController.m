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
#import "ApiCmdMovie_getAllCinemas.h"
#import "MovieListTableViewDelegate.h"
#import "CinemaViewController.h"
#import "ASIHTTPRequest.h"
#import "ApiCmd.h"

#define MovieButtonTag 10
#define CinemaButtonTag 11

@interface MovieViewController ()<ApiNotify>{
    UIButton *movieButton;
    UIButton *cinemaButton;
}
@property(nonatomic,retain)MovieListTableViewDelegate *movieDelegate;
@end

@implementation MovieViewController
@synthesize movieTableView = _movieTableView;
@synthesize moviesArray = _moviesArray;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            self.apiCmdMovie_getAllMovies = [[DataBaseManager sharedInstance] getAllMoviesListFromWeb:self];
        });
        
        _cinemaViewController = [[CinemaViewController alloc] initWithNibName:nil bundle:nil];
    }
    return self;
}

- (void)dealloc{
    
    self.moviesArray = nil;
    self.movieTableView = nil;
    self.movieDelegate = nil;
    
    self.apiCmdMovie_getAllCinemas = nil;
    self.apiCmdMovie_getAllMovies = nil;
    
    [super dealloc];
}

- (void)viewWillAppear:(BOOL)animated{
    [self.navigationController setNavigationBarHidden:NO];
    
    self.apiCmdMovie_getAllMovies = [[DataBaseManager sharedInstance] getAllMoviesListFromWeb:self];
    self.apiCmdMovie_getAllCinemas =[[DataBaseManager sharedInstance] getAllCinemasListFromWeb:self];
    
    
#ifdef TestCode
    [self updatData];//测试代码
#endif
    
}

- (void)updatData{
    for (int i=0; i<10; i++) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
             self.apiCmdMovie_getAllMovies = [[DataBaseManager sharedInstance] getAllMoviesListFromWeb:self];
        });
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[CacheManager sharedInstance] setMovieViewController:self];
    
    //创建TopView
    UIView *topView = [[UIView alloc] initWithFrame:CGRectMake(0, 7, 140, 30)];
    UIButton *moviebt = [UIButton buttonWithType:UIButtonTypeCustom];
    UIButton *cinemabt = [UIButton buttonWithType:UIButtonTypeCustom];
    [moviebt setTitle:@"电影" forState:UIControlStateNormal];
    [moviebt setExclusiveTouch:YES];
    [cinemabt setTitle:@"影院" forState:UIControlStateNormal];
    moviebt.tag = MovieButtonTag;
    cinemabt.tag = CinemaButtonTag;
    [moviebt setBackgroundColor:[UIColor clearColor]];
    [cinemabt setBackgroundColor:[UIColor clearColor]];
    [moviebt addTarget:self action:@selector(clickMovieButton:) forControlEvents:UIControlEventTouchUpInside];
    [cinemabt addTarget:self action:@selector(clickCinemaButton:) forControlEvents:UIControlEventTouchUpInside];
    [moviebt setBackgroundColor:[UIColor colorWithRed:0.047 green:0.678 blue:1.000 alpha:1.000]];
    [moviebt setFrame:CGRectMake(0, 0, 70, 30)];
    [cinemabt setFrame:CGRectMake(70, 0, 70, 30)];
    [topView addSubview:moviebt];
    [topView addSubview:cinemabt];
    self.navigationItem.titleView = topView;
    [topView release];
    
    //create movie tableview and init
    _movieTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, iPhoneAppFrame.size.width, iPhoneAppFrame.size.height-44)
                                                   style:UITableViewStylePlain];
    
    _movieDelegate = [[MovieListTableViewDelegate alloc] init];
    _movieDelegate.parentViewController = self;
    
    [self setTableViewDelegate];
    
    _movieTableView.backgroundColor = [UIColor colorWithRed:0.880 green:0.963 blue:0.925 alpha:1.000];
    _movieTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    [self.view addSubview:_movieTableView];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        [self updateData:0];
    });
}

- (void)setTableViewDelegate{
    _movieTableView.dataSource = _movieDelegate;
    _movieTableView.delegate = _movieDelegate;
}

- (void)clickMovieButton:(id)sender{
    [self cleanUpButtonBackground];
    [movieButton setBackgroundColor:[UIColor colorWithRed:0.047 green:0.678 blue:1.000 alpha:1.000]];
}

- (void)clickCinemaButton:(id)sender{
    
    [self cleanUpButtonBackground];
    [cinemaButton setBackgroundColor:[UIColor colorWithRed:0.047 green:0.678 blue:1.000 alpha:1.000]];
    
    if (!_cinemaViewController) {
        _cinemaViewController = [[CinemaViewController alloc] initWithNibName:nil bundle:nil];
        [[CacheManager sharedInstance] setCinemaViewController:_cinemaViewController];
    }
    
    _cinemaViewController.isMovie_Cinema = NO;
    [self.navigationController pushViewController:_cinemaViewController animated:YES];
}

- (void)cleanUpButtonBackground{
    [movieButton setBackgroundColor:[UIColor clearColor]];
    [cinemaButton setBackgroundColor:[UIColor clearColor]];
}

#pragma mark -
#pragma mark apiNotiry
-(void)apiNotifyResult:(id)apiCmd error:(NSError *)error{
    
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
//            [[[CacheManager sharedInstance] mUserDefaults] setObject:@"0" forKey:UpdatingMoviesList];
        }
            break;
            
        case API_MCinemaCmd:
        {
            NSArray *array = [[DataBaseManager sharedInstance] getAllCinemasListFromCoreData];
            ABLoggerDebug(@"影院 count ==== %d",[array count]);
//            [[[CacheManager sharedInstance] mUserDefaults] setObject:@"0" forKey:UpdatingCinemasList];
//            ABLoggerWarn(@"可以请求 影院列表数据 === %d",[[[[CacheManager sharedInstance] mUserDefaults] objectForKey:UpdatingCinemasList] intValue]);
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
