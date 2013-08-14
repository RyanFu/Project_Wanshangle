//
//  Statistics.h
//  Statistics
//
//  Created by yujing on 6/14/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
//#import "FlurryAnalytics.h"
#import "Flurry.h"
#import "MobClick.h"

@interface Statistics : NSObject
-(void)statisticsTraceLog;
+ (id) defaultStatistics;
-(void)addStatistics:(NSString*)flurryAndUmeng;
@end
