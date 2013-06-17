//
//  MovieListTableViewDelegate.m
//  WanShangLe
//
//  Created by stephenliu on 13-6-8.
//  Copyright (c) 2013年 stephenliu. All rights reserved.
//
#import "ShowTableViewDelegate.h"
#import "ShowViewController.h"
#import "ShowTableViewCell.h"
#import "UIImageView+WebCache.h"
#import "ShowDetailViewController.h"
#import "SShow.h"

@implementation ShowTableViewDelegate

#pragma mark -
#pragma mark UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [_parentViewController.showsArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    ABLoggerMethod();
    static NSString *CellIdentifier = @"mShowCell";
    static BOOL nibsRegistered = NO;
    if (!nibsRegistered) {
        UINib *nib = [UINib nibWithNibName:@"ShowTableViewCell" bundle:nil];
        [tableView registerNib:nib forCellReuseIdentifier:CellIdentifier];
        nibsRegistered = YES;
    }
    
    ShowTableViewCell * cell = (ShowTableViewCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [self createNewMocieCell];
    }
    
    [self configureCell:cell atIndexPath:indexPath];
    
    return cell;
}

- (void)configureCell:(ShowTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    
    SShow *show = [_parentViewController.showsArray objectAtIndex:indexPath.row];
    [cell.show_imageView setImageWithURL:[NSURL URLWithString:[show webImg]]
                         placeholderImage:[UIImage imageNamed:@"placeholder"] options:SDWebImageRetryFailed];
    cell.show_name.text = show.name;
    cell.show_rating.text = [NSString stringWithFormat:@"%@ : %0.1f (%d 万人)",show.ratingfrom,[show.rating floatValue],[show.ratingpeople intValue]/10000];
    cell.show_price.text =  [NSString stringWithFormat:@"%@  %@   %@元起",show.date,show.where,[[show.price objectAtIndex:0] stringValue]];
    
}

-(ShowTableViewCell *)createNewMocieCell{
    ABLoggerMethod();
     ShowTableViewCell * cell = [[[NSBundle mainBundle] loadNibNamed:@"ShowTableViewCell" owner:self options:nil] objectAtIndex:0];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    //    cell.selectedBackgroundView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"history_menu_cell_background"]] autorelease];
    return cell;
}

#pragma mark -
#pragma mark UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 80.0f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    ShowDetailViewController *showDetailController = [[ShowDetailViewController alloc] initWithNibName:(iPhone5?@"ShowDetailViewController_5":@"ShowDetailViewController") bundle:nil];
    [_parentViewController.navigationController pushViewController:showDetailController animated:YES];
    [showDetailController release];
}


@end
