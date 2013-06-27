//
//  MovieDetailViewController.m
//  WanShangLe
//
//  Created by stephenliu on 13-6-21.
//  Copyright (c) 2013年 stephenliu. All rights reserved.
//

#import "MovieDetailViewController.h"
#import "ApiCmdMovie_getAllMovieDetail.h"
#import "ApiCmd_recommendOrLook.h"
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
    [[[ApiClient defaultClient] requestArray] removeObject:_apiCmdMovie_getAllMovieDetail];
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
        [_imgView setImageWithURL:[NSURL URLWithString:_mMovie.webImg]
                 placeholderImage:[UIImage imageNamed:@"placeholder"]
                          options:SDWebImageRetryFailed];
        self.apiCmdMovie_getAllMovieDetail = (ApiCmdMovie_getAllMovieDetail *)[[DataBaseManager sharedInstance] getMovieDetailFromWeb:self movieId:_mMovie.uid];
    }else{
        [self initMovieDetailData];
    }
    
}

- (void)initMovieDetailData{
    
    NSDictionary *tDic = _mMovie.movieDetail.info;
    ABLoggerInfo(@"tDic ===== %@",tDic);
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
    _descriptionTextView.text = [tDic objectForKey:@"description"];
}

- (void)updateRecOrLookData{
    ABLoggerInfo(@"推荐 ===== %@",_mMovie.movieDetail.recommendadded);
    _recommendLabel.text = _mMovie.movieDetail.recommendadded;
    _wantLookLabel.text = _mMovie.movieDetail.wantedadded;
}

#pragma mark -
#pragma mark 点击按钮 Event
-(IBAction)clickRecommendButton:(id)sender{
    [[DataBaseManager sharedInstance] getRecommendOrLookForWeb:_mMovie.uid APIType:WSLRecommendAPITypeMovieInteract cType:WSLRecommendLookTypeRecommend delegate:self];
    [self startAddOneAnimation:(UIButton *)sender];
}

-(IBAction)clickWantLookButton:(id)sender{
    [[DataBaseManager sharedInstance] getRecommendOrLookForWeb:_mMovie.uid APIType:WSLRecommendAPITypeMovieInteract cType:WSLRecommendLookTypeLook delegate:self];
    [self startAddOneAnimation:(UIButton *)sender];
}

- (void)startAddOneAnimation:(UIButton *)sender{
    sender.enabled = NO;
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(sender.center.x-5, sender.center.y-10, 20, 20)];
    [label setBackgroundColor:[UIColor clearColor]];
    label.text = @"+1";
    label.textColor = [UIColor colorWithRed:1.000 green:0.430 blue:0.540 alpha:1.000];
    label.alpha = 1.0;
    [self.view addSubview:label];
    [label release];
    
    [UIView animateWithDuration:1 animations:^{
        
        [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
        label.frame = CGRectMake(sender.center.x-5, sender.center.y-30, 20, 20);
        label.textColor = [UIColor colorWithRed:1.000 green:0.181 blue:0.373 alpha:1.000];
        label.alpha = 0.4;
        
    } completion:^(BOOL finished) {
        [label removeFromSuperview];
        sender.enabled = YES;
    }];
}

#pragma mark -
#pragma mark apiNotiry
-(void)apiNotifyResult:(id)apiCmd error:(NSError *)error{
    
    if (error) {
        return;
    }
    
    int tag = [[apiCmd httpRequest] tag];
    ABLogger_int(tag);
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        switch (tag) {
            case API_MMovieDetailCmd:
            {
                
                [[DataBaseManager sharedInstance] insertMovieDetailIntoCoreDataFromObject:[apiCmd responseJSONObject] withApiCmd:apiCmd];
            }
                break;
            case API_MMovieRecOrLookCmd:
            {
                [[DataBaseManager sharedInstance] insertMovieRecommendIntoCoreDataFromObject:_mMovie.uid data:[apiCmd responseJSONObject] withApiCmd:apiCmd];
            }
                break;
                
            default:
            {
                NSAssert(0, @"没有从网络抓取到数据");
            }
                break;
        }
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
    self.mMovie = [[DataBaseManager sharedInstance] getMovieWithId:_mMovie.uid];
    dispatch_sync(dispatch_get_main_queue(), ^{
        ABLogger_int(tag);
        switch (tag) {
            case 0:
            case API_MMovieDetailCmd:
            {
                [self initMovieDetailData];
            }
                break;
            case API_MMovieRecOrLookCmd:
            {
                
                [self updateRecOrLookData];
            }
                break;
                
            default:
            {
                NSAssert(0, @"没有从网络抓取到数据");
            }
                break;
        }
    });
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    ABLoggerWarn(@"接收到内存警告了");
    // Dispose of any resources that can be recreated.
}

@end
