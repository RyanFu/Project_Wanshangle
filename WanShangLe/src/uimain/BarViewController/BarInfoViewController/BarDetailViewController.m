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


@interface BarDetailViewController ()<ApiNotify>{
     ShareType _followType;
    
}
@property(nonatomic,assign) AppDelegate *appDelegate;
@property(nonatomic,retain) ApiCmdBar_getBarDetail *apiCmdBar_getBarDetail;
@end

@implementation BarDetailViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
    }
    return self;
}

- (void)dealloc{
    self.mBar = nil;
    
    [_apiCmdBar_getBarDetail.httpRequest clearDelegatesAndCancel];
    _apiCmdBar_getBarDetail.delegate = nil;
    [[[ApiClient defaultClient] requestArray] removeObject:_apiCmdBar_getBarDetail];
    self.apiCmdBar_getBarDetail = nil;
    
    self.barDetailImg = nil;
    self.mBar = nil;
    
    [super dealloc];
}

- (void)viewWillAppear:(BOOL)animated{
    [[UINavigationBar appearance] setBackgroundImage:[UIImage imageNamed:@"bg_navigationBar"] forBarMetrics:UIBarMetricsDefault];
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
    _appDelegate = [AppDelegate appDelegateInstance];
    
    UIImage *img = [UIImage imageNamed:@"bg_movie_detail_info@2x"];
    _barDetailImg = [[UIImageView alloc] initWithFrame:CGRectMake(9, 176,302, 270)];
    [_barDetailImg setBackgroundColor:[UIColor clearColor]];
    UIEdgeInsets insets = UIEdgeInsetsMake(80, 20, 18, 20);
    _barDetailImg.image = [img resizableImageWithCapInsets:insets resizingMode:UIImageResizingModeStretch];
    [_barDetailImg setContentScaleFactor:2.0f];
    [_mScrollView addSubview:_barDetailImg];
    [_barDetailImg release];
    
    if ([[DataBaseManager sharedInstance] isSelectedLike:_mBar.uid withType:API_RecommendOrLookBarType]) {
        [_bar_yesButton setBackgroundImage:[UIImage imageNamed:@"bar_btn_yes_blue_n@2x"] forState:UIControlStateNormal];
    }

    if (_mBar.barDetail==nil) {//酒吧详情为空
       
    }else{
        [self initBarDetailData];
    }

}

- (void)initBarDetailData{
    
    UILabel *barInfoLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 50, 282, 220)];
    [barInfoLabel setBackgroundColor:[UIColor clearColor]];
    [barInfoLabel setNumberOfLines:0];
    barInfoLabel.font = [UIFont systemFontOfSize:15];
    barInfoLabel.text = _mBar.description;
    CGSize misize = [barInfoLabel.text sizeWithFont:[UIFont systemFontOfSize:15] constrainedToSize:CGSizeMake(barInfoLabel.bounds.size.width, MAXFLOAT)];
    
    if (misize.height>barInfoLabel.bounds.size.height) {
        barInfoLabel.frame = CGRectMake(10, 50, 282, misize.height);
        float extendHeight = misize.height - 220;
        [_mScrollView setContentSize:CGSizeMake(self.view.bounds.size.width, self.view.bounds.size.height+extendHeight)];
        [_barDetailImg setFrame:CGRectMake(9, 176,302, 270+extendHeight)];
    }
    
    [_barDetailImg addSubview:barInfoLabel];
    [barInfoLabel release];
}

- (void)updateRecOrLookData{

}

#pragma mark -
#pragma mark 点击按钮 Event

- (void)clickBackButton:(id)sender{
    [self.navigationController popViewControllerAnimated:YES];
}

-(IBAction)clickYESButton:(id)sender{
    
}

-(IBAction)clickPhoneButton:(id)sender{
    
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
                
                [[DataBaseManager sharedInstance] insertBarDetailIntoCoreDataFromObject:[apiCmd responseJSONObject] withApiCmd:apiCmd];
            }
                break;
            case API_RecommendOrLookCmd:
            {
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
            case API_BBarRecOrLookCmd:
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
@end
