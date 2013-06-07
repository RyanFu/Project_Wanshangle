//
//  main.m
//  WanShangLe
//
//  Created by stephenliu on 13-6-4.
//  Copyright (c) 2013年 stephenliu. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "AppDelegate.h"

int main(int argc, char *argv[])
{
    @autoreleasepool {
        
        CFTimeInterval time1 = Elapsed_Time;
        /**********************************************/
        //   we need to do data update here
        /**********************************************/
        // data updator for version 1.0
        NSArray* updaterArray = [[[NSArray alloc] initWithObjects:
                                  [[[SystemDataUpdater1_0 alloc] init] autorelease],
                                  // add other updaters here for such as version 1.1, 1.2, 1.3 2.0...
                                  nil]
                                 autorelease];
        
        SystemDataUpdater* systemDataUpdater = [[[SystemDataUpdater alloc] initWithUpdaterArray:updaterArray] autorelease];
        
        [systemDataUpdater doUpdate];
        
        /***************** we do system init here ************************/
        [SysConfig doSystemInit];
        /***************** we do systemInfo init here ************************/
        [SysInfo  doInit];

        CFTimeInterval time2 = Elapsed_Time;
        ElapsedTime(time2, time1);
        
        int a = UIApplicationMain(argc, argv, nil, NSStringFromClass([AppDelegate class]));
        
        return a;
    }
}
