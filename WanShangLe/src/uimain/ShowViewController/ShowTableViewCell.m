//
//  MovieTableViewCell.m
//  WanShangLe
//
//  Created by stephenliu on 13-6-6.
//  Copyright (c) 2013年 stephenliu. All rights reserved.
//

#import "ShowTableViewCell.h"

@implementation ShowTableViewCell

@synthesize show_name;
@synthesize show_price;
@synthesize show_rating;
@synthesize show_imageView;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    ABLoggerMethod();
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
    }
    return self;
}

- (void)awakeFromNib{
    ABLoggerMethod();
    [super awakeFromNib];
    
    [self setSelectionStyle:UITableViewCellSelectionStyleGray];
    [self setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)dealloc{
    
    self.show_rating = nil;
    self.show_price = nil;
    self.show_name = nil;
    self.show_imageView = nil;
    [super dealloc];
}

@end
