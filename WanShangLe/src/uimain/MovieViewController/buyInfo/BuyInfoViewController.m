//
//  BuyInfoViewController.m
//  WanShangLe
//
//  Created by liu on 6/13/13.
//  Copyright (c) 2013 stephenliu. All rights reserved.
//

#import "BuyInfoViewController.h"
#import "BuyInfoTableViewDelegate.h"
#import "ApiCmdMovie_getBuyInfo.h"
#import "MMovie.h"
#import "MCinema.h"

@interface BuyInfoViewController ()<ApiNotify>
@property(nonatomic,retain)BuyInfoTableViewDelegate *buyInfoTableViewDelegate;
@end

@implementation BuyInfoViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = @"购票详情";
        [[DataBaseManager sharedInstance] getBuyInfoFromWebWithaMovie:_mMovie
                                                              aCinema:_mCinema
                                                            aSchedule:_schedule
                                                             delegate:self];
    }
    return self;
}

- (void)dealloc{
    self.marray = nil;
    self.mTableView = nil;
    self.mMovie = nil;
    self.mCinema = nil;
    self.buyInfoTableViewDelegate = nil;
    
    [super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.movieName.text = _mMovie.name;
    self.movieInfo.text = _mMovie.aword;
    self.cinemaName.text = _mCinema.name;
    self.cinemaInfo.text = _mCinema.address;

    _buyInfoTableViewDelegate = [[BuyInfoTableViewDelegate alloc] init];
}

- (void)setTableViewDelegate{
    _mTableView.delegate = _buyInfoTableViewDelegate;
    _mTableView.dataSource = _buyInfoTableViewDelegate;
    _buyInfoTableViewDelegate.parentViewController = self;
}

#pragma mark -
#pragma mark apiNotiry
-(void)apiNotifyResult:(id)apiCmd error:(NSError *)error{
    
    if (error) {
        return;
    }
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        [[DataBaseManager sharedInstance] insertBuyInfoIntoCoreDataFromObject:[apiCmd responseJSONObject]
                                                                    withApiCmd:apiCmd
                                                                    withaMovie:_mMovie
                                                                    andaCinema:_mCinema
                                                                    aSchedule:_schedule];
        
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
        case API_MBuyInfoCmd:
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
    
    self.marray = [[responseDic objectForKey:@"data"] objectForKey:@"vendors"];
    ABLoggerDebug(@"%@",self.marray);
    
    [self setTableViewDelegate];
    
    dispatch_sync(dispatch_get_main_queue(), ^{
        
        [_mTableView reloadData];
    });
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    ABLoggerWarn(@"接收到内存警告了");
    // Dispose of any resources that can be recreated.
}

@end
