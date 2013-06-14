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
#import "MMovie.h"

@interface ScheduleViewController ()<ApiNotify>{
    
}
@property(nonatomic,retain) ApiCmdMovie_getSchedule *apiCmdMovie_getSchedule;
@property(nonatomic,retain) ScheduleTableViewDelegate *scheduleTableViewDelegate;
@property(nonatomic,retain) NSArray *todaySchedules;
@property(nonatomic,retain) NSArray *tomorrowSchedules;

@end

@implementation ScheduleViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = _mMovie.name;
        [[DataBaseManager sharedInstance] getScheduleFromWebWithaMovie:_mMovie andaCinema:_mCinema delegate:self];
    }
    return self;
}

- (void)dealloc{
    self.todayButton = nil;
    self.tomorrowButton = nil;
    self.cinemaButton = nil;
    self.mTableView = nil;
    self.mMovie = nil;
    self.mCinema = nil;
    
    self.todaySchedules = nil;
    self.todaySchedules = nil;
    self.schedulesArray = nil;
    self.scheduleTableViewDelegate = nil;
    [super dealloc];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
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
    
    if (!_scheduleTableViewDelegate) {
        _scheduleTableViewDelegate = [[ScheduleTableViewDelegate alloc] init];
    }
    [self setTableViewDelegate];
    
    [_todayButton setBackgroundColor:[UIColor colorWithRed:0.047 green:0.678 blue:1.000 alpha:1.000]];
    
}

- (IBAction)clickCinemaButton:(id)sender{
    
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
