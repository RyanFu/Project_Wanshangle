//
//  RootViewController.m
//  WanShangLe
//
//  Created by stephenliu on 13-6-5.
//  Copyright (c) 2013年 stephenliu. All rights reserved.
//

#import "RootViewController.h"

#import "MovieViewController.h"
#import "KtvViewController.h"
#import "ShowViewController.h"
#import "BarViewController.h"
#import "SettingViewController.h"

#import "SIAlertView.h"
#import "UIImageView+WebCache.h"

@interface RootViewController (){
    WSLUserClickStyle userClickStyle;
    
}
@property(nonatomic,retain) MovieViewController* movieViewController;
@property(nonatomic,retain) KtvViewController* ktvViewController;
@property(nonatomic,retain) ShowViewController* showViewController;
@property(nonatomic,retain) BarViewController* barViewController;
@end

@implementation RootViewController
@synthesize movieViewController = _movieViewController;
@synthesize ktvViewController = _ktvViewController;
@synthesize showViewController = _showViewController;
@synthesize barViewController = _barViewController;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        userClickStyle = WSLUserClickStyleNone;
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated{
//   [self.navigationController setNavigationBarHidden:YES];
}

- (void)viewWillDisappear:(BOOL)animate{
    userClickStyle = WSLUserClickStyleNone;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.cityButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_cityButton setTitle:@"选择城市" forState:UIControlStateNormal];
    [_cityButton setTintColor:[UIColor whiteColor]];
    _cityButton.frame = CGRectMake(0, 0, 100, 30);
    [_cityButton addTarget:self action:@selector(clickCityButton:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.titleView = _cityButton;
    
    [[CacheManager sharedInstance] setRootViewController:self];
    
    [LocationManager defaultLocationManager].cityLabel = _cityButton;
    
    [[SIAlertView appearance] setMessageFont:[UIFont systemFontOfSize:20]];
    [[SIAlertView appearance] setTitleFont:[UIFont systemFontOfSize:20]];
    [[SIAlertView appearance] setTitleColor: [UIColor colorWithRed:0.199 green:0.731 blue:1.000 alpha:1.000]];
    [[SIAlertView appearance] setMessageColor:[UIColor colorWithRed:0.090 green:0.481 blue:0.905 alpha:1.000]];
    [[SIAlertView appearance] setCornerRadius:12];
    [[SIAlertView appearance] setShadowRadius:20];
    
    NSString *title = @"选择城市";
    if (!(isEmpty([[LocationManager defaultLocationManager] getUserCity]))) {
        title = [[LocationManager defaultLocationManager] getUserCity];
    }
    [_cityButton setTitle:title forState:UIControlStateNormal];
    
    SDWebImageManager.sharedManager.imageDownloader.executionOrder = SDWebImageDownloaderLIFOExecutionOrder;
    
    UIButton *settingButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [settingButton setTitle:@"设置" forState:UIControlStateNormal];
    [settingButton setTintColor:[UIColor whiteColor]];
    settingButton.frame = CGRectMake(0, 0, 60, 30);
    [settingButton addTarget:self action:@selector(clickSettingButton:) forControlEvents:UIControlEventTouchUpInside];
    [settingButton setBackgroundColor:[UIColor colorWithRed:0.143 green:0.517 blue:1.000 alpha:1.000]];
    UIBarButtonItem *settingItem = [[UIBarButtonItem alloc] initWithCustomView:settingButton];
    [self.navigationItem setRightBarButtonItem:settingItem animated:YES];
    [settingItem release];
    
}

//电影
- (IBAction)clickMovieButton:(id)sender{
    userClickStyle = WSLUserClickStyleMovie;
    
    if (![self checkUserCity])return;
    
    if (!_movieViewController) {
        _movieViewController = [[MovieViewController alloc] initWithNibName:nil bundle:nil];
    }
    
    [self.navigationController pushViewController:_movieViewController animated:YES];
}

//KTV
- (IBAction)clickKTVButton:(id)sender{
    userClickStyle = WSLUserClickStyleKTV;
    
    if (![self checkUserCity])return;
    
    if (!_ktvViewController) {
        _ktvViewController = [[KtvViewController alloc] initWithNibName:(iPhone5?@"KtvViewController":@"KtvViewController") bundle:nil];
    }
    
    [self.navigationController pushViewController:_ktvViewController animated:YES];
}

//演出
- (IBAction)clickShowButton:(id)sender{
    userClickStyle = WSLUserClickStyleShow;
    
    if (![self checkUserCity])return;
    
    if (!_showViewController) {
        _showViewController = [[ShowViewController alloc] initWithNibName:(iPhone5?@"ShowViewController_5":@"ShowViewController") bundle:nil];
    }
    
    [self.navigationController pushViewController:_showViewController animated:YES];
}

//酒吧
- (IBAction)clickBarButton:(id)sender{
    userClickStyle = WSLUserClickStyleBar;
    
    if (![self checkUserCity])return;
    
    if (!_barViewController) {
        _barViewController = [[BarViewController alloc] initWithNibName:(iPhone5?@"BarViewController_5":@"BarViewController") bundle:nil];
    }
    
    [self.navigationController pushViewController:_barViewController animated:YES];
}

//设置
- (void)clickSettingButton:(id)sender{
    
   SettingViewController* settingController = [[SettingViewController alloc] initWithNibName:@"SettingViewController" bundle:nil];
    [self.navigationController pushViewController:settingController animated:YES];
    [settingController release];
}

//选择城市
- (IBAction)clickCityButton:(id)sender{
    [self popupCityPanel];
}

/**
 check user city no nil
 @param sender
 */
- (BOOL)checkUserCity{
    NSString *city = [[LocationManager defaultLocationManager] getUserCity];
    if (!city) {
        [self popupCityPanel];
    }
    
    return (city)?YES:NO;
}

- (void)popupCityPanel{
    
    SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:@"请选择一个城市,亲!" andMessage:nil];
    [alertView addButtonWithTitle:@"北京"
                             type:SIAlertViewButtonTypeDefault
                          handler:^(SIAlertView *alertView) {
                              [[LocationManager defaultLocationManager] setUserCity:@"北京市" CallBack:^{
                                  [self checkUserClickStyle];
                              }];
                              ABLoggerInfo(@"手动选择城市 北京");
                          }];
    [alertView addButtonWithTitle:@"上海"
                             type:SIAlertViewButtonTypeDefault
                          handler:^(SIAlertView *alertView) {
                              [[LocationManager defaultLocationManager] setUserCity:@"上海市" CallBack:^{
                                  [self checkUserClickStyle];
                              }];
                              ABLoggerInfo(@"手动选择城市 上海");
                          }];
    [alertView addButtonWithTitle:@"广州"
                             type:SIAlertViewButtonTypeDefault
                          handler:^(SIAlertView *alertView) {
                              [[LocationManager defaultLocationManager] setUserCity:@"广州市" CallBack:^{
                                  [self checkUserClickStyle];
                              }];
                              ABLoggerInfo(@"手动选择城市 广州");
                          }];
    [alertView addButtonWithTitle:@"深圳"
                             type:SIAlertViewButtonTypeDefault
                          handler:^(SIAlertView *alertView) {
                              [[LocationManager defaultLocationManager] setUserCity:@"深圳市" CallBack:^{
                                  [self checkUserClickStyle];
                              }];
                              ABLoggerInfo(@"手动选择城市 深圳");
                          }];
    
    alertView.transitionStyle = SIAlertViewTransitionStyleDropDown;
    alertView.backgroundStyle = SIAlertViewBackgroundStyleSolid;
    
    [alertView show];
    [alertView release];
}

- (void)checkUserClickStyle{
    
    switch (userClickStyle) {
        case WSLUserClickStyleMovie:
            [self clickMovieButton:nil];
            break;
        case WSLUserClickStyleKTV:
            [self clickKTVButton:nil];
            break;
        case WSLUserClickStyleShow:
            [self clickShowButton:nil];
            break;
        case WSLUserClickStyleBar:
            [self clickBarButton:nil];
            break;
        default:
            break;
    }
    
    userClickStyle = WSLUserClickStyleNone;
}

- (void)didReceiveMemoryWarning
{
    ABLoggerWarn(@"接收到内存警告了");
    
    [super didReceiveMemoryWarning];
    
    /*释放可以再生成的资源*/
}

- (void)dealloc{
    self.movieViewController = nil;
    self.ktvViewController = nil;
    self.showViewController = nil;
    self.barViewController = nil;
    [super dealloc];
}

@end
