//
//  CinemaViewController.h
//  WanShangLe
//
//  Created by stephenliu on 13-6-8.
//  Copyright (c) 2013年 stephenliu. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ApiCmdKTV_getSearchKTVs;
@class KtvManagerViewController;

typedef void (^SearchKTVCompleteCallBack)(NSMutableArray *searchArray, BOOL isSuccess);

@interface KtvManagerSearchController : NSObject{
}
@property(nonatomic,assign) KtvManagerViewController *mparentController;

@property(nonatomic,retain) NSMutableArray *mArray;
@property(nonatomic,retain) NSMutableArray *mCacheArray;
@property(nonatomic,retain) NSString *searchString;

@property(nonatomic,copy) SearchKTVCompleteCallBack searchCallBack;
@property(nonatomic,retain) ApiCmdKTV_getSearchKTVs *apiCmdKTV_getSearchKTVs;

- (void)loadSearchMoreDataForSearchString:(NSString *)searchString complete:(SearchKTVCompleteCallBack)callBack;
- (void)startKTVSearchForSearchString:(NSString *)searchString complete:(SearchKTVCompleteCallBack)callBack;
@end
