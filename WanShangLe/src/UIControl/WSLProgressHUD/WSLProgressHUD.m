//
//  MMProgressHUD.m
//  MMProgressHUD
//
//  Created by Lars Anderson on 10/7/11.
//  Copyright 2011 Mutual Mobile. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "WSLProgressHUD.h"

#if __IPHONE_OS_VERSION_MIN_REQUIRED < __IPHONE_5_0
#error MMProgressHUD uses APIs only available in iOS 5.0+
#endif

@interface WSLProgressHUD ()
@property (nonatomic, retain) UIImageView *backgroundImgView;
@property (nonatomic, retain) UIButton *cancelButton;
@property (nonatomic, assign) UIWindow *mwindow;
@property (nonatomic, readwrite, retain) UIView *overlayView;

@property (nonatomic, retain) UIView *progressViewContainer;
@end

@implementation WSLProgressHUD

- (void)dealloc{
    
    self.titleLabel = nil;
    self.statusLabel = nil;
    self.imageView = nil;
    
    self.titleText = nil;
    self.statusText = nil;
    self.image = nil;
    self.animationImages = nil;
    self.cancelBlock = nil;
    
    self.overlayView = nil;

    self.backgroundImgView = nil;
    self.cancelButton = nil;
    
    [super dealloc];
}

#pragma mark - Class Methods
+ (instancetype)sharedHUD{
    static WSLProgressHUD *__sharedHUD = nil;
    
    static dispatch_once_t mmSharedHUDOnceToken;
    dispatch_once(&mmSharedHUDOnceToken, ^{        
        __sharedHUD = [[WSLProgressHUD alloc] init];
    });
    
    return __sharedHUD;
}

#pragma mark - Initializers
- (instancetype)init{
    if( (self = [super initWithFrame:iPhoneAppFrame]) ){
     _mwindow = [[UIApplication sharedApplication].delegate window];
    }
    
    return self;
}

- (void)initBackgroundImageView{
    if (_backgroundImgView==nil) {
        _backgroundImgView = [[UIImageView alloc] initWithImage:[[CacheManager sharedInstance] imageNamed:@"bg_custom_alertView@2x"]];
    }
    _backgroundImgView.center = _mwindow.center;
    [_backgroundImgView removeFromSuperview];
    [self addSubview:self.backgroundImgView];
}

- (void)initLoadingImageView{
    if (_imageView==nil) {
        _imageView = [[UIImageView alloc] init];
    }
    _imageView.frame = CGRectMake(72, 37, 60, 60);
    [_imageView removeFromSuperview];
    [_backgroundImgView addSubview:self.imageView];
}

- (void)initStatusLabel{
    if (_statusLabel==nil) {
        _statusLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 102, 164, 46)];
    }
    _statusLabel.numberOfLines = 2;
    _statusLabel.font = [UIFont systemFontOfSize:15];
    _statusLabel.textColor = [UIColor whiteColor];
    _statusLabel.backgroundColor = [UIColor clearColor];
    [_statusLabel setTextAlignment:NSTextAlignmentCenter];
    [_statusLabel removeFromSuperview];
    [_backgroundImgView addSubview:self.statusLabel];
}

- (void)initOverlay{
    if (_overlayView==nil) {
        _overlayView = [[UIView alloc] initWithFrame:iPhoneScreenBounds];
        _overlayView.backgroundColor = [UIColor clearColor];
    }
    [_overlayView removeFromSuperview];
    [self addSubview:_overlayView];
}

- (void)initCancelButton{
    if (_cancelButton==nil) {
        self.cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
    }
    self.cancelButton.backgroundColor = [UIColor clearColor];
    [self.cancelButton setFrame:CGRectMake(227, 194, 34, 30)];
    [self.cancelButton removeFromSuperview];
    [self addSubview:_cancelButton];
    [self.cancelButton addTarget:self action:@selector(clickCancelButton:) forControlEvents:UIControlEventTouchUpInside];
}
#pragma mark -
#pragma mark 显示
+ (void)showWithTitle:(NSString *)title
               status:(NSString *)status
          cancelBlock:(void(^)(void))cancelBlock{
    
    if ([NSThread isMainThread] == NO) {
        dispatch_sync(dispatch_get_main_queue(), ^{
            [[WSLProgressHUD sharedHUD] showWithTitle:title
                                               status:status
                                  confirmationMessage:nil
                                          cancelBlock:cancelBlock
                                               images:nil];
        });
    }else{
        [[WSLProgressHUD sharedHUD] showWithTitle:title
                                           status:status
                              confirmationMessage:nil
                                      cancelBlock:cancelBlock
                                           images:nil];
    }
}

