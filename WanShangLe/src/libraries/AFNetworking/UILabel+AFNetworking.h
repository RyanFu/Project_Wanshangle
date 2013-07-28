// UILabel+AFNetworking.h
//
// Copyright (c) 2011 Gowalla (http://gowalla.com/)
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import <Foundation/Foundation.h>
#import "AFJSONRequestOperation.h"
#import <Availability.h>

#if __IPHONE_OS_VERSION_MIN_REQUIRED
#import <UIKit/UIKit.h>

/**
 This category adds methods to the UIKit framework's `UIImageView` class. The methods in this category provide support for loading remote images asynchronously from a URL.
 */
@interface AFJsonCache : NSObject{
    
}
@property(nonatomic,retain)NSMutableDictionary *scheduleCache;
- (NSString *)cachedJsonForRequest:(NSString *)request;
- (void)cacheJson:(NSString *)Json
       forRequest:(NSString *)request;
@end

@class MMovie,MCinema;
@interface UILabel (AFNetworking)

- (void)setJSONWithWithMovie:(MMovie *)aMovie
                      cinema:(MCinema *)aCinema
                 placeholder:(NSString *)placeholderString
                     success:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, NSString *resultString))success
                     failure:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error))failure;

/**
 Cancels any executing image request operation for the receiver, if one exists.
 */
- (void)cancelJSONRequestOperation;

+ (NSOperationQueue *)af_sharedJsonRequestOperationQueue;

+ (AFJsonCache *)af_sharedJsonCache;
@end

#endif
