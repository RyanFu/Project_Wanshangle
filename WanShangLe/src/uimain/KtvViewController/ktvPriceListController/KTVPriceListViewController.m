//
//  KTVPriceListViewController.m
//  WanShangLe
//
//  Created by stephenliu on 13-7-5.
//  Copyright (c) 2013年 stephenliu. All rights reserved.
//

#import "KTVPriceListViewController.h"
#import "KTVPriceTableViewDelegate.h"
#import "KTVDiscountInfoDelegate.h"
#import "ApiCmdKTV_getPriceList.h"
#import "KKTVPriceInfo.h"
#import "KKTV.h"
#import "ASIHTTPRequest.h"
#import "AppDelegate.h"
#import <ShareSDK/ShareSDK.h>
#import "ApiCmd.h"
#import "UIImage+Crop.h"

#define IntroduceLabelHeight 90
#define IntroduceLabelWidth 302
#define IntroduceControlWidth 150
#define TableHeaderViewHeight 315
#define TailerView_Y 245

#define DiscountTableView_Height 93

@interface KTVPriceListViewController ()<ApiNotify>{
    BOOL isCanExpand;
}
@property(nonatomic,retain)ApiCmdKTV_getPriceList *apiCmdKTV_getPriceList;
@property(nonatomic,retain)KTVPriceTableViewDelegate *mTableViewDelegate;
@property(nonatomic,retain)KTVDiscountInfoDelegate *discountDelegate;
@property(nonatomic,retain)KKTVPriceInfo *mKTVPriceInfo;
@end

@implementation KTVPriceListViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = @"现场详情";
//        isExpandInfo = YES;
        isCanExpand = YES;
    }
    return self;
}

- (void)dealloc{
    [self cancelApiCmd];
    self.mTableViewDelegate = nil;
    self.discountDelegate = nil;
    
    self.mArray = nil;
    self.mDiscountArray = nil;
    self.mTodayArray = nil;
    self.mTomorrowArray = nil;
    self.mKTV = nil;
    self.mKTVPriceInfo = nil;
    
    [super dealloc];
}

-(void)cancelApiCmd{
    [self.apiCmdKTV_getPriceList.httpRequest clearDelegatesAndCancel];
    [[[ApiClient defaultClient] requestArray] removeObject:_apiCmdKTV_getPriceList];
    self.apiCmdKTV_getPriceList.delegate = nil;
}

#pragma mark -
#pragma mark UIView Cycle

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [[UINavigationBar appearance] setBackgroundImage:[UIImage imageNamed:@"bg_navigationBar"] forBarMetrics:UIBarMetricsDefault];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.view setBackgroundColor:Color4];
    
    [self initBarButtonItem];
    
    [self initData];
    
}

#pragma mark -
#pragma mark init Data
- (void)initData{
    
    _mTableView.tableFooterView = [[[UIView alloc] initWithFrame:CGRectZero] autorelease];
    [_mTableView setTableHeaderView:_mTableHeaderView];
    
//    _mDiscountTableView.tableFooterView = _mDiscountFooterView;
    _mDiscountTableView.scrollEnabled = NO;
    _mDiscountTableView.showsVerticalScrollIndicator = NO;
    
    [_todayButton setBackgroundColor:[UIColor colorWithRed:0.047 green:0.678 blue:1.000 alpha:1.000]];
    
    //change today tomorrow button title
    DataBaseManager *dbManager = [DataBaseManager sharedInstance];
    [_todayButton setTitle:[NSString stringWithFormat:@"今天(%@)",[dbManager getTodayWeek]] forState:UIControlStateNormal];
    [_tomorrowButton setTitle:[NSString stringWithFormat:@"明天(%@)",[dbManager getTomorrowWeek]] forState:UIControlStateNormal];
    
    _ktv_name.text = _mKTV.name;
    _ktv_address.text = _mKTV.address;
    
    self.mDiscountArray = [_mKTVPriceInfo.priceInfoDic objectForKey:@"specialoffers"];
    if (!isNull(self.mDiscountArray) && [self.mDiscountArray count]>0) {
        [self addDiscountPanelView];
    }
    
    self.mKTVPriceInfo = [[DataBaseManager sharedInstance] getKTVPriceInfoFromCoreDataWithId:_mKTV.uid];
    if (self.mKTVPriceInfo==nil) {
        self.apiCmdKTV_getPriceList = (ApiCmdKTV_getPriceList *)[[DataBaseManager sharedInstance] getKTVPriceListFromWebWithaKTV:_mKTV delegate:self];
    }else{
        [self formatKTVPriceInfo];
    }
}

