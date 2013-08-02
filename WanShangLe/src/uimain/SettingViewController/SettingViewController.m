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

#define DisplayTime 2

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
    [MMProgressHUD dismissWithSuccess:@""];
    [super dealloc];
}

- (void)viewWillAppear:(BOOL)animated{
    
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
    CinemaManagerViewController *cinemaController = [[CinemaManagerViewController alloc] initWithNibName:@"CinemaManagerViewController" bundle:nil];
    [self.navigationController pushViewController:cinemaController animated:YES];
    [cinemaController release];
}

-(IBAction)clickKTVManager:(id)sender{
    KtvManagerViewController *ktvController = [[KtvManagerViewController alloc] initWithNibName:@"KtvManagerViewController" bundle:nil];
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
    NSArray *array = [[NSArray alloc] initWithObjects:@"1",@"3",@"5",@"10",nil];
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
    [MMProgressHUD setDisplayStyle:MMProgressHUDDisplayStylePlain];
    [MMProgressHUD setPresentationStyle:MMProgressHUDPresentationStyleDrop];
    [MMProgressHUD showWithTitle:@"正在清理缓存" status:@"请稍等..."];
    
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
            [self updateCacheSize];
        });
    });
}

- (void)updateCacheSize{
    float cacheSize = [[DataBaseManager sharedInstance] CoreDataSize]/1024.0/1024.0;
    _cacheLabel.text = [NSString stringWithFormat:@"%0.2fM",cacheSize];
}

-(IBAction)clickRecommendFriends:(id)sender{
    
}

-(IBAction)clickRatingUs:(id)sender{
    NSUInteger m_appleID = 519513981;
    NSString *str = [NSString stringWithFormat:
                     @"itms-apps://ax.itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?type=Purple+Software&id=%d",
                     m_appleID ];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:str]];
}

#pragma mark 意见反馈
-(IBAction)clickSuggestionButton:(id)sender{
    SuggestionViewController *suggestionController = [[SuggestionViewController alloc] initWithNibName:@"SuggestionViewController" bundle:nil];
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

#pragma mark 内存警告
- (void)didReceiveMemoryWarning
{
    ABLoggerWarn(@"接收到内存警告了");
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
