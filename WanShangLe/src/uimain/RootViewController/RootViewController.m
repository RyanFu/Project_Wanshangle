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
#import "JSButton.h"
#import "SIAlertView.h"
#import "UIImageView+WebCache.h"
#import "City.h"

@interface RootViewController (){
    WSLUserClickStyle userClickStyle;
    
}
@property(nonatomic,retain) UIView *cityPanel;
@property(nonatomic,retain) UIControl *cityPanelMask;
@end

@implementation RootViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        userClickStyle = WSLUserClickStyleNone;
    }
    return self;
}

- (void)dealloc{
    self.cityPanel = nil;
    self.cityPanelMask = nil;
    [super dealloc];
}

#pragma mark -
#pragma mark UIView Cycle
- (void)viewWillAppear:(BOOL)animated{
    [[ApiClient defaultClient] clearHttpRequestTask];
    ABLoggerMethod();
}

- (void)viewDidAppear:(BOOL)animated{
    ABLoggerMethod();
}

- (void)viewWillDisappear:(BOOL)animate{
    userClickStyle = WSLUserClickStyleNone;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _city_arrow_imgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"btn_city_arrow_f@2x"] highlightedImage:[UIImage imageNamed:@"btn_city_arrow_n@2x"]];
    NSString *title = @"选择城市";
    
    self.cityButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_cityButton setTintColor:[UIColor whiteColor]];
    _cityButton.frame = CGRectMake(0, 0, 200, 30);
    [_cityButton addTarget:self action:@selector(clickCityButton:) forControlEvents:UIControlEventTouchUpInside];
    [_cityButton addObserver:self forKeyPath:@"title" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:NULL];
    self.navigationItem.titleView = _cityButton;
    [_cityButton addSubview:_city_arrow_imgView];
    
    [LocationManager defaultLocationManager].cityLabel = _cityButton;
    
    [[SIAlertView appearance] setMessageFont:[UIFont systemFontOfSize:20]];
    [[SIAlertView appearance] setTitleFont:[UIFont systemFontOfSize:20]];
    [[SIAlertView appearance] setTitleColor: [UIColor colorWithRed:0.199 green:0.731 blue:1.000 alpha:1.000]];
    [[SIAlertView appearance] setMessageColor:[UIColor colorWithRed:0.090 green:0.481 blue:0.905 alpha:1.000]];
    [[SIAlertView appearance] setCornerRadius:5];
    [[SIAlertView appearance] setShadowRadius:20];
    
    //设置已选择的城市
    if (!(isEmpty([[LocationManager defaultLocationManager] getUserCity]))) {
        title = [[LocationManager defaultLocationManager] getUserCity];
    }
    [_cityButton setTitle:title forState:UIControlStateNormal];
    [_cityButton setValue:nil forKey:@"title"];
    
    //图片异步加载配置
    SDWebImageManager.sharedManager.imageDownloader.executionOrder = SDWebImageDownloaderLIFOExecutionOrder;
    
    //设置按钮配置
    UIButton *settingButton = [UIButton buttonWithType:UIButtonTypeCustom];
    settingButton.frame = CGRectMake(0, 0, 45, 30);
    [settingButton setBackgroundImage:[UIImage imageNamed:@"btn_setting_n@2x"] forState:UIControlStateNormal];
    [settingButton setBackgroundImage:[UIImage imageNamed:@"btn_setting_f@2x"] forState:UIControlStateHighlighted];
    [settingButton addTarget:self action:@selector(clickSettingButton:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *settingItem = [[UIBarButtonItem alloc] initWithCustomView:settingButton];
    [self.navigationItem setRightBarButtonItem:settingItem animated:YES];
    [settingItem release];
}

#pragma mark -
#pragma mark 按钮点击事件
//电影
- (IBAction)clickMovieButton:(id)sender{
    userClickStyle = WSLUserClickStyleMovie;
    
    if (![self checkUserCity])return;
    
    MovieViewController *_movieViewController = [[MovieViewController alloc] initWithNibName:(iPhone5?@"MovieViewController_5":@"MovieViewController") bundle:nil];
    [self.navigationController pushViewController:_movieViewController animated:YES];
    [_movieViewController release];
}

//KTV
- (IBAction)clickKTVButton:(id)sender{
    userClickStyle = WSLUserClickStyleKTV;
    
    if (![self checkUserCity])return;

    KtvViewController *ktvViewController = [[KtvViewController alloc] initWithNibName:(iPhone5?@"KtvViewController_5":@"KtvViewController") bundle:nil];    
    [self.navigationController pushViewController:ktvViewController animated:YES];
    [ktvViewController release];
}

//演出
- (IBAction)clickShowButton:(id)sender{
    userClickStyle = WSLUserClickStyleShow;
    
    if (![self checkUserCity])return;
    
    ShowViewController *_showViewController = [[ShowViewController alloc] initWithNibName:(iPhone5?@"ShowViewController_5":@"ShowViewController") bundle:nil];
    [self.navigationController pushViewController:_showViewController animated:YES];
    [_showViewController release];
}

//酒吧
- (IBAction)clickBarButton:(id)sender{
    userClickStyle = WSLUserClickStyleBar;
    
    if (![self checkUserCity])return;
    
    BarViewController *_barViewController = [[BarViewController alloc] initWithNibName:(iPhone5?@"BarViewController_5":@"BarViewController") bundle:nil];
    [self.navigationController pushViewController:_barViewController animated:YES];
    [_barViewController release];
}

//设置
- (void)clickSettingButton:(id)sender{
    
    if (![self checkUserCity])return;
    SettingViewController* settingController = [[SettingViewController alloc] initWithNibName:(iPhone5?@"SettingViewController_5":@"SettingViewController") bundle:nil];
    [self.navigationController pushViewController:settingController animated:YES];
    [settingController release];
}

//选择城市
- (IBAction)clickCityButton:(id)sender{
    if (!self.cityPanel) {
        [self popupCityPanel];
    }else{
        [self stopAnimationCityPanel];
    }
}

#pragma mark -
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
    
    _cityPanelMask = [[UIControl alloc] initWithFrame:self.view.bounds];
    _cityPanelMask.backgroundColor = [UIColor colorWithWhite:0.000 alpha:0.650];
    [_cityPanelMask addTarget:self action:@selector(dismissCityPanel) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_cityPanelMask];
    [_cityPanelMask release];
    
    self.cityPanel = [[[UIView alloc] initWithFrame:CGRectMake(0, -120, 320, 119)] autorelease];
    
    
    UIImageView *bgImg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bg_city_panel@2x"]];
    bgImg.frame = CGRectMake(0, 0, 320, 119);
    [self.cityPanel addSubview:bgImg];
    [bgImg release];
    
    JSButton *bt1 = [[JSButton alloc] initWithFrame:CGRectMake(5,30,70,35)];
    [bt1 setTitle:@"北京" forState:UIControlStateNormal];
    [bt1 setTag:1];
    [bt1 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [_cityPanel addSubview:bt1];
    
    [bt1 performBlock:^(JSButton *sender) {
        [[LocationManager defaultLocationManager] setUserCity:@"北京市" CallBack:^{
            [self setSelectedButton:bt1];
        }];
        ABLoggerInfo(@"手动选择城市 北京");
    } forEvents:UIControlEventTouchUpInside];
    
    JSButton *bt2 = [[JSButton alloc] initWithFrame:CGRectMake(85,30,70,35)];
    [bt2 setTitle:@"上海" forState:UIControlStateNormal];
    [bt2 setTag:2];
    [bt2 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [_cityPanel addSubview:bt2];
    [bt2 performBlock:^(JSButton *sender) {
        [[LocationManager defaultLocationManager] setUserCity:@"上海市" CallBack:^{
            [self setSelectedButton:bt2];
        }];
        ABLoggerInfo(@"手动选择城市 上海");
    } forEvents:UIControlEventTouchUpInside];
    
    JSButton *bt3 = [[JSButton alloc] initWithFrame:CGRectMake(165,30,70,35)];
    [bt3 setTitle:@"广州" forState:UIControlStateNormal];
    [bt3 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [_cityPanel addSubview:bt3];
    [bt3 setTag:3];
    [bt3 performBlock:^(JSButton *sender) {
        [[LocationManager defaultLocationManager] setUserCity:@"广州市" CallBack:^{
            [self setSelectedButton:bt3];
        }];
        ABLoggerInfo(@"手动选择城市 广州");
    } forEvents:UIControlEventTouchUpInside];
    
    
    JSButton *bt4 = [[JSButton alloc] initWithFrame:CGRectMake(245,30,70,35)];
    [bt4 setTitle:@"深圳" forState:UIControlStateNormal];
    [bt4 setTag:4];
    [bt4 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [_cityPanel addSubview:bt4];
    
    [bt4 performBlock:^(JSButton *sender) {
        [[LocationManager defaultLocationManager] setUserCity:@"深圳市" CallBack:^{
            [self setSelectedButton:bt4];
        }];
        ABLoggerInfo(@"手动选择城市 深圳");
    } forEvents:UIControlEventTouchUpInside];
    
    [self cleanCityButtonStateWithPanel:_cityPanel];
    [self selectedCityButtonInPanel:_cityPanel];
    [self startAnimationCityPanel];
    [bt4 release];
    [bt3 release];
    [bt2 release];
    [bt1 release];
}

- (void)dismissCityPanel{
    [self clickCityButton:nil];
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if([keyPath isEqualToString:@"title"])
    {
        _city_arrow_imgView.frame = CGRectMake((_cityButton.titleLabel.frame.origin.x+_cityButton.titleLabel.frame.size.width), 5, 21, 21);
    }
}

- (void)cleanCityButtonStateWithPanel:(UIView *)panel{
    for (int i=1;i<5;i++) {
        UIButton *bt = (UIButton*)[panel viewWithTag:i];
        [bt setBackgroundImage:[UIImage imageNamed:@"btn_city_n@2x"] forState:UIControlStateNormal];
        [bt setBackgroundImage:[UIImage imageNamed:@"btn_city_f@2x"] forState:UIControlStateHighlighted];
    }
}

- (void)selectedCityButtonInPanel:(UIView*)panel{
    NSArray *array = [NSArray arrayWithObjects:@"北京",@"上海",@"广州",@"深圳", nil];
    UIButton *bt = (UIButton *)[panel viewWithTag:(1+[array indexOfObject:[[LocationManager defaultLocationManager] getUserCity]])];
    [bt setBackgroundImage:[UIImage imageNamed:@"btn_city_f@2x"] forState:UIControlStateNormal];
    [self addLocationIconWithPanel:panel andButton:bt];
}

- (void)setSelectedButton:(UIButton *)sender{
    
    [self cleanCityButtonStateWithPanel:_cityPanel];
    [sender setBackgroundImage:[UIImage imageNamed:@"btn_city_f@2x"] forState:UIControlStateNormal];
    [self addLocationIconWithPanel:_cityPanel andButton:sender];
    [self stopAnimationCityPanel];
    [self checkUserClickStyle];
}

- (void)addLocationIconWithPanel:(UIView *)panel andButton:(UIButton*)bt{
    
    NSString *locationCity = [LocationManager defaultLocationManager].locationCity;
    locationCity = [[DataBaseManager sharedInstance] validateCity:locationCity];
    
    if (!isEmpty(locationCity)) {
        UIImage *img = nil;
        if ([locationCity isEqualToString:bt.currentTitle]) {
            img = [UIImage imageNamed:@"btn_location_icon@2x"];
        }else{
            img = [UIImage imageNamed:@"btn_location_icon_black@2x"];
            NSArray *array = [NSArray arrayWithObjects:@"北京",@"上海",@"广州",@"深圳", nil];
            bt = (UIButton *)[panel viewWithTag:(1+[array indexOfObject:locationCity])];
            
        }
        UIImageView *locationImg = [[UIImageView alloc] initWithImage:img];
        locationImg.frame = CGRectMake(2, 11, 12, 12);
        [bt addSubview:locationImg];
        [locationImg release];
    }
}

- (void)startAnimationCityPanel{
    [self.view addSubview:_cityPanel];
    _city_arrow_imgView.highlighted = YES;
    [UIView animateWithDuration:0.3 animations:^{
        [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
        _cityPanel.frame = CGRectMake(0, 0, 320, 119);
    } completion:^(BOOL finished) {
        
    }];
}

- (void)stopAnimationCityPanel{
    _city_arrow_imgView.highlighted = NO;
    
    [UIView animateWithDuration:0.3 animations:^{
        [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
        _cityPanel.frame = CGRectMake(0, -120, 320, 119);
    } completion:^(BOOL finished) {
        [self.cityPanelMask removeFromSuperview];
        [self.cityPanel removeFromSuperview];
        self.cityPanel = nil;
    }];
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

- (BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return (interfaceOrientation == UIDeviceOrientationPortrait);
}

- (void)didReceiveMemoryWarning
{
    ABLoggerWarn(@"接收到内存警告了");
    
    [super didReceiveMemoryWarning];
    
    /*释放可以再生成的资源*/
}

@end
