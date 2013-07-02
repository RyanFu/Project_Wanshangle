//
//  MovieDetailViewController.m
//  WanShangLe
//
//  Created by stephenliu on 13-6-21.
//  Copyright (c) 2013年 stephenliu. All rights reserved.
//

#import "ASIHTTPRequest.h"
#import "MMovie.h"
#import "MMovieDetail.h"
#import "UIImageView+WebCache.h"
#import <ShareSDK/ShareSDK.h>
#import "AppDelegate.h"
#import "MovieDetailViewController.h"
#import "ApiCmdMovie_getAllMovieDetail.h"
#import "ApiCmd_recommendOrLook.h"


@interface MovieDetailViewController ()<ApiNotify>{
     ShareType _followType;
    
}
@property(nonatomic,assign) AppDelegate *appDelegate;
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
    [[UINavigationBar appearance] setBackgroundImage:[UIImage imageNamed:@"bg_navigationBar"] forBarMetrics:UIBarMetricsDefault];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _appDelegate = [AppDelegate appDelegateInstance];
    
    _imgView = [[UIImageView alloc] initWithFrame:CGRectMake(7, 6, 90, 120)];
    [_mScrollView addSubview:_imgView];
    [_imgView release];

    UIImage *img = [UIImage imageNamed:@"bg_movie_detail_info@2x"];
    _movieInfoImgView = [[UIImageView alloc] initWithFrame:CGRectMake(9, 176,302, 270)];
    [_movieInfoImgView setBackgroundColor:[UIColor clearColor]];
    UIEdgeInsets insets = UIEdgeInsetsMake(80, 20, 18, 20);
    _movieInfoImgView.image = [img resizableImageWithCapInsets:insets resizingMode:UIImageResizingModeStretch];
    [_movieInfoImgView setContentScaleFactor:2.0f];
    [_mScrollView addSubview:_movieInfoImgView];
    [_movieInfoImgView release];
    
    [_recommendButton setBackgroundImage:[UIImage imageNamed:@"btn_good_h_f"] forState:UIControlStateNormal];
    [_recommendButton setBackgroundImage:[UIImage imageNamed:@"btn_good_s_f"] forState:UIControlStateHighlighted];
    [_recommendButton setBackgroundImage:[UIImage imageNamed:@"btn_good_s_f"] forState:UIControlStateSelected];
    
    [_wantLookButton setBackgroundImage:[UIImage imageNamed:@"btn_look_h_f"] forState:UIControlStateNormal];
    [_wantLookButton setBackgroundImage:[UIImage imageNamed:@"btn_look_s_f"] forState:UIControlStateHighlighted];
    [_wantLookButton setBackgroundImage:[UIImage imageNamed:@"btn_look_s_f"] forState:UIControlStateSelected];
    
    if (_mMovie.movieDetail.info==nil) {
        [_imgView setImageWithURL:[NSURL URLWithString:_mMovie.webImg]
                 placeholderImage:[UIImage imageNamed:@"movie_placeholder@2x"]
                          options:SDWebImageRetryFailed];
        self.apiCmdMovie_getAllMovieDetail = (ApiCmdMovie_getAllMovieDetail *)[[DataBaseManager sharedInstance] getMovieDetailFromWeb:self movieId:_mMovie.uid];
    }else{
        [self initMovieDetailData];
    }
    
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [backButton setFrame:CGRectMake(0, 0, 45, 30)];
    [backButton addTarget:self action:@selector(clickBackButton:) forControlEvents:UIControlEventTouchUpInside];
    [backButton setBackgroundImage:[UIImage imageNamed:@"bt_back_n@2x"] forState:UIControlStateNormal];
    [backButton setBackgroundImage:[UIImage imageNamed:@"bt_back_f@2x"] forState:UIControlStateHighlighted];
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    self.navigationItem.leftBarButtonItem = backItem;
    
    UIButton *shareBt = [UIButton buttonWithType:UIButtonTypeCustom];
    [shareBt setFrame:CGRectMake(0, 0, 45, 32)];
    [shareBt addTarget:self action:@selector(shareButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [shareBt setBackgroundImage:[UIImage imageNamed:@"btn_share_n@2x"] forState:UIControlStateNormal];
    [shareBt setBackgroundImage:[UIImage imageNamed:@"btn_share_f@2x"] forState:UIControlStateHighlighted];
    UIBarButtonItem *shareItem = [[UIBarButtonItem alloc] initWithCustomView:shareBt];
    self.navigationItem.rightBarButtonItem = shareItem;
}

- (void)initMovieDetailData{
    
    NSDictionary *tDic = _mMovie.movieDetail.info;
    ABLoggerInfo(@"tDic ===== %@",tDic);
    [_imgView setImageWithURL:[NSURL URLWithString:[tDic objectForKey:@"coverurl"]]
             placeholderImage:[UIImage imageNamed:@"movie_placeholder@2x"]
                      options:SDWebImageRetryFailed];
    _directorLabel.text = [tDic objectForKey:@"director"];
    
    UILabel *movieInfoLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 50, 282, 220)];
    [movieInfoLabel setBackgroundColor:[UIColor clearColor]];
    [movieInfoLabel setNumberOfLines:0];
    movieInfoLabel.font = [UIFont systemFontOfSize:15];
    movieInfoLabel.text = [tDic objectForKey:@"description"];
    CGSize misize = [movieInfoLabel.text sizeWithFont:[UIFont systemFontOfSize:15] constrainedToSize:CGSizeMake(movieInfoLabel.bounds.size.width, MAXFLOAT)];
   
    if (misize.height>movieInfoLabel.bounds.size.height) {
         movieInfoLabel.frame = CGRectMake(10, 50, 282, misize.height);
        float extendHeight = misize.height - 220;
        [_mScrollView setContentSize:CGSizeMake(self.view.bounds.size.width, self.view.bounds.size.height+extendHeight)];
        [_movieInfoImgView setFrame:CGRectMake(9, 176,302, 270+extendHeight)];
    }
    
    [_movieInfoImgView addSubview:movieInfoLabel];
    
    
