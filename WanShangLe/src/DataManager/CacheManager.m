
#import "CacheManager.h"

static CacheManager *_sharedInstance = nil;

@implementation CacheManager

@synthesize cache;


+ (instancetype)sharedInstance {
    
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        _sharedInstance = [[self alloc] init];
    });
    
    return _sharedInstance;
}

+ (void)destroySharedInstance {
    
    [_sharedInstance release];
    _sharedInstance = nil;
}

-(id)init {
    
    self = [super init];
    
    if (self) {
        
        self.cache = [[[NSCache alloc] init] autorelease];
    }
    
    return self;
}

-(void)setCache:(id)obj forKey:(NSString *)key {
    
    [cache setObject:obj forKey:key];
    
}


-(id)getCacheForKey:(NSString *)key {
    
    return [cache objectForKey:key];
    
}


-(void)dealloc {
    
    [cache release];
    cache = nil;
    
    [super dealloc];
}

@end
