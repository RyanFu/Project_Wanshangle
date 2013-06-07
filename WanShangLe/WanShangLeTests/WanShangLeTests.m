//
//  WanShangLeTests.m
//  WanShangLeTests
//
//  Created by stephenliu on 13-6-4.
//  Copyright (c) 2013年 stephenliu. All rights reserved.
//

#import "WanShangLeTests.h"
#import "ReachabilityManager.h"

@implementation WanShangLeTests

- (void)setUp
{
    [super setUp];
    
    // Set-up code here.
}

- (void)tearDown
{
    // Tear-down code here.
    
    [super tearDown];
}

- (void)testReachability
{
    if([[ReachabilityManager defaultReachabilityManager] isReachableNetwork]){
        ABLoggerDebug(@"可以访问网络");
    }
}

@end
