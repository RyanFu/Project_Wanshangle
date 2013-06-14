//
//  MovieListTableViewDelegate.m
//  WanShangLe
//
//  Created by stephenliu on 13-6-8.
//  Copyright (c) 2013年 stephenliu. All rights reserved.
//
#import "CinemaMovieTableViewDelegate.h"
#import "ScheduleTableViewCell.h"
#import "CinemaMovieViewController.h"
#import "BuyInfoViewController.h"
#import "MSchedule.h"

@implementation CinemaMovieTableViewDelegate

#pragma mark -
#pragma mark UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [_parentViewController.schedulesArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *CellIdentifier = @"mScheduleCell";
    static BOOL nibsRegistered = NO;
    if (!nibsRegistered) {
        UINib *nib = [UINib nibWithNibName:@"ScheduleTableViewCell" bundle:nil];
        [tableView registerNib:nib forCellReuseIdentifier:CellIdentifier];
        nibsRegistered = YES;
    }
    
    ScheduleTableViewCell * cell = (ScheduleTableViewCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        ABLoggerMethod();
        cell = [self createNewMocieCell];
    }
    
    [self configureCell:cell atIndexPath:indexPath];
    
    return cell;
}

- (void)configureCell:(ScheduleTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    cell.schedule_time.text = [_parentViewController.schedulesArray objectAtIndex:indexPath.row];
}

-(ScheduleTableViewCell *)createNewMocieCell{
    ABLoggerMethod();
     ScheduleTableViewCell * cell = [[[NSBundle mainBundle] loadNibNamed:@"ScheduleTableViewCell" owner:self options:nil] objectAtIndex:0];
    [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
    cell.selectionStyle = UITableViewCellSelectionStyleBlue;
    //    cell.selectedBackgroundView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"history_menu_cell_background"]] autorelease];
    return cell;
}

#pragma mark -
#pragma mark UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 44;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    BuyInfoViewController *buyInfoController = [[BuyInfoViewController alloc] initWithNibName:(iPhone5?@"BuyInfoViewController_5":@"BuyInfoViewController") bundle:nil];
    buyInfoController.schedule = [_parentViewController.schedulesArray objectAtIndex:indexPath.row];
    buyInfoController.mMovie = _parentViewController.mMovie;
    buyInfoController.mCinema = _parentViewController.mCinema;
    [_parentViewController.navigationController pushViewController:buyInfoController animated:YES];
    [buyInfoController release];
}


@end
