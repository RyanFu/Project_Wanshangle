//
//  MovieTableViewCell.m
//  WanShangLe
//
//  Created by stephenliu on 13-6-6.
//  Copyright (c) 2013年 stephenliu. All rights reserved.
//

#import "ScheduleTableViewCell.h"

@implementation ScheduleTableViewCell
@synthesize schedule_time;
@synthesize schedule_view;
@synthesize schedule_price;
@synthesize schedule_timeLong;
@synthesize tuan_seat_imgView;

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
    
    [self setBackgroundColor:Color4];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
//    if (selected)
//        [self setBackgroundColor:[UIColor redColor]];
//    else
//        [self setBackgroundColor:[UIColor yellowColor]];
}

-(void)dealloc{
    self.schedule_price = nil;
    self.schedule_time = nil;
    self.schedule_timeLong = nil;
    self.schedule_view = nil;
    [super dealloc];
}

@end
