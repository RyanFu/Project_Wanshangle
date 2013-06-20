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
#import "MMovie.h"
#import "MCinema.h"
#import "iCarousel.h"
#import "ReflectionView.h"
#import "UIImageView+WebCache.h"

#define CoverFlowItemTag 100

@interface CinemaMovieViewController ()<ApiNotify,iCarouselDataSource,iCarouselDelegate>
@property(nonatomic,retain) ApiCmdMovie_getSchedule *apiCmdMovie_getSchedule;
@property(nonatomic,retain) CinemaMovieTableViewDelegate *cinemaMovieTableViewDelegate;
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
    
    [[self.apiCmdMovie_getSchedule httpRequest] clearDelegatesAndCancel];
    [self.apiCmdMovie_getSchedule setDelegate:nil];
    self.apiCmdMovie_getSchedule = nil;
    
    self.todayButton = nil;
    self.tomorrowButton = nil;
    self.cinemaInfo = nil;
    self.mTableView = nil;
    self.coverFlow = nil;
    self.movieActor = nil;
    self.movieName = nil;
    self.movieRating = nil;
    self.movieTimeLong = nil;
    self.mMovie = nil;
    self.mCinema = nil;
    
    self.todaySchedules = nil;
    self.todaySchedules = nil;
    self.schedulesArray = nil;
    self.moviesArray = nil;
    self.cinemaMovieTableViewDelegate = nil;
    
    [super dealloc];
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
    
    _coverFlow.type = iCarouselTypeCoverFlow2;
    [_coverFlow reloadData];
}


- (IBAction)clickMovieInfo:(id)sender{
    ABLoggerInfo(@"");
    
    CinemaViewController *cinemaViewController = [CacheManager sharedInstance].cinemaViewController;
    
    
    NSArray *array = [NSArray arrayWithObjects:
                      [CacheManager sharedInstance].rootViewController,
                      [CacheManager sharedInstance].movieViewController,
                      [CacheManager sharedInstance].cinemaViewController,
                      nil];
    
    cinemaViewController.mMovie = self.mMovie;
    cinemaViewController.isMovie_Cinema = YES;
    
    ABLogger_bool(cinemaViewController.isMovie_Cinema);
    [self.navigationController setViewControllers:array animated:YES];
}

- (void)cleanUpButtonBackground{
    [_tomorrowButton setBackgroundColor:[UIColor clearColor]];
    [_todayButton setBackgroundColor:[UIColor clearColor]];
}

- (IBAction)clickTodayButton:(id)sender{
    [self cleanUpButtonBackground];
    [_todayButton setBackgroundColor:[UIColor colorWithRed:0.047 green:0.678 blue:1.000 alpha:1.000]];
    
    self.schedulesArray = self.todaySchedules;
    [_mTableView reloadData];
}

- (IBAction)clickTomorrowButton:(id)sender{
    [self cleanUpButtonBackground];
    [_tomorrowButton setBackgroundColor:[UIColor colorWithRed:0.047 green:0.678 blue:1.000 alpha:1.000]];
    
    self.schedulesArray = self.tomorrowSchedules;
    [_mTableView reloadData];
}

#pragma mark -
#pragma mark iCarousel methods

- (NSUInteger)numberOfItemsInCarousel:(iCarousel *)carousel
{
    return [_moviesArray count];
}

- (UIView *)carousel:(iCarousel *)carousel viewForItemAtIndex:(NSUInteger)index reusingView:(ReflectionView *)view
{
    UIImageView *view2 = nil;
	
	//create new view if no view is available for recycling
	if (view == nil)
	{
        //set up reflection view
		view = [[[ReflectionView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 100, 100)] autorelease];
        
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
          placeholderImage:[UIImage imageNamed:@"placeholder"]
                   options:SDWebImageRetryFailed
                 completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
                     [(ReflectionView *)[view2 superview] update];
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
            return YES;
        }
        case iCarouselOptionSpacing:
        {
            //add a bit of spacing between the item views
            //            return value * 1.1f;
            return value * 1.8f;
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
    
    _movieName.text =aMovie.name;
    _movieActor.text =aMovie.aword;
    _movieRating.text = [NSString stringWithFormat:@"%@ : %0.1f (%d 万人)",aMovie.ratingFrom,[aMovie.rating floatValue],[aMovie.ratingpeople intValue]/10000];
    _movieTimeLong.text = @"120分钟";
    
    self.apiCmdMovie_getSchedule = [[DataBaseManager sharedInstance] getScheduleFromWebWithaMovie:_mMovie andaCinema:_mCinema delegate:self];
}


#pragma mark -
#pragma mark apiNotiry
-(void)apiNotifyResult:(id)apiCmd error:(NSError *)error{
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        [[DataBaseManager sharedInstance] insertScheduleIntoCoreDataFromObject:[apiCmd responseJSONObject]
                                                                    withApiCmd:apiCmd
                                                                    withaMovie:_mMovie
                                                                    andaCinema:_mCinema];
        
        int tag = [[apiCmd httpRequest] tag];
        [self updateData:tag responseData:[apiCmd responseJSONObject]];
        
    });
    
}

- (void) apiNotifyLocationResult:(id) apiCmd  error:(NSError*) error{
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        int tag = [[apiCmd httpRequest] tag];
        [self updateData:tag responseData:[apiCmd responseJSONObject]];
    });
}

- (void)updateData:(int)tag responseData:(NSDictionary *)responseDic
{
    ABLogger_int(tag);
    switch (tag) {
        case 0:
        case API_MScheduleCmd:
        {
            [self formatCinemaData:responseDic];
        }
            break;
        default:
        {
            NSAssert(0, @"没有从网络抓取到数据");
        }
            break;
    }
}

- (void)formatCinemaData:(NSDictionary *)responseDic{
    ABLoggerMethod();
    NSArray *schedules = [[responseDic objectForKey:@"data"] objectForKey:@"schedule"];
    self.todaySchedules = [[schedules objectAtIndex:0] objectForKey:@"starts"];
    self.tomorrowSchedules = [[schedules objectAtIndex:1] objectForKey:@"starts"];
    self.schedulesArray = self.todaySchedules;
    
    [self setTableViewDelegate];
    
    dispatch_sync(dispatch_get_main_queue(), ^{
        
        [_mTableView reloadData];
    });
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
}

@end
