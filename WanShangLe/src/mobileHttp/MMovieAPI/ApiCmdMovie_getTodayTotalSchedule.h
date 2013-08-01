//
//  ApiCmdBindingHuiShowAccount.h
//  mobileapi
//
//  Created by doujingxuan on 10/30/12.
//
//

#import "ApiCmd.h"

@interface ApiCmdMovie_getTodayTotalSchedule : ApiCmd{
}
@property(nonatomic,retain)NSString *movie_id;
@property(nonatomic,retain)NSString *cinema_id;
@property(nonatomic,retain)NSString *timedistance;
- (NSMutableDictionary*) getParamDict;
- (void) parseResultData:(NSDictionary*) dictionary;

/**
 *  execute apiCmd return an ASIHTTPRequest
 ***/
- (ASIHTTPRequest*)prepareExecuteApiCmd;

+ (NSURL *)getURLWithMovie:(MMovie *)aMovie cinema:(MCinema *)aCinema;
@end
