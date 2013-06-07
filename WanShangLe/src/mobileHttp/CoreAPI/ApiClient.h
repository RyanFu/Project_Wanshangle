//
//  ApiClient.h
//  Gaopeng
//
//  Created by yuqiang on 11-10-11.
//  Copyright 2011年 GP. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ApiNotify.h"
@class ASIHTTPRequest,ApiCmd;

/**
 *  @author yuqiang
 *
 *  This is the ApiClient , You should keep this Object 
 *  as a singleton , reuse it , and use it one at a time
 *
 *  This class is NOT-Thread safe
 */
@interface ApiClient : NSObject<ApiNotify>{

@private
    ASIHTTPRequest *request;
}
@property(nonatomic,assign) ASIHTTPRequest *request;
@property(nonatomic,assign) NSMutableArray *requestArray;

+ (id) defaultClient;
-(void)cancelASIDataFormRequest;

/**
 *  execute ApiCmd asynchrouse
 **/
- (void) executeApiCmdAsync:(ApiCmd*) cmd;

/**
 *  execute ApiCmd sync
 **/
- (NSError*) executeApiCmd:(ApiCmd*) cmd;
-(NSString*)errorInfo:(NSNumber*)errorNumber;
@end
