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
#import "CinemaDiscountInfoController.h"
#import "MMovie.h"
#import "MCinema.h"
#import "ASIHTTPRequest.h"
#import <ShareSDK/ShareSDK.h>
#import "AppDelegate.h"
#import "UIImage+Crop.h"

@interface BuyInfoViewController ()<ApiNotify>
@property(nonatomic,retain)BuyInfoTableViewDelegate *buyInfoTableViewDelegate;
@property(nonatomic,retain)ApiCmdMovie_getBuyInfo *apiCmdMovie_getBuyInfo;
@end

@implementation BuyInfoViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)dealloc{
    [self cancelApiCmd];
    
    self.marray = nil;
    self.mTableView = nil;
    self.mMovie = nil;
    self.mCinema = nil;
    self.mSchedule = nil;
    self.mPrice = nil;
    self.buyInfoTableViewDelegate = nil;
    
    [super dealloc];
}

- (void)cancelApiCmd{
    [_apiCmdMovie_getBuyInfo.httpRequest clearDelegatesAndCancel];
    _apiCmdMovie_getBuyInfo.delegate = nil;
    [[[ApiClient defaultClient] requestArray] removeObject:_apiCmdMovie_getBuyInfo];
    self.apiCmdMovie_getBuyInfo = nil;
}

#pragma mark -
#pragma mark UIView lifeCycle
- (void)viewWillAppear:(BOOL)animated{
    [[UINavigationBar appearance] setBackgroundImage:[UIImage imageNamed:@"bg_navigationBar"] forBarMetrics:UIBarMetricsDefault];
}

- (void)viewDidDisappear:(BOOL)animated{
   
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.view setBackgroundColor:Color4];
    
    [self initBarItem];
    
    [self initData];
    
    [self initTableView];
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
    
    self.title = _mMovie.name;
    _cinema_name_label.text = _mCinema.name;
    _cinema_address_label.text = _mCinema.address;
    _schedule_label.text = _mSchedule;
   _discountButton.enabled = NO;
    
    self.apiCmdMovie_getBuyInfo =  (ApiCmdMovie_getBuyInfo *)[[DataBaseManager sharedInstance]
                                                              getBuyInfoFromWebWithaMovie:_mMovie
                                                              aCinema:_mCinema
                                                              aSchedule:_mSchedule
                                                              delegate:self];
}

- (void)initTableView{
    [_mTableView setTableHeaderView:_mHeaderView];
    [_mTableView setTableFooterView:[[[UIView alloc] initWithFrame:CGRectZero] autorelease]];
    [_mTableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [_mTableView setBackgroundColor:[UIColor colorWithRed:0.784 green:0.800 blue:0.835 alpha:1.000]];
}

- (void)setTableViewDelegate{
    
    if (_buyInfoTableViewDelegate==nil) {
         _buyInfoTableViewDelegate = [[BuyInfoTableViewDelegate alloc] init];
    }
    
    _mTableView.delegate = _buyInfoTableViewDelegate;
    _mTableView.dataSource = _buyInfoTableViewDelegate;
    
    _buyInfoTableViewDelegate.parentViewController = self;
    _buyInfoTableViewDelegate.mArray = _marray;
    _buyInfoTableViewDelegate.mTableView = _mTableView;
}

#pragma mark -
#pragma mark 点击按钮 Event
- (void)clickBackButton:(id)sender{
    
    if (![[DataBaseManager sharedInstance] isFavoriteCinemaWithId:_mCinema.uid]) {
        [[CacheManager sharedInstance] showAddFavoritePopupView:@"要添加这个影院到常去吗？" objectId:self.mCinema.uid dataType:MCinemaFavorite];
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)clickDiscountButton:(id)sender{
    CinemaDiscountInfoController *discountController = [[CinemaDiscountInfoController alloc]
                                                        initWithNibName:(iPhone5?@"CinemaDiscountInfoController_5":@"CinemaDiscountInfoController") bundle:nil];
    discountController.mCinema = _mCinema;
    [self.navigationController pushViewController:discountController animated:YES];
    [discountController release];
}
#pragma mark -
#pragma mark apiNotiry

- (ApiCmd *)apiGetDelegateApiCmd{
    return _apiCmdMovie_getBuyInfo;
}

-(void)apiNotifyResult:(id)apiCmd error:(NSError *)error{
    
    if (error) {
        return;
    }
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
       [[DataBaseManager sharedInstance] insertBuyInfoIntoCoreDataFromObject:[apiCmd responseJSONObject]
                                                                    withApiCmd:apiCmd
                                                                    withaMovie:_mMovie
                                                                    andaCinema:_mCinema
                                                                    aSchedule:_mSchedule];
        
        int tag = [[apiCmd httpRequest] tag];
        [self updateData:tag responseData:[[apiCmd responseJSONObject] objectForKey:@"data"]];
        
    });
    
}

