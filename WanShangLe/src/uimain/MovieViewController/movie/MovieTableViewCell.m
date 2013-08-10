//
//  MovieTableViewCell.m
//  WanShangLe
//
//  Created by stephenliu on 13-6-6.
//  Copyright (c) 2013年 stephenliu. All rights reserved.
//

#import "MovieTableViewCell.h"

@implementation MovieTableViewCell

@synthesize movie_imageView;
@synthesize movie_name;
@synthesize movie_rating;
@synthesize movie_word;

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
    
    [self setSelectionStyle:UITableViewCellSelectionStyleNone];
    [self setAccessoryType:UITableViewCellAccessoryNone];
    
//    UIView *bgView = [[[UIView alloc] initWithFrame:self.bounds] autorelease];
//    [bgView setBackgroundColor:Color7];
    [self.contentView setBackgroundColor:Color4];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

-(void)dealloc{
    
    self.movie_word = nil;
    self.movie_rating = nil;
    self.movie_name = nil;
    self.movie_imageView = nil;
    [super dealloc];
}

@end
