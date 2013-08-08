//
//  BuyInfoTableViewCell.m
//  TestExpansionTableView
//
//  Created by liu on 6/13/13.
//  Copyright (c) 2013 liu. All rights reserved.
//

#import "KTVDiscountTableViewCell.h"

@implementation KTVDiscountTableViewCell

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
    [self setAccessoryType:UITableViewCellAccessoryNone];
}

- (void)dealloc{
    [super dealloc];
}

@end
