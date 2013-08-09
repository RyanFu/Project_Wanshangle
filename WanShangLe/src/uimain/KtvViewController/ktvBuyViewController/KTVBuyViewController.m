//
//  KTVBuyViewController.m
//  WanShangLe
//
//  Created by stephenliu on 13-7-5.
//  Copyright (c) 2013年 stephenliu. All rights reserved.
//

#import "KTVBuyViewController.h"
#import "KTVBuyTableViewDelegate.h"
#import "KTVPriceListViewController.h"
#import "ApiCmdKTV_getBuyList.h"
#import "ASIHTTPRequest.h"
#import <ShareSDK/ShareSDK.h>
#import "AppDelegate.h"
#import "SIAlertView.h"
#import "KKTV.h"

@interface KTVBuyViewController ()<ApiNotify>
@property(nonatomic,retain) KTVBuyTableViewDelegate *ktvBuyTableViewDelegate;
@property(nonatomic,retain) ApiCmdKTV_getBuyList *apiCmdKTV_getBuyList;
@end

@implementation KTVBuyViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)dealloc{

    [_apiCmdKTV_getBuyList.httpRequest clearDelegatesAndCancel];
    _apiCmdKTV_getBuyList.delegate = nil;
    [[[ApiClient defaultClient] requestArray] removeObject:_apiCmdKTV_getBuyList];
    self.apiCmdKTV_getBuyList = nil;
    
    self.ktvBuyTableViewDelegate = nil;
    
    self.mKTV = nil;
    self.mArray = nil;
    
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc removeObserver:self];
    
    [super dealloc];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [[UINavigationBar appearance] setBackgroundImage:[UIImage imageNamed:@"bg_navigationBar"] forBarMetrics:UIBarMetricsDefault];
}

- (void)viewDidAppear:(BOOL)animated{
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self initDisplayData];
    [self createBarButtonItem];
    [self initTableView];
    [self setTableViewDelegate];
    
    [self requestWebData];
}

#pragma mark -
#pragma mark init Data
- (void)requestWebData{
    self.apiCmdKTV_getBuyList = (ApiCmdKTV_getBuyList*)[[DataBaseManager sharedInstance] getKTVTuanGouListFromWebWithaKTV:_mKTV delegate:self];
}

- (void)initDisplayData{
    
    self.ktvNameLabel.text = _mKTV.name;
    self.ktvAddressLabel.text = _mKTV.address;
    
    if ([_mKTV.favorite boolValue]) {
        [_favoriteButton setImage:[UIImage imageNamed:@"btn_favorite_n@2x"] forState:UIControlStateNormal];
    }
    
    if ([_mKTV.favorite boolValue]) {
        _favoriteButton.selected = YES;
        [_favoriteButton setImage:[UIImage imageNamed:@"btn_favorite_n@2x"] forState:UIControlStateNormal];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateFavoriteState:) name:KKTVAddFavoriteNotification object:nil];
}

- (void)updateFavoriteState:(NSNotification *)notification {
    if ([_mKTV.favorite boolValue]) {
        _favoriteButton.selected = YES;
        [_favoriteButton setImage:[UIImage imageNamed:@"btn_favorite_n@2x"] forState:UIControlStateNormal];
    }
}

- (void)createBarButtonItem{
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

- (void)initTableView{
    _mTableView = [[UITableView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:_mTableView];
    _mTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _mTableView.backgroundColor = [UIColor clearColor];
    _mTableView.tableHeaderView = _headerView;
    UIView *view = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 44)] autorelease];
//    view.backgroundColor = [UIColor redColor];
    _mTableView.tableFooterView = view;
}

- (void)setTableViewDelegate{
    if (_ktvBuyTableViewDelegate==nil) {
        _ktvBuyTableViewDelegate = [[KTVBuyTableViewDelegate alloc] init];
    }
    _mTableView.delegate = _ktvBuyTableViewDelegate;
    _mTableView.dataSource = _ktvBuyTableViewDelegate;
    _ktvBuyTableViewDelegate.mArray = self.mArray;
    _ktvBuyTableViewDelegate.parentViewController = self;
}

