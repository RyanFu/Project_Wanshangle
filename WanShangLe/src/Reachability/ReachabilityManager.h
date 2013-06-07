//
//  ReachabilityManager.h
//  WanShangLe
//
//  Created by stephenliu on 13-6-4.
//  Copyright (c) 2013年 stephenliu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ReachabilityManager : NSObject

+ (instancetype)defaultReachabilityManager;

/**
 此函数用来判断是否网络连接服务器正常
 需要导入Reachability类
 @returns BOOL
 */
- (BOOL)isReachableNetwork;

@end
