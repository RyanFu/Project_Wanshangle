//
//  common.m
//  Gaopeng
//
//  Created by yuqiang on 11-10-12.
//  Copyright 2011年 GP. All rights reserved.
//

#import <CommonCrypto/CommonDigest.h>
#import <iconv.h>

#import "common.h"

#import "RegexKitLite.h"
#import "common.h"

static NSString *regrexUrl = @"\\b((?:[\\w-]+://?|www[.])[^\\s()<>]+(?:\\([\\w\\d]+\\)|(?:[^\\p{Punct}\\s]|/))+|\\.com|\\.cn|\\.org|\\.net|\\.hk|\\.int|\\.edu|\\.gov|\\.mil|\\.arpa|\\.biz|\\info|\\.name|\\.pro|\\.coop|\\.aero|\\.museum|\\.cc|\\.tv)";

NSDate* parseDateFromNSNumber(NSNumber* number){
    
    if (nil == number || ![number isKindOfClass:[NSNumber class]]) {
        return nil;
    }
    
    return [NSDate dateWithTimeIntervalSince1970:[number longValue]];
}

BOOL parseBoolFromString(NSString* boolValue){
    
    if (nil == boolValue) {
        return NO;
    }
    
    static NSString* boolTrue = @"true";
    //static NSString* boolFalse = @"false";
    
    if (NSOrderedSame == [boolTrue caseInsensitiveCompare:boolValue]) {
        return YES;
    }
    
    return NO;
}

NSString* encodeURL( NSString *string)
{
    NSString *newString = (__bridge NSString *)CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, (__bridge CFStringRef)string, NULL, CFSTR(":/?#[]@!$ &'()*+,;=\"<>%{}|\\^~`"), CFStringConvertNSStringEncodingToEncoding(NSUTF8StringEncoding));
    
    if (newString) 
    {
        return newString;
    }
    
    return @"";
}

