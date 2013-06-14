//
//  Created by stephenliu on 13-6-4.
//  Copyright (c) 2013年 stephenliu. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MovieViewController,CinemaViewController,RootViewController;

@interface CacheManager : NSObject {
    
    NSCache *cache;
    NSMutableDictionary *mUserDefaults;
}
@property (retain, nonatomic) NSMutableDictionary *mUserDefaults;
@property (retain, nonatomic) NSCache *cache;
@property (nonatomic,assign) dispatch_queue_t dispatch_queue_syn_default;
@property (nonatomic,assign) RootViewController *rootViewController;
@property (nonatomic,assign) MovieViewController *movieViewController;
@property (nonatomic,assign) CinemaViewController *cinemaViewController;


+(instancetype)sharedInstance;
+(void)destroySharedInstance;

-(void)cleanUp;

-(void)setCache:(id)obj forKey:(NSString *)key;
-(id)getCacheForKey:(NSString *)key;

@end
