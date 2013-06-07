//
//  Created by stephenliu on 13-6-4.
//  Copyright (c) 2013年 stephenliu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CacheManager : NSObject {
    
    NSCache *cache;
}

@property (retain, nonatomic) NSCache *cache;

+(instancetype)sharedInstance;
+(void)destroySharedInstance;

-(void)setCache:(id)obj forKey:(NSString *)key;
-(id)getCacheForKey:(NSString *)key;

@end
