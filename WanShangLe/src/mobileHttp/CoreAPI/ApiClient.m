//
//  ApiClient.m
//  Gaopeng
//
//  Created by yuqiang on 11-10-11.
//  Copyright 2011年 GP. All rights reserved.
//
#import "ApiConfig.h"

#import "ApiCmd.h"
#import "ApiClient.h"
#import "ASIHTTPRequest.h"
#import "ASINetworkQueue.h"
#import "common.h"

static ASINetworkQueue *networkQueue = nil;

@implementation ApiClient

// define getter/setter methods
@synthesize request;
@synthesize requestArray = _requestArray;

+ (instancetype)defaultClient {
    static ApiClient *_apiClient = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        _apiClient = [[self alloc] init];
    });
    
    return _apiClient;
}

/**
 *  do init work
 */
- (id)init
{
    self = [super init];
    if (self) {
        networkQueue = [[ASINetworkQueue alloc] init];
        //[networkQueue setDelegate:self];
        [networkQueue setShouldCancelAllRequestsOnFailure:NO];
        [networkQueue go];
        
        _requestArray = [[NSMutableArray alloc] initWithCapacity:10];
    }
    return self;
}

-(void)cancelASIDataFormRequest
{
    [networkQueue cancelAllOperations];
}

- (void) apiNotifyResult:(id) apiCmd  error:(NSError*) error {
    
}
/**
 *  release all resources
 *
 */
- (void) dealloc {
    
    [networkQueue release];networkQueue=nil;
    self.requestArray = nil;
    
	[super dealloc];
}

/**
 *  do signature of all parametrs
 */
- (NSString*) signParam:(NSMutableDictionary*) dict{
    
    // add all keys into array
    NSMutableArray* paramArray = [[[NSMutableArray alloc] initWithCapacity:[dict count]] autorelease];
    
    NSEnumerator *enumerator = [dict keyEnumerator];
    NSString* key;
    
    while ((key = [enumerator nextObject])) {
        [paramArray addObject:key];
    }
    
    // sort the param array
    [paramArray sortUsingComparator:^(id obj1, id obj2){
        NSString* str1 = obj1;
        NSString* str2 = obj2;
        return [str1 compare:str2];
    }];
    
    // append the values to form the pre-encryption string
    NSMutableString* mutableString = [[[NSMutableString alloc] initWithCapacity:128] autorelease];
    for (NSInteger index = 0; index < [paramArray count]; index++) {
        id tmpId = [dict objectForKey:[paramArray objectAtIndex:index]];
        
        NSString* strValue =  @"";
        
        if ([tmpId isKindOfClass:[NSString class]]) {
            strValue = tmpId;
        }else if([tmpId isKindOfClass:[NSNumber class]]){
            strValue = [tmpId stringValue];
        }else{
            // do nothing
           ABLoggerError(@"Error Value of [%@], can only accept NSString or NSNumber",[paramArray objectAtIndex:index]);
        }
        
        [mutableString appendString:strValue];
    }
    
    // append the apiSignParamKey
    [mutableString appendString:[ApiConfig getApiSignParamKey]];
    ABLoggerDebug(@"urlstring---------%@",mutableString);
    // do MD5 encryption
    return md5(mutableString);
}



- (void) executeApiCmdAsync:(ApiCmd*) cmd{
    
    self.request = [cmd prepareExecuteApiCmd];
    [_requestArray addObject:cmd];
    //[request startAsynchronous];
    [networkQueue addOperation:request];
    
     ABLoggerDebug(@"request array count === %d",[[[ApiClient defaultClient] requestArray] count]);
}


- (NSError*) executeApiCmd:(ApiCmd*) cmd{
    
    self.request = [cmd prepareExecuteApiCmd];
    [request startSynchronous];
    
    NSError *error = [request error];
    
    NSData *data = [request responseData];
    NSString *string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    ABLoggerDebug(@"response data lenght ============= %d",[data length]);
    ABLoggerDebug(@"response string ============= %@",string);
    
    if (error) {
        ABLoggerDebug(@"Error [%@]", [error localizedDescription]);
    }
    
    return error;
}

