//
//  AppDelegate.m
//  WanShangLe
//
//  Created by stephenliu on 13-6-4.
//  Copyright (c) 2013年 stephenliu. All rights reserved.
//

#import "AppDelegate.h"
#import "RootViewController.h"
#import "ApiConfig.h"

@interface AppDelegate(){
    
}

@end

@implementation AppDelegate

@synthesize window = _window;
@synthesize rootViewController = _rootViewController;

- (void)dealloc
{
    [_window release];
    self.rootViewController = nil;
    
    [super dealloc];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    
    CFTimeInterval time1 = Elapsed_Time;
    
    ABLogger_rect(iPhoneAppFrame);
    ABLogger_rect(iPhoneScreenBounds);
    if (iPhone5) {
        ABLoggerInfo(@"运行在iphone5设备上 === %0.2f",[[UIScreen mainScreen] currentMode].size.height);
    }else{
        ABLoggerInfo(@"运行在非iphone5设备上");
    }
    
    // set Dev Env
    [ApiConfig setEnv:APIDEV];
    // enable API Debug
    [ApiConfig setApiMessageDebug:YES];
    
    //configure coredata
    [MagicalRecord setupCoreDataStackWithAutoMigratingSqliteStoreNamed:@"DataStore.sqlite"];
    //[MagicalRecord setupCoreDataStackWithStoreNamed:@"DataStore.sqlite"];
    
    //location user city 定位用户的城市
    [[LocationManager defaultLocationManager] startLocationUserGPS];
    
    //inset all citys into coreData
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        
        [[DataBaseManager sharedInstance] insertAllCitysIntoCoreData];
        
    });
    
    self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
    // Override point for customization after application launch.
    
    _rootViewController = [[RootViewController alloc] initWithNibName:(iPhone5?@"RootViewController_5":@"RootViewController") bundle:nil];
    
    UINavigationController *_navigationController = [[UINavigationController alloc] initWithRootViewController:_rootViewController];
    [[UINavigationBar appearance] setTintColor:[UIColor colorWithRed:0.016 green:0.613 blue:0.899 alpha:1.000]];
    
    self.window.rootViewController = _navigationController;
    [_navigationController release];
    
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    
    CFTimeInterval time2 = Elapsed_Time;
    ElapsedTime(time2, time1);
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    [[NSManagedObjectContext MR_contextForCurrentThread] MR_saveToPersistentStoreAndWait];
    [MagicalRecord cleanUp];
}

+ (instancetype)appDelegateInstance{
	return (AppDelegate *)[UIApplication sharedApplication].delegate;
}

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application
{
    ABLoggerWarn(@"AppDelegate 接受到内存警告了");
}

@end
