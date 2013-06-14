
#import "CacheManager.h"

static CacheManager *_sharedInstance = nil;

@implementation CacheManager
@synthesize mUserDefaults;

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

- (void)cleanUp{
    [mUserDefaults removeAllObjects];
}

-(id)init {
    
    self = [super init];
    
    if (self) {
        self.mUserDefaults = [NSMutableDictionary dictionaryWithCapacity:10];
        self.cache = [[[NSCache alloc] init] autorelease];
        _dispatch_queue_syn_default = dispatch_queue_create("com.gcd.wanshangle.thread", NULL);
        dispatch_retain(_dispatch_queue_syn_default);
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
    
    self.mUserDefaults = nil;
    dispatch_release(_dispatch_queue_syn_default);
    
    [super dealloc];
}

@end
