//
//  SettingViewController.m
//  WanShangLe
//
//  Created by stephenliu on 13-6-21.
//  Copyright (c) 2013年 stephenliu. All rights reserved.
//

#import "SettingViewController.h"
#import "KtvManagerViewController.h"
#import "SuggestionViewController.h"

@interface SettingViewController ()

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
    
    [_mScrollView setContentSize:CGSizeMake(self.view.bounds.size.width, 505)];
    
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    [self cleanDistanceFilterButtonState];
    int index = [[userDefault objectForKey:DistanceFilter] intValue];
    [(UIButton *)[_distanceFilterBtns objectAtIndex:index] setSelected:YES];
    
    float cacheSize = [[DataBaseManager sharedInstance] CoreDataSize]/1024.0/1024.0;
    _cacheLabel.text = [NSString stringWithFormat:@"%0.2fM",cacheSize];
}
#pragma mark -
#pragma mark xib Button event

- (void)clickBackButton:(id)sender{
    
    [self.navigationController popViewControllerAnimated:YES];
}

-(IBAction)clickCinemaManager:(id)sender{
    
}

-(IBAction)clickKTVManager:(id)sender{
    KtvManagerViewController *ktvController = [[KtvManagerViewController alloc] initWithNibName:@"KtvManagerViewController" bundle:nil];
    [self.navigationController pushViewController:ktvController animated:YES];
    [ktvController release];
}

-(IBAction)clickDistanceFilter:(id)sender{
    
    [self cleanDistanceFilterButtonState];
    
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    int index = [(UIButton *)sender tag];
    [(UIButton *)[_distanceFilterBtns objectAtIndex:index-1] setSelected:YES];
    [userDefault setObject:[NSString stringWithFormat:@"%d",index-1] forKey:DistanceFilter];

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

-(IBAction)clickSuggestionButton:(id)sender{
    SuggestionViewController *suggestionController = [[SuggestionViewController alloc] initWithNibName:@"SuggestionViewController" bundle:nil];
    [self.navigationController pushViewController:suggestionController animated:YES];
    [suggestionController release];
}

-(IBAction)clickVersionCheck:(id)sender{
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
