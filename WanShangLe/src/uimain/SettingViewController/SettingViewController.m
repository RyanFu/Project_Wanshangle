//
//  SettingViewController.m
//  WanShangLe
//
//  Created by stephenliu on 13-6-21.
//  Copyright (c) 2013年 stephenliu. All rights reserved.
//

#import "SettingViewController.h"
#import "KtvManagerViewController.h"
#import "CinemaManagerViewController.h"
#import "SuggestionViewController.h"
#import "ApiCmd_app_update.h"
#import "MMProgressHUD.h"
#import "SIAlertView.h"
#import "ASIHTTPRequest.h"
#import <ShareSDK/ShareSDK.h>
#import "AppDelegate.h"

#define DisplayTime 1

@interface SettingViewController (){
    
}
@property(assign,nonatomic)UIView *markView;
-(void)genTKLoadingView:(NSString *)title;
@end

@implementation SettingViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = @"设置";
    }
    return self;
}

- (void)dealloc{
    
    [super dealloc];
}

- (void)viewWillAppear:(BOOL)animated{
    [[UINavigationBar appearance] setBackgroundImage:[UIImage imageNamed:@"bg_navigationBar"] forBarMetrics:UIBarMetricsDefault];
}

- (void)viewWillDisappear:(BOOL)animated{
    [MMProgressHUD dismiss];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self initBarButtonItem];
    
    [self initData];
}

#pragma mark -
#pragma mark 初始化数据
- (void)initBarButtonItem{
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [backButton setFrame:CGRectMake(0, 0, 45, 30)];
    [backButton addTarget:self action:@selector(clickBackButton:) forControlEvents:UIControlEventTouchUpInside];
    [backButton setBackgroundImage:[UIImage imageNamed:@"bt_back_n@2x"] forState:UIControlStateNormal];
    [backButton setBackgroundImage:[UIImage imageNamed:@"bt_back_f@2x"] forState:UIControlStateHighlighted];
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    self.navigationItem.leftBarButtonItem = backItem;
    [backItem release];
}

- (void)initData{
    
    [MMProgressHUD setDisplayStyle:MMProgressHUDDisplayStylePlain];
    [MMProgressHUD setPresentationStyle:MMProgressHUDPresentationStyleFade];
    
    
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    
    [_mScrollView setContentSize:CGSizeMake(self.view.bounds.size.width, 505)];
    
    [self cleanDistanceFilterButtonState];
    int index = [[userDefault objectForKey:DistanceFilter] intValue];
    [(UIButton *)[_distanceFilterBtns objectAtIndex:index] setSelected:YES];
    
    [self updateCacheSize];
}
#pragma mark -
#pragma mark xib Button event

- (void)clickBackButton:(id)sender{
    
    [self.navigationController popViewControllerAnimated:YES];
}

-(IBAction)clickCinemaManager:(id)sender{
    CinemaManagerViewController *cinemaController = [[CinemaManagerViewController alloc] initWithNibName:(iPhone5?@"CinemaManagerViewController_5":@"CinemaManagerViewController") bundle:nil];
    [self.navigationController pushViewController:cinemaController animated:YES];
    [cinemaController release];
}

-(IBAction)clickKTVManager:(id)sender{
    KtvManagerViewController *ktvController = [[KtvManagerViewController alloc] initWithNibName:(iPhone5?@"KtvManagerViewController_5":@"KtvManagerViewController") bundle:nil];
    [self.navigationController pushViewController:ktvController animated:YES];
    [ktvController release];
}

-(IBAction)clickDistanceFilter:(id)sender{
    
    [self cleanDistanceFilterButtonState];
    
    int index = [(UIButton *)sender tag];
    [(UIButton *)[_distanceFilterBtns objectAtIndex:index] setSelected:YES];
    
    [self updateFilterDistanceData:index];
    
}


- (void)updateFilterDistanceData:(int)index{
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    NSArray *array = [[[NSArray alloc] initWithObjects:@"1",@"3",@"5",@"10",nil] autorelease];
    [userDefault setObject:[array objectAtIndex:index] forKey:DistanceFilterData];
    [userDefault setObject:[NSString stringWithFormat:@"%d",index] forKey:DistanceFilter];
    [userDefault synchronize];
}

-(void)cleanDistanceFilterButtonState{
    for (UIButton *bt in _distanceFilterBtns) {
        bt.selected = NO;
    }
}

-(IBAction)clickUserSettingSwitchButton:(id)sender{
    UISwitch *switchBtn = (UISwitch *)sender;
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    if (switchBtn.isOn) {
        [userDefault setObject:@"1" forKey:UserSetting];
    }else{
        [userDefault setObject:@"0" forKey:UserSetting];
    }
}

-(IBAction)clickCleanDataBaseCache:(id)sender{

    [MMProgressHUD showWithTitle:@"清理缓存" status:@"请稍等..."];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        CFTimeInterval time1 = Elapsed_Time;
        [[DataBaseManager sharedInstance] cleanUpDataBaseCache];
        
        CFTimeInterval time2 = Elapsed_Time;
        ElapsedTime(time2, time1);
        CFTimeInterval escapeTime = time2 - time1;
        if (escapeTime<DisplayTime) {
            NSTimeInterval sleeptimee = DisplayTime-escapeTime;
            [NSThread sleepForTimeInterval:sleeptimee];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            //                [self stopTKLoadingView];
            [MMProgressHUD dismissWithSuccess:@"清理完毕!"];
             _cacheLabel.text = [NSString stringWithFormat:@"0.0M"];
        });
    });
}