- (void) apiNotifyLocationResult:(id)apiCmd cacheOneData:(id)cacheData{
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        int tag = [[apiCmd httpRequest] tag];
        [self updateData:tag responseData:cacheData];
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
    
    self.marray = [responseDic objectForKey:@"prices"];
    ABLoggerDebug(@"marray count ==== %d",[_marray count]);
    
//    //价钱排序，从低到高
//    self.marray  = [self.marray sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
//        int first =  [[(NSDictionary*)a objectForKey:@"price"] intValue];
//        int second = [[(NSDictionary*)b objectForKey:@"price"] intValue];
//        
//        if (first>second) {
//            return NSOrderedDescending;
//        }else if(first<second){
//            return NSOrderedAscending;
//        }else{
//            return NSOrderedSame;
//        }
//    }];
    
    [self setTableViewDelegate];
    
    dispatch_sync(dispatch_get_main_queue(), ^{
        
        _price_label.text = [NSString stringWithFormat:@"现场价 %0.0f元",[[responseDic objectForKey:@"origprice"] floatValue]];
        
        int discountCount = [[responseDic objectForKey:@"specialpfferscount"] intValue];
        if (discountCount>0) {
            _discountNum.text = [NSString stringWithFormat:@"%d项",discountCount];
            _discountButton.enabled = YES;
            [self addDiscountViewButton];
        }else{
//            _discountNum.text = @"暂无";
            _discountButton.enabled = NO;
        }
    
        
        [_mTableView reloadData];
    });
}
#pragma mark -
#pragma mark 刷新Header View
- (void)addDiscountViewButton{
    [_discountView removeFromSuperview];
    
    CGRect discountFrame = _discountView.frame;
    discountFrame.origin = CGPointMake(10, 78);
    _discountView.frame = discountFrame;

    CGRect newFrame = _mHeaderView.frame;
    newFrame.size.height = 133;
    _mHeaderView.frame = newFrame;
    
    [_mHeaderView addSubview:_discountView];
    
    _mTableView.tableHeaderView = _mHeaderView;
}

#pragma mark -
#pragma mark 分享
- (void)shareButtonClick:(id)sender{
    
    AppDelegate *_appDelegate = [AppDelegate appDelegateInstance];
    
    //    AppDelegate *_appDelegate = [AppDelegate appDelegateInstance];
    //    [CacheManager sharedInstance].rootNavController.view
    UIImage *shareImg = [self.view imageWithView:_appDelegate.window];
    
    //定义菜单分享列表
    NSArray *shareList = [ShareSDK getShareListWithType:ShareTypeWeixiTimeline, ShareTypeWeixiSession, ShareTypeSMS,nil];
    
    NSString *shareContent = [NSString stringWithFormat:@"《晚上了》的电影票比价的功能超级赞啊，%@的%@在%@,最低票价是%@:%@！一起去看吗？"
                              ,[[DataBaseManager sharedInstance] getTimeFromDate:_mSchedule]
                              ,_mMovie.name
                              , _mCinema.name
                              ,[[_marray objectAtIndex:0] objectForKey:@"supplierName"]
                              ,[NSString stringWithFormat:@"%@元",[[_marray objectAtIndex:0] objectForKey:@"price"]]];
    
    //创建分享内容
    //    NSString *imagePath = [[NSBundle mainBundle] pathForResource:IMAGE_NAME ofType:IMAGE_EXT];
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
