//
//  GuidePagesController.m
//  Gaopeng
//
//  Created by admin Admin on 11-11-22.
//  Copyright 2011年 GP. All rights reserved.
//

#import "PageScrollView.h"
#import "GuidePagesController.h"
#import <QuartzCore/QuartzCore.h>

@implementation GuidePagesController

@synthesize delegate = _delegate;
@synthesize selector = _selector;

- (id)init
{
    self = [super init];
    if (self) {
        // Custom initialization
        _delegate = nil;
        _selector = nil;
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void) closeGuidePagesView:(id) sender {

    [UIView animateWithDuration:1.0 animations:^{
        CGAffineTransform transform = CGAffineTransformMakeScale(2.0, 2.0);
        self.view.transform = transform;
        self.view.alpha = 0;
    } completion:^(BOOL finished) {
        [self.view removeFromSuperview];

    }];
    
    if (nil != _delegate && nil != _selector) {
            [_delegate performSelector:_selector withObject:self];
    }

}


// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
    
    CGRect pageFrame = iPhoneAppFrame;
    
    UIImageView* page01 = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:(iPhone5?@"page_01_5":@"page_01")]] autorelease];
    UIImageView* page02 = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:(iPhone5?@"page_02_5":@"page_02")]] autorelease];
    UIImageView* imageView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:(iPhone5?@"page_03_5":@"page_03")]] autorelease];
    
    page01.frame = pageFrame;
    page02.frame = pageFrame;
    
    // we cover a touchView over imageView , so we can accept user's touch event
    UIView* lastPage = [[[UIView alloc] initWithFrame:pageFrame] autorelease];
    UIButton* lastPageTouchView = [[[UIButton alloc] initWithFrame:lastPage.bounds] autorelease];
    [lastPageTouchView addTarget:self action:@selector(closeGuidePagesView:) forControlEvents:UIControlEventTouchUpInside];
    imageView.frame = lastPage.bounds;
    [lastPage addSubview:imageView];
    [lastPage addSubview:lastPageTouchView];
    
    NSMutableArray* pageArray = [[[NSMutableArray alloc] 
            initWithObjects: page01, page02,lastPage,nil] autorelease];
    
    PageScrollView* pageScrollView = [[[PageScrollView alloc] initWithFrame:pageFrame] autorelease];
    pageScrollView.pages = pageArray;
    
//    UIButton *skipButton = [UIButton buttonWithType:UIButtonTypeCustom];
//
//    [skipButton setBackgroundColor:[UIColor redColor]];
//    [skipButton setFrame:CGRectMake(255, 12, 55, 55)];
//    [skipButton addTarget:self action:@selector(skip:) forControlEvents:UIControlEventTouchUpInside];
//    [pageScrollView addSubview:skipButton];
    
    self.view = pageScrollView;
}

- (void)viewDidLoad{
    [super viewDidLoad];
    [self.view setBackgroundColor:Color4];
}

-(void)skip:(id)sender{
    [self closeGuidePagesView:nil];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES];
}
-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
 [self.navigationController setNavigationBarHidden:NO];
}
- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