- (void)updateCacheSize{
    float cacheSize = [[DataBaseManager sharedInstance] CoreDataSize]/1024.0/1024.0;
    _cacheLabel.text = [NSString stringWithFormat:@"%0.2fM",cacheSize];
}

-(IBAction)clickRecommendFriends:(id)sender{
    [self shareButtonClick:sender];
}

-(IBAction)clickRatingUs:(id)sender{
    NSUInteger m_appleID = 684303588;
    NSString *str = [NSString stringWithFormat:
                     @"itms-apps://ax.itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?type=Purple+Software&id=%d",
                     m_appleID ];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:str]];
}

#pragma mark 意见反馈
-(IBAction)clickSuggestionButton:(id)sender{
    SuggestionViewController *suggestionController = [[SuggestionViewController alloc] initWithNibName:(iPhone5?@"SuggestionViewController_5":@"SuggestionViewController") bundle:nil];
    [self.navigationController pushViewController:suggestionController animated:YES];
    [suggestionController release];
}

#pragma mark 软件更新检查
/*
 {
 httpCode: 200,
 errors: [ ],
 data: {
 newestversion: "1.0.0",
 update: false,
 content: "",
 uri: ""
 },
 token: null,
 timestamp: "1375323240"
 }
 */
-(IBAction)clickVersionCheck:(id)sender{
    
    //    UIButton *bt = (UIButton *)sender;
    
//    [MMProgressHUD setDisplayStyle:MMProgressHUDDisplayStylePlain];
//    [MMProgressHUD setPresentationStyle:MMProgressHUDPresentationStyleNone];
    [MMProgressHUD showWithTitle:@"正在检查更新" status:@"请稍等..."];
    
     CFTimeInterval time1 = Elapsed_Time;
    
    NSMutableData *dataReceived = [NSMutableData data];
    __block ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[ApiCmd_app_update getRequestURL]];
    
	[request setDataReceivedBlock:^(NSData *data){
        [dataReceived appendData:data];
    }];
    
    [request setCompletionBlock:^{

        [[DataBaseManager sharedInstance] cleanUpDataBaseCache];
        
        CFTimeInterval time2 = Elapsed_Time;
        ElapsedTime(time2, time1);
        CFTimeInterval escapeTime = time2 - time1;
        if (escapeTime<DisplayTime) {
            NSTimeInterval sleeptimee = DisplayTime-escapeTime;
            [NSThread sleepForTimeInterval:sleeptimee];
        }
        [MMProgressHUD dismiss];
        [self parseAppUpdateData:dataReceived];
	}];
    
	[request setFailedBlock:^{
        
        double delayInSeconds = 1.0;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^{
            [MMProgressHUD dismissWithError:@"检查更新失败"];
        });
        
        ABLoggerWarn(@"检查 软件 更新 失败");
	}];
	
	[[[ApiClient defaultClient] networkQueue] addOperation:request];
}

- (void)parseAppUpdateData:(NSData *)reponseData{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        
        NSError *error = nil;
        NSDictionary *updateDic= [NSJSONSerialization JSONObjectWithData:reponseData options:0 error:&error];
        if (error) {
            ABLoggerWarn(@"Fail to parseJson 软件更新 with error:\n%@", [error localizedDescription]);
        }
        ABLoggerDebug(@"更新版本 数据 === %@",updateDic);
        NSDictionary *dataDic = [updateDic objectForKey:@"data"];
        NSNumber *isUpdate = [dataDic objectForKey:@"update"];
        NSString *content = [dataDic objectForKey:@"content"];
        NSString *uri = [dataDic objectForKey:@"uri"];
        NSString *newestversion = [dataDic objectForKey:@"newestversion"];
        
        dispatch_sync(dispatch_get_main_queue(), ^{
            
            if ([isUpdate boolValue]) {
                SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"有可更新的版本 %@",newestversion]
                                                                 andMessage:content];
                
                
                [alertView addButtonWithTitle:@"取消"
                                         type:SIAlertViewButtonTypeCancel
                                      handler:^(SIAlertView *alertView) {
                                          
                                      }];
                [alertView addButtonWithTitle:@"更新"
                                         type:SIAlertViewButtonTypeDefault
                                      handler:^(SIAlertView *alertView) {
                                          [[UIApplication sharedApplication] openURL:[NSURL URLWithString:uri]];
                                      }];
                [alertView show];
                [alertView release];
            }else {
                SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"你的版本已经是最新的了"]
                                                                 andMessage:@""];
                [alertView addButtonWithTitle:@"确定"
                                         type:SIAlertViewButtonTypeDefault
                                      handler:^(SIAlertView *alertView) {
                                      }];
                [alertView show];
                [alertView release];
            }
        });
    });
}

- (void)shareButtonClick:(id)sender{
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    
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

#pragma mark 内存警告
- (void)didReceiveMemoryWarning
{
    ABLoggerWarn(@"接收到内存警告了");
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
