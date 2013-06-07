//
//  common.h
//  Gaopeng
//
//  Created by yuqiang on 11-10-12.
//  Copyright 2011年 GP. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSDate* parseDateFromNSNumber(NSNumber* number);

extern BOOL parseBoolFromString(NSString* boolValue);

/**
 * extract the file name from path
 *
 **/
NSString* extractFileNameFromPath(NSString* path);


/* NSString to url */
NSString* encodeURL( NSString *string);

/**
 *  get the Tmp path of download file
 *
 ***/
NSString* getTmpDownloadFilePath(NSString* filePath);

/**
 *  get cache file path
 ***/
NSString* getCacheFilePath(NSString* cacheKey);

/**
 * do md5 hash
 ***/
NSString* md5(NSString* input);

NSString* trimString (NSString* input);

BOOL isNull(id object);

BOOL isEmpty(NSString* str);

id defaultNilObject(id object);

NSString* defaultEmptyString(id object);

BOOL validateEmail(NSString* email);
BOOL validateMobile(NSString* mobile);

NSString* convertToHexStr(const char* buffer, int length);

int convertStingEncoding(const char* toEncoding, const char* fromEncoding, 
                            const char* inBuffer, size_t* inBufferSize,
                            char* outBuffer, size_t* outBufferSize);


NSString* convertCharStrToUTF8(const char* inBuffer, size_t inBufferSize);

NSString* getDocumentsFilePath(const NSString* fileName);

NSString* getResourcePath(NSString* basePath, NSString* resName, NSString* resType);

NSURL* getResourceUrl(NSString* basePath, NSString* resName, NSString* resType);

/**
 * parse URL www.baidu.com to http://www.baidu.com
 ***/

BOOL fcheckIsURL(NSString* str);
NSString* doParseURL(NSString *url);

BOOL checkIsURL(NSString* str);

