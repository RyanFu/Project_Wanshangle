//
//  KTVPriceListViewController.m
//  WanShangLe
//
//  Created by stephenliu on 13-7-5.
//  Copyright (c) 2013年 stephenliu. All rights reserved.
//

#import "KTVPriceListViewController.h"
#import "KTVPriceTableViewDelegate.h"
#import "ApiCmdKTV_getPriceList.h"
#import "KKTVPriceInfo.h"
#import "KKTV.h"
#import "ASIHTTPRequest.h"
#import "AppDelegate.h"
#import <ShareSDK/ShareSDK.h>
#import "ApiCmd.h"

#define IntroduceLabelHeight 90
#define IntroduceLabelWidth 302
#define IntroduceControlWidth 150
#define TableHeaderViewHeight 315
#define TailerView_Y 245

@interface KTVPriceListViewController ()<ApiNotify>{
    BOOL isExpandInfo;
    BOOL isCanExpand;
}
@property(nonatomic,retain)ApiCmdKTV_getPriceList *apiCmdKTV_getPriceList;
@property(nonatomic,retain)KTVPriceTableViewDelegate *mTableViewDelegate;
@property(nonatomic,retain)KKTVPriceInfo *mKTVPriceInfo;
@end

@implementation KTVPriceListViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = @"现场详情";
        isExpandInfo = YES;
        isCanExpand = NO;
    }
    return self;
}

- (void)dealloc{
    [self cancelApiCmd];
    self.mTableViewDelegate = nil;
    
    self.mArray = nil;
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
    
    [self initBarButtonItem];
    
    [self initData];
    
}

