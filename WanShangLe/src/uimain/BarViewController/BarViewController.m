//
//  ShowViewController.m
//  WanShangLe
//
//  Created by stephenliu on 13-6-5.
//  Copyright (c) 2013年 stephenliu. All rights reserved.
//

#import "BarViewController.h"
#import "ApiCmdShow_getAllShows.h"
#import "BarTableViewDelegate.h"

@interface BarViewController ()<ApiNotify>
@property(nonatomic,retain) BarTableViewDelegate *barTableViewDelegate;
@property(nonatomic,retain) UIView *maskView;

@end

@implementation BarViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
            self.apiCmdBar_getAllBars = [[DataBaseManager sharedInstance] getAllBarsListFromWeb:self];
    }
    return self;
}

- (void)dealloc{
    

    self.mTableView = nil;
    self.barsArray = nil;
    self.apiCmdBar_getAllBars = nil;
    self.barTableViewDelegate= nil;
    self.maskView = nil;
    
    [super dealloc];
}

- (void)viewWillAppear:(BOOL)animated{
    [self.navigationController setNavigationBarHidden:NO];
    
    self.apiCmdBar_getAllBars = [[DataBaseManager sharedInstance] getAllBarsListFromWeb:self];
    
#ifdef TestCode
    [self updatData];//测试代码
#endif
    
}

- (void)updatData{
    for (int i=0; i<10; i++) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            self.apiCmdBar_getAllBars = [[DataBaseManager sharedInstance] getAllBarsListFromWeb:self];
        });
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _barTableViewDelegate = [[BarTableViewDelegate alloc] init];
    _barTableViewDelegate.parentViewController = self;
    [self setTableViewDelegate];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self updateData:0];
    });
    
    _maskView = [[UIView alloc] initWithFrame:self.view.bounds];
    [_maskView setBackgroundColor:[UIColor colorWithWhite:0.400 alpha:0.250]];

}

- (void)setTableViewDelegate{
    _mTableView.dataSource = _barTableViewDelegate;
    _mTableView.delegate = _barTableViewDelegate;
}

#pragma mark -
#pragma mark xib Button event
- (IBAction)clickTodayButton:(id)sender{
    UIButton *bt = (UIButton *)sender;
    [self cleanUpButtonBackground];
    [bt setBackgroundColor:[UIColor colorWithRed:0.184 green:0.973 blue:0.629 alpha:1.000]];
}
- (IBAction)clickTomorrowButton:(id)sender{
    UIButton *bt = (UIButton *)sender;
    [self cleanUpButtonBackground];
    [bt setBackgroundColor:[UIColor colorWithRed:0.184 green:0.973 blue:0.629 alpha:1.000]];

}
- (IBAction)clickWeekendButton:(id)sender{
    UIButton *bt = (UIButton *)sender;
    [self cleanUpButtonBackground];
    [bt setBackgroundColor:[UIColor colorWithRed:0.184 green:0.973 blue:0.629 alpha:1.000]];

}

- (void)cleanUpButtonBackground{
    for (UIButton *bt in _mButtons) {
        [bt setBackgroundColor:[UIColor clearColor]];
    }
}

#pragma mark -
#pragma mark apiNotiry
-(void)apiNotifyResult:(id)apiCmd error:(NSError *)error{
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        [[DataBaseManager sharedInstance] insertBarsIntoCoreDataFromObject:[apiCmd responseJSONObject] withApiCmd:apiCmd];
        
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
        case API_BBarCmd:
        {
            NSArray *array = [[DataBaseManager sharedInstance] getAllBarsListFromCoreData];
            self.barsArray = array;
            ABLoggerDebug(@"酒吧 count ==== %d",[self.barsArray count]);
            
            [self setTableViewDelegate];
            dispatch_sync(dispatch_get_main_queue(), ^{
                
                [self.mTableView reloadData];
            });
        }
            break;
        default:
        {
            NSAssert(0, @"没有从网络抓取到数据");
        }
            break;
    }
}

- (void)didReceiveMemoryWarning
{
    ABLoggerWarn(@"接收到内存警告了");
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
