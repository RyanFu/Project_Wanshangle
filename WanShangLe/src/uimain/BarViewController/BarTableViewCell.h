//
//  MovieTableViewCell.h
//  WanShangLe
//
//  Created by stephenliu on 13-6-6.
//  Copyright (c) 2013年 stephenliu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BarTableViewCell : UITableViewCell{

}
@property(nonatomic,retain) IBOutlet UILabel *bar_name;
@property(nonatomic,retain) IBOutlet UILabel *bar_popular;
@property(nonatomic,retain) IBOutlet UILabel *bar_address;
@property(nonatomic,retain) IBOutlet UILabel *bar_date;
@property(nonatomic,retain) IBOutlet UILabel *bar_distance;
@property(nonatomic,retain) IBOutlet UIImageView *bar_image_location;
@end
