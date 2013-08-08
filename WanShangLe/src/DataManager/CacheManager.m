
#import "CacheManager.h"
#import "SIAlertView.h"

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
//        self.mUserDefaults = [NSMutableDictionary dictionaryWithCapacity:10];
//        self.cache = [[[NSCache alloc] init] autorelease];
//        _dispatch_queue_syn_default = dispatch_queue_create("com.gcd.wanshangle.thread", NULL);
//        dispatch_retain(_dispatch_queue_syn_default);
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

- (void)showAddFavoritePopupView:(NSString *)title objectId:(NSString *)objectId dataType:(int)dataType{
    
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    NSNumber *buy_hint_bool = [userDefault objectForKey:AddFavorite_HintType];
    
    if(isNull(buy_hint_bool) || ![buy_hint_bool boolValue]){
        SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:title
                                                         andMessage:@"\n\n\n"];
        [alertView addButtonWithTitle:@"取消"
                                 type:SIAlertViewButtonTypeCancel
                              handler:^(SIAlertView *alertView) {
                              }];
        [alertView addButtonWithTitle:@"收藏"
                                 type:SIAlertViewButtonTypeDefault
                              handler:^(SIAlertView *alertView) {
                                  switch (dataType) {
                                      case MCinemaFavorite:{
                                          [[DataBaseManager sharedInstance] addFavoriteCinemaWithId:objectId];
                                          [[NSNotificationCenter defaultCenter] postNotificationName:MCinemaAddFavoriteNotification object:nil];
                                      }
                                          break;
                                          
                                      case KKTVFavorite:{
                                          [[DataBaseManager sharedInstance] addFavoriteKTVWithId:objectId];
                                          [[NSNotificationCenter defaultCenter] postNotificationName:KKTVAddFavoriteNotification object:nil];
                                      }
                                          break;
                                  }
                              }];
        UILabel *promptLabel = [[[UILabel alloc] initWithFrame:CGRectMake(115, 60, 110, 22)] autorelease];
        promptLabel.backgroundColor = [UIColor clearColor];
        promptLabel.text = @"下次不再提醒";
        promptLabel.textColor = [UIColor colorWithWhite:0.400 alpha:1.000];
        
        UIButton *checkBox = [UIButton buttonWithType:UIButtonTypeCustom];
        [checkBox setImage:[UIImage imageNamed:@"btn_checkBox_n@2x"] forState:UIControlStateNormal];
        [checkBox setImage:[UIImage imageNamed:@"btn_checkBox_f@2x"] forState:UIControlStateSelected];
        [checkBox addTarget:self action:@selector(clickCheckBox:) forControlEvents:UIControlEventTouchUpInside];
        checkBox.frame = CGRectMake(85, 62, 20, 20);
        
        [alertView show];
        [alertView.containerView addSubview:checkBox];
        [alertView.containerView addSubview:promptLabel];
        
        [alertView release];
    }
}

- (void)clickCheckBox:(id)sender{
    UIButton *bt = (UIButton *)sender;
    if (bt.selected) {
        bt.selected = NO;
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:AddFavorite_HintType];
    }else{
        bt.selected = YES;
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:AddFavorite_HintType];
    }
    [[NSUserDefaults standardUserDefaults] synchronize];
}


@end
