//
//  MovieDetailViewController.m
//  WanShangLe
//
//  Created by stephenliu on 13-6-21.
//  Copyright (c) 2013年 stephenliu. All rights reserved.
//

#import "MovieDetailViewController.h"
#import "ApiCmdMovie_getAllMovieDetail.h"
#import "ASIHTTPRequest.h"
#import "MMovie.h"
#import "MMovieDetail.h"
#import "UIImageView+WebCache.h"

@interface MovieDetailViewController ()<ApiNotify>{
    
}
@property(nonatomic,retain) ApiCmdMovie_getAllMovieDetail *apiCmdMovie_getAllMovieDetail;
@end

@implementation MovieDetailViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {

    }
    return self;
}

- (void)dealloc{
    self.mMovie = nil;
    
    [_apiCmdMovie_getAllMovieDetail.httpRequest clearDelegatesAndCancel];
    _apiCmdMovie_getAllMovieDetail.delegate = nil;
    self.apiCmdMovie_getAllMovieDetail = nil;
    
    [super dealloc];
}

- (void)viewWillAppear:(BOOL)animated{
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _imgView = [[UIImageView alloc] initWithFrame:CGRectMake(7, 6, 120, 170)];
    [self.view addSubview:_imgView];
    
    if (_mMovie.movieDetail.info==nil) {
        
        self.apiCmdMovie_getAllMovieDetail = (ApiCmdMovie_getAllMovieDetail *)[[DataBaseManager sharedInstance] getMovieDetailFromWeb:self movieId:_mMovie.uid];
    }else{
        [self initMovieDetailData];
    }

}

- (void)initMovieDetailData{
    NSDictionary *tDic = _mMovie.movieDetail.info;
    [_imgView setImageWithURL:[NSURL URLWithString:[tDic objectForKey:@"coverurl"]]
             placeholderImage:[UIImage imageNamed:@"placeholder"]
                      options:SDWebImageRetryFailed];
    
    _directorLabel.text = [tDic objectForKey:@"director"];
    _actorLabel.text = [tDic objectForKey:@"star"];
    _typeLabel.text = [tDic objectForKey:@"type"];
    _durationLabel.text = [tDic objectForKey:@"duration"];
    _startdayLabel.text = [tDic objectForKey:@"startday"];
    _recommendLabel.text = [tDic objectForKey:@"recommendadded"];
    _wantLookLabel.text = [tDic objectForKey:@"wantedadded"];
    _descriptionLabel.text = [tDic objectForKey:@"description"];
}

#pragma mark -
#pragma mark 点击按钮 Event
-(IBAction)clickRecommendButton:(id)sender{
    [self startAddOneAnimation:(UIButton *)sender];
}

-(IBAction)clickWantLookButton:(id)sender{
    [self startAddOneAnimation:(UIButton *)sender];
}

- (void)startAddOneAnimation:(UIButton *)sender{
    
    _addOneLabel.center = CGPointMake(sender.center.x-5, sender.center.y-10);
    _addOneLabel.alpha = 1.0;
    [self.view addSubview:_addOneLabel];
    
    [UIView animateWithDuration:1 animations:^{
        
        [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
        _addOneLabel.center = CGPointMake(sender.center.x-5, sender.center.y-20);
        _addOneLabel.alpha = 0.4;
        
    } completion:^(BOOL finished) {
        [_addOneLabel removeFromSuperview];
    }];
}

#pragma mark -
#pragma mark apiNotiry
-(void)apiNotifyResult:(id)apiCmd error:(NSError *)error{
    
    if (error) {
        return;
    }
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        [[DataBaseManager sharedInstance] insertMovieDetailIntoCoreDataFromObject:[apiCmd responseJSONObject] withApiCmd:apiCmd];
        
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
    return _apiCmdMovie_getAllMovieDetail;
}

- (void)updateData:(int)tag
{
    ABLogger_int(tag);
    switch (tag) {
        case 0:
        case API_MMovieDetailCmd:
        {
            
            dispatch_sync(dispatch_get_main_queue(), ^{
                [self initMovieDetailData];
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
    [super didReceiveMemoryWarning];
    ABLoggerWarn(@"接收到内存警告了");
    // Dispose of any resources that can be recreated.
}

@end
