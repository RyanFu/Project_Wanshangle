//
//  MovieDetailViewController.m
//  WanShangLe
//
//  Created by stephenliu on 13-6-21.
//  Copyright (c) 2013年 stephenliu. All rights reserved.
//

#import "ASIHTTPRequest.h"
#import "BBar.h"
#import "BBarDetail.h"
#import <ShareSDK/ShareSDK.h>
#import "AppDelegate.h"
#import "BarDetailViewController.h"
#import "ApiCmdBar_getBarDetail.h"
#import "ActionState.h"
#import "SIAlertView.h"
#import "UIImage+Crop.h"
#import "UIActionSheet+MKBlockAdditions.h"
#import "WSLProgressHUD.h"

#define IntroduceLabelHeight_5 213
#define IntroduceLabelHeight 130
@interface BarDetailViewController ()<ApiNotify>{
    ShareType _followType;
    BOOL isRecommended;
}
@property(nonatomic,assign) BBarDetail *mBarDetail;
@property(nonatomic,assign) AppDelegate *appDelegate;
@property(nonatomic,retain) ApiCmdBar_getBarDetail *apiCmdBar_getBarDetail;
@property(nonatomic,retain) UIActionSheet *mActionSheet;
@end

@implementation BarDetailViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = @"酒吧详情";
    }
    return self;
}

- (void)dealloc{
    self.mBar = nil;
    self.mBarDetail = nil;
    
    [_apiCmdBar_getBarDetail.httpRequest clearDelegatesAndCancel];
    _apiCmdBar_getBarDetail.delegate = nil;
    [[[ApiClient defaultClient] requestArray] removeObject:_apiCmdBar_getBarDetail];
    self.apiCmdBar_getBarDetail = nil;
    
    self.barDetailImg = nil;
    self.mBar = nil;
    self.mActionSheet = nil;
    
    [super dealloc];
}

- (void)viewWillAppear:(BOOL)animated{
    [[UINavigationBar appearance] setBackgroundImage:[UIImage imageNamed:@"bg_navigationBar"] forBarMetrics:UIBarMetricsDefault];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self dismissActionSheet];
}

- (void)dismissActionSheet{
    if (_mActionSheet.isVisible) {
        [_mActionSheet dismissWithClickedButtonIndex:1 animated:NO];
    }
}

- (void)viewDidLoad
{
//    [self.view setBackgroundColor:Color4];
    
    [super viewDidLoad];
    
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
    
    if (isEmpty(_mBar.phoneNumber)) {
        _phoneButton.enabled = NO;
    }
    
    _appDelegate = [AppDelegate appDelegateInstance];
    
    if ([[DataBaseManager sharedInstance] isSelectedLike:_mBar.uid withType:API_RecommendOrLookBarType]) {
        [_bar_yesButton setBackgroundImage:[UIImage imageNamed:@"bar_btn_yes_blue_n@2x"] forState:UIControlStateNormal];
        isRecommended = YES;
    }
    
    _bar_name.text = _mBar.barName;
    _bar_address.text = _mBar.address;
    
    self.mBarDetail = [[DataBaseManager sharedInstance] getBarDetailWithId:_mBar.uid];

    if (_mBarDetail==nil) {//酒吧详情为空
        
        [WSLProgressHUD showWithTitle:nil status:nil cancelBlock:^{
            
        }];
        self.apiCmdBar_getBarDetail = (ApiCmdBar_getBarDetail *)[[DataBaseManager sharedInstance] getBarDetailFromWeb:self barId:_mBar.uid];
        
    }else{
        [self initBarDetailData];
        [self requestRecommendAndWantLookCount];

        self.mBarDetail = _mBar.barDetail;
    }
}

- (void)initBarDetailData{
    ABLoggerDebug(@"_mBarDetail.detailInfo == %@",_mBarDetail.detailInfo);
    _bar_event.text = [_mBarDetail.detailInfo objectForKey:@"eventname"];
    NSString *introduceInfo = [_mBarDetail.detailInfo objectForKey:@"description"];
    _bar_introduce.text =  (isEmpty(introduceInfo)?@"该活动暂时没有介绍信息":introduceInfo);
    
    CGSize misize = [_bar_introduce.text sizeWithFont:_bar_introduce.font constrainedToSize:CGSizeMake(_bar_introduce.bounds.size.width, MAXFLOAT)];
    
    if (misize.height>_bar_introduce.bounds.size.height) {
        
        CGRect introFrame = _bar_introduce.frame;
        introFrame.size.height = misize.height;
        _bar_introduce.frame = introFrame;
        
        if (misize.height>(iPhone5?IntroduceLabelHeight_5:IntroduceLabelHeight) ) {
            float extendHeight = misize.height - (iPhone5?IntroduceLabelHeight_5:IntroduceLabelHeight);
            [_mScrollView setContentSize:CGSizeMake(self.view.bounds.size.width, self.view.bounds.size.height+extendHeight)];
            CGRect bgImgFrame = _barDetailImg.frame;
            bgImgFrame.size.height += extendHeight;
            _barDetailImg.frame = bgImgFrame;
        }
        
    }
    
    [self updateRecommendAndWantLookCount];
}

