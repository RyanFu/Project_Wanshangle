//
//  CinemaViewController.m
//  WanShangLe
//
//  Created by stephenliu on 13-6-8.
//  Copyright (c) 2013年 stephenliu. All rights reserved.
//

#import "CinemaManagerViewController.h"
#import "CinemaManagerSearchController.h"
#import "ApiCmdMovie_getSearchCinemas.h"
#import "EGORefreshTableHeaderView.h"
#import "ASIHTTPRequest.h"
#import "MCinema.h"
#import "ApiCmd.h"

@interface CinemaManagerSearchController()<ApiNotify>{
    BOOL isLoadMore;
    BOOL isLoading;
}
@end

@implementation CinemaManagerSearchController

- (id)init
{
    self = [super init];
    if (self) {
        _mArray = [[NSMutableArray alloc] initWithCapacity:DataCount];
        _mCacheArray = [[NSMutableArray alloc] initWithCapacity:DataCount];
    }
    return self;
}

- (void)dealloc{
    
    [_apiCmdMovie_getSearchCinemas.httpRequest clearDelegatesAndCancel];
    _apiCmdMovie_getSearchCinemas.delegate = nil;
    [[[ApiClient defaultClient] requestArray] removeObject:_apiCmdMovie_getSearchCinemas];
    self.apiCmdMovie_getSearchCinemas = nil;
    
    self.mArray = nil;
    self.mCacheArray = nil;
    
    self.searchString = nil;
    self.searchCallBack = nil;
    
    [super dealloc];
}

#pragma mark -
#pragma mark apiNotiry
-(void)apiNotifyResult:(id)apiCmd error:(NSError *)error{
    
    
    if (error!=nil) {
        if (self.searchCallBack) {
            _searchCallBack(_mArray,NO);
        }
        isLoading = NO;
        return;
    }
    
    NSArray *dataArray = [[DataBaseManager sharedInstance] insertTemporaryCinemasIntoCoreDataFromObject:[apiCmd responseJSONObject] withApiCmd:apiCmd];
    if (dataArray==nil || [dataArray count]<=0) {
        if (self.searchCallBack) {
            _searchCallBack(_mArray,NO);
        }
        isLoading = NO;
        return;
    }
    
    int tag = [[apiCmd httpRequest] tag];
    [self addDataIntoCacheData:dataArray];
    [self updateData:tag withData:[self getCacheData]];
}

- (void) apiNotifyLocationResult:(id)apiCmd cacheData:(NSArray*)cacheData{
    isLoading = NO;
    
    [self addDataIntoCacheData:cacheData];
    [self updateData:API_MCinemaSearchCmd withData:[self getCacheData]];
}

- (ApiCmd *)apiGetDelegateApiCmd{
    return _apiCmdMovie_getSearchCinemas;
}

- (void)updateData:(int)tag withData:(NSArray*)dataArray
{
    if (dataArray==nil || [dataArray count]<=0) {
        isLoading = NO;
        return;
    }
    
    switch (tag) {
        case 0:
        case API_MCinemaSearchCmd:{
            [self formatCinemaData:dataArray];
        }
            break;
            
        default:
        {
            NSAssert(0, @"没有从网络抓取到数据");
        }
            break;
    }
    
}

#pragma mark -
#pragma mark FormateData
- (void)formatCinemaData:(NSArray*)dataArray{
    [self formatCinemaDataFilterAll:dataArray];
}

#pragma mark -
#pragma mark FilterCinema FormatData
- (void)formatCinemaDataFilterAll:(NSArray*)pageArray{
    
    NSArray *array_coreData = pageArray;
    ABLoggerDebug(@"搜索 影院店 count ==== %d",[array_coreData count]);
    
    if (isLoadMore) {//加载更多
        [_mArray addObjectsFromArray:array_coreData];
    }else{//更新数据
        NSMutableArray *removeArray = [NSMutableArray arrayWithArray:_mArray];
        [_mArray addObjectsFromArray:array_coreData];
        [_mArray removeObjectsInArray:removeArray];
    }
    
    
    if (self.searchCallBack) {
        _searchCallBack(_mArray,YES);
    }
    
    isLoading = NO;
}

#pragma mark -
#pragma mark 刷新和加载更多
- (void)loadSearchMoreDataForSearchString:(NSString *)searchString complete:(SearchCinemaCompleteCallBack)callBack{
    if (isLoading)return;
    
    isLoadMore = YES;
    isLoading = YES;
    self.searchCallBack = callBack;
    self.searchString = searchString;
    [self updateData:0 withData:[self getCacheData]];
}

#pragma mark -
#pragma mark 请求服务器搜索Cinema
- (void)startCinemaSearchForSearchString:(NSString *)searchString complete:(SearchCinemaCompleteCallBack)callBack{
    if (isLoading)return;
    
    isLoadMore = NO;
    isLoading = YES;
    self.searchCallBack = callBack;
    self.searchString = searchString;
    [_mCacheArray removeAllObjects];
    [self updateData:0 withData:[self getCacheData]];
}
//添加缓存数据
- (void)addDataIntoCacheData:(NSArray *)dataArray{
    
    [self.mCacheArray addObjectsFromArray:dataArray];
}

//获取缓存数据
- (NSArray *)getCacheData{
    
    if ([_mCacheArray count]<=0) {
        
        int number = [_mArray count];
        ABLoggerDebug(@"Cinema 数组 number ==  %d",number);
        
        if (!isLoadMore) {
            number = 0;
        }
        
        NSString *dataType = [NSString stringWithFormat:@"%d",API_MCinemaSearchCmd];
        self.apiCmdMovie_getSearchCinemas = (ApiCmdMovie_getSearchCinemas *)[[DataBaseManager sharedInstance] getCinemasSearchListFromWeb:self
                                                                                                                                   offset:number
                                                                                                                                    limit:DataLimit
                                                                                                                                 dataType:dataType
                                                                                                                             searchString:_searchString];
        return  nil;
    }
    
    ABLoggerInfo(@"_cacheArray count == %d",[_mCacheArray count]);
    int count = DataCount; //取10条数据
    if ([_mCacheArray count]<DataCount) {
        count = [_mCacheArray count];//取小于10条数据
    }
    
    NSMutableArray *aPageData = [NSMutableArray arrayWithCapacity:count];
    for (int i=0; i<count; i++) {
        MCinema *object = [_mCacheArray objectAtIndex:i];
        [aPageData addObject:object];
    }
    
    if (count>0) {
        [_mCacheArray removeObjectsInRange:NSMakeRange(0, count)];
    }
    
    ABLoggerInfo(@"_cacheArray count == %d",[_mCacheArray count]);
    ABLoggerInfo(@"aPageData count == %d",[aPageData count]);
    
    return aPageData;
}

@end
