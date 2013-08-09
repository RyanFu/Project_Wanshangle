//
//  SuggestionViewController.m
//  WanShangLe
//
//  Created by stephenliu on 13-7-10.
//  Copyright (c) 2013年 stephenliu. All rights reserved.
//

#import "SuggestionViewController.h"
#import "ApiCmd_app_suggestion.h"
#import "ASIHTTPRequest.h"
#import "ASIFormDataRequest.h"
#import "SIAlertView.h"
//#import "MMProgressHUD.h"

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
    [backButton setFrame:CGRectMake(0, 0, 45, 32)];
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
//    NSData *dataToSend = [_adviceTextView.text dataUsingEncoding:NSUTF8StringEncoding];
    NSMutableData *dataReceived = [NSMutableData data];
    __block ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[ApiCmd_app_suggestion getRequestURL]];
    
	[request setDataReceivedBlock:^(NSData *data){
        [dataReceived appendData:data];
    }];
    
    [request setCompletionBlock:^{
       [self parseAppUpdateData:dataReceived];
	}];
    
	[request setFailedBlock:^{
        ABLoggerWarn(@"检查 软件 更新 失败");
        
        SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"提交失败"]
                                                         andMessage:@""];
        [alertView addButtonWithTitle:@"确定"
                                 type:SIAlertViewButtonTypeDefault
                              handler:^(SIAlertView *alertView) {
                              }];
        [alertView show];
        [alertView release];
	}];
	
    [request setRequestMethod:@"POST"];
    [request setPostValue:_adviceTextView.text forKey:@"content"];
    
    [request startAsynchronous];
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


/*
 {
 httpCode: 200,
 errors: [ ],
 data: {
     record: true
 },
 token: null,
 timestamp: "1375324470"
 }
 */
- (void)parseAppUpdateData:(NSData *)reponseData{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        
        NSError *error = nil;
        NSDictionary *updateDic= [NSJSONSerialization JSONObjectWithData:reponseData options:0 error:&error];
        if (error) {
            ABLoggerWarn(@"Fail to parseJson 软件更新 with error:\n%@", [error localizedDescription]);
        }
        ABLoggerDebug(@"反馈 数据 === %@",updateDic);
        NSDictionary *dataDic = [updateDic objectForKey:@"data"];
        NSNumber *record = [dataDic objectForKey:@"record"];
        
        dispatch_sync(dispatch_get_main_queue(), ^{
            
            if ([record boolValue]) {
                SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"提交成功"]
                                                                 andMessage:@""];
                
                [alertView show];
                [alertView release];
                
                double delayInSeconds = 1.0;
                dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
                dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                    [self.navigationController popViewControllerAnimated:YES];
                    [alertView dismissAnimated:YES];
                });
            }else {
                SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"提交失败"]
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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    ABLoggerWarn(@"接收到内存警告了");
    // Dispose of any resources that can be recreated.
}
@end
