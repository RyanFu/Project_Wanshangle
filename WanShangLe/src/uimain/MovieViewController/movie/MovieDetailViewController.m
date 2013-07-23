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
#import "ApiCmd_recommendOrLook.h"

#define IntroduceLabelHeight 213

@interface MovieDetailViewController ()<ApiNotify>{
     ShareType _followType;
    
    BOOL isRecommended;
    BOOL isLooked;
}
@property(nonatomic,retain) MMovieDetail *mMovieDetail;
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
    
    self.movie_portImgView = nil;
    self.mMovie = nil;
    self.mMovieDetail = nil;
    [super dealloc];
}

- (void)viewWillAppear:(BOOL)animated{
    [[UINavigationBar appearance] setBackgroundImage:[UIImage imageNamed:@"bg_navigationBar"] forBarMetrics:UIBarMetricsDefault];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _appDelegate = [AppDelegate appDelegateInstance];
    
    [self initBarItem];
    
    [self initData];
}

- (void)initBarItem{
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [backButton setFrame:CGRectMake(0, 0, 45, 30)];
    [backButton addTarget:self action:@selector(clickBackButton:) forControlEvents:UIControlEventTouchUpInside];
    [backButton setBackgroundImage:[UIImage imageNamed:@"bt_back_n@2x"] forState:UIControlStateNormal];
    [backButton setBackgroundImage:[UIImage imageNamed:@"bt_back_f@2x"] forState:UIControlStateHighlighted];
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    self.navigationItem.leftBarButtonItem = backItem;
    [backItem release];
    
    UIButton *shareBt = [UIButton buttonWithType:UIButtonTypeCustom];
    [shareBt setFrame:CGRectMake(0, 0, 45, 32)];
    [shareBt addTarget:self action:@selector(shareButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [shareBt setBackgroundImage:[UIImage imageNamed:@"btn_share_n@2x"] forState:UIControlStateNormal];
    [shareBt setBackgroundImage:[UIImage imageNamed:@"btn_share_f@2x"] forState:UIControlStateHighlighted];
    UIBarButtonItem *shareItem = [[UIBarButtonItem alloc] initWithCustomView:shareBt];
    self.navigationItem.rightBarButtonItem = shareItem;
    [shareItem release];
}

- (void)initData{
    
    //初试化海报图片
    _movie_portImgView = [[UIImageView alloc] initWithFrame:CGRectMake(9, 10, 89, 119)];
    _movie_portImgView.image = [UIImage imageNamed:@"movie_placeholder_H@2x"];
    [_mScrollView addSubview:_movie_portImgView];
    
    if ([[DataBaseManager sharedInstance] isSelectedLike:_mMovie.uid withType:API_RecommendOrLookMovieType]) {
        [_movie_yesButton setBackgroundImage:[UIImage imageNamed:@"btn_good_s_f@2x"] forState:UIControlStateNormal];
        isRecommended = YES;
    }
    if ([[DataBaseManager sharedInstance] isSelectedWantLook:_mMovie.uid withType:API_RecommendOrLookMovieType]) {
        [_movie_wantLookButton setBackgroundImage:[UIImage imageNamed:@"btn_look_s_f@2x"] forState:UIControlStateNormal];
        isLooked = YES;
    }
    
    self.mMovieDetail = [[DataBaseManager sharedInstance] getMovieDetailWithId:_mMovie.uid];
    
    if (_mMovieDetail==nil) {//电影详情为空
        self.apiCmdMovie_getAllMovieDetail = (ApiCmdMovie_getAllMovieDetail *)[[DataBaseManager sharedInstance] getMovieDetailFromWeb:self movieId:_mMovie.uid];
        
    }else{
        [self initMovieDetailData];
        [self requestRecommendAndWantLookCount];
        
        _movie_yes.text = _mMovieDetail.recommendation;
        _movie_wantLook.text = _mMovieDetail.wantlook;
        
        self.mMovieDetail = _mMovie.movieDetail;
    }

    [_movie_portImgView setImageWithURL:[NSURL URLWithString:_mMovie.webImg]
                      placeholderImage:[UIImage imageNamed:@"movie_placeholder_H@2x"]
                               options:SDWebImageRetryFailed];
}

- (void)initMovieDetailData{

    _movie_director.text = [_mMovieDetail.info objectForKey:@"director"];
    _movie_actor.text = [_mMovieDetail.info objectForKey:@"star"];
    _movie_type.text = [_mMovieDetail.info objectForKey:@"type"];
    _movie_district.text = @"NULL缺少字段";
    _movie_timeLong.text = [[_mMovieDetail.info objectForKey:@"duration"] stringByAppendingString:@"分钟"];
    _movie_uptime.text = [_mMovieDetail.info objectForKey:@"startday"];
    
    _movie_rating.text = [NSString stringWithFormat:@"%@评分: %@",_mMovie.ratingFrom,_mMovie.rating];
    _movie_introduce.text = [_mMovieDetail.info objectForKey:@"description"];
    
    CGSize misize = [_movie_introduce.text sizeWithFont:_movie_introduce.font constrainedToSize:CGSizeMake(_movie_introduce.bounds.size.width, MAXFLOAT)];
    
    if (misize.height>_movie_introduce.bounds.size.height) {

        CGRect introFrame = _movie_introduce.frame;
        introFrame.size.height = misize.height;
        _movie_introduce.frame = introFrame;
        
        if (misize.height>IntroduceLabelHeight) {
            float extendHeight = misize.height - IntroduceLabelHeight;
             [_mScrollView setContentSize:CGSizeMake(self.view.bounds.size.width, self.view.bounds.size.height+extendHeight)];
            CGRect bgImgFrame = _movie_introBgImgView.frame;
            bgImgFrame.size.height += extendHeight;
            _movie_introBgImgView.frame = bgImgFrame;
        }
    }
    
    [self updateRecommendAndWantLookCount];
}

- (void)requestRecommendAndWantLookCount{
    [[DataBaseManager sharedInstance] getRecommendOrLookForWeb:_mMovie.uid APIType:WSLRecommendAPITypeMovieInteract cType:WSLRecommendLookTypeLook delegate:self];
}

- (void)updateRecommendAndWantLookCount{
    _movie_yes.text = _mMovieDetail.recommendation;
    _movie_wantLook.text = _mMovieDetail.wantlook;
    
}
#pragma mark -
#pragma mark 点击按钮 Event

- (void)clickBackButton:(id)sender{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)clickYesButton:(id)sender{
    if (isRecommended || _mMovieDetail==nil) {
        return;
    }
    
     ABLoggerDebug(@"info === %@",_mMovieDetail.info);
    [_movie_yesButton setBackgroundImage:[UIImage imageNamed:@"btn_good_s_f@2x"] forState:UIControlStateNormal];
    isRecommended = YES;
    [[DataBaseManager sharedInstance] getRecommendOrLookForWeb:_mMovie.uid APIType:WSLRecommendAPITypeMovieInteract cType:WSLRecommendLookTypeRecommend delegate:self];
    
    NSMutableDictionary *tDic = [NSMutableDictionary dictionaryWithCapacity:5];
    [tDic setObject:_mMovie.uid forKey:@"uid"];
    [tDic setObject:API_RecommendOrLookMovieType forKey:@"type"];
    [tDic setObject:[_mMovieDetail.info objectForKey:@"startday"] forKey:@"beginTime"];
    [tDic setObject:[[DataBaseManager sharedInstance] dateWithTimeIntervalSinceNow:(2*30*24*60*60) fromDate:[_mMovieDetail.info objectForKey:@"startday"]] forKey:@"endTime"];
    [tDic setObject:[NSNumber numberWithBool:YES] forKey:@"recommend"];
    [[DataBaseManager sharedInstance] addActionState:tDic];
    
    _movie_yes.text = [NSString stringWithFormat:@"%d",[_movie_yes.text intValue]+1];
    [self startAddOneAnimation:(UIButton *)sender];
}

- (IBAction)clickWantLookButton:(id)sender{
    if (isLooked || _mMovieDetail==nil) {
        return;
    }
    
    [_movie_wantLookButton setBackgroundImage:[UIImage imageNamed:@"btn_look_s_f@2x"] forState:UIControlStateNormal];
    isLooked = YES;
    [[DataBaseManager sharedInstance] getRecommendOrLookForWeb:_mMovie.uid APIType:WSLRecommendAPITypeMovieInteract cType:WSLRecommendLookTypeLook delegate:self];
    
    NSMutableDictionary *tDic = [NSMutableDictionary dictionaryWithCapacity:5];
    [tDic setObject:_mMovie.uid forKey:@"uid"];
    [tDic setObject:API_RecommendOrLookMovieType forKey:@"type"];
    [tDic setObject:[_mMovieDetail.info objectForKey:@"startday"] forKey:@"beginTime"];
    [tDic setObject:[[DataBaseManager sharedInstance] dateWithTimeIntervalSinceNow:(2*30*24*60*60) fromDate:[_mMovieDetail.info objectForKey:@"startday"]] forKey:@"endTime"];
    [tDic setObject:[NSNumber numberWithBool:YES] forKey:@"wantLook"];
    [[DataBaseManager sharedInstance] addActionState:tDic];
    
    _movie_wantLook.text = [NSString stringWithFormat:@"%d",[_movie_wantLook.text intValue]+1];
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
                 self.mMovieDetail = [[DataBaseManager sharedInstance] insertMovieDetailIntoCoreDataFromObject:[apiCmd responseJSONObject] withApiCmd:apiCmd];
            }
                break;
            case API_RecommendOrLookCmd:
            {
                self.mMovieDetail = [[DataBaseManager sharedInstance] insertMovieRecommendIntoCoreDataFromObject:[apiCmd responseJSONObject] withApiCmd:apiCmd];
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

        [self updateData:0];

    });
}

- (ApiCmd *)apiGetDelegateApiCmd{
    return _apiCmdMovie_getAllMovieDetail;
}

- (void)updateData:(int)tag
{
    dispatch_sync(dispatch_get_main_queue(), ^{
        ABLogger_int(tag);
        switch (tag) {
            case 0:
            case API_MMovieDetailCmd:
            {
                [self initMovieDetailData];
            }
                break;
            case API_RecommendOrLookCmd:
            {
                [self updateRecommendAndWantLookCount];
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

#pragma mark -
#pragma mark FilterCinema FormatData
- (void)formatKTVDataFilterAll:(NSArray*)pageArray{
}


- (void)shareButtonClick:(id)sender{
    
//    AppDelegate *_appDelegate = [AppDelegate appDelegateInstance];
    
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
@end
