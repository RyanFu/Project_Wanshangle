//
//  ApiCmdBindingHuiShowAccount.h
//  mobileapi
//
//  Created by doujingxuan on 10/30/12.
//
//

#import "ApiCmd.h"

@interface ApiCmdMovie_getAllMovies : ApiCmd{
}
@property(nonatomic,retain) NSString *cinemaid;
- (NSMutableDictionary*) getParamDict;
- (void) parseResultData:(NSDictionary*) dictionary;

/**
 *  execute apiCmd return an ASIHTTPRequest
 ***/
- (ASIHTTPRequest*)prepareExecuteApiCmd;
@end
