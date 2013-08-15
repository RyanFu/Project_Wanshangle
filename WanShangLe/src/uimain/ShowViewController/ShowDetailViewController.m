//
//  ShowDetailViewController.m
//  WanShangLe
//
//  Created by stephenliu on 13-6-17.
//  Copyright (c) 2013年 stephenliu. All rights reserved.
//

#import "ShowDetailViewController.h"
#import "ApiCmdShow_getShowDetail.h"
#import "ApiCmd_recommendOrLook.h"
#import <ShareSDK/ShareSDK.h>
#import "UIImageView+WebCache.h"
#import "AppDelegate.h"
#import "ApiCmd.h"
#import "ASIHTTPRequest.h"
#import "SShow.h"
#import "SShowDetail.h"
#import "WebSiteBuyViewController.h"
#import "UIImage+Crop.h"
#import "WSLProgressHUD.h"

#define IntroduceLabelHeight_5 108
#define IntroduceLabelHeight 43

@interface ShowDetailViewController()<ApiNotify>{
    BOOL isRecommended;
    BOOL isLooked;
    
}
@property(nonatomic,retain)SShowDetail *mShowDetail;
@property(nonatomic,retain)ApiCmdShow_getShowDetail *apiCmdShow_getShowDetail;
@end

@implementation ShowDetailViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = @"演出详情";
        isRecommended = NO;
        isLooked = NO;
    }
    return self;
}

- (void)dealloc{
    
    [_apiCmdShow_getShowDetail.httpRequest clearDelegatesAndCancel];
    _apiCmdShow_getShowDetail.delegate = nil;
    [[[ApiClient defaultClient] requestArray] removeObject:_apiCmdShow_getShowDetail];
    self.apiCmdShow_getShowDetail = nil;
    
    self.show_portImgView = nil;
    self.mShow = nil;
    self.mShowDetail = nil;
    [super dealloc];
}

#pragma mark -
#pragma mark UIView Cycle
- (void)viewWillAppear:(BOOL)animated{
    [[UINavigationBar appearance] setBackgroundImage:[UIImage imageNamed:@"bg_navigationBar"] forBarMetrics:UIBarMetricsDefault];
    
    if (self.mShowDetail==nil) {
        [WSLProgressHUD showWithTitle:nil status:nil cancelBlock:^{
            
        }];
    }
}

- (void)viewWillDisappear:(BOOL)animated{
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.view setBackgroundColor:Color4];
    
    [self initBarItem];
    [self initData];

}

- (void)initBarItem{
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [backButton setFrame:CGRectMake(0, 0, 45, 32)];
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
    _show_portImgView = [[UIImageView alloc] initWithFrame:CGRectMake(9, 10, 89, 119)];
    _show_portImgView.image = [UIImage imageNamed:@"show_placeholder_L@2x"];
    [_mScrollView addSubview:_show_portImgView];
    
    if ([[DataBaseManager sharedInstance] isSelectedLike:_mShow.uid withType:API_RecommendOrLookShowType]) {
        [_show_yesButton setBackgroundImage:[UIImage imageNamed:@"btn_good_s_f@2x"] forState:UIControlStateNormal];
        isRecommended = YES;
    }
    if ([[DataBaseManager sharedInstance] isSelectedWantLook:_mShow.uid withType:API_RecommendOrLookShowType]) {
        [_show_wantLookButton setBackgroundImage:[UIImage imageNamed:@"btn_look_s_f@2x"] forState:UIControlStateNormal];
        isLooked = YES;
    }
    
    self.mShowDetail = [[DataBaseManager sharedInstance] getShowDetailFromCoreDataWithId:_mShow.uid];
    
    if (_mShowDetail==nil) {//演出详情为空
        self.apiCmdShow_getShowDetail = (ApiCmdShow_getShowDetail *)[[DataBaseManager sharedInstance] getShowDetailFromWeb:self showId:_mShow.uid];
        
    }else{
        [self initShowDetailData];
        [self requestRecommendAndWantLookCount];
        
        _show_yes.text = _mShowDetail.recommendation;
        _show_wantLook.text = _mShowDetail.wantLook;
        
        [WSLProgressHUD dismiss];
    }
    
    [_show_portImgView setImageWithURL:[NSURL URLWithString:_mShow.webImg]
                      placeholderImage:[UIImage imageNamed:@"show_placeholder_L@2x"]
                               options:SDWebImageRetryFailed];
    
    
    _show_name.text = _mShow.name;
    
//    int ratingPeople = [_mShow.ratingpeople intValue];
//    NSString *scopeStr = @"人";
//    if (ratingPeople >10000) {
//        ratingPeople = ratingPeople/10000;
//        scopeStr = @"万人";
//    }
//    _show_rating.text = [NSString stringWithFormat:@"%@评分: %@",_mShow.ratingfrom,_mShow.rating];
    _show_address.text = _mShow.address;
    _theatre_name.text = _mShow.theatrename;
    _show_time.text = _mShow.beginTime;

}

