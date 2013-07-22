//
//  MovieTableViewCell.h
//  WanShangLe
//
//  Created by stephenliu on 13-6-6.
//  Copyright (c) 2013年 stephenliu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CinemaManagerCell : UITableViewCell{

}
@property(nonatomic,retain)IBOutlet UILabel *cinema_name;
@property(nonatomic,retain)IBOutlet UILabel *cinema_address;
@property(nonatomic,retain)IBOutlet UIButton *cinemaFavoriteButton;
@end
