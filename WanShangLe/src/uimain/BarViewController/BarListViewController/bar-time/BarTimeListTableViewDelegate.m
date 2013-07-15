//
//  MovieListTableViewDelegate.m
//  WanShangLe
//
//  Created by stephenliu on 13-6-8.
//  Copyright (c) 2013年 stephenliu. All rights reserved.
//
#import "BarTimeListTableViewDelegate.h"
#import "BarTimeViewController.h"
#import "BarDetailViewController.h"
#import "BarTableViewCell.h"
#import "BBar.h"

#define TagTuan 500

@interface BarTimeListTableViewDelegate(){
    
}
@end

@implementation BarTimeListTableViewDelegate

#pragma mark -
#pragma mark UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    
    return [_mArray count];
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    if ([_mArray count]<=0) {//每次刷新表的时候检测是否有数据
        _refreshTailerView.hidden = YES;
    }else{
        _refreshTailerView.hidden = NO;
    }
    
    _refreshTailerView.frame = CGRectMake(0.0f, _mTableView.contentSize.height, _mTableView.frame.size.width, _mTableView.bounds.size.height);
    
    return [[[_mArray objectAtIndex:section] objectForKey:@"list"] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if ([_mArray count]<=0 || _mArray==nil) {
        return nil;
    }
    
    return [self barCelltableView:tableView cellForRowAtIndexPath:indexPath];
    
    
}

#pragma mark -
#pragma mark 正常模式Cell
- (UITableViewCell *)barCelltableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *CellIdentifier = @"mBarCell";
    
    BarTableViewCell * cell = (BarTableViewCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [self createNewMocieCell];
    }
    
    [self configCell:cell cellForRowAtIndexPath:indexPath];
    
    return cell;
}

-(BarTableViewCell *)createNewMocieCell{
    ABLoggerMethod();
    BarTableViewCell * cell = [[[NSBundle mainBundle] loadNibNamed:@"BarTableViewCell" owner:self options:nil] objectAtIndex:0];
    [cell setAccessoryType:UITableViewCellAccessoryNone];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

- (void)configCell:(BarTableViewCell *)cell cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    BBar *abar = nil;
    int row = indexPath.row;
    
    cell.bar_distance.hidden = YES;
    cell.bar_image_location.hidden = YES;
    
    NSArray *list = [[_mArray objectAtIndex:indexPath.section] objectForKey:@"list"];
    abar = [list objectAtIndex:row];
    
    [self configureCell:cell withObject:abar];
}

- (void)configureCell:(BarTableViewCell *)cell withObject:(BBar *)abar {
    
    cell.bar_event_name.text = abar.name;
    cell.bar_name.text = abar.barName;
    cell.bar_date.text = abar.begintime;
    cell.bar_popular.text = abar.popular;
    
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:4];
    if ([abar.zhekou boolValue]) {
        [array addObject:cell.bar_image_zhekou];
    }
    if ([abar.juan boolValue]) {
        [array addObject:cell.bar_image_juan];
    }
    if ([abar.seat boolValue]) {
        [array addObject:cell.bar_image_seat];
    }
    if ([abar.tuan boolValue]) {
        [array addObject:cell.bar_image_tuan];
    }
    
    [[cell viewWithTag:TagTuan] removeFromSuperview];
    if ([array count]<=0) {
        return;
    }
    
    int twidth = 0;
    UIView *view = [[UIView alloc] init];
    for (int i=0;i<[array count];i++) {
        
        UIView *tview = [array objectAtIndex:i];
        CGRect tframe = tview.frame;
        
        tframe.origin.x = twidth;
        twidth += tframe.size.width + 5;
        
        tview.frame = tframe;
        [view addSubview:tview];
    }
    
    CGRect tFrame = [(UIView *)[array lastObject] frame];
    int width = (int)tFrame.origin.x+ tFrame.size.width;
    [cell addSubview:view];
    view.tag = TagTuan;
    [view release];
    
    int nameSize_width = (cell.bounds.size.width-width-cell.bar_name.frame.origin.x);
    
    CGSize nameSize = [abar.name sizeWithFont:cell.bar_name.font
                            constrainedToSize:CGSizeMake(nameSize_width,MAXFLOAT)];
    
    CGRect cell_newFrame = cell.bar_name.frame;
    cell_newFrame.size.width = nameSize.width;
    cell.bar_name.frame = cell_newFrame;
    
    int view_x = cell.bar_name.frame.origin.x+cell.bar_name.frame.size.width +10;
    [view setFrame:CGRectMake(view_x, 0, width, 15)];
    CGPoint newCenter = view.center;
    newCenter.y = cell.bar_name.center.y;
    view.center = newCenter;
}

#pragma mark -
#pragma mark UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 80;
}

#pragma mark -
#pragma mark UITableViewDelegate
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    
    UILabel *headerView = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 320, 30)];
    headerView.backgroundColor = [UIColor colorWithWhite:0.829 alpha:1.000];
    
    NSString *name = [[_mArray objectAtIndex:section] objectForKey:@"name"];
    NSArray *list = [[_mArray objectAtIndex:section] objectForKey:@"list"];
    headerView.text = [NSString stringWithFormat:@"%@  (共%d家)",name,[list count]];
    
    return [headerView autorelease];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    
    return 20.0f;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    //iPhone5?@"barBuyViewController_5":@"barBuyViewController"
    BarDetailViewController *barBuyController = [[BarDetailViewController alloc] initWithNibName:@"BarDetailViewController" bundle:nil];
}

#pragma mark -
#pragma mark Data Source Loading / Reloading Methods
/*加载新数据*/
- (void)reloadTableViewDataSource{
	_reloading = YES;
    [_parentViewController loadNewData];
}

/*加载更多*/
- (void)loadMoreTableViewDataSource {
    _reloading = YES;
    [_parentViewController loadMoreData];
}

- (void)doneReLoadingTableViewData
{
	//  model should call this when its done loading
	_reloading = NO;
    [_refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:_mTableView];
    [_mTableView reloadData];
}

- (void)doneLoadingTableViewData
{
    [_refreshTailerView egoRefreshScrollViewDataSourceDidFinishedLoading:_mTableView];
    [_mTableView reloadData];
    _refreshTailerView.frame = CGRectMake(0.0f, _mTableView.contentSize.height, _mTableView.frame.size.width, _mTableView.bounds.size.height);
    _reloading = NO;
}

#pragma mark -
#pragma mark UIScrollViewDelegate Methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    [_refreshHeaderView egoRefreshScrollViewDidScroll:scrollView];
    [_refreshTailerView egoRefreshScrollViewDidScroll:scrollView];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
	[_refreshHeaderView egoRefreshScrollViewDidEndDragging:scrollView];
    [_refreshTailerView egoRefreshScrollViewDidEndDragging:scrollView];
}


#pragma mark -
#pragma mark EGORefreshTableHeaderDelegate Methods

- (void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView*)view{
    
    if (view.tag == EGOHeaderView) {
        [self reloadTableViewDataSource];
    } else {
        [self loadMoreTableViewDataSource];
    }
    
}

- (BOOL)egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView*)view{
	return _reloading; // should return if data source model is reloading
}

- (NSDate*)egoRefreshTableHeaderDataSourceLastUpdated:(EGORefreshTableHeaderView*)view{
	
	return [NSDate date]; // should return date data source was last changed
}
@end
