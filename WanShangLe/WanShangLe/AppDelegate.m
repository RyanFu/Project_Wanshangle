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
#import "WSLUncaughtExceptionHandler.h"
#import "AFJSONRequestOperation.h"
#import "AFHTTPRequestOperation.h"
#import "ASIHTTPRequest.h"
#import "GuidePagesController.h"
#import "WSLProgressHUD.h"

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
    
    /*应用异步程序初始化*/
    [self applicationconfigrationInit];
        
    self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
    // Override point for customization after application launch.
    
    RootViewController *rootViewController = [[[RootViewController alloc] initWithNibName:(iPhone5?@"RootViewController_5":@"RootViewController") bundle:nil] autorelease];
    UINavigationController *_navigationController = [[[UINavigationController alloc] initWithRootViewController:rootViewController] autorelease];
    [[UINavigationBar appearance] setBackgroundImage:[UIImage imageNamed:@"bg_navigationBar"] forBarMetrics:UIBarMetricsDefault];
    _rootController = _navigationController;
    
    self.window.rootViewController = _rootController;
    [CacheManager sharedInstance].rootNavController = _rootController;
    
    self.window.backgroundColor = Color4;
    [self.window makeKeyAndVisible];
    
    [self showGuidePage];//显示引导页面
    
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
    
    //获取服务器的时间用来校对本地时间
    [self getServerCurrentTime];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    [[NSManagedObjectContext MR_contextForCurrentThread] MR_saveToPersistentStoreAndWait];
    [MagicalRecord cleanUp];
}

/**
	应用程序接受到内存警告
	@param application App对象
 */
- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application
{
    ABLoggerWarn(@"AppDelegate 接受到内存警告了");
    
    [WSLProgressHUD cleanCache];
    
    report_memory();
    
    logMemUsage();
}

- (void)applicationconfigrationInit{
    
    ABLogger_rect(iPhoneAppFrame);
    ABLogger_rect(iPhoneScreenBounds);
    if (iPhone5) {
        ABLoggerInfo(@"运行在iphone5设备上 === %0.2f",[[UIScreen mainScreen] currentMode].size.height);
    }else{
        ABLoggerInfo(@"运行在非iphone5设备上");
    }
    
    ABLoggerDebug(@"开始 异步 初始化");
    dispatch_sync(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        
        ABLoggerDebug(@"运行 异步 初始化");
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
        // set Dev Env
        [ApiConfig setEnv:APIDEV];
        // enable API Debug
        [ApiConfig setApiMessageDebug:YES];
        
        /**
         注册SDK应用，此应用请到http://www.sharesdk.cn中进行注册申请。
         此方法必须在启动时调用，否则会限制SDK的使用。
         **/
        [ShareSDK registerApp:@"387cdf313f8"];
        [ShareSDK convertUrlEnabled:NO];
        [self initializePlat];
        
        //友盟初始化
        [[Statistics defaultStatistics] statisticsTraceLog];
        
        //configure coredata
        [MagicalRecord setupCoreDataStackWithAutoMigratingSqliteStoreNamed:@"DataStore.sqlite"];
        //[MagicalRecord setupCoreDataStackWithStoreNamed:@"DataStore.sqlite"];
        
        // 异常捕获 exception caught
        [self performSelector:@selector(installUncaughtExceptionHandler) withObject:nil afterDelay:0];
        
    });
    
    ABLoggerDebug(@"结束 异步 初始化");
}

/**
 第一次显示App 引导页面
 */
- (void)showGuidePage{
    if (isNull([[NSUserDefaults standardUserDefaults] objectForKey:NewApp]) || [[[NSUserDefaults standardUserDefaults] objectForKey:NewApp] boolValue]) {
        GuidePagesController* guidePagesController = [[GuidePagesController alloc] init];
        guidePagesController.delegate = self;
        guidePagesController.selector = @selector(guidePageComplete:);
        
        [_rootController.view addSubview:guidePagesController.view];
        
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:NO] forKey:NewApp];
    }else{
        //location user city 定位用户的城市
        [[LocationManager defaultLocationManager] startLocationUserGPS];
    }
}

/**
 引导页面完成后的回调方法
 @param guidePageController 引导页对象
 */
- (void)guidePageComplete:(GuidePagesController *)guidePageController{
    [guidePageController release];
    //location user city 定位用户的城市
    [[LocationManager defaultLocationManager] startLocationUserGPS];
}

/**
 微信初始化
 */
- (void)initializePlat{
    
    /**
     连接微信应用以使用相关功能，此应用需要引用WeChatConnection.framework和微信官方SDK
     http://open.weixin.qq.com上注册应用，并将相关信息填写以下字段
     **/
    [ShareSDK connectWeChatWithAppId:@"wx788861997bc9ceaa" wechatCls:[WXApi class]];
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

+ (instancetype)appDelegateInstance{
	return (AppDelegate *)[UIApplication sharedApplication].delegate;
}

//重置KeyWindow，解决第三方框架更改KeyWindow后为Nil的Bug
- (void)reSetKeyWindow{
    _window.rootViewController = _rootController;
    [_window makeKeyWindow];
}


/**
	添加友好崩溃提示
 */
- (void)installUncaughtExceptionHandler
{
	InstallWSLUncaughtExceptionHandler();
}

/**
	获取服务器当前时间用来校对本地时间误差
 */
- (void)getServerCurrentTime{

     dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
         NSData *timeData = [NSData dataWithContentsOfURL:[NSURL URLWithString:@"http://api.wanshangle.com:10000/api?appId=000001&sign=sign&time=1&v=1.0&api=server.currenttime"]];
         NSError *error = nil;
         if (isNull(timeData)) {
             return ;
         }
         NSDictionary *timeDic = [NSJSONSerialization JSONObjectWithData:timeData options:0 error:&error];
         if (error) {
             ABLoggerWarn(@"Fail to parseJson 系统时间 with error:\n%@", [error localizedDescription]);
         }
         
        double timeStamp = [[[timeDic objectForKey:@"data"] objectForKey:@"timestamp"] doubleValue];
        double localTime = [[NSDate date] timeIntervalSince1970];
        
        
        [DataBaseManager sharedInstance].missTime = timeStamp-localTime;
         ABLoggerInfo(@"获取服务器时间 ======= %@",timeDic);
     });
}

@end
