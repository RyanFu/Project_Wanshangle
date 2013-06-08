//
//  MovieTableViewCell.m
//  WanShangLe
//
//  Created by stephenliu on 13-6-6.
//  Copyright (c) 2013年 stephenliu. All rights reserved.
//

#import "CinemaTableViewCell.h"

@implementation CinemaTableViewCell

@synthesize cinema_name;
@synthesize cinema_address;
@synthesize cinema_count;
@synthesize cinema_price;
@synthesize cinema_tuan;

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
    
    self.cinema_name = nil;
    self.cinema_address = nil;
    self.cinema_count = nil;
    self.cinema_price = nil;
    self.cinema_tuan = nil;
    [super dealloc];
}

@end
