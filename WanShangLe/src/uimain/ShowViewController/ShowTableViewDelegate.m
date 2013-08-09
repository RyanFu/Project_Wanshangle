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
@synthesize mTableView = _mTableView;

#pragma mark -
#pragma mark UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    if ([_mArray count]<=0 || _mArray==nil ||_parentViewController.isDone) {//每次刷新表的时候检测是否有数据
        _refreshTailerView.hidden = YES;
    }else{
        _refreshTailerView.hidden = NO;
    }

    return [_mArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    ABLoggerMethod();
    static NSString *CellIdentifier = @"mShowCell";
    
    ShowTableViewCell * cell = (ShowTableViewCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [self createNewMocieCell];
    }
    
    if ([_mArray count]<=0 || _mArray==nil) {
        return cell;
    }
    
    [self configureCell:cell atIndexPath:indexPath];
    
    return cell;
}

- (void)configureCell:(ShowTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    
    SShow *show = [_mArray objectAtIndex:indexPath.row];
    [cell.show_imageView setImageWithURL:[NSURL URLWithString:[show webImg]]
                         placeholderImage:[UIImage imageNamed:@"show_placeholder_S@2x"] options:SDWebImageRetryFailed];
    cell.show_name.text = show.name;
    cell.show_imageView.frame = CGRectMake(4, 10, 65, 87);
    
    int ratingPeople = [show.ratingpeople intValue];
    NSString *scopeStr = @"人";
    if (ratingPeople >10000) {
        ratingPeople = ratingPeople/10000;
        scopeStr = @"万人";
    }
    
    cell.show_rating.text = [NSString stringWithFormat:@"%@评分: %@ (%d%@)",show.ratingfrom,show.rating,ratingPeople,scopeStr];
    cell.show_price.text =  [NSString stringWithFormat:@"%@元",show.price];
    cell.theatre_name.text = show.theatrename;
    cell.show_time.text = [[DataBaseManager sharedInstance] getYMDFromDate:show.beginTime];
    
}

-(ShowTableViewCell *)createNewMocieCell{
    ABLoggerMethod();
     ShowTableViewCell * cell = [[[NSBundle mainBundle] loadNibNamed:@"ShowTableViewCell" owner:self options:nil] objectAtIndex:0];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.accessoryType = UITableViewCellAccessoryNone;
    
    cell.show_imageView = [[[UIImageView alloc] init] autorelease];
    [cell.contentView addSubview:cell.show_imageView];
    
    return cell;
}

#pragma mark -
#pragma mark UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 108.0f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    SShow *aShow = [_mArray objectAtIndex:indexPath.row];
    ShowDetailViewController *showDetailController = [[ShowDetailViewController alloc] initWithNibName:(iPhone5?@"ShowDetailViewController_5":@"ShowDetailViewController") bundle:nil];
    showDetailController.mShow = aShow;
    [_parentViewController.navigationController pushViewController:showDetailController animated:YES];
    [showDetailController release];
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
    
    if (!_refreshHeaderView.hidden) {
        [_refreshHeaderView egoRefreshScrollViewDidScroll:scrollView];
    }
    if(!_refreshTailerView.hidden){
        [_refreshTailerView egoRefreshScrollViewDidScroll:scrollView];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    if (!_refreshHeaderView.hidden) {
        [_refreshHeaderView egoRefreshScrollViewDidEndDragging:scrollView];
    }
    if(!_refreshTailerView.hidden){
        [_refreshTailerView egoRefreshScrollViewDidEndDragging:scrollView];
    }
}


#pragma mark -
#pragma mark EGORefreshTableHeaderDelegate Methods

- (void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView*)view{
    
    if (view.tag == EGOHeaderView && !view.hidden) {
        [self reloadTableViewDataSource];
    } else if(view.tag == EGOBottomView && !view.hidden){
        [self loadMoreTableViewDataSource];
    }
    
}

- (BOOL)egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView*)view{
    if (view.hidden) {
        return NO;
    }
    
	return _reloading; // should return if data source model is reloading
}

- (NSDate*)egoRefreshTableHeaderDataSourceLastUpdated:(EGORefreshTableHeaderView*)view{
	
	return [[DataBaseManager sharedInstance] date]; // should return date data source was last changed
}

@end
