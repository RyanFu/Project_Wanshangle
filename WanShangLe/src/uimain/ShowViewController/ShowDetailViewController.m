//
//  ShowDetailViewController.m
//  WanShangLe
//
//  Created by stephenliu on 13-6-17.
//  Copyright (c) 2013年 stephenliu. All rights reserved.
//

#import "ShowDetailViewController.h"
#import "ApiCmdShow_getShowDetail.h"
#import <ShareSDK/ShareSDK.h>
#import "UIImageView+WebCache.h"
#import "AppDelegate.h"
#import "ApiCmd.h"
#import "ASIHTTPRequest.h"
#import "SShow.h"
#import "SShowDetail.h"

@interface ShowDetailViewController()<ApiNotify>{
    
}
@property(nonatomic,retain)SShowDetail *mShowDetail;
@property(nonatomic,retain)ApiCmdShow_getShowDetail *apiCmdShow_getShowDetail;
@end

@implementation ShowDetailViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
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
}

- (void)viewWillDisappear:(BOOL)animated{
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];

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
    _show_portImgView = [[UIImageView alloc] initWithFrame:CGRectMake(9, 10, 89, 119)];
    _show_portImgView.image = [UIImage imageNamed:@"show_placeholder_L@2x"];
    [_mScrollView addSubview:_show_portImgView];

    if ([[DataBaseManager sharedInstance] isSelectedLike:_mShow.uid withType:SShow_Type]) {
        [_show_yesButton setBackgroundImage:[UIImage imageNamed:@"bar_btn_yes_blue_n@2x"] forState:UIControlStateNormal];
    }
    if ([[DataBaseManager sharedInstance] isSelectedWantLook:_mShow.uid withType:SShow_Type]) {
        [_show_wantLookButton setBackgroundImage:[UIImage imageNamed:@"bar_btn_yes_blue_n@2x"] forState:UIControlStateNormal];
    }
    
     self.mShowDetail = [[DataBaseManager sharedInstance] getShowDetailFromCoreDataWithId:_mShow.uid];

    if (_mShowDetail==nil) {//演出详情为空

        self.apiCmdShow_getShowDetail = (ApiCmdShow_getShowDetail *)[[DataBaseManager sharedInstance] getShowDetailFromWeb:self showId:_mShow.uid];

    }else{
        [self initShowDetailData];
    }
    
    [_show_portImgView setImageWithURL:[NSURL URLWithString:_mShow.webImg]
             placeholderImage:[UIImage imageNamed:@"show_placeholder_L@2x"]
                      options:SDWebImageRetryFailed];

    
    _show_name.text = _mShow.name;
    
    int ratingPeople = [_mShow.ratingpeople intValue];
    NSString *scopeStr = @"人";
    if (ratingPeople >10000) {
        ratingPeople = ratingPeople/10000;
        scopeStr = @"万人";
    }
    _show_rating.text = [NSString stringWithFormat:@"%@评分: %@ (%d%@)",_mShow.ratingfrom,_mShow.rating,ratingPeople,scopeStr];
    _show_address.text = _mShow.address;
    _show_time.text = _mShow.beginTime;
    _show_yes.text = [NSString stringWithFormat:@"%d",[_mShow.recommend intValue]];
    _show_wantLook.text = [NSString stringWithFormat:@"%d",[_mShow.wantLook intValue]];
}

- (void)initShowDetailData{
    
    _show_introduce.text = self.mShowDetail.introduce;
    CGSize misize = [_show_introduce.text sizeWithFont:_show_introduce.font constrainedToSize:CGSizeMake(_show_introduce.bounds.size.width, MAXFLOAT)];
    
    if (misize.height>_show_introduce.bounds.size.height) {
        
         float extendHeight = misize.height - _show_introduce.frame.size.height;
        
        CGRect introFrame = _show_introduce.frame;
        introFrame.size.height = misize.height;
        _show_introduce.frame = introFrame;

        [_mScrollView setContentSize:CGSizeMake(self.view.bounds.size.width, self.view.bounds.size.height+extendHeight)];
        
        CGRect bgImgFrame = _show_introBgImgView.frame;
        bgImgFrame.size.height += extendHeight;
        _show_introBgImgView.frame = bgImgFrame;
    }
    
    self.show_prices.text = _mShowDetail.prices;
    CGSize pricesSize = [self.show_prices.text sizeWithFont:self.show_prices.font constrainedToSize:CGSizeMake(MAXFLOAT, _show_prices.bounds.size.height)];
    CGRect newPricesFrame = _show_prices.frame;
    newPricesFrame.size.width = pricesSize.width;
    _show_prices.frame = newPricesFrame;
    _show_priceScrollView.contentSize = pricesSize;
    
}

#pragma mark -
#pragma mark 点击按钮 Event

- (void)clickBackButton:(id)sender{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)clickBuyButton:(id)sender{
    
}
- (IBAction)clickYesButton:(id)sender{
    
}
- (IBAction)clickWantLookButton:(id)sender{
    
}


#pragma mark -
#pragma mark apiNotiry
-(void)apiNotifyResult:(id)apiCmd error:(NSError *)error{
    
    if (error!=nil) {
        return;
    }
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
       self.mShowDetail = [[DataBaseManager sharedInstance] insertShowDetailIntoCoreDataFromObject:[apiCmd responseJSONObject] withApiCmd:apiCmd];

        [self updateData:0];
        
    });
}

- (void) apiNotifyLocationResult:(id)apiCmd cacheData:(NSArray*)cacheData{
    
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
            case 12:
            {
            
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
    
    AppDelegate *_appDelegate = [AppDelegate appDelegateInstance];
    
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


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
