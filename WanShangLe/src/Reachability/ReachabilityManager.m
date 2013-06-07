//
//  ReachabilityManager.m
//  WanShangLe
//
//  Created by stephenliu on 13-6-4.
//  Copyright (c) 2013年 stephenliu. All rights reserved.
//

#import "ReachabilityManager.h"
#import "Reachability.h"

@interface ReachabilityManager()

@end

@implementation ReachabilityManager

- (void)dealloc
{
    [super dealloc];
}

+ (instancetype)defaultReachabilityManager {
    static ReachabilityManager *_reachabilityManager = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        _reachabilityManager = [[self alloc] init];
    });
    
    return _reachabilityManager;
}

- (id)init{
    
    self = [super init];
    
    if (self) {
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(reachabilityChanged:)
                                                     name:kReachabilityChangedNotification
                                                   object:nil];
        
        Reachability * reach = [Reachability reachabilityWithHostname:@"www.baidu.com"];
        
        /*
         reach.reachableBlock = ^(Reachability * reachability)
         {
         dispatch_async(dispatch_get_main_queue(), ^{
         blockLabel.text = @"Block Says Reachable";
         });
         };
         
         reach.unreachableBlock = ^(Reachability * reachability)
         {
         dispatch_async(dispatch_get_main_queue(), ^{
         blockLabel.text = @"Block Says Unreachable";
         });
         };
         */
        
        [reach startNotifier];
    }
    return self;
}


/**
 网络变化时会通知
 @param note
 */
-(void)reachabilityChanged:(NSNotification*)note
{
    //Reachability * reach = [note object];
    switch([[Reachability reachabilityForInternetConnection] currentReachabilityStatus]) {
        case ReachableViaWWAN:
        {
            ABLoggerInfo(@"ReachableViaWWAN 手机3G网络");
            break;
        }
        case ReachableViaWiFi:
        {
            ABLoggerInfo(@"ReachableViaWiFi wifi网络");
            break;
        }
        default:
        {
            ABLoggerWarn(@"没有网络");
            break;
        }
    }
    
    /*
     if([reach isReachable])
     {
     notificationLabel.text = @"Notification Says Reachable";
     }
     else
     {
     notificationLabel.text = @"Notification Says Unreachable";
     }
     */
}

- (BOOL)isReachableNetwork
{
    return  [[Reachability reachabilityForInternetConnection] isReachable];
}
@end
