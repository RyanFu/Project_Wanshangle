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
#import "UIImageView+WebCache.h"
#import "MMovie.h"

#define MovieButtonTag 10
#define CinemaButtonTag 11

@interface MovieViewController ()<UITableViewDataSource,UITableViewDelegate,ApiNotify>{
    NSArray *moviesArray;
}
@property(nonatomic,retain)UITableView *movieTableView;
@property(nonatomic,retain)NSArray *moviesArray;
@property(nonatomic,assign)ApiCmd *mapiCmd;
@end

@implementation MovieViewController
@synthesize movieTableView = _movieTableView;
@synthesize moviesArray = _moviesArray;
@synthesize mapiCmd = _mapiCmd;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
            
            self.mapiCmd = [[DataBaseManager sharedInstance] getAllMoviesListFromWeb:self];
            
        });
        
    }
    return self;
}

- (void)dealloc{
    
    self.moviesArray = nil;
    self.movieTableView = nil;
    self.mapiCmd = nil;
    
    [super dealloc];
}

- (void)viewWillAppear:(BOOL)animated{
    [self.navigationController setNavigationBarHidden:NO];

    self.mapiCmd = [[DataBaseManager sharedInstance] getAllMoviesListFromWeb:self];
    
    [self updatData];
}

- (void)updatData{
    for (int i=0; i<100; i++) {
        self.mapiCmd = [[DataBaseManager sharedInstance] getAllMoviesListFromWeb:self];
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
    [moviebt setFrame:CGRectMake(0, 0, 70, 30)];
    [cinemabt setFrame:CGRectMake(70, 0, 70, 30)];
    [topView addSubview:moviebt];
    [topView addSubview:cinemabt];
    self.navigationItem.titleView = topView;
    [topView release];
    
    //create movie tableview and init
    _movieTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, iPhoneAppFrame.size.width, iPhoneAppFrame.size.height-44)
                                                   style:UITableViewStylePlain];
    
    _movieTableView.dataSource = self;
    _movieTableView.delegate = self;
    _movieTableView.backgroundColor = [UIColor colorWithRed:0.880 green:0.963 blue:0.925 alpha:1.000];
    _movieTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    //    _moviesArray = [[NSMutableArray alloc] initWithObjects:@"11", @"22",@"33",@"44",@"55",@"66",@"77",@"88",@"99",@"100",nil];
    [self.view addSubview:_movieTableView];
}

- (void)clickMovieButton:(id)sender{
    UIButton *bt = (UIButton *)sender;
    UIButton *cinemabt = (UIButton *)[[sender superview] viewWithTag:CinemaButtonTag];
    [cinemabt setBackgroundColor:[UIColor clearColor]];
    [bt setBackgroundColor:[UIColor colorWithRed:0.047 green:0.678 blue:1.000 alpha:1.000]];
}

- (void)clickCinemaButton:(id)sender{
    UIButton *bt = (UIButton *)sender;
    UIButton *moviebt = (UIButton *)[[sender superview] viewWithTag:MovieButtonTag];
    [moviebt setBackgroundColor:[UIColor clearColor]];
    [bt setBackgroundColor:[UIColor colorWithRed:0.047 green:0.678 blue:1.000 alpha:1.000]];
}

#pragma mark -
#pragma mark UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [_moviesArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    ABLoggerMethod();
    static NSString *CellIdentifier = @"mMovieCell";
    static BOOL nibsRegistered = NO;
    if (!nibsRegistered) {
        UINib *nib = [UINib nibWithNibName:@"MovieTableViewCell" bundle:nil];
        [tableView registerNib:nib forCellReuseIdentifier:CellIdentifier];
        nibsRegistered = YES;
    }
    
    MovieTableViewCell * cell = (MovieTableViewCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [self createNewMocieCell];
    }
    
    [self configureCell:cell atIndexPath:indexPath];
    
    return cell;
}

- (void)configureCell:(MovieTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    
    MMovie *movie = [_moviesArray objectAtIndex:indexPath.row];
    [cell.movie_imageView setImageWithURL:[NSURL URLWithString:movie.webImg]
                         placeholderImage:[UIImage imageNamed:@"placeholder"] options:SDWebImageRetryFailed];
    cell.movie_name.text = movie.name;
    cell.movie_new.hidden = YES;
    if ([movie.newMovie boolValue]) {
        cell.movie_new.hidden = NO;
    }
    cell.movie_rating.text = [NSString stringWithFormat:@"%@ : %0.1f (%d 万人)",movie.ratingFrom,[movie.rating floatValue],[movie.ratingpeople intValue]/10000];
    cell.movie_word.text = movie.aword;

}

-(MovieTableViewCell *)createNewMocieCell{
    ABLoggerMethod();
    MovieTableViewCell * cell = [[[MovieTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"mMovieCell"] autorelease];
    [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
    cell.selectionStyle = UITableViewCellSelectionStyleBlue;
    //    cell.selectedBackgroundView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"history_menu_cell_background"]] autorelease];
    return cell;
}

#pragma mark -
#pragma mark UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 80.0f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

-(void)apiNotifyResult:(id)apiCmd error:(NSError *)error{
    
    NSArray *array = [[DataBaseManager sharedInstance] getAllMoviesListFromCoreData];
    self.moviesArray = array;
    ABLoggerDebug(@"count ==== %d",[self.moviesArray count]);
    
    [self.movieTableView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