- (void)initShowDetailData{
    
    _show_introduce.text = self.mShowDetail.introduce;
    
//   [_show_introduce setBackgroundColor:[UIColor redColor]];
    ABLoggerDebug(@"_show_introduce.text === %@",_show_introduce.text);
    
    CGSize misize = [_show_introduce.text sizeWithFont:_show_introduce.font constrainedToSize:CGSizeMake(_show_introduce.bounds.size.width, MAXFLOAT)];
    
    if (misize.height>_show_introduce.bounds.size.height) {

        CGRect introFrame = _show_introduce.frame;
        introFrame.size.height = misize.height;
        _show_introduce.frame = introFrame;
        
        if (misize.height>(iPhone5?IntroduceLabelHeight_5:IntroduceLabelHeight)) {
            float extendHeight = misize.height - (iPhone5?IntroduceLabelHeight_5:IntroduceLabelHeight);
            [_mScrollView setContentSize:CGSizeMake(self.view.bounds.size.width, self.view.bounds.size.height+extendHeight)];
            CGRect bgImgFrame = _show_introBgImgView.frame;
            bgImgFrame.size.height += extendHeight;
            _show_introBgImgView.frame = bgImgFrame;
        }
    }
    
    self.show_prices.text = _mShowDetail.prices;
    CGSize pricesSize = [self.show_prices.text sizeWithFont:self.show_prices.font constrainedToSize:CGSizeMake(MAXFLOAT, _show_prices.bounds.size.height)];
    CGRect newPricesFrame = _show_prices.frame;
    newPricesFrame.size.width = pricesSize.width;
    _show_prices.frame = newPricesFrame;
    _show_priceScrollView.contentSize = pricesSize;
    
    _show_yes.text = _mShowDetail.recommendation;
    _show_wantLook.text = _mShowDetail.wantLook;
    
//    [self.introduceView bringSubviewToFront:_show_introduce];
}

- (void)requestRecommendAndWantLookCount{
    [[DataBaseManager sharedInstance] getRecommendOrLookForWeb:_mShow.uid APIType:WSLRecommendAPITypePerformInteract cType:WSLRecommendLookTypeNone delegate:self];
}

- (void)updateRecommendAndWantLookCount{
    _show_yes.text = _mShowDetail.recommendation;
    _show_wantLook.text = _mShowDetail.wantLook;

}
#pragma mark -
#pragma mark 点击按钮 Event

- (void)clickBackButton:(id)sender{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)clickBuyButton:(id)sender{
    WebSiteBuyViewController *webViewController = [[WebSiteBuyViewController alloc] initWithNibName:(iPhone5?@"WebSiteBuyViewController_5":@"WebSiteBuyViewController") bundle:nil];
    webViewController.mURLStr = _mShowDetail.extpayurl;
    [self.navigationController pushViewController:webViewController animated:YES];
    [webViewController release];
}

- (IBAction)clickYesButton:(id)sender{
    if (isRecommended || _mShowDetail==nil) {
        return;
    }

    [_show_yesButton setBackgroundImage:[UIImage imageNamed:@"btn_good_s_f@2x"] forState:UIControlStateNormal];
    isRecommended = YES;
    [[DataBaseManager sharedInstance] getRecommendOrLookForWeb:_mShow.uid APIType:WSLRecommendAPITypePerformInteract cType:WSLRecommendLookTypeRecommend delegate:self];

    NSMutableDictionary *tDic = [NSMutableDictionary dictionaryWithCapacity:5];
    [tDic setObject:_mShow.uid forKey:@"uid"];
    [tDic setObject:API_RecommendOrLookShowType forKey:@"type"];
    [tDic setObject:(isNull(_mShow.beginTime)?[[DataBaseManager sharedInstance] getNowDate]:_mShow.beginTime) forKey:@"beginTime"];
    [tDic setObject:(isNull(_mShow.endTime)?[[DataBaseManager sharedInstance] getNowDate]:_mShow.endTime) forKey:@"endTime"];
    [tDic setObject:[NSNumber numberWithBool:YES] forKey:@"recommend"];
    [[DataBaseManager sharedInstance] addActionState:tDic];

    _show_yes.text = [NSString stringWithFormat:@"%d",[_show_yes.text intValue]+1];
    [self startAddOneAnimation:(UIButton *)sender];
}

