//
//  ApiClient.h
//  Gaopeng
//
//  Created by yuqiang on 11-10-11.
//  Copyright 2011年 GP. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ApiNotify.h"
@class ASIHTTPRequest,ApiCmd,ASINetworkQueue;

/**
 *  @author yuqiang
 *
 *  This is the ApiClient , You should keep this Object
 *  as a singleton , reuse it , and use it one at a time
 *
 *  This class is NOT-Thread safe
 */
@interface ApiClient : NSObject<ApiNotify>{
    
}
@property(nonatomic,retain) NSMutableArray *requestArray;
@property(nonatomic,retain) ASINetworkQueue *networkQueue;

+ (id) defaultClient;
-(void)cancelASIDataFormRequest;

/**
 *  execute ApiCmd asynchrouse
 **/
- (BOOL) executeApiCmdAsync:(ApiCmd*) cmd;

/**
 *  execute ApiCmd sync
 **/
-(NSError*)executeApiCmd:(ApiCmd*) cmd;
-(NSString*)errorInfo:(NSNumber*)errorNumber;

//当用户在主界面RootViewController时候，清除所有的网络请求
- (void)clearHttpRequestTask;
@end
