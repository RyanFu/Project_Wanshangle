//
//  WebSiteBuyViewController.m
//  WanShangLe
//
//  Created by stephenliu on 13-7-30.
//  Copyright (c) 2013年 stephenliu. All rights reserved.
//

#import "WebSiteBuyViewController.h"
#import "MMProgressHUD.h"
#import "MMProgressHUDOverlayView.h"
#import "ApiCmd_app_suggestion.h"
#import "ASIHTTPRequest.h"
#import "ASIFormDataRequest.h"
#import "AppDelegate.h"

@interface WebSiteBuyViewController ()<UIScrollViewDelegate,UITextViewDelegate>{
    BOOL isShowErrorPanel;
}

@property(nonatomic,retain) UIControl *markView;
@property(nonatomic,retain) UIWebView *mWebView;
@end

@implementation WebSiteBuyViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [MMProgressHUD setDisplayStyle:MMProgressHUDDisplayStylePlain];
        [MMProgressHUD setPresentationStyle:MMProgressHUDPresentationStyleFade];
        [[MMProgressHUD sharedHUD] setOverlayMode:MMProgressHUDWindowOverlayModeNone];
        [MMProgressHUD showWithTitle:@"" status:@"正在加载..."];
    }
    return self;
}

- (void)dealloc{
    
    self.mURLStr = nil;
    self.mWebView = nil;
    self.markView = nil;
    
    [super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self initBarItem];
    
    [self initData];
    
}

#pragma mark -
#pragma mark 初始化数据
- (void)initBarItem{
    UIButton *backBt = [UIButton buttonWithType:UIButtonTypeCustom];
    [backBt setFrame:CGRectMake(0, 0, 90, 32)];
    [backBt addTarget:self action:@selector(clickBackButton:) forControlEvents:UIControlEventTouchUpInside];
    [backBt setBackgroundImage:[UIImage imageNamed:@"btn_arrow_back@2x"] forState:UIControlStateNormal];
    [backBt setTitle:@"返回晚上了" forState:UIControlStateNormal];
    backBt.titleLabel.font = [UIFont systemFontOfSize:14];
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithCustomView:backBt];
    self.navigationItem.leftBarButtonItem = backItem;
    [backItem release];
}

- (void)initData{
    NSURL *url = [NSURL URLWithString:_mURLStr];
    _mWebView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height-49)];
    [_mWebView loadRequest:[NSURLRequest requestWithURL:url]];
    _mWebView.delegate = self;
    _mWebView.scrollView.delegate = self;
    [self.view addSubview:_mWebView];
    
    [self updateBackForwardButtonState];
}

#pragma mark -
#pragma mark UIButton Events
- (void)clickBackButton:(id)sender{
    [self.navigationController popViewControllerAnimated:YES];
    [self clickErrorOtherCancelButton:nil];
}

- (IBAction)clickcWebBackButton:(id)sender{
    [errorPopupView removeFromSuperview];
    if(_mWebView.canGoBack){
        [_mWebView goBack];
    }
    
}
- (IBAction)clickcWebForwardkButton:(id)sender{
    [errorPopupView removeFromSuperview];
    if(_mWebView.canGoForward){
        [_mWebView goForward];
    }
}

- (IBAction)clickcWebPostErrorButton:(id)sender{
    if (!isShowErrorPanel) {
        [self popupErrorView];
    }else{
        [self dismissErrorView];
    }
}

- (void)updateBackForwardButtonState{
    backButton.enabled = _mWebView.canGoBack;
    forwardButton.enabled = _mWebView.canGoForward;
}