-(NSString*)errorInfo:(NSNumber*)errorNumber
{
    NSString * errorString;
    errorString= [errorNumber stringValue];
    NSMutableDictionary * tmpDict = [[[NSMutableDictionary alloc] initWithCapacity:30] autorelease];
    /*系统错误*/
    [tmpDict setObject:@"无效的调用接口" forKey:@"10004000"];
    [tmpDict setObject:@"参数未找到" forKey:@"10004001"];
    [tmpDict setObject:@"缺少必需参数" forKey:@"10004002"];
    [tmpDict setObject:@"请求的API不存在" forKey:@"10004003"];
    [tmpDict setObject:@"签名验证失败" forKey:@"10004004"];
    [tmpDict setObject:@"API需求参数未找到" forKey:@"10004005"];
    //[tmpDict setObject:@"Token无效,必须重新登录" forKey:@"10004006"];
    [tmpDict setObject:@"账户过期请重新登录" forKey:@"10004006"];
    [tmpDict setObject:@"Token已过期" forKey:@"10004007"];
    [tmpDict setObject:@"API需求参数赋值未知" forKey:@"10004008"];
    [tmpDict setObject:@"无权访问此接口" forKey:@"10004009"];
    [tmpDict setObject:@"API处理异常" forKey:@"10005000"];
    
    /*用户业务错误*/
    [tmpDict setObject:@"用户名或密码错误" forKey:@"10014001"];
    [tmpDict setObject:@"更新用户资料失败" forKey:@"10014002"];
    [tmpDict setObject:@"用户注册失败" forKey:@"10014003"];
    [tmpDict setObject:@"用户状态异常，或已被锁定" forKey:@"10014004"];
    [tmpDict setObject:@"要创建的用户已存在" forKey:@"10014005"];
    [tmpDict setObject:@"此外部平台帐户已经在绑定列表中" forKey:@"10014006"];
    [tmpDict setObject:@"预绑定帐户ID无效" forKey:@"10014007"];
    [tmpDict setObject:@"用户绑定外部帐号失败" forKey:@"10014008"];
    [tmpDict setObject:@"关联的用户模型未找到" forKey:@"10014009"];
    [tmpDict setObject:@"联合登录失败" forKey:@"10014010"];
    [tmpDict setObject:@"自动创建用户失败" forKey:@"10014011"];
    [tmpDict setObject:@"此外部平台帐户尚未绑定帐号" forKey:@"10014012"];
    [tmpDict setObject:@"用户原始密码错误" forKey:@"10014013"];
    [tmpDict setObject:@"用户修改密码失败" forKey:@"10014014"];
    [tmpDict setObject:@"邮箱地址已经存在" forKey:@"10014015"];
    [tmpDict setObject:@"手机号码已经存在" forKey:@"10014016"];
    [tmpDict setObject:@"昵称已经被占用" forKey:@"10014017"];
    [tmpDict setObject:@"用户未关联此外部帐号" forKey:@"10014018"];
    [tmpDict setObject:@"用户取消绑定外部帐号失败" forKey:@"10014019"];
    [tmpDict setObject:@"用户本次不是使用外部帐号进行登录" forKey:@"10014020"];
    [tmpDict setObject:@"邮箱域名系回首系统所有" forKey:@"10014021"];
    [tmpDict setObject:@"系统生成邮箱已被更新" forKey:@"10014022"];
    [tmpDict setObject:@"自动登录失败" forKey:@"10014023"];
    [tmpDict setObject:@"当前外部帐号禁止解除绑定" forKey:@"10014024"];
    [tmpDict setObject:@"更新外部帐号信息失败" forKey:@"10014025"];
    [tmpDict setObject:@"密码长度限制为6-12个字符" forKey:@"10014026"];
    [tmpDict setObject:@"模型报错" forKey:@"10016000"];
    
    /*附件业务错误*/
    [tmpDict setObject:@"上传附件失败" forKey:@"10024001"];
    [tmpDict setObject:@"下载附件失败" forKey:@"10024002"];
    [tmpDict setObject:@"未找到上传文件" forKey:@"10024003"];
    [tmpDict setObject:@"模型错误" forKey:@"10026000"];
    [tmpDict setObject:@"请选择文件上传" forKey:@"10024004"];
    [tmpDict setObject:@"不支持的图片类型" forKey:@"10024005"];
    [tmpDict setObject:@"图片大小超出限制" forKey:@"10024006"];
    [tmpDict setObject:@"图片尺寸不正确" forKey:@"10024007"];
    [tmpDict setObject:@"图片保存失败" forKey:@"10024008"];
    
    return [tmpDict objectForKey:errorString];
}
@end
