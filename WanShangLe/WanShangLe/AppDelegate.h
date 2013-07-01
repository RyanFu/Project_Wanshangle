//
//  AppDelegate.h
//  WanShangLe
//
//  Created by stephenliu on 13-6-4.
//  Copyright (c) 2013年 stephenliu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WXApi.h"
#import "AGViewDelegate.h"

@class RootViewController;

@interface AppDelegate : UIResponder <UIApplicationDelegate,WXApiDelegate>{
    
    enum WXScene _scene;
}
@property (nonatomic,readonly) AGViewDelegate *viewDelegate;
@property (retain, nonatomic) UIWindow *window;
@property (retain, nonatomic) RootViewController *rootViewController;

+ (instancetype)appDelegateInstance;
@end