#pragma mark -
#pragma mark init Data
- (void)initData{
    
    _mTableViewDelegate = [[KTVPriceTableViewDelegate alloc] init];
    
    _mTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    [_mTableView setTableHeaderView:_mTableHeaderView];
    
    _ktv_introduce.numberOfLines = 0;
    [_todayButton setBackgroundColor:[UIColor colorWithRed:0.047 green:0.678 blue:1.000 alpha:1.000]];
    
    //change today tomorrow button title
    DataBaseManager *dbManager = [DataBaseManager sharedInstance];
    [_todayButton setTitle:[NSString stringWithFormat:@"今天(%@)",[dbManager getTodayWeek]] forState:UIControlStateNormal];
    [_tomorrowButton setTitle:[NSString stringWithFormat:@"明天(%@)",[dbManager getTomorrowWeek]] forState:UIControlStateNormal];
    
    _ktv_name.text = _mKTV.name;
    _ktv_address.text = _mKTV.address;
    _ktv_introduce.text = [_mKTVPriceInfo.priceInfoDic objectForKey:@"specialoffers"];
    
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
    
    if (isEmpty(_ktv_introduce.text)) {
        _ktv_introduce.text = [_mKTVPriceInfo.priceInfoDic objectForKey:@"specialoffers"];
        
//        _ktv_introduce.text = @"你好额度为法国潍坊潍坊问哦 为微粉机问哦 问我饿你好额度为法国潍坊潍坊问哦 为微粉机问哦 问我饿额外违法未缴费为问哦发为范文芳你好额度为法国潍坊潍坊问哦 为微粉机问哦 问我饿额外违法未缴费为问哦发为范文芳你好额度为法国潍坊潍坊问哦 为微粉机问哦 问我饿额外违法未缴费为问哦发为范文芳你好额度为法国潍坊潍坊问哦 为微粉机问哦 问我饿额外违法未缴费为问哦发为范文芳你好额度为法国潍坊潍坊问哦 为微粉机问哦 问我饿额外违法未缴费为问哦发为范文芳你好额度为法国潍坊潍坊问哦 ";
    }
    
    
    CGSize misize = [_ktv_introduce.text sizeWithFont:_ktv_introduce.font constrainedToSize:CGSizeMake(_ktv_introduce.bounds.size.width, MAXFLOAT)];
    
    //    [UIView beginAnimations:nil context:nil];
    //    [UIView setAnimationDuration:5];
    //    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    
    __block CGRect introFrame = _ktv_introduce.frame;
    
    [UIView animateWithDuration:0.3 animations:^{
        if (isExpandInfo) {//折叠
            isExpandInfo = !isExpandInfo;
            _arrowImg.transform = CGAffineTransformIdentity;

            introFrame.size.height = misize.height;
            
            if (misize.height>IntroduceLabelHeight) {
                introFrame.size.height = IntroduceLabelHeight;
                isCanExpand = YES;
            }else{
                isCanExpand = NO;
            }
            
            _introduceImgView.frame = CGRectMake(0, 0, IntroduceLabelWidth, IntroduceControlWidth);
            _infoControl.frame = CGRectMake(9, 76, IntroduceLabelWidth, IntroduceControlWidth);
            
            CGRect tailerFrame = _mHeaderTailerView.frame;
            tailerFrame.origin.y = TailerView_Y;
            _mHeaderTailerView.frame = tailerFrame;
            
            CGRect headerFrame = _mTableHeaderView.frame;
            headerFrame.size.height = TableHeaderViewHeight;
            _mTableHeaderView.frame = headerFrame;
            
            CGRect arrowFrame = _arrowImg.frame;
            arrowFrame.origin.y = _infoControl.height-14;
            _arrowImg.frame = arrowFrame;
            
            _ktv_introduce.frame = introFrame;
            [_mTableView setTableHeaderView:_mTableHeaderView];
            
        }else if(!isExpandInfo && isCanExpand){//展开
            isExpandInfo = !isExpandInfo;
            _arrowImg.transform = CGAffineTransformMakeRotation(DEGREES_TO_RADIANS(180));
            
            if (misize.height>_ktv_introduce.bounds.size.height) {
                
                if (misize.height>IntroduceLabelHeight) {
                    float extendHeight = misize.height - IntroduceLabelHeight;
                    
                    CGRect headerFrame = _mTableHeaderView.frame;
                    headerFrame.size.height += extendHeight;
                    _mTableHeaderView.frame = headerFrame;
                    
                    _introduceImgView.frame = CGRectMake(0, 0, IntroduceLabelWidth, IntroduceControlWidth+extendHeight);
                    _infoControl.frame = CGRectMake(9, 76, IntroduceLabelWidth, IntroduceControlWidth+extendHeight);
                    
                    CGRect tailerFrame = _mHeaderTailerView.frame;
                    tailerFrame.origin.y = TailerView_Y+extendHeight;
                    _mHeaderTailerView.frame = tailerFrame;
                    
                    CGRect arrowFrame = _arrowImg.frame;
                    arrowFrame.origin.y = _infoControl.height-14;
                    _arrowImg.frame = arrowFrame;
                }
                
                introFrame.size.height = misize.height;
                [_mTableView setTableHeaderView:_mTableHeaderView];
            }
        }
    } completion:^(BOOL finished) {

        _ktv_introduce.frame = introFrame;
        [_mTableView reloadData];
    }];
    
    //    [UIView commitAnimations];
}

#pragma mark -
#pragma mark UITableVidew Delegate
- (void)setTableViewDelegate{
    _mTableView.delegate = _mTableViewDelegate;
    _mTableView.dataSource = _mTableViewDelegate;
    _mTableViewDelegate.parentViewController = self;
    _mTableViewDelegate.mArray = self.mArray;
    _mTableViewDelegate.mTableView = self.mTableView;
}

#pragma mark -
#pragma mark UIButton Event
- (void)clickBackButton:(id)sender{
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

-(IBAction)clickIntroduceButton:(id)sender{
    if (!isCanExpand)return;//因为信息不够多,不能展开详情
    [self updateKTVPriceInfo];
    
    
    
}

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
    ABLoggerWarn(@"接收到内存警告了");
    // Dispose of any resources that can be recreated.
}

@end
