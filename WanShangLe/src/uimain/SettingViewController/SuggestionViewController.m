//
//  SuggestionViewController.m
//  WanShangLe
//
//  Created by stephenliu on 13-7-10.
//  Copyright (c) 2013年 stephenliu. All rights reserved.
//

#import "SuggestionViewController.h"

@interface SuggestionViewController ()

@end

@implementation SuggestionViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        self.title = @"意见反馈";
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
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

- (void)clickBackButton:(id)sender{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end