//    _actorLabel.text = [tDic objectForKey:@"star"];
//    _typeLabel.text = [tDic objectForKey:@"type"];
//    _durationLabel.text = [tDic objectForKey:@"duration"];
//    _startdayLabel.text = [tDic objectForKey:@"startday"];
//    _recommendLabel.text = [tDic objectForKey:@"recommendadded"];
//    _wantLookLabel.text = [tDic objectForKey:@"wantedadded"];
//    _descriptionTextView.text = [tDic objectForKey:@"description"];
}

- (void)updateRecOrLookData{
    ABLoggerInfo(@"推荐 ===== %@",_mMovie.movieDetail.recommendadded);
    
    if (isEmpty( _mMovie.movieDetail.recommendadded)) {
        _recommendLabel.text = [NSString stringWithFormat:@"%d",[_recommendLabel.text intValue]+1];
    }else{
        _recommendLabel.text = _mMovie.movieDetail.recommendadded;
    }
    
    if (isEmpty( _mMovie.movieDetail.wantedadded)) {
        _wantLookLabel.text = [NSString stringWithFormat:@"%d",[_wantLookLabel.text intValue]+1];
    }else{
        _wantLookLabel.text = _mMovie.movieDetail.wantedadded;
    }
}

#pragma mark -
#pragma mark 点击按钮 Event

