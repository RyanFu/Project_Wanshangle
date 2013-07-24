//
//  MovieTableViewCell.h
//  WanShangLe
//
//  Created by stephenliu on 13-6-6.
//  Copyright (c) 2013年 stephenliu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface KTVPriceCellSection : UITableViewCell{
   
}
@property (nonatomic,retain) IBOutlet UIImageView *arrowImageView;
@property (nonatomic,retain) IBOutlet UILabel *room_time;
@property (nonatomic,retain) IBOutlet UILabel *room_count;

- (void)changeArrowWithUp:(BOOL)up;
@end
