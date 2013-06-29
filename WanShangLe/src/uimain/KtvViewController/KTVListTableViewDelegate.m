//
//  MovieListTableViewDelegate.m
//  WanShangLe
//
//  Created by stephenliu on 13-6-8.
//  Copyright (c) 2013年 stephenliu. All rights reserved.
//
#import "KTVListTableViewDelegate.h"
#import "KtvViewController.h"
#import "KTVTableViewCell.h"
#import "KKTV.h"

@implementation KTVListTableViewDelegate

#pragma mark -
#pragma mark UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [_parentViewController.ktvsArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    ABLoggerMethod();
    static NSString *CellIdentifier = @"mKTVCell";
    static BOOL nibsRegistered = NO;
    if (!nibsRegistered) {
        UINib *nib = [UINib nibWithNibName:@"KTVTableViewCell" bundle:nil];
        [tableView registerNib:nib forCellReuseIdentifier:CellIdentifier];
        nibsRegistered = YES;
    }
    
    KTVTableViewCell * cell = (KTVTableViewCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [self createNewMocieCell];
    }
    
    [self configureCell:cell atIndexPath:indexPath];
    
    return cell;
}

- (void)configureCell:(KTVTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    
    KKTV *ktv = [_parentViewController.ktvsArray objectAtIndex:indexPath.row];
    cell.ktv_name.text = ktv.name;
    cell.ktv_discounts.text = [NSString stringWithFormat:@"共有 %d 个优惠和团购",[ktv.discounts intValue]];
    cell.ktv_address.text = ktv.address;
    cell.ktv_price.text = [NSString stringWithFormat:@"%@ 元起",[ktv.price stringValue]];
    
}

-(KTVTableViewCell *)createNewMocieCell{
    ABLoggerMethod();
     KTVTableViewCell * cell = [[[NSBundle mainBundle] loadNibNamed:@"KTVTableViewCell" owner:self options:nil] objectAtIndex:0];
    [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
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
    
//    _parentViewController.cinemaViewController.isMovie_Cinema = YES;
//    _parentViewController.cinemaViewController.mMovie = [_parentViewController.moviesArray objectAtIndex:indexPath.row];
//    [_parentViewController.navigationController pushViewController:_parentViewController.cinemaViewController animated:YES];
}


@end