#pragma mark -
#pragma mark Button Event
- (void)clickBackButton:(id)sender{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)clickPhoneButton:(id)sender{
    NSString *message = @"";
    NSString *phoneNumber = nil;
    
    if (isEmpty(_mKTV.phoneNumber)) {
        message = @"该影院暂时没有电话号码";
    }else{
        phoneNumber = _mKTV.phoneNumber;
    }
    
    SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:@"电话号码" andMessage:message];
    
    if (!isEmpty(phoneNumber)) {
        [alertView addButtonWithTitle:phoneNumber
                                 type:SIAlertViewButtonTypeDefault
                              handler:^(SIAlertView *alertView) {
                                  [[LocationManager defaultLocationManager] callPhoneNumber:phoneNumber];
                              }];
    }
    
    [alertView addButtonWithTitle:@"取消"
                             type:SIAlertViewButtonTypeCancel
                          handler:^(SIAlertView *alertView) {
                          }];
    [alertView show];
    [alertView release];
}

- (IBAction)clickFavoriteButton:(id)sender{
    if (_favoriteButton.isSelected) {
        [_favoriteButton setSelected:NO];
        [[DataBaseManager sharedInstance] deleteFavoriteKTVWithId:_mKTV.uid];
        [_favoriteButton setImage:[UIImage imageNamed:@"btn_unFavorite_n@2x"] forState:UIControlStateNormal];
    }else{
        [_favoriteButton setSelected:YES];
        [_favoriteButton setImage:[UIImage imageNamed:@"btn_favorite_n@2x"] forState:UIControlStateNormal];
        [[DataBaseManager sharedInstance] addFavoriteKTVWithId:_mKTV.uid];
    }
}

- (IBAction)clickPriceListButton:(id)sender{
    KTVPriceListViewController *priceController = [[KTVPriceListViewController alloc] initWithNibName:(iPhone5?@"KTVPriceListViewController_5":@"KTVPriceListViewController") bundle:nil];
    priceController.mKTV = _mKTV;
    [[CacheManager sharedInstance].rootNavController pushViewController:priceController animated:YES];
    [priceController release];
}

#pragma mark -
#pragma mark apiNotiry
-(void)apiNotifyResult:(id)apiCmd error:(NSError *)error{
    
    if (error) {
        return;
    }
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        [[DataBaseManager sharedInstance] insertKTVTuanGouListIntoCoreDataFromObject:[apiCmd responseJSONObject] withApiCmd:apiCmd withaKTV:_mKTV];
        
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

- (ApiCmd *)apiGetDelegateApiCmd{
    return _apiCmdKTV_getBuyList;
}

- (void)updateData:(int)tag responseData:(NSDictionary *)responseDic
{
    ABLogger_int(tag);
    switch (tag) {
        case 0:
        case API_KKTVBuyListCmd:
        {
            [self formatKTVData:responseDic];
        }
            break;
        default:
        {
            NSAssert(0, @"没有从网络抓取到数据");
        }
            break;
    }
}

- (void)formatKTVData:(NSDictionary *)responseDic{
    ABLoggerMethod();
    
    self.mArray = [responseDic objectForKey:@"deals"];
    ABLoggerDebug(@"KTV 团购 列表 count ==== %d",[_mArray count]);
    
    self.mArray  = [self.mArray sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
        int first =  [[(NSDictionary*)a objectForKey:@"price"] intValue];
        int second = [[(NSDictionary*)b objectForKey:@"price"] intValue];
        
        if (first>second) {
            return NSOrderedDescending;
        }else if(first<second){
            return NSOrderedAscending;
        }else{
            return NSOrderedSame;
        }
    }];
    
    [self setTableViewDelegate];
    
    dispatch_sync(dispatch_get_main_queue(), ^{
        
        [_mTableView reloadData];
    });
}

#pragma mark -
#pragma mark 分享
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
    ABLoggerWarn(@"接收到内存警告了");
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
