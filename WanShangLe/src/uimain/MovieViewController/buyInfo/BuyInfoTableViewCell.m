//
//  BuyInfoTableViewCell.m
//  TestExpansionTableView
//
//  Created by liu on 6/13/13.
//  Copyright (c) 2013 liu. All rights reserved.
//

#import "BuyInfoTableViewCell.h"

@implementation BuyInfoTableViewCell
@synthesize imgView;
@synthesize expansionView;
@synthesize vendorName;
@synthesize type;
@synthesize clickCount;
@synthesize price;
@synthesize buyInfo_textView;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)awakeFromNib{
    [super awakeFromNib];
    
    [self setSelectionStyle:UITableViewCellSelectionStyleNone];
    [self setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
}

- (void)dealloc{
    self.imgView = nil;
    self.expansionView = nil;
    self.vendorName = nil;
    self.type = nil;
    self.clickCount = nil;
    self.price = nil;
    self.buyInfo_textView = nil;
    [super dealloc];
}

@end
