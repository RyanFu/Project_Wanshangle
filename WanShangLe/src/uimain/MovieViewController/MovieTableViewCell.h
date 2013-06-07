//
//  MovieTableViewCell.h
//  WanShangLe
//
//  Created by stephenliu on 13-6-6.
//  Copyright (c) 2013年 stephenliu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MovieTableViewCell : UITableViewCell{
    IBOutlet UILabel *movie_name;
    IBOutlet UILabel *movie_word;
    IBOutlet UILabel *movie_rating;
    IBOutlet UILabel *movie_new;
    IBOutlet UIImageView *movie_imageView;
}
@property(nonatomic,retain) UILabel *movie_name;
@property(nonatomic,retain) UILabel *movie_word;
@property(nonatomic,retain) UILabel *movie_rating;
@property(nonatomic,retain) UILabel *movie_new;
@property(nonatomic,retain) UIImageView *movie_imageView;
@end
