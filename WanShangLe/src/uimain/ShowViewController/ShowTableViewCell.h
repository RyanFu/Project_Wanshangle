//
//  MovieTableViewCell.h
//  WanShangLe
//
//  Created by stephenliu on 13-6-6.
//  Copyright (c) 2013年 stephenliu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ShowTableViewCell : UITableViewCell{

}
@property(nonatomic,retain) IBOutlet UILabel *show_name;
@property(nonatomic,retain) IBOutlet UILabel *show_price;
@property(nonatomic,retain) IBOutlet UILabel *show_rating;
@property(nonatomic,retain) IBOutlet UILabel *show_time;
@property(nonatomic,retain) IBOutlet UILabel *show_address;
@property(nonatomic,retain) UIImageView *show_imageView;
@end
