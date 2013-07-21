//
//  ApiCmdBindingHuiShowAccount.h
//  mobileapi
//
//  Created by doujingxuan on 10/30/12.
//
//

#import "ApiCmd.h"

typedef NS_ENUM(NSInteger, WSLRecommendAPIType) {
    WSLRecommendAPITypeNone = 0,
    WSLRecommendAPITypeMovieInteract,
    WSLRecommendAPITypePerformInteract,
    WSLRecommendAPITypeKTVInteract,
    WSLRecommendAPITypeBarInteract
};

typedef NS_ENUM(NSInteger, WSLRecommendLookType) {
    WSLRecommendLookTypeNone = 0,
    WSLRecommendLookTypeRecommend,
    WSLRecommendLookTypeLook
};

@interface ApiCmd_recommendOrLook : ApiCmd
{
    
}
@property(nonatomic,assign)WSLRecommendLookType mType;
@property(nonatomic,assign)WSLRecommendAPIType mAPIType;
@property(nonatomic,retain)NSString *object_id;
- (NSMutableDictionary*) getParamDict;
- (void) parseResultData:(NSDictionary*) dictionary;

/**
 *  execute apiCmd return an ASIHTTPRequest
 ***/
- (ASIHTTPRequest*)prepareExecuteApiCmd;
@end