NSString* encodeURLByAddingPercentEscapes( NSString *string)
{
    return [string stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
}

NSString* extractFileNameFromPath(NSString* path){
    return [path lastPathComponent];
}


NSString* getTmpDownloadFilePath(NSString* filePath){
    return [NSTemporaryDirectory() stringByAppendingPathComponent:extractFileNameFromPath(filePath)];
}

NSString* getCacheFilePath(NSString* cacheKey){
    return [NSTemporaryDirectory() stringByAppendingPathComponent:cacheKey];
}

NSString* md5(NSString* input)
{
    const char *cStr = [input UTF8String];
    unsigned char digest[CC_MD5_DIGEST_LENGTH];
    CC_MD5( cStr, strlen(cStr), digest ); // This is the md5 call
    
    NSMutableString *output = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    
    for(int i = 0; i < CC_MD5_DIGEST_LENGTH; i++)
        [output appendFormat:@"%02x", digest[i]];
    
    return  output;
    
}

NSString* trimString (NSString* input) {
    NSMutableString *mStr = [input mutableCopy];
    CFStringTrimWhitespace((CFMutableStringRef)mStr);   
    NSString *result = [mStr copy];   
    [mStr release];
    return [result autorelease];
}

BOOL isNull(id object) {
    return (nil == object || [object isKindOfClass:[NSNull class]]);
}

id defaultNilObject(id object) {
    
    if (isNull(object)) {
        return nil;
    }
    
    return object;
}

BOOL isEmpty(NSString* str) {
    
    if (isNull(str)) {
        return YES;
    }
    
    return [trimString(str) length] <= 0;
}

NSString* defaultEmptyString(id object) {
    
    if (isNull(object)) {
        return @"";
    }
    
    if ([object isKindOfClass:[NSString class]]) {
        return object;
    }
    
    if ([object respondsToSelector:@selector(stringValue)]) {
        return [object stringValue];
    }
    
    return @"";
}


BOOL validateEmail(NSString* email) {
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
	NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
	return [emailTest evaluateWithObject:email];
}

BOOL validateMobile(NSString* mobile) {
    NSString *phoneRegex = @"^((13[0-9])|(15[^4,\\D])|(18[0,0-9]))\\d{8}$";
    NSPredicate *phoneTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",phoneRegex];
    return [phoneTest evaluateWithObject:mobile];
}


NSString* convertToHexStr(const char* buffer, int length) {
    NSMutableString* mutableString = [[[NSMutableString alloc] initWithCapacity:4*length] autorelease];
    
    for (int index = 0; index < length; index++) {
        [mutableString appendFormat:@"%x,", buffer[index]];
    }
    
    return mutableString;
}


int convertStingEncoding(const char* toEncoding, const char* fromEncoding, 
                            const char* inBuffer, size_t* inBufferSize,
                            char* outBuffer, size_t* outBufferSize){
    
    iconv_t handle = iconv_open(toEncoding, fromEncoding);
    
    // do not support the encoding
    if (((iconv_t) -1) == handle) {
        ABLoggerDebug(@"Do not Support Encoding  toEncoding[%s] fromEncoding[%s]", toEncoding, fromEncoding);
        return (size_t)handle;
    }

    int convertSize = iconv(handle, (const char**)(&inBuffer), inBufferSize, &outBuffer, outBufferSize);
    iconv_close(handle);
    
    return convertSize;
}

NSString* convertCharStrToUTF8(const char* inBuffer, size_t inBufferSize) {
    
//    ABLoggerDebug(@"Dump Hex {%@}", convertToHexStr(inBuffer, inBufferSize));
//    
//    NSData* data = [NSData dataWithBytes:inBuffer length:inBufferSize];
//    
//    NSString* retStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
//    
//    if (nil != retStr) {
//        ABLoggerDebug(@"recognize UTF-8 encoding [%@]", retStr);
//        [retStr autorelease];
//        return  retStr;
//    }
//    
//    NSStringEncoding gb2312Encoding = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_2312_80);
//    retStr = [[NSString alloc] initWithData:data encoding:gb2312Encoding];
//    
//    if (nil != retStr) {
//        ABLoggerDebug(@"recognize GB2312 encoding [%@]", retStr);
//        [retStr autorelease];
//        return  retStr;
//    }
//    
//    NSStringEncoding gbkEncoding = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
//    retStr = [[NSString alloc] initWithData:data encoding:gbkEncoding];
//    
//    if (nil != retStr) {
//        ABLoggerDebug(@"recognize GBK encoding [%@]", retStr);
//        [retStr autorelease];
//        return  retStr;
//    }
//    
//    return @"ERROR";
    
    static char* fromEncodingArray[] = {
        "GB18030",
        "ISO-8859-1",
        "UTF8",
        0
    };
    
    char** currentEncoding = fromEncodingArray;
    
    // make sure we would have enough space to containing all characters
    size_t outBufferSize = inBufferSize * 4 + 4;
    char* outBuffer = (char*)malloc(outBufferSize * sizeof(char));
    
    for (; *currentEncoding; currentEncoding++) {
        // clean the bufffer first
        memset(outBuffer, 0, outBufferSize);
        size_t tmpInBufferSize = inBufferSize;
        size_t tmpOutBufferSize = outBufferSize;
        
        int count = convertStingEncoding("utf-8", *currentEncoding, inBuffer, &tmpInBufferSize, 
                                           outBuffer, &tmpOutBufferSize) ;
        if(count > 0){
            goto out_free;
        }
        
    }
    ABLoggerDebug(@"Can not recognize the encoding, use UTF-8 as default");
    free(outBuffer);
    return [NSString stringWithUTF8String:inBuffer];
    
out_free:
    
    ABLoggerDebug(@"Success Convert from currentEncoding[%s] to UTF8", *currentEncoding);
    NSString* retString = [NSString stringWithUTF8String:outBuffer];
    free(outBuffer);
    return retString;
}


NSString* getDocumentsFilePath(const NSString* fileName) {
    
    NSString* documentRoot = [NSHomeDirectory() stringByAppendingPathComponent:@"/Documents"];
    return [documentRoot stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@", fileName]];
}


NSString* getResourcePath(NSString* basePath, NSString* resName, NSString* resType) {
    NSString* path = [NSString pathWithComponents:[NSArray arrayWithObjects:basePath, resName, nil]];
    return [[NSBundle mainBundle] pathForResource:path ofType:resType];
}

NSURL* getResourceUrl(NSString* basePath, NSString* resName, NSString* resType) {
    NSString* path = [NSString pathWithComponents:[NSArray arrayWithObjects:basePath, resName, nil]];
    return [[NSBundle mainBundle] URLForResource:path withExtension:resType];
}
BOOL checkIsURL(NSString* str){
    
    if (isEmpty(str)) {
        return NO;
    }
    
    //str = [str lowercaseString];
    
    NSString *urlStr = [NSString stringWithFormat:@"%@",str];
    NSArray *blankSpace = [urlStr componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    //urlStr = [urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    ABLoggerDebug(@"blankSpace ===== %d",[blankSpace count]);
    
    if ([urlStr isMatchedByRegex:regrexUrl] && [NSURL URLWithString:urlStr] && ([blankSpace count]==1)) {
        ABLoggerDebug(@"It is an url = %@",urlStr);  
        return YES;
    }
    
    ABLoggerDebug(@"It is not an url = %@",urlStr);
    
    return NO;
}



NSString* doParseURL(NSString *url){
    
    //url = [url lowercaseString];
    //url = [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    NSString *strURL = nil;
    
    if (!isEmpty(url)) {//判断url字符串不为空
        
        if ([url isMatchedByRegex:regrexUrl] && [NSURL URLWithString:url]) {//判断是否为url格式
            ABLoggerDebug(@"It is an url = %@",url);
            
            NSRange range_http1 = [url rangeOfString:@"http://" options:NSCaseInsensitiveSearch];
            NSRange range_http2 = [url rangeOfString:@"http:/" options:NSCaseInsensitiveSearch];
            NSRange range_http3 = [url rangeOfString:@"http:" options:NSCaseInsensitiveSearch];
            NSRange range_https1 = [url rangeOfString:@"https://" options:NSCaseInsensitiveSearch];
            NSRange range_https2 = [url rangeOfString:@"https:/" options:NSCaseInsensitiveSearch];
            NSRange range_https3 = [url rangeOfString:@"https:" options:NSCaseInsensitiveSearch];
            ABLoggerDebug(@"range_http ===location===%d length===%d",range_http1.location,range_http1.length);
            ABLoggerDebug(@"range_https ===location===%d length===%d",range_https1.location,range_https1.length);
            if ((range_http1.location == 0) || 
                (range_http2.location == 0) ||
                (range_http3.location == 0) ||
                (range_https1.location == 0) ||
                (range_https2.location == 0) ||
                (range_https3.location == 0)) {
                strURL = url;
            }else{
                strURL = [NSString stringWithFormat:@"http://%@",url];
            }   
        }
    }
    ABLoggerDebug(@"strURL ====== %@",strURL);
    return strURL;
}
