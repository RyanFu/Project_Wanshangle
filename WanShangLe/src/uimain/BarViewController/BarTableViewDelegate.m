//
//  MovieListTableViewDelegate.m
//  WanShangLe
//
//  Created by stephenliu on 13-6-8.
//  Copyright (c) 2013年 stephenliu. All rights reserved.
//
#import "BarTableViewDelegate.h"
#import "BarViewController.h"
#import "BarTableViewCell.h"
#import "BBar.h"

@implementation BarTableViewDelegate

#pragma mark -
#pragma mark UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [_parentViewController.barsArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    ABLoggerMethod();
    static NSString *CellIdentifier = @"mBarCell";
    static BOOL nibsRegistered = NO;
    if (!nibsRegistered) {
        UINib *nib = [UINib nibWithNibName:@"BarTableViewCell" bundle:nil];
        [tableView registerNib:nib forCellReuseIdentifier:CellIdentifier];
        nibsRegistered = YES;
    }
    
    BarTableViewCell * cell = (BarTableViewCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [self createNewMocieCell];
    }
    
    [self configureCell:cell atIndexPath:indexPath];
    
    return cell;
}

- (void)configureCell:(BarTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    
    BBar *bar = [_parentViewController.barsArray objectAtIndex:indexPath.row];
    cell.bar_name.text = bar.name;
    cell.bar_popular.text = [NSString stringWithFormat:@"%d 人气",[bar.popular intValue]];
    cell.bar_address.text = bar.address;
    cell.bar_date.text = bar.date;
    
}

-(BarTableViewCell *)createNewMocieCell{
    ABLoggerMethod();
     BarTableViewCell * cell = [[[NSBundle mainBundle] loadNibNamed:@"BarTableViewCell" owner:self options:nil] objectAtIndex:0];
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
//    ShowDetailViewController *showDetailController = [[ShowDetailViewController alloc] initWithNibName:(iPhone5?@"ShowDetailViewController_5":@"ShowDetailViewController") bundle:nil];
//    [_parentViewController.navigationController pushViewController:showDetailController animated:YES];
//    [showDetailController release];
}


@end
