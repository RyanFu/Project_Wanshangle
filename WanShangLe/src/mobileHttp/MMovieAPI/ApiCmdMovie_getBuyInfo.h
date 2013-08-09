//
//  ApiCmdBindingHuiShowAccount.h
//  mobileapi
//
//  Created by doujingxuan on 10/30/12.
//
//

#import "ApiCmd.h"

@interface ApiCmdMovie_getBuyInfo : ApiCmd{
}
@property(nonatomic,retain)NSString *cinemaId;
@property(nonatomic,retain)NSString *movieId;
@property(nonatomic,retain)NSString *playtime;
@property(nonatomic,retain)NSString *timedistance;
- (NSMutableDictionary*) getParamDict;
- (void) parseResultData:(NSDictionary*) dictionary;

/**
 *  execute apiCmd return an ASIHTTPRequest
 ***/
- (ASIHTTPRequest*)prepareExecuteApiCmd;
@end