- (IBAction)clickWantLookButton:(id)sender{
    if (isLooked || _mShowDetail==nil) {
        return;
    }
    
    [_show_wantLookButton setBackgroundImage:[UIImage imageNamed:@"btn_look_s_f@2x"] forState:UIControlStateNormal];
    isLooked = YES;
    [[DataBaseManager sharedInstance] getRecommendOrLookForWeb:_mShow.uid APIType:WSLRecommendAPITypePerformInteract cType:WSLRecommendLookTypeLook delegate:self];
    
    NSMutableDictionary *tDic = [NSMutableDictionary dictionaryWithCapacity:5];
    [tDic setObject:_mShow.uid forKey:@"uid"];
    [tDic setObject:API_RecommendOrLookShowType forKey:@"type"];
    [tDic setObject:(isNull(_mShow.beginTime)?[[DataBaseManager sharedInstance] getNowDate]:_mShow.beginTime) forKey:@"beginTime"];
    [tDic setObject:(isNull(_mShow.endTime)?[[DataBaseManager sharedInstance] getNowDate]:_mShow.endTime) forKey:@"endTime"];
    [tDic setObject:[NSNumber numberWithBool:YES] forKey:@"wantLook"];
    [[DataBaseManager sharedInstance] addActionState:tDic];
    
    _show_wantLook.text = [NSString stringWithFormat:@"%d",[_show_wantLook.text intValue]+1];
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
    [WSLProgressHUD dismiss];
    
    if (error!=nil) {
        return;
    }
    
    int tag = [[apiCmd httpRequest] tag];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        switch (tag) {
            case 0:
            case API_SShowDetailCmd:
            {
               self.mShowDetail = [[DataBaseManager sharedInstance] insertShowDetailIntoCoreDataFromObject:[apiCmd responseJSONObject] withApiCmd:apiCmd];
            }
                break;
            case API_RecommendOrLookCmd:
            {
                self.mShowDetail = [[DataBaseManager sharedInstance] insertShowDetailRecommendOrLookCountIntoCoreDataFromObject:[apiCmd responseJSONObject] withApiCmd:apiCmd];
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

- (void) apiNotifyLocationResult:(id)apiCmd cacheData:(NSArray*)cacheData{
    [WSLProgressHUD dismiss];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self updateData:0];
    });
}

- (ApiCmd *)apiGetDelegateApiCmd{
    return _apiCmdShow_getShowDetail;
}

- (void)updateData:(int)tag
{
    dispatch_sync(dispatch_get_main_queue(), ^{
        ABLogger_int(tag);
        switch (tag) {
            case 0:
            case API_SShowDetailCmd:
            {
                [self initShowDetailData];
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

#pragma mark -
#pragma mark FormateData
- (void)formatKTVData:(NSArray*)dataArray{
    
    [self formatKTVDataFilterAll:dataArray];
}

#pragma mark -
#pragma mark FilterCinema FormatData
- (void)formatKTVDataFilterAll:(NSArray*)pageArray{
}


- (void)shareButtonClick:(id)sender{
     AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    
    //    AppDelegate *_appDelegate = [AppDelegate appDelegateInstance];
    //    [CacheManager sharedInstance].rootNavController.view
    UIImage *shareImg = [self.view imageWithView:appDelegate.window];
    
    //定义菜单分享列表
    NSArray *shareList = [ShareSDK getShareListWithType:ShareTypeWeixiTimeline, ShareTypeWeixiSession, ShareTypeSMS,nil];
    
    //创建分享内容
    //    NSString *imagePath = [[NSBundle mainBundle] pathForResource:IMAGE_NAME ofType:IMAGE_EXT];
    NSString *shareContent = [NSString stringWithFormat:@"晚上了，去看个演出？%@/ %@/ %@, %@"
                              ,[[DataBaseManager sharedInstance] getTimeFromDate:_mShow.beginTime]
                              ,_mShow.name
                              , _mShow.theatrename
                              ,[_mShowDetail.introduce substringToIndex:20]];
    id<ISSContent> publishContent = [ShareSDK content:shareContent
                                       defaultContent:nil
                                                image:[ShareSDK jpegImageWithImage:shareImg quality:1]
                                                title:nil
                                                  url:SHARE_URL
                                          description:nil
                                            mediaType:SSPublishContentMediaTypeImage];
    
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
    [publishContent addWeixinTimelineUnitWithType:INHERIT_VALUE
                                          content:INHERIT_VALUE
                                            title:@"Hello 微信朋友圈!"
                                              url:nil
                                            image:INHERIT_VALUE
                                     musicFileUrl:nil
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
                                               authManagerViewDelegate:appDelegate.viewDelegate];
    
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
                                                        shareViewDelegate:appDelegate.viewDelegate
                                                      friendsViewDelegate:appDelegate.viewDelegate
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


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    ABLoggerWarn(@"接收到内存警告了");
    // Dispose of any resources that can be recreated.
}

@end