- (void)popupErrorView{
    if (isShowErrorPanel==YES) {
        return;
    }
    isShowErrorPanel = YES;
    CGRect orginFrame = errorPopupView.frame;
    orginFrame.origin.x = self.view.bounds.size.width-errorPopupView.bounds.size.width-10;
    orginFrame.origin.y = self.view.bounds.size.height-errorPopupView.bounds.size.height-bottomBar.bounds.size.height+10;
    errorPopupView.frame = orginFrame;
    errorPopupView.alpha = 0.3;
    [self.view addSubview:errorPopupView];
    
    [UIView animateWithDuration:0.3 animations:^{
        [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
        
        CGRect newFrame = errorPopupView.frame;
        newFrame.origin.y = self.view.bounds.size.height-errorPopupView.bounds.size.height-bottomBar.bounds.size.height-10;
        errorPopupView.frame = newFrame;
        errorPopupView.alpha = 1.0;
    } completion:^(BOOL finished) {
        
    }];
}

- (void)dismissErrorView{
    if (isShowErrorPanel==NO) {
        return;
    }
    isShowErrorPanel = NO;
    [UIView animateWithDuration:0.3 animations:^{
        [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
        
        CGRect orginFrame = errorPopupView.frame;
        orginFrame.origin.y = self.view.bounds.size.height-errorPopupView.bounds.size.height-bottomBar.bounds.size.height+10;
        errorPopupView.frame = orginFrame;
        errorPopupView.alpha = 0.3;
        
    } completion:^(BOOL finished) {
        [errorPopupView removeFromSuperview];
    }];
}

- (IBAction)clickErrorPriceButton:(id)sender{
    [self commitErrorToserver:[NSString stringWithFormat:@"价格错误 %@",_mURLStr]];
}

- (IBAction)clickErrorWebButton:(id)sender{
    [self commitErrorToserver:[NSString stringWithFormat:@"网页无效 %@",_mURLStr]];
}

- (IBAction)clickErrorInfoButton:(id)sender{
    [self commitErrorToserver:[NSString stringWithFormat:@"信息错误 %@",_mURLStr]];
}

- (IBAction)clickErrorOtherButton:(id)sender{
    [_adviceTextView becomeFirstResponder];
    [UIView animateWithDuration:0.3 animations:^{
        [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
        [self.view addSubview:commitErrorView];
    } completion:^(BOOL finished) {
        [self dismissErrorView];
    }];
}

- (IBAction)clickErrorOtherCancelButton:(id)sender{
    
    [UIView animateWithDuration:0.3 animations:^{
        [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
        [commitErrorView removeFromSuperview];
    } completion:^(BOOL finished) {
        [_adviceTextView resignFirstResponder];
    }];
}

- (IBAction)clickErrorOtherCommitButton:(id)sender{
    [self commitErrorToserver:_adviceTextView.text];
    [self clickErrorOtherCancelButton:nil];
}

- (void)commitErrorToserver:(NSString *)message{
    NSMutableData *dataReceived = [NSMutableData data];
    __block ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[ApiCmd_app_suggestion getRequestURL]];
    
	[request setDataReceivedBlock:^(NSData *data){
        [dataReceived appendData:data];
    }];
    
    [request setCompletionBlock:^{
        [self parseAppUpdateData:dataReceived];
	}];
    
	[request setFailedBlock:^{
        ABLoggerWarn(@"上传 错误 反馈 失败");
        [self showFailView];
	}];
    
    [request setUploadSizeIncrementedBlock:^(long long size) {
        ABLoggerDebug(@"上传成功");
        
    }];
	
    [request setRequestMethod:@"POST"];
    [request setPostValue:message forKey:@"content"];
    
    [request startAsynchronous];
    
    
}

- (void)parseAppUpdateData:(NSData *)reponseData{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        
        NSError *error = nil;
        NSDictionary *updateDic= [NSJSONSerialization JSONObjectWithData:reponseData options:0 error:&error];
        if (error) {
            ABLoggerWarn(@"Fail to parseJson 网页 错误 反馈 with error:\n%@", [error localizedDescription]);
        }
        ABLoggerDebug(@"错误 数据 === %@",updateDic);
        NSDictionary *dataDic = [updateDic objectForKey:@"data"];
        NSNumber *record = [dataDic objectForKey:@"record"];
        
        dispatch_sync(dispatch_get_main_queue(), ^{
            
            if ([record boolValue]) {
                [self showSuccessView];
            }else {
                [self showFailView];
            }
        });
    });
}

- (void)showSuccessView{
    [MMProgressHUD setDisplayStyle:MMProgressHUDDisplayStylePlain];
    [MMProgressHUD setPresentationStyle:MMProgressHUDPresentationStyleFade];
    
    [MMProgressHUD showWithTitle:nil status:@"恭喜,提交成功" image:[UIImage imageNamed:@"tag_smile_face@2x"]];
    [self dismissErrorView];
    
    double delayInSeconds = 1.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [MMProgressHUD dismiss];
        
    });
}

- (void)showFailView{
    [MMProgressHUD setDisplayStyle:MMProgressHUDDisplayStylePlain];
    [MMProgressHUD setPresentationStyle:MMProgressHUDPresentationStyleFade];
    [MMProgressHUD showWithTitle:@"抱歉，提交失败" status:@"请重新提交" image:[UIImage imageNamed:@"tag_cry_face"]];
    [self dismissErrorView];
    
    double delayInSeconds = 1.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [MMProgressHUD dismiss];
        
    });
}
#pragma mark -
#pragma mark UIWebViewDelegate
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType{
    
    return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)webView{
    [self updateBackForwardButtonState];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView{
    [self dismissErrorView];
    [self updateBackForwardButtonState];
    [MMProgressHUD dismiss];
}
- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error{
    
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    [self dismissErrorView];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    
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
    ABLoggerWarn(@"接收到内存警告了");
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
