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
#import <ShareSDK/ShareSDK.h>
#import "BBar.h"

@interface AppDelegate(){
    
}

@end

@implementation AppDelegate

@synthesize window = _window;

- (id)init
{
    if(self = [super init])
    {
        _scene = WXSceneSession;
        _viewDelegate = [[AGViewDelegate alloc] init];
    }
    return self;
}

- (void)dealloc
{
    [_window release];
    [_viewDelegate release];
    
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
    
    /**
     注册SDK应用，此应用请到http://www.sharesdk.cn中进行注册申请。
     此方法必须在启动时调用，否则会限制SDK的使用。
     **/
    [ShareSDK registerApp:@"api20"];
    [ShareSDK convertUrlEnabled:NO];
    [self initializePlat];
    
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
    /*
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        
        [[DataBaseManager sharedInstance] insertAllCitysIntoCoreData];
        
    });*/
    
    self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
    // Override point for customization after application launch.
    
    RootViewController *rootViewController = [[RootViewController alloc] initWithNibName:(iPhone5?@"RootViewController_5":@"RootViewController") bundle:nil];
    
    UINavigationController *_navigationController = [[UINavigationController alloc] initWithRootViewController:rootViewController];[rootViewController release];
    [[UINavigationBar appearance] setBackgroundImage:[UIImage imageNamed:@"bg_navigationBar"] forBarMetrics:UIBarMetricsDefault];
    
    self.window.rootViewController = _navigationController;
    [CacheManager sharedInstance].rootNavController = _navigationController;
    [_navigationController release];
    
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    
    CFTimeInterval time2 = Elapsed_Time;
    ElapsedTime(time2, time1);
    
    /* 测试本地时间戳
    NSArray *arrays = [City MR_findAllWithPredicate:[NSPredicate predicateWithFormat:@"locationDate > %@",@"20130715095231898"]];
    for (City *tCity in arrays) {
        
        if ([tCity.locationDate compare:@"20130715095234733" options:NSNumericSearch] == NSOrderedDescending ||
            [tCity.locationDate compare:@"20130715095234733" options:NSNumericSearch] == NSOrderedSame) {
            
            ABLoggerDebug(@"city name = %@ id = %@ locationDate = %@",tCity.name,tCity.uid,tCity.locationDate);
        }
    }*/
    /*
    NSArray *arrays = [[DataBaseManager sharedInstance] getBarsListFromCoreDataWithCityName:nil
                                                                                     offset:0
                                                                                      limit:30
                                                                                   Latitude:-1
                                                                                  longitude:-1
                                                                                   dataType:@"1"
                                                                                  validDate:@"20130715214708154"];
    
    ABLoggerDebug(@"bar count ====== %d",[arrays count]);
     */
    return YES;
}

- (void)initializePlat{
    
    /**
     连接微信应用以使用相关功能，此应用需要引用WeChatConnection.framework和微信官方SDK
     http://open.weixin.qq.com上注册应用，并将相关信息填写以下字段
     **/
    [ShareSDK connectWeChatWithAppId:@"wx6dd7a9b94f3dd72a" wechatCls:[WXApi class]];
}

- (BOOL)application:(UIApplication *)application
      handleOpenURL:(NSURL *)url
{
    return [ShareSDK handleOpenURL:url
                        wxDelegate:self];
}


- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString  *)sourceApplication
         annotation:(id)annotation
{
    return [ShareSDK handleOpenURL:url
                 sourceApplication:sourceApplication
                        annotation:annotation
                        wxDelegate:self];
}

#pragma mark - WXApiDelegate

-(void) onReq:(BaseReq*)req
{
    
}

-(void) onResp:(BaseResp*)resp
{
    
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
