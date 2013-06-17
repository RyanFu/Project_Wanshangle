//
//  ApiCmdBindingHuiShowAccount.h
//  mobileapi
//
//  Created by doujingxuan on 10/30/12.
//
//

#import "ApiCmd.h"

@interface ApiCmdBar_getAllBars : ApiCmd
{
@private
    
}
- (NSMutableDictionary*) getParamDict;
- (void) parseResultData:(NSDictionary*) dictionary;

/**
 *  execute apiCmd return an ASIHTTPRequest
 ***/
- (ASIHTTPRequest*)prepareExecuteApiCmd;
@end
