//
//  JSButton.m
//  JSButton
//
//  Created by Josh Sklar on 4/9/13.
//  Copyright (c) 2013 Josh Sklar. All rights reserved.
//

#import "JSButton.h"
#import <QuartzCore/QuartzCore.h>

@interface JSButton()
@property(nonatomic,copy)completionBlock tappedButtonBlock;
@end

@implementation JSButton

+ (id)buttonWithType:(UIButtonType)buttonType{
    return [super buttonWithType:buttonType];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        /*
        self.backgroundColor = [UIColor colorWithWhite:0.996 alpha:1.000];
        self.layer.cornerRadius = 6.;
        self.layer.borderColor = [UIColor colorWithWhite:0.400 alpha:1.000].CGColor;
        self.layer.borderWidth = .5;
        [self setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [self addTarget:self action:@selector(didTouchInsideBtn) forControlEvents:UIControlEventTouchDown|UIControlEventTouchDragEnter];
        [self addTarget:self action:@selector(didTouchOutsideBtn) forControlEvents:UIControlEventTouchUpInside|UIControlEventTouchDragExit];
         */
    }
    return self;
}

- (void)performBlock:(completionBlock)block forEvents:(UIControlEvents)controlEvents;
{
    self.tappedButtonBlock = block;
    [self addTarget:self action:@selector(didTapButton:) forControlEvents:controlEvents];
}


#pragma mark - Internal methods

- (void)didTapButton:(id)sender
{
    _tappedButtonBlock(sender);
}

- (void)didTouchInsideBtn
{
    self.backgroundColor = [UIColor colorWithRed:0.184 green:0.545 blue:0.914 alpha:1.000];
}

- (void)didTouchOutsideBtn
{
    self.backgroundColor = [UIColor colorWithWhite:0.996 alpha:1.000];
}

- (void)dealloc{
    
    self.tappedButtonBlock = nil;
    [super dealloc];
}

@end
