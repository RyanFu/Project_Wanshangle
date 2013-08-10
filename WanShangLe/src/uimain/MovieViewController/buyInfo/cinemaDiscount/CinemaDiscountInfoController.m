//
//  BuyInfoViewController.m
//  WanShangLe
//
//  Created by liu on 6/13/13.
//  Copyright (c) 2013 stephenliu. All rights reserved.
//

#import "CinemaDiscountInfoController.h"
#import "ApiCmdMovie_getCinemaDiscount.h"
#import "CinemaDiscountInfoDelegate.h"
#import "MCinema.h"
#import "MBuyTicketInfo.h"
#import "MCinemaDiscount.h"
#import "ASIHTTPRequest.h"
#import <ShareSDK/ShareSDK.h>
#import "AppDelegate.h"
#import "UIImage+Crop.h"

#define IntroduceLabelHeight 213

@interface CinemaDiscountInfoController ()<ApiNotify>{
    
}
@property(nonatomic,retain)MCinemaDiscount *mCinemaDiscount;
@property(nonatomic,retain)ApiCmdMovie_getCinemaDiscount *apiCmdMovie_getCinemaDiscount;
@property(nonatomic,retain)CinemaDiscountInfoDelegate *mTableDelegate;
@end

@implementation CinemaDiscountInfoController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = @"影院折扣详情";
    }
    return self;
}

- (void)dealloc{
    
    [self cancelApiCmd];
    self.mCinemaDiscount = nil;
    self.mTableDelegate = nil;
    self.mArray = nil;
    
    [super dealloc];
}

- (void)cancelApiCmd{
    [_apiCmdMovie_getCinemaDiscount.httpRequest clearDelegatesAndCancel];
    _apiCmdMovie_getCinemaDiscount.delegate = nil;
    [[[ApiClient defaultClient] requestArray] removeObject:_apiCmdMovie_getCinemaDiscount];
    self.apiCmdMovie_getCinemaDiscount = nil;
}

#pragma mark -
#pragma mark UIView lifeCycle
- (void)viewWillAppear:(BOOL)animated{
    [[UINavigationBar appearance] setBackgroundImage:[UIImage imageNamed:@"bg_navigationBar"] forBarMetrics:UIBarMetricsDefault];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.view setBackgroundColor:Color4];
    
    [self initBarItem];
    
    [self initData];
}

#pragma mark -
#pragma mark 初始化数据 initData
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
    
    _cinema_name_label.text = _mCinema.name;
    _cinema_address_label.text = _mCinema.address;
    
    [_mTableView setTableHeaderView:_mHeaderView];
    _mHeaderView.backgroundColor = [UIColor clearColor];
    
    self.mCinemaDiscount = [[DataBaseManager sharedInstance] getCinemaDiscountFromCoreData:_mCinema];
    
    if (_mCinemaDiscount.discountInfo==nil) {//影院折扣详情空
           self.apiCmdMovie_getCinemaDiscount =  (ApiCmdMovie_getCinemaDiscount *)[[DataBaseManager sharedInstance] getCinemaDiscountFromWebDelegate:self cinema:_mCinema];
        
    }else{
        self.mArray = [self.mCinemaDiscount.discountInfo objectForKey:@"specialoffers"];
        [self setTableViewDelegate];
        
        [_mTableView reloadData];
    }
}

- (void)setTableViewDelegate{

    if (_mTableDelegate==nil) {
        _mTableDelegate = [[CinemaDiscountInfoDelegate alloc] init];
    }
    
    _mTableView.delegate = _mTableDelegate;
    _mTableView.dataSource = _mTableDelegate;
    
    _mTableDelegate.parentViewController = self;
    _mTableDelegate.mArray = self.mArray;
    _mTableDelegate.mTableView = _mTableView;
}
#pragma mark -
#pragma mark 点击按钮 Event
- (void)clickBackButton:(id)sender{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark -
#pragma mark apiNotiry

- (ApiCmd *)apiGetDelegateApiCmd{
    return _apiCmdMovie_getCinemaDiscount;
}

-(void)apiNotifyResult:(id)apiCmd error:(NSError *)error{
    
    if (error) {
        return;
    }
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        self.mCinemaDiscount = [[DataBaseManager sharedInstance] insertCinemaDiscountIntoCoreData:[apiCmd responseJSONObject] cinema:_mCinema withApiCmd:apiCmd];
        
        int tag = [[apiCmd httpRequest] tag];
        [self updateData:tag responseData:nil];
        
    });
    
}

- (void) apiNotifyLocationResult:(id)apiCmd cacheOneData:(id)cacheData{
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        int tag = [[apiCmd httpRequest] tag];
        self.mCinemaDiscount = cacheData;
        [self updateData:tag responseData:nil];
    });
}

- (void)updateData:(int)tag responseData:(NSDictionary *)responseDic
{
    ABLogger_int(tag);
    switch (tag) {
        case 0:
        case API_MDiscountInfoCmd:
        {
            [self formatCinemaData:nil];
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
    
    self.mArray = [self.mCinemaDiscount.discountInfo objectForKey:@"specialoffers"];
    [self setTableViewDelegate];
    
    dispatch_sync(dispatch_get_main_queue(), ^{
        [_mTableView reloadData];
    });
}

- (void)shareButtonClick:(id)sender{
    
    AppDelegate *_appDelegate = [AppDelegate appDelegateInstance];
    
    //    AppDelegate *_appDelegate = [AppDelegate appDelegateInstance];
    //    [CacheManager sharedInstance].rootNavController.view
    UIImage *shareImg = [self.view imageWithView:_appDelegate.window];
    
    //定义菜单分享列表
    NSArray *shareList = [ShareSDK getShareListWithType:ShareTypeWeixiTimeline, ShareTypeWeixiSession, ShareTypeSMS,nil];
    
    //创建分享内容
    //    NSString *imagePath = [[NSBundle mainBundle] pathForResource:IMAGE_NAME ofType:IMAGE_EXT];
    id<ISSContent> publishContent = [ShareSDK content:Recommend_SMS_Content
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
    ABLoggerWarn(@"接收到内存警告了");
    // Dispose of any resources that can be recreated.
}

@end
