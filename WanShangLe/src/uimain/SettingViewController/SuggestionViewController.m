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

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = @"意见反馈";
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initBarItem];
    [self initTextViewState];
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
    
    UIButton *commitBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [commitBtn setFrame:CGRectMake(0, 0, 45, 32)];
    [commitBtn addTarget:self action:@selector(clickCommitButton:) forControlEvents:UIControlEventTouchUpInside];
    [commitBtn setBackgroundImage:[UIImage imageNamed:@"btn_Blue_BarButtonItem_n@2x"] forState:UIControlStateNormal];
    [commitBtn setBackgroundImage:[UIImage imageNamed:@"btn_Blue_BarButtonItem_f@2x"] forState:UIControlStateHighlighted];
    [commitBtn setTitle:@"提交" forState:UIControlStateNormal];
    [commitBtn setTintColor:[UIColor whiteColor]];
    UIBarButtonItem *commitBtnItem = [[UIBarButtonItem alloc] initWithCustomView:commitBtn];
    self.navigationItem.rightBarButtonItem = commitBtnItem;
    [commitBtnItem release];
}

- (void)initTextViewState{
    [_adviceTextView becomeFirstResponder];
}

- (void)beginEditingTextView{
    [_adviceTextView setText:@""];
    [_adviceTextView setTextColor:[UIColor blackColor]];
}

- (void)clickBackButton:(id)sender{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)clickCommitButton:(id)sender{
    
}

#pragma mark -
#pragma mark UITextViewDelegate
- (BOOL)textViewShouldBeginEditing:(UITextView *)textView;{
    return YES;
}

- (BOOL)textViewShouldEndEditing:(UITextView *)textView{
    return YES;
}

- (void)textViewDidBeginEditing:(UITextView *)textView{
    
}

- (void)textViewDidEndEditing:(UITextView *)textView{

}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    return YES;
}

- (void)textViewDidChange:(UITextView *)textView{
    _placeHoldText.hidden = (textView.text.length<=0)?NO:YES;
}

- (void)textViewDidChangeSelection:(UITextView *)textView{
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    ABLoggerWarn(@"接收到内存警告了");
    // Dispose of any resources that can be recreated.
}
@end
