//
//  WebSiteBuyViewController.m
//  WanShangLe
//
//  Created by stephenliu on 13-7-30.
//  Copyright (c) 2013年 stephenliu. All rights reserved.
//

#import "WebSiteBuyViewController.h"

@interface WebSiteBuyViewController (){
}

@property(nonatomic,retain) UIControl *markView;
@property(nonatomic,retain) UIWebView *mWebView;
@end

@implementation WebSiteBuyViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
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
    [self.view addSubview:_mWebView];
    [self updateBackForwardButtonState];
}

#pragma mark -
#pragma mark UIButton Events
- (void)clickBackButton:(id)sender{
    [self.navigationController popViewControllerAnimated:YES];
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
    UIButton *bt = (UIButton *)sender;
    if (bt.tag) {
        bt.tag = 0;
        [self dismissErrorView];
    }else{
        bt.tag = 1;
        [self popupErrorView];
    }
}

- (void)updateBackForwardButtonState{
    backButton.enabled = _mWebView.canGoBack;
    forwardButton.enabled = _mWebView.canGoForward;
}


- (void)popupErrorView{
    
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
    
}
- (IBAction)clickErrorWebButton:(id)sender{
    
}
- (IBAction)clickErrorInfoButton:(id)sender{
    
}
- (IBAction)clickErrorOtherButton:(id)sender{
    
}
#pragma mark -
#pragma mark UIWebViewDelegate
- (void)webViewDidStartLoad:(UIWebView *)webView{
    
}
- (void)webViewDidFinishLoad:(UIWebView *)webView{
    [self updateBackForwardButtonState];
}
- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error{
    
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    [errorPopupView removeFromSuperview];
}
- (void)didReceiveMemoryWarning
{
      ABLoggerWarn(@"接收到内存警告了");
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