- (void)requestRecommendAndWantLookCount{
    [[DataBaseManager sharedInstance] getRecommendOrLookForWeb:_mBar.uid APIType:WSLRecommendAPITypeBarInteract cType:WSLRecommendLookTypeNone delegate:self];
}

- (void)updateRecommendAndWantLookCount{
    NSString *value = _mBarDetail.recommendation;
    [self.bar_yes setText:value];
}
#pragma mark -
#pragma mark 点击按钮 Event

- (void)clickBackButton:(id)sender{
    [self.navigationController popViewControllerAnimated:YES];
}

-(IBAction)clickYESButton:(id)sender{
    if (isRecommended || _mBarDetail.detailInfo==nil) {
        return;
    }
     ABLoggerDebug(@"_mBarDetail.detailInfo 2222== %@",_mBarDetail.detailInfo);
    [_bar_yesButton setBackgroundImage:[UIImage imageNamed:@"bar_btn_yes_blue_n@2x"] forState:UIControlStateNormal];
    isRecommended = YES;
    [[DataBaseManager sharedInstance] getRecommendOrLookForWeb:_mBar.uid APIType:WSLRecommendAPITypeBarInteract cType:WSLRecommendLookTypeRecommend delegate:self];
    
    NSMutableDictionary *tDic = [NSMutableDictionary dictionaryWithCapacity:5];
    [tDic setObject:_mBar.uid forKey:@"uid"];
    [tDic setObject:API_RecommendOrLookBarType forKey:@"type"];
    [tDic setObject:[_mBarDetail.detailInfo objectForKey:@"begintime"] forKey:@"beginTime"];
    [tDic setObject:[_mBarDetail.detailInfo objectForKey:@"endtime"] forKey:@"endTime"];
    [tDic setObject:[NSNumber numberWithBool:YES] forKey:@"recommend"];
    [[DataBaseManager sharedInstance] addActionState:tDic];
    
    NSString *value = [NSString stringWithFormat:@"%d",[_bar_yes.text intValue]+1];
    [self.bar_yes setText:value];
    [self startAddOneAnimation:(UIButton *)sender];

}

-(IBAction)clickPhoneButton:(id)sender{
    NSString *message = @"";
    NSString *phoneNumber = nil;
    

    phoneNumber = _mBar.phoneNumber;
    
    if (isEmpty(phoneNumber)) {
         phoneNumber = @"暂无号码";
    }
    
    self.mActionSheet = [UIActionSheet actionSheetWithTitle:@"电话号码"
                                                    message:nil
                                                    buttons:[NSArray arrayWithObjects:phoneNumber,nil]
                                                 showInView:self.view
                                                  onDismiss:^(int buttonIndex) {
                                                      switch (buttonIndex) {
                                                          case 0:
                                                          {
                                                              [[LocationManager defaultLocationManager] callPhoneNumber:phoneNumber];
                                                          }
                                                              break;
                                                          default:
                                                              break;
                                                      }
                                                      self.mActionSheet = nil;
                                                  } onCancel:^{
                                                      
                                                  }];
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
        [WSLProgressHUD dismiss];
        return;
    }
    
    int tag = [[apiCmd httpRequest] tag];
    ABLogger_int(tag);
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        switch (tag) {
            case API_BBarDetailCmd:
            {
                
                self.mBarDetail = [[DataBaseManager sharedInstance] insertBarDetailIntoCoreDataFromObject:[apiCmd responseJSONObject] withApiCmd:apiCmd];
            }
                break;
            case API_RecommendOrLookCmd:
            {
               BBarDetail *tBarDetail = [[DataBaseManager sharedInstance] insertBarRecommendIntoCoreDataFromObject:[apiCmd responseJSONObject] withApiCmd:apiCmd];
                if (tBarDetail) {
                    self.mBarDetail = tBarDetail;
                }
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
    return _apiCmdBar_getBarDetail;
}

- (void)updateData:(int)tag
{
    dispatch_sync(dispatch_get_main_queue(), ^{
        ABLogger_int(tag);
        switch (tag) {
            case 0:
            case API_BBarDetailCmd:
            {
                [self initBarDetailData];
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
        
         [WSLProgressHUD dismiss];
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

- (void)shareButtonClick:(id)sender{
    
    //    AppDelegate *_appDelegate = [AppDelegate appDelegateInstance];
    //    [CacheManager sharedInstance].rootNavController.view
    UIImage *shareImg = [self.view imageWithView:_appDelegate.window];
    
    //定义菜单分享列表
    NSArray *shareList = [ShareSDK getShareListWithType:ShareTypeWeixiTimeline, ShareTypeWeixiSession, ShareTypeSMS,nil];
    
    NSString *shareContent = [NSString stringWithFormat:@"晚上了，一起去？%@/ %@/ %@, %@"
                              ,[[DataBaseManager sharedInstance] getTimeFromDate:_mBar.begintime]
                              ,_mBar.barName
                              , _mBar.name
                              ,[_bar_introduce.text substringToIndex:20]];

    
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
@end
