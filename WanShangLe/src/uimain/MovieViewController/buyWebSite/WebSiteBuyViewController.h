//
//  WebSiteBuyViewController.h
//  WanShangLe
//
//  Created by stephenliu on 13-7-30.
//  Copyright (c) 2013年 stephenliu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WebSiteBuyViewController : UIViewController<UIWebViewDelegate,UIScrollViewDelegate>{
    IBOutlet UIButton *backButton;
    IBOutlet UIButton *forwardButton;
    IBOutlet UIButton *postErrorButton;
    IBOutlet UIView *bottomBar;
    IBOutlet UIView *errorPopupView;
    IBOutlet UIView *commitErrorView;
}
@property(nonatomic,retain)IBOutlet UITextView *adviceTextView;
@property(nonatomic,retain)IBOutlet UILabel *placeHoldText;
@property(nonatomic,retain) NSString *mURLStr;

- (IBAction)clickcWebBackButton:(id)sender;
- (IBAction)clickcWebForwardkButton:(id)sender;
- (IBAction)clickcWebPostErrorButton:(id)sender;

- (IBAction)clickErrorPriceButton:(id)sender;
- (IBAction)clickErrorWebButton:(id)sender;
- (IBAction)clickErrorInfoButton:(id)sender;
- (IBAction)clickErrorOtherButton:(id)sender;

- (IBAction)clickErrorOtherCancelButton:(id)sender;
- (IBAction)clickErrorOtherCommitButton:(id)sender;
@end
