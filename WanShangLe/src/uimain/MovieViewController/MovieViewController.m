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

#define MovieButtonTag 10
#define CinemaButtonTag 11

@interface MovieViewController ()<ApiNotify>{
    UIButton *movieButton;
    UIButton *cinemaButton;
}
@property(nonatomic,retain)MovieListTableViewDelegate *movieDelegate;
@property(nonatomic,retain)CinemaViewController *cinemaViewController;
@end

@implementation MovieViewController
@synthesize movieTableView = _movieTableView;
@synthesize moviesArray = _moviesArray;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
            
            [[DataBaseManager sharedInstance] getAllMoviesListFromWeb:self];
            
        });
    }
    return self;
}

- (void)dealloc{
    
    self.moviesArray = nil;
    self.movieTableView = nil;
    self.movieDelegate = nil;

    [super dealloc];
}

- (void)viewWillAppear:(BOOL)animated{
    [self.navigationController setNavigationBarHidden:NO];

    [[DataBaseManager sharedInstance] getAllMoviesListFromWeb:self];
    
#ifdef TestCode
    //[self updatData];//测试代码
#endif
    
}

- (void)updatData{
    for (int i=0; i<10; i++) {
        [[DataBaseManager sharedInstance] getAllMoviesListFromWeb:self];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
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
    
    _movieTableView.dataSource = _movieDelegate;
    _movieTableView.delegate = _movieDelegate;
    _movieTableView.backgroundColor = [UIColor colorWithRed:0.880 green:0.963 blue:0.925 alpha:1.000];
    _movieTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    //    _moviesArray = [[NSMutableArray alloc] initWithObjects:@"11", @"22",@"33",@"44",@"55",@"66",@"77",@"88",@"99",@"100",nil];
    [self.view addSubview:_movieTableView];
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
    }
    
    [self.navigationController pushViewController:_cinemaViewController animated:YES];
}

- (void)cleanUpButtonBackground{
    [movieButton setBackgroundColor:[UIColor clearColor]];
    [cinemaButton setBackgroundColor:[UIColor clearColor]];
}

-(void)apiNotifyResult:(id)apiCmd error:(NSError *)error{
    
    int tag = [[apiCmd httpRequest] tag];
    
    ABLogger_int(tag);
    switch (tag) {
        case API_MMovieCmd:
        {
            NSArray *array = [[DataBaseManager sharedInstance] getAllMoviesListFromCoreData];
            self.moviesArray = array;
            ABLoggerDebug(@"count ==== %d",[self.moviesArray count]);
            
            [self.movieTableView reloadData];
        }
            break;
        case API_MCinemaCmd:
        {
        }
            break;
        default:
        {
            NSAssert(0, @"没有从网络抓取到数据");
        }
            break;
    }

    
    [[[ApiClient defaultClient] requestArray] removeObject:self];
    ABLoggerWarn(@"request array count === %d",[[[ApiClient defaultClient] requestArray] count]);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