- (void)clickBackButton:(id)sender{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)shareButtonClick:(id)sender{
    
    //定义菜单分享列表
    NSArray *shareList = [ShareSDK getShareListWithType:ShareTypeWeixiTimeline, ShareTypeWeixiSession, ShareTypeSMS,nil];
    
    //创建分享内容
    NSString *imagePath = [[NSBundle mainBundle] pathForResource:IMAGE_NAME ofType:IMAGE_EXT];
    id<ISSContent> publishContent = [ShareSDK content:CONTENT
                                       defaultContent:@"hello"
                                                image:[ShareSDK imageWithPath:imagePath]
                                                title:@"ShareSDK"
                                                  url:@"http://www.sharesdk.cn"
                                          description:@"这是一条测试信息"
                                            mediaType:SSPublishContentMediaTypeNews];
    
    //定制微信好友信息
    [publishContent addWeixinSessionUnitWithType:INHERIT_VALUE
                                         content:INHERIT_VALUE
                                           title:@"Hello 微信好友!"
                                             url:INHERIT_VALUE
                                           image:INHERIT_VALUE
                                    musicFileUrl:nil
                                         extInfo:nil
                                        fileData:nil
                                    emoticonData:nil];
    
    //定制微信朋友圈信息
    [publishContent addWeixinTimelineUnitWithType:[NSNumber numberWithInteger:SSPublishContentMediaTypeMusic]
                                          content:INHERIT_VALUE
                                            title:@"Hello 微信朋友圈!"
                                              url:@"http://y.qq.com/i/song.html#p=7B22736F6E675F4E616D65223A22E4BDA0E4B88DE698AFE79C9FE6ADA3E79A84E5BFABE4B990222C22736F6E675F5761704C69766555524C223A22687474703A2F2F74736D7573696332342E74632E71712E636F6D2F586B303051563558484A645574315070536F4B7458796931667443755A68646C2F316F5A4465637734356375386355672B474B304964794E6A3770633447524A574C48795333383D2F3634363232332E6D34613F7569643D32333230303738313038266469723D423226663D312663743D3026636869643D222C22736F6E675F5769666955524C223A22687474703A2F2F73747265616D31382E71716D757369632E71712E636F6D2F33303634363232332E6D7033222C226E657454797065223A2277696669222C22736F6E675F416C62756D223A22E5889BE980A0EFBC9AE5B08FE5B7A8E89B8B444E414C495645EFBC81E6BC94E594B1E4BC9AE5889BE7BAAAE5BD95E99FB3222C22736F6E675F4944223A3634363232332C22736F6E675F54797065223A312C22736F6E675F53696E676572223A22E4BA94E69C88E5A4A9222C22736F6E675F576170446F776E4C6F616455524C223A22687474703A2F2F74736D757369633132382E74632E71712E636F6D2F586C464E4D31354C5569396961495674593739786D436534456B5275696879366A702F674B65356E4D6E684178494C73484D6C6A307849634A454B394568572F4E3978464B316368316F37636848323568413D3D2F33303634363232332E6D70333F7569643D32333230303738313038266469723D423226663D302663743D3026636869643D2673747265616D5F706F733D38227D"
                                            image:INHERIT_VALUE
                                     musicFileUrl:@"http://mp3.mwap8.com/destdir/Music/2009/20090601/ZuiXuanMinZuFeng20090601119.mp3"
                                          extInfo:nil
                                         fileData:nil
                                     emoticonData:nil];
    
    //创建容器
    id<ISSContainer> container = [ShareSDK container];
    [container setIPadContainerWithView:sender arrowDirect:UIPopoverArrowDirectionUp];
    
    id<ISSAuthOptions> authOptions = [ShareSDK authOptionsWithAutoAuth:YES
                                                         allowCallback:YES
                                                         authViewStyle:SSAuthViewStyleFullScreenPopup
                                                          viewDelegate:nil
                                               authManagerViewDelegate:_appDelegate.viewDelegate];
    
    //在授权页面中添加关注官方微博
    [authOptions setFollowAccounts:[NSDictionary dictionaryWithObjectsAndKeys:
                                    [ShareSDK userFieldWithType:SSUserFieldTypeName value:@"ShareSDK"],
                                    SHARE_TYPE_NUMBER(ShareTypeSinaWeibo),
                                    [ShareSDK userFieldWithType:SSUserFieldTypeName value:@"ShareSDK"],
                                    SHARE_TYPE_NUMBER(ShareTypeTencentWeibo),
                                    nil]];
    
    //显示分享菜单
    [ShareSDK showShareActionSheet:container
                         shareList:shareList
                           content:publishContent
                     statusBarTips:YES
                       authOptions:authOptions
                      shareOptions:[ShareSDK defaultShareOptionsWithTitle:nil
                                                          oneKeyShareList:[NSArray defaultOneKeyShareList]
                                                           qqButtonHidden:NO
                                                    wxSessionButtonHidden:NO
                                                   wxTimelineButtonHidden:NO
                                                     showKeyboardOnAppear:NO
                                                        shareViewDelegate:_appDelegate.viewDelegate
                                                      friendsViewDelegate:_appDelegate.viewDelegate
                                                    picViewerViewDelegate:nil]
                            result:^(ShareType type, SSPublishContentState state, id<ISSStatusInfo> statusInfo, id<ICMErrorInfo> error, BOOL end) {
                                if (state == SSPublishContentStateSuccess)
                                {
                                    NSLog(@"分享成功");
                                }
                                else if (state == SSPublishContentStateFail)
                                {
                                    NSLog(@"分享失败,错误码:%d,错误描述:%@", [error errorCode], [error errorDescription]);
                                }
                            }];
}

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

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1)
    {
        id<ISSAuthOptions> authOptions = [ShareSDK authOptionsWithAutoAuth:YES
                                                             allowCallback:YES
                                                             authViewStyle:SSAuthViewStyleFullScreenPopup
                                                              viewDelegate:nil
                                                   authManagerViewDelegate:_appDelegate.viewDelegate];
        
        //在授权页面中添加关注官方微博
        [authOptions setFollowAccounts:[NSDictionary dictionaryWithObjectsAndKeys:
                                        [ShareSDK userFieldWithType:SSUserFieldTypeName value:@"ShareSDK"],
                                        SHARE_TYPE_NUMBER(ShareTypeSinaWeibo),
                                        [ShareSDK userFieldWithType:SSUserFieldTypeName value:@"ShareSDK"],
                                        SHARE_TYPE_NUMBER(ShareTypeTencentWeibo),
                                        nil]];
        
        //关注用户
        [ShareSDK followUserWithType:_followType
                               field:@"ShareSDK"
                           fieldType:SSUserFieldTypeName
                         authOptions:authOptions
                        viewDelegate:_appDelegate.viewDelegate
                              result:^(SSResponseState state, id<ISSUserInfo> userInfo, id<ICMErrorInfo> error) {
                                  NSString *msg = nil;
                                  if (state == SSResponseStateSuccess)
                                  {
                                      msg = @"关注成功";
                                  }
                                  else if (state == SSResponseStateFail)
                                  {
                                      msg = [NSString stringWithFormat:@"关注失败:%@", error.errorDescription];
                                  }
                                  
                                  if (msg)
                                  {
                                      UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示"
                                                                                          message:msg
                                                                                         delegate:nil
                                                                                cancelButtonTitle:@"知道了"
                                                                                otherButtonTitles:nil];
                                      [alertView show];
                                      [alertView release];
                                  }
                              }];
    }
}


@end
