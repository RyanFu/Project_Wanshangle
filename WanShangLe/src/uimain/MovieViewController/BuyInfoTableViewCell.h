//
//  BuyInfoTableViewCell.h
//  TestExpansionTableView
//
//  Created by liu on 6/13/13.
//  Copyright (c) 2013 liu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BuyInfoTableViewCell : UITableViewCell
@property(nonatomic,retain) IBOutlet UIImageView *imgView;
@property(nonatomic,retain) IBOutlet UILabel *vendorName;
@property(nonatomic,retain) IBOutlet UILabel *type;
@property(nonatomic,retain) IBOutlet UILabel *clickCount;
@property(nonatomic,retain) IBOutlet UILabel *price;
@property(nonatomic,retain) IBOutlet UIView *expansionView;
@property(nonatomic,retain) IBOutlet UITextView *buyInfo_textView;

@end
