//
//  ShowViewController.m
//  WanShangLe
//
//  Created by stephenliu on 13-6-5.
//  Copyright (c) 2013年 stephenliu. All rights reserved.
//

#import "ShowViewController.h"
#import "ApiCmdShow_getAllShows.h"
#import "ShowTableViewDelegate.h"

@interface ShowViewController ()<ApiNotify>
@property(nonatomic,retain) ShowTableViewDelegate *showTableViewDelegate;
@property(nonatomic,retain) UIView *maskView;

@end

@implementation ShowViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            self.apiCmdShow_getAllShows = [[DataBaseManager sharedInstance] getAllShowsListFromWeb:self];
        });
    }
    return self;
}

- (void)dealloc{
    
    self.typeButton = nil;
    self.timeButton = nil;
    self.orderButton = nil;
    self.mTableView = nil;
    self.typeView = nil;
    self.timeView = nil;
    self.orderView = nil;
    self.apiCmdShow_getAllShows = nil;
    self.showsArray = nil;
    self.showTableViewDelegate = nil;
    self.maskView = nil;
    
    [super dealloc];
}

- (void)viewWillAppear:(BOOL)animated{
    [self.navigationController setNavigationBarHidden:NO];
    
    self.apiCmdShow_getAllShows = [[DataBaseManager sharedInstance] getAllShowsListFromWeb:self];
    
#ifdef TestCode
    [self updatData];//测试代码
#endif
    
}

- (void)updatData{
    for (int i=0; i<10; i++) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            self.apiCmdShow_getAllShows = [[DataBaseManager sharedInstance] getAllShowsListFromWeb:self];
        });
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _showTableViewDelegate = [[ShowTableViewDelegate alloc] init];
    _showTableViewDelegate.parentViewController = self;
    [self setTableViewDelegate];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        [self updateData:0];
    });
    
    _maskView = [[UIView alloc] initWithFrame:self.view.bounds];
    [_maskView setBackgroundColor:[UIColor colorWithWhite:0.400 alpha:0.250]];

    ABLoggerDebug(@"%@",_typeBts);
}

- (void)setTableViewDelegate{
    _mTableView.dataSource = _showTableViewDelegate;
    _mTableView.delegate = _showTableViewDelegate;
}

