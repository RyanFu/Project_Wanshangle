//
//  SuggestionViewController.h
//  WanShangLe
//
//  Created by stephenliu on 13-7-10.
//  Copyright (c) 2013年 stephenliu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SuggestionViewController : UIViewController<UITextViewDelegate>
@property(nonatomic,retain)IBOutlet UITextView *adviceTextView;
@property(nonatomic,retain)IBOutlet UILabel *placeHoldText;
@end
