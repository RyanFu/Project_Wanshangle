//
//  MovieListTableViewDelegate.m
//  WanShangLe
//
//  Created by stephenliu on 13-6-8.
//  Copyright (c) 2013年 stephenliu. All rights reserved.
//
#import "BarNearByListTableViewDelegate.h"
#import "BarNearByViewController.h"
#import "BarDetailViewController.h"
#import "BarTableViewCell.h"
#import "BBar.h"

#define TagTuan 500

@interface BarNearByListTableViewDelegate(){
    
}
@end

@implementation BarNearByListTableViewDelegate

#pragma mark -
#pragma mark UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if ([_mArray count]<=0) {//每次刷新表的时候检测是否有数据
        _refreshTailerView.hidden = YES;
    }else{
         _refreshTailerView.hidden = NO;
    }
    
  return [_mArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  return [self barCelltableView:tableView cellForRowAtIndexPath:indexPath];
}

#pragma mark -
#pragma mark 正常模式Cell
- (UITableViewCell *)barCelltableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    ABLoggerMethod();
    static NSString *CellIdentifier = @"mBarCell";

    BarTableViewCell *cell = (BarTableViewCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [self createNewMocieCell];
    }
    
    if ([_mArray count]<=0 || _mArray==nil){
        return cell;
    }
    
    [self configCell:cell cellForRowAtIndexPath:indexPath];
    
    ABLoggerDebug(@"返回cell");
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
    cell.bar_distance.hidden = NO;
    cell.bar_image_location.hidden = NO;
    abar = [_mArray objectAtIndex:row];

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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
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