- (void)showWithTitle:(NSString *)title
               status:(NSString *)status
  confirmationMessage:(NSString *)confirmation
          cancelBlock:(void(^)(void))cancelBlock
               images:(NSArray *)images{
    
    self.cancelBlock = cancelBlock;
    self.titleText = title;
    self.statusText = (isEmpty(status)?@"正在加载中...":status);
    
    if (images==nil || [images count]==0) {
        [[WSLProgressHUD sharedHUD] loadProgressImages];
    }else{
        [WSLProgressHUD sharedHUD].animationImages = images;
    }
    
    [self show];
}

- (void)show{

    [self.layer removeAllAnimations];
    
    [self initOverlay];
    [self initBackgroundImageView];
    [self initLoadingImageView];
    [self initStatusLabel];
    [self initCancelButton];
    [self _buildHUD];
    [self startLoadingAnimation];
}

- (void)_buildHUD{
    
    _statusLabel.text = _statusText;
    [_mwindow addSubview:self];
    self.alpha = 0;
    [UIView animateWithDuration:0.3 animations:^{
        [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
        self.alpha = 1.0;
    } completion:^(BOOL finished) {
        
    }];
}

- (void)loadProgressImages{
    if (self.animationImages==nil ||
        [self.animationImages count]==0) {
        NSMutableArray *imgsArray = [NSMutableArray arrayWithCapacity:12];
        for (int i=1;i<=12;i++) {
            NSString *name = [NSString stringWithFormat:@"loading_progress%d@2x",i];
            [imgsArray addObject:[[CacheManager sharedInstance] imageNamed:name]];
        }
        self.animationImages = imgsArray;
    }
}

- (void)startLoadingAnimation{
    
    if(self.animationImages.count > 0){
       
        self.imageView.animationImages = self.animationImages;
        
        self.imageView.animationDuration = 0.7;
        
        self.imageView.contentMode = UIViewContentModeScaleAspectFit;
        
        [self.imageView startAnimating];
    }
}

#pragma mark - Dismiss

- (void)clickCancelButton:(id)sender{
    
    [UIView animateWithDuration:1 animations:^{
        [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
        self.alpha = 0;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
        
        if ([self.imageView isAnimating]) {
            [self.imageView stopAnimating];
            if (self.cancelBlock) {
                _cancelBlock();
                 self.cancelBlock = nil;
            }
        }
    }];
}

+ (void)dismiss{
    
    if ([NSThread isMainThread] == NO) {
        dispatch_sync(dispatch_get_main_queue(), ^{
            [[WSLProgressHUD sharedHUD] dismiss];
        });
    }else{
        [[WSLProgressHUD sharedHUD] dismiss];
    }
    
}

- (void)dismiss{
    
    
    
    if ([self superview]==nil && ![self.imageView isAnimating]) {
        return;
    }

    [UIView animateWithDuration:1 animations:^{
        [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
        self.alpha = 0;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
        
        if ([self.imageView isAnimating]) {
            [self.imageView stopAnimating];
        }
    }];
}

+(void)cleanCache{
    
    if ([NSThread isMainThread] == NO) {
        dispatch_sync(dispatch_get_main_queue(), ^{
            [[WSLProgressHUD sharedHUD] cleanCache];
        });
    }else{
        [[WSLProgressHUD sharedHUD] cleanCache];
    }
}

-(void)cleanCache{
    if ([self.imageView isAnimating]) {
        ABLoggerWarn(@"正在运行。。。不能清除 WSLProgressHUD 缓存");
        return;
    }
    
    ABLoggerWarn(@"清除 WSLProgressHUD 缓存");
    self.titleLabel = nil;
    self.statusLabel = nil;
    self.imageView = nil;
    
    self.titleText = nil;
    self.statusText = nil;
    self.image = nil;
    self.animationImages = nil;
    self.cancelBlock = nil;
    
    self.overlayView = nil;
    self.backgroundImgView = nil;
    self.cancelButton = nil;
}
@end
