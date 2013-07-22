//
//  CinemaViewController.h
//  WanShangLe
//
//  Created by stephenliu on 13-6-8.
//  Copyright (c) 2013年 stephenliu. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ApiCmdMovie_getSearchCinemas;
@class CinemaManagerViewController;

typedef void (^SearchCinemaCompleteCallBack)(NSMutableArray *searchArray, BOOL isSuccess);

@interface CinemaManagerSearchController : NSObject{
}
@property(nonatomic,assign) CinemaManagerViewController *mparentController;

@property(nonatomic,retain) NSMutableArray *mArray;
@property(nonatomic,retain) NSMutableArray *mCacheArray;
@property(nonatomic,retain) NSString *searchString;

@property(nonatomic,copy) SearchCinemaCompleteCallBack searchCallBack;
@property(nonatomic,retain) ApiCmdMovie_getSearchCinemas *apiCmdMovie_getSearchCinemas;

- (void)loadSearchMoreDataForSearchString:(NSString *)searchString complete:(SearchCinemaCompleteCallBack)callBack;
- (void)startCinemaSearchForSearchString:(NSString *)searchString complete:(SearchCinemaCompleteCallBack)callBack;
@end
