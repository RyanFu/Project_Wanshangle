//
//  ApiNotify.h
//  Gaopeng
//
//  Created by yuqiang on 11-10-11.
//  Copyright 2011年 GP. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ApiCmd;
/**
 *  @author yuqiang
 *
 *  We do asynchrous callback by using this protocol
 *
 */
@protocol ApiNotify <NSObject>

- (void) apiNotifyResult:(id) apiCmd  error:(NSError*) error;

@optional
- (void) apiNotifyLocationResult:(id) apiCmd  error:(NSError*) error;
- (ApiCmd *)apiGetDelegateApiCmd;
@end
