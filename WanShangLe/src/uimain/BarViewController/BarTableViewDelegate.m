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

@interface BarTableViewDelegate()
@property(nonatomic,assign) MMFilterBarListType barFilterType;
@end

@implementation BarTableViewDelegate
@synthesize mTableView = _mTableView;

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
    cell.bar_popular.text = [NSString stringWithFormat:@"%d分",[bar.popular intValue]];
    cell.bar_address.text = bar.address;
    cell.bar_date.text = bar.date;

    BOOL isHidden = !(_barFilterType==MMFilterBarListTypeNearby);
    cell.bar_distance.hidden = isHidden;
    cell.bar_image_location.hidden = isHidden;

}

-(BarTableViewCell *)createNewMocieCell{
    ABLoggerMethod();
     BarTableViewCell *cell = [[[NSBundle mainBundle] loadNibNamed:@"BarTableViewCell" owner:self options:nil] objectAtIndex:0];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    //    cell.selectedBackgroundView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"history_menu_cell_background"]] autorelease];
    return cell;
}

#pragma mark -
#pragma mark UITableViewDelegate

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    
    if (_barFilterType==MMFilterBarListTypeTime) {
        NSArray *mArray = _parentViewController.barsArray;
        UILabel *headerView = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 320, 30)];
        headerView.backgroundColor = [UIColor colorWithWhite:0.829 alpha:1.000];
        
        NSString *name = [[mArray objectAtIndex:section] objectForKey:@"name"];
        NSArray *list = [[mArray objectAtIndex:section] objectForKey:@"list"];
        headerView.text = [NSString stringWithFormat:@"%@  (共%d家)",name,[list count]];
        
        return [headerView autorelease];
    }
    
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 80.0f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
//    ShowDetailViewController *showDetailController = [[ShowDetailViewController alloc] initWithNibName:(iPhone5?@"ShowDetailViewController_5":@"ShowDetailViewController") bundle:nil];
//    [_parentViewController.navigationController pushViewController:showDetailController animated:YES];
//    [showDetailController release];
}

#pragma mark -
#pragma mark Data Source Loading / Reloading Methods

- (void)reloadTableViewDataSource{
    
    //    [_model reload];
	_reloading = YES;
	
}

- (void)doneReLoadingTableViewData
{
	//  model should call this when its done loading
	_reloading = NO;
	[_refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:_mTableView];
}

#pragma mark -
#pragma mark UIScrollViewDelegate Methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    [_refreshHeaderView egoRefreshScrollViewDidScroll:scrollView];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
	[_refreshHeaderView egoRefreshScrollViewDidEndDragging:scrollView];
}


#pragma mark -
#pragma mark EGORefreshTableHeaderDelegate Methods

- (void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView*)view{
	if (view.tag == EGOHeaderView) {
        [self reloadTableViewDataSource];
        [self performSelector:@selector(doneReLoadingTableViewData) withObject:nil afterDelay:3.0];
    }
}

- (BOOL)egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView*)view{
	return _reloading; // should return if data source model is reloading
}

- (NSDate*)egoRefreshTableHeaderDataSourceLastUpdated:(EGORefreshTableHeaderView*)view{
	
	return [NSDate date]; // should return date data source was last changed
	
}

@end
