//
//  MovieTableViewCell.m
//  WanShangLe
//
//  Created by stephenliu on 13-6-6.
//  Copyright (c) 2013年 stephenliu. All rights reserved.
//

#import "CinemaTableViewCellSection.h"

@implementation CinemaTableViewCellSection

@synthesize cinema_district;

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
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)changeArrowWithUp:(BOOL)up
{
    if (up) {
        self.arrowImageView.image = [UIImage imageNamed:@"UpAccessory.png"];
    }else
    {
        self.arrowImageView.image = [UIImage imageNamed:@"DownAccessory.png"];
    }
}

-(void)dealloc{
    
    self.cinema_district = nil;
    [super dealloc];
}

@end
