//
//  MovieTableViewCell.h
//  WanShangLe
//
//  Created by stephenliu on 13-6-6.
//  Copyright (c) 2013年 stephenliu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MovieTableViewCell : UITableViewCell{

}
@property(nonatomic,retain) IBOutlet UILabel *movie_name;
@property(nonatomic,retain) IBOutlet UILabel *movie_word;
@property(nonatomic,retain) IBOutlet UILabel *movie_rating;
@property(nonatomic,retain) UIImageView *movie_imageView;

@property(nonatomic,retain) IBOutlet UIImageView *movie_image_new;
@property(nonatomic,retain) IBOutlet UIImageView *movie_image_hot;
@property(nonatomic,retain) IBOutlet UIImageView *movie_image_3dimx;
@property(nonatomic,retain) IBOutlet UIImageView *movie_image_imx;
@property(nonatomic,retain) IBOutlet UIImageView *movie_image_3d;
@end