- (void)initBarButtonItem{
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

- (void)updateKTVPriceInfo{
    
    self.mDiscountArray = [_mKTVPriceInfo.priceInfoDic objectForKey:@"specialoffers"];
    if (!isNull(self.mDiscountArray) && [self.mDiscountArray count]>0) {
        [self addDiscountPanelView];
    }

}

- (void)addDiscountPanelView{
    _discountHeaderView.frame = CGRectMake(10, 0, 300, 45);
    _mDiscountTableView.frame = CGRectMake(0, 123, 320, 93);
    _discountFooterView.frame = CGRectMake(10, 0, 320, 20);
    [_mTableHeaderView addSubview:_discountHeaderView];
    [_mTableHeaderView addSubview:_mDiscountTableView];
    [_mTableHeaderView addSubview:_discountFooterView];

    _mHeaderTailerView.frame = CGRectMake(0, 246, 320, 70);
    
    CGRect headerFrame = _mTableHeaderView.frame;
    headerFrame.size.height = TableHeaderViewHeight;
    _mTableHeaderView.frame = headerFrame;
    [_mTableView setTableHeaderView:_mTableHeaderView];
    
    [self setDiscountTableViewDelegate];
    [_mDiscountTableView reloadData];
}

- (void)expandDiscountTableView{
    
    [_mDiscountTableView setAllowsSelection:NO];
    
    [UIView animateWithDuration:0.3 animations:^{
        if (isCanExpand) {//展开
            isCanExpand = NO;
            _arrowImg.transform = CGAffineTransformMakeRotation(DEGREES_TO_RADIANS(180));
            
            int dHeight = _mDiscountTableView.contentSize.height - DiscountTableView_Height;
            
            CGRect footerFrame = _discountFooterView.frame;
            footerFrame.origin.y += dHeight;
            _discountFooterView.frame = footerFrame;
            
            CGRect tableFrame = _mDiscountTableView.frame;
            tableFrame.size.height = _mDiscountTableView.contentSize.height+15;
            _mDiscountTableView.frame = tableFrame;
            
            CGRect tailerFrame = _mHeaderTailerView.frame;
            tailerFrame.origin.y += dHeight;
            _mHeaderTailerView.frame = tailerFrame;

            
            CGRect headerFrame = _mTableHeaderView.frame;
            headerFrame.size.height += dHeight;
            _mTableHeaderView.frame = headerFrame;
            [_mTableView setTableHeaderView:_mTableHeaderView];
            
        }else{//折叠
            isCanExpand = YES;
            _arrowImg.transform = CGAffineTransformIdentity;
            
            
            CGRect footerFrame = _discountFooterView.frame;
            footerFrame.origin.y = 215;
            _discountFooterView.frame = footerFrame;
            
            CGRect tableFrame = _mDiscountTableView.frame;
            tableFrame.size.height = 105;
            _mDiscountTableView.frame = tableFrame;
            
            CGRect tailerFrame = _mHeaderTailerView.frame;
            tailerFrame.origin.y = 245;
            _mHeaderTailerView.frame = tailerFrame;
            
            CGRect headerFrame = _mTableHeaderView.frame;
            headerFrame.size.height = TableHeaderViewHeight;
            _mTableHeaderView.frame = headerFrame;
            [_mTableView setTableHeaderView:_mTableHeaderView];
        }
    } completion:^(BOOL finished) {

        [_mTableView reloadData];
        [_mDiscountTableView setAllowsSelection:YES];
    }];

}

#pragma mark -
#pragma mark UITableVidew Delegate
- (void)setTableViewDelegate{
    
    if (_mTableViewDelegate==nil) {
        _mTableViewDelegate = [[KTVPriceTableViewDelegate alloc] init];
    }
    
    _mTableView.delegate = _mTableViewDelegate;
    _mTableView.dataSource = _mTableViewDelegate;
    _mTableViewDelegate.parentViewController = self;
    _mTableViewDelegate.mArray = self.mArray;
    _mTableViewDelegate.mTableView = self.mTableView;
}

- (void)setDiscountTableViewDelegate{
    
    if (_discountDelegate==nil) {
        _discountDelegate = [[KTVDiscountInfoDelegate alloc] init];
    }
    
    _mDiscountTableView.delegate = _discountDelegate;
    _mDiscountTableView.dataSource = _discountDelegate;
    _discountDelegate.parentViewController = self;
    _discountDelegate.mArray = self.mDiscountArray;
    _discountDelegate.mTableView = self.mDiscountTableView;
}

#pragma mark -
#pragma mark UIButton Event
- (void)clickBackButton:(id)sender{
    
    [[CacheManager sharedInstance] showAddFavoritePopupView:@"要就改KTV添加到常去吗？" objectId:self.mKTV.uid dataType:KKTVFavorite];
    
    [self.navigationController popViewControllerAnimated:YES];
}

-(IBAction)clickTodayButton:(id)sender{
    
    [self cleanUpButtonBackground];
    _tomorrowButton.selected = NO;
    _todayButton.selected = YES;
    [_todayButton setBackgroundColor:[UIColor colorWithRed:0.047 green:0.678 blue:1.000 alpha:1.000]];
    
    self.mArray = _mTodayArray;
    [self setTableViewDelegate];
    
    [_mTableView reloadData];
}
-(IBAction)clickTomorrowButton:(id)sender{
    
    [self cleanUpButtonBackground];
    _tomorrowButton.selected = YES;
    _todayButton.selected = NO;
    [_tomorrowButton setBackgroundColor:[UIColor colorWithRed:0.047 green:0.678 blue:1.000 alpha:1.000]];
    
    self.mArray = _mTomorrowArray;
    [self setTableViewDelegate];
    
    [_mTableView reloadData];
}

- (void)cleanUpButtonBackground{
    [_tomorrowButton setBackgroundColor:[UIColor clearColor]];
    [_todayButton setBackgroundColor:[UIColor clearColor]];
}

//-(IBAction)clickIntroduceButton:(id)sender{
//    if (!isCanExpand)return;//因为信息不够多,不能展开详情
//    [self updateKTVPriceInfo];
//}

#pragma mark -
#pragma mark apiNotiry
-(void)apiNotifyResult:(id)apiCmd error:(NSError *)error{
    
    if (error){
        return;
    }
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        self.mKTVPriceInfo = [[DataBaseManager sharedInstance] insertKTVPriceListIntoCoreDataFromObject:[apiCmd responseJSONObject] withApiCmd:apiCmd withaKTV:_mKTV];
        int tag = [[apiCmd httpRequest] tag];
        [self updateData:tag];
        
    });
    
}

- (ApiCmd *)apiGetDelegateApiCmd{
    return _apiCmdKTV_getPriceList;
}

- (void)apiNotifyLocationResult:(id)apiCmd cacheDictionaryData:(NSDictionary *)cacheData{
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    });
}

- (void)updateData:(int)tag
{
    ABLogger_int(tag);
    switch (tag) {
        case 0:
        case API_KKTVPriceListCmd:
        {
            [self formatKTVPriceInfo];
        }
            break;
        default:
        {
            NSAssert(0, @"没有从网络抓取到数据");
        }
            break;
    }
}

- (void)formatKTVPriceInfo{
    
    NSArray *pricesArray = [_mKTVPriceInfo.priceInfoDic objectForKey:@"list"];
    
    self.mTodayArray = [pricesArray objectAtIndex:0];
    self.mTomorrowArray = [pricesArray objectAtIndex:1];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self updateKTVPriceInfo];
        [self clickTodayButton:nil];
    });
    
}

#pragma mark -
#pragma mark 分享 Event
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