#pragma mark -
#pragma mark xib Button event
- (IBAction)clickTypeButton:(id)sender{
    
    [self cleanUpButtonBackground];
    [_typeButton setBackgroundColor:[UIColor colorWithRed:0.184 green:0.973 blue:0.629 alpha:1.000]];
    [_typeView setAlpha:0];
    
    [self.view addSubview:_maskView];
    [self.view addSubview:_typeView];
    
    CGRect newFrame = _typeView.frame;
    newFrame.origin = CGPointMake(_typeButton.frame.origin.x, _typeButton.frame.origin.y);
    _typeView.frame = newFrame;
    
    [UIView animateWithDuration:0.2 animations:^{
        [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
        [_typeView setAlpha:1];
        CGRect newFrame = _typeView.frame;
        newFrame.origin = CGPointMake(_typeButton.frame.origin.x, _typeButton.frame.origin.y+_typeButton.frame.size.height);
        _typeView.frame = newFrame;
    } completion:^(BOOL finished) {
        
    }];
}

- (IBAction)clickTimeButton:(id)sender{
    [self cleanUpButtonBackground];
    [_timeButton setBackgroundColor:[UIColor colorWithRed:0.184 green:0.973 blue:0.629 alpha:1.000]];
    [_timeView setAlpha:0];
    
    [self.view addSubview:_maskView];
    [self.view addSubview:_timeView];
    
    CGRect newFrame = _timeView.frame;
    newFrame.origin = CGPointMake(_timeButton.frame.origin.x, _timeButton.frame.origin.y);
    _timeView.frame = newFrame;
    
    [UIView animateWithDuration:0.2 animations:^{
        [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
        [_timeView setAlpha:1];
        CGRect newFrame = _timeView.frame;
        newFrame.origin = CGPointMake(_timeButton.frame.origin.x, _timeButton.frame.origin.y+_timeButton.frame.size.height);
        _timeView.frame = newFrame;
    } completion:^(BOOL finished) {
        
    }];
}

- (IBAction)clickOrderButton:(id)sender{
    [self cleanUpButtonBackground];
    [_orderButton setBackgroundColor:[UIColor colorWithRed:0.184 green:0.973 blue:0.629 alpha:1.000]];
    [_orderView setAlpha:0];
    
    [self.view addSubview:_maskView];
    [self.view addSubview:_orderView];
    
    CGRect newFrame = _orderView.frame;
    newFrame.origin = CGPointMake(_orderButton.frame.origin.x, _orderButton.frame.origin.y);
    _orderView.frame = newFrame;
    
    [UIView animateWithDuration:0.2 animations:^{
        [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
        [_orderView setAlpha:1];
        CGRect newFrame = _orderView.frame;
        newFrame.origin = CGPointMake(_orderButton.frame.origin.x, _orderButton.frame.origin.y+_orderButton.frame.size.height);
        _orderView.frame = newFrame;
    } completion:^(BOOL finished) {
        
    }];
}

- (void)cleanUpButtonBackground{
    [_typeButton setBackgroundColor:[UIColor clearColor]];
    [_timeButton setBackgroundColor:[UIColor clearColor]];
    [_orderButton setBackgroundColor:[UIColor clearColor]];
}

- (IBAction)clickTypeSubButtonDown:(id)sender{
    UIButton *bt = (UIButton *)sender;
    int tag = [bt tag];
    
    [self cleanUpTypeSubButton];
    [bt setBackgroundColor:[UIColor colorWithRed:0.047 green:0.678 blue:1.000 alpha:1.000]];
    
    switch (tag) {
        case 1:{
           
        }
        
        break;
        case 2:{

        }
        
        break;
        case 3:{

        }
        
        break;
        case 4:{

        }
        
        break;
        case 5:{

        }
        
        break;
    default:
        break;
    }
}

- (IBAction)clickTypeSubButtonUp:(id)sender{
    [_typeView removeFromSuperview];
    [_maskView removeFromSuperview];
}

- (void)cleanUpTypeSubButton{
    for (UIButton *bt in _typeBts) {
        [bt setBackgroundColor:[UIColor clearColor]];
    }
}

- (IBAction)clickTimeSubButtonDown:(id)sender{
    UIButton *bt = (UIButton *)sender;
    int tag = [bt tag];
    
    [self cleanUpTimeSubButton];
    [bt setBackgroundColor:[UIColor colorWithRed:0.047 green:0.678 blue:1.000 alpha:1.000]];
    
    switch (tag) {
        case 1:{
            
        }
            
            break;
        case 2:{
            
        }
            
            break;
        case 3:{
            
        }
            
            break;
        case 4:{
            
        }
            
            break;
        case 5:{
            
        }
            
            break;
        default:
            break;
    }
}

- (IBAction)clickTimeSubButtonUp:(id)sender{
    [_timeView removeFromSuperview];
    [_maskView removeFromSuperview];
}

- (void)cleanUpTimeSubButton{
    for (UIButton *bt in _timeBts) {
        [bt setBackgroundColor:[UIColor clearColor]];
    }
}

- (IBAction)clickOrderSubButtonDown:(id)sender{
    UIButton *bt = (UIButton *)sender;
    int tag = [bt tag];
    
    [self cleanUpOrderSubButton];
    [bt setBackgroundColor:[UIColor colorWithRed:0.047 green:0.678 blue:1.000 alpha:1.000]];
    
    switch (tag) {
        case 1:{
            
        }
            
            break;
        case 2:{
            
        }
            
            break;
        case 3:{
            
        }
            
            break;
        case 4:{
            
        }
            
            break;
        case 5:{
            
        }
            
            break;
        default:
            break;
    }
}

- (IBAction)clickOrderSubButtonUp:(id)sender{
    [_orderView removeFromSuperview];
    [_maskView removeFromSuperview];
}

- (void)cleanUpOrderSubButton{
    for (UIButton *bt in _orderBts) {
        [bt setBackgroundColor:[UIColor clearColor]];
    }
}

#pragma mark -
#pragma mark apiNotiry
-(void)apiNotifyResult:(id)apiCmd error:(NSError *)error{
    
    if (error) {
        return;
    }
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        [[DataBaseManager sharedInstance] insertShowsIntoCoreDataFromObject:[apiCmd responseJSONObject] withApiCmd:apiCmd];
        
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
        case API_SShowCmd:
        {
            NSArray *array = [[DataBaseManager sharedInstance] getAllShowsListFromCoreData];
            self.showsArray = array;
            ABLoggerDebug(@"演出 count ==== %d",[self.showsArray count]);
            
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
