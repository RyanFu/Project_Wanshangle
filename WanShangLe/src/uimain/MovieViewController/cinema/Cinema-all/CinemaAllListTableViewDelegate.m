//
//  MovieListTableViewDelegate.m
//  WanShangLe
//
//  Created by stephenliu on 13-6-8.
//  Copyright (c) 2013年 stephenliu. All rights reserved.
//
#import "CinemaAllListTableViewDelegate.h"
#import "CinemaAllViewController.h"
#import "CinemaTableViewCell.h"
#import "MCinema.h"

#import "ScheduleViewController.h"
#import "CinemaMovieViewController.h"
#import "CinemaViewController.h"

#define TagTuan 500

@interface CinemaAllListTableViewDelegate(){
    
}
@end

@implementation CinemaAllListTableViewDelegate

#pragma mark -
#pragma mark UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if ([_parentViewController.searchBar.text length] <= 0) {//正常模式
        return [_mArray count];
    }
    //搜索模式
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    if ([_parentViewController.searchBar.text length] <= 0) {//正常模式
        
        _refreshTailerView.frame = CGRectMake(0.0f, _mTableView.contentSize.height, _mTableView.frame.size.width, _mTableView.bounds.size.height);
        if (_mArray==nil || [_mArray count]<=0) {
            _refreshTailerView.hidden = YES;
        }else{
            _refreshTailerView.hidden = NO;
        }
        
        return [[[_mArray objectAtIndex:section] objectForKey:@"list"] count];
    }
    
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([_parentViewController.searchBar.text length] <= 0) {//正常模式
        
        return [self cinemaCelltableView:tableView cellForRowAtIndexPath:indexPath];
    }
    
    return [self cinemaSearchtableView:tableView cellForRowAtIndexPath:indexPath];
}

#pragma mark -
#pragma mark 正常模式Cell
- (UITableViewCell *)cinemaCelltableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *CellIdentifier = @"mCinemaCell";
    
    CinemaTableViewCell * cell = (CinemaTableViewCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [self createNewMocieCell];
    }
    
    if ([_mArray count]<=0 || _mArray==nil) {
        return cell;
    }
    
    [self configCell:cell cellForRowAtIndexPath:indexPath];
    
    return cell;
}

-(CinemaTableViewCell *)createNewMocieCell{
    ABLoggerMethod();
    CinemaTableViewCell * cell = [[[NSBundle mainBundle] loadNibNamed:@"CinemaTableViewCell" owner:self options:nil] objectAtIndex:0];
    [cell setAccessoryType:UITableViewCellAccessoryNone];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

- (void)configCell:(CinemaTableViewCell *)cell cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSArray *list = [[_mArray objectAtIndex:indexPath.section] objectForKey:@"list"];
    MCinema *cinema = [list objectAtIndex:indexPath.row];
    cell.cinema_name.text = cinema.name;
    cell.cinema_address.text = cinema.address;
    
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:4];
    if ([cinema.zhekou boolValue]) {
        [array addObject:cell.cinema_image_zhekou];
    }
    if ([cinema.juan boolValue]) {
        [array addObject:cell.cinema_image_juan];
    }
    if ([cinema.seat boolValue]) {
        [array addObject:cell.cinema_image_seat];
    }
    if ([cinema.tuan boolValue]) {
        [array addObject:cell.cinema_image_tuan];
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
    ABLoggerInfo(@"view frame ===== %d",width);
    [cell addSubview:view];
    [view release];
    
    int nameSize_width = (cell.bounds.size.width-width-cell.cinema_name.frame.origin.x);
    ABLoggerDebug(@"cinema.name = %@",cinema.name);
    
    CGSize nameSize = [cinema.name sizeWithFont:cell.cinema_name.font
                              constrainedToSize:CGSizeMake(nameSize_width,MAXFLOAT)];
    
    CGRect cell_newFrame = cell.cinema_name.frame;
    cell_newFrame.size.width = nameSize.width;
    cell.cinema_name.frame = cell_newFrame;
    
    int view_x = cell.cinema_name.frame.origin.x+cell.cinema_name.frame.size.width +10;
    [view setFrame:CGRectMake(view_x, 0, width, 15)];
    CGPoint newCenter = view.center;
    newCenter.y = cell.cinema_name.center.y;
    view.center = newCenter;
    cell.cinema_name.text = cinema.name;
}

#pragma mark -
#pragma mark 搜索Cell
- (UITableViewCell *)cinemaSearchtableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *indentifier = @"CinemaCellSearch";
    
    UITableViewCell *cell = (UITableViewCell*)[tableView dequeueReusableCellWithIdentifier:indentifier];
    
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:indentifier] autorelease];
		cell.selectionStyle=UITableViewCellSelectionStyleNone;
	}
    return cell;
}

#pragma mark -
#pragma mark UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if ([_parentViewController.searchBar.text length] <= 0) {//正常模式
        return 80.0f;
    }
    
    return 44.0f;
}

#pragma mark -
#pragma mark UITableViewDelegate
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    
    if ([_parentViewController.searchBar.text length] <= 0) {//正常模式
        UILabel *headerView = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 320, 30)];
        headerView.backgroundColor = [UIColor colorWithWhite:0.829 alpha:1.000];
        
        NSString *name = [[_mArray objectAtIndex:section] objectForKey:@"name"];
        NSArray *list = [[_mArray objectAtIndex:section] objectForKey:@"list"];
        headerView.text = [NSString stringWithFormat:@"%@  (共%d家)",name,[list count]];
        
        return [headerView autorelease];

    }
    //搜索模式
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    
    if ([_parentViewController.searchBar.text length] <= 0) {//正常模式
        return 20.0f;
    }
    //搜索模式
    return 0.0f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if ([_parentViewController.searchBar.text length] <= 0) {//正常模式
        
        NSDictionary *dic = [_mArray objectAtIndex:indexPath.section];
        NSArray *list = [dic objectForKey:@"list"];
        MCinema *mCinema = [list objectAtIndex:indexPath.row];
        MMovie *mMovie = [_parentViewController.mParentController mMovie];
        
        BOOL isMoviePanel = [CacheManager sharedInstance].isMoviePanel;
        UINavigationController *rootNavigationController = [CacheManager sharedInstance].rootNavController;
        
        if (isMoviePanel) {
            ScheduleViewController *scheduleViewController = [[ScheduleViewController alloc]
                                                              initWithNibName:(iPhone5?@"ScheduleViewController_5":@"ScheduleViewController")
                                                              bundle:nil];
            scheduleViewController.mCinema = mCinema;
            scheduleViewController.mMovie = mMovie;
            [rootNavigationController pushViewController:scheduleViewController animated:YES];
            [scheduleViewController release];
        }else{
            CinemaMovieViewController *cinemaMovieController = [[CinemaMovieViewController alloc]
                                                                initWithNibName:(iPhone5?@"CinemaMovieViewController_5":@"CinemaMovieViewController")
                                                                bundle:nil];
            cinemaMovieController.mCinema = mCinema;
            cinemaMovieController.mMovie = mMovie;
            [rootNavigationController pushViewController:cinemaMovieController animated:YES];
            [cinemaMovieController release];
        }
        
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        
    } else {//搜索模式
        
    }
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
    if(!_refreshHeaderView.hidden){
        [_refreshTailerView egoRefreshScrollViewDidScroll:scrollView];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    if (!_refreshHeaderView.hidden) {
        [_refreshHeaderView egoRefreshScrollViewDidEndDragging:scrollView];
    }
    if(!_refreshHeaderView.hidden){
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
	
	return [NSDate date]; // should return date data source was last changed
}

#pragma mark -
#pragma mark UISearchBarDelegate methods
- (void)scrollTableViewToSearchBarAnimated:(BOOL)animated
{
    [self.mTableView setContentOffset:CGPointMake(0, 44) animated:animated];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *) searchBar{
    ABLoggerWarn(@"");
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    ABLoggerWarn(@"");
    [_mTableView resignFirstResponder];
    [self scrollTableViewToSearchBarAnimated:YES];
}


- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar{
    ABLoggerWarn(@"");
    [_parentViewController beginSearch];
    //    [self getAllSearchktvData];
    
    _parentViewController.searchBar.showsScopeBar = YES;
    [_parentViewController.searchBar sizeToFit];
    [_parentViewController.searchBar setShowsCancelButton:YES animated:YES];
    
    for(id cc in [_parentViewController.searchBar subviews])
    {
        if([cc isKindOfClass:[UIButton class]])
        {
            UIButton *btn = (UIButton *)cc;
            [btn setTitle:@""  forState:UIControlStateNormal];
            //            [btn setBackgroundColor:[UIColor colorWithWhite:0.800 alpha:1.000]];
            [btn setBackgroundImage:[UIImage imageNamed:@"btn_search_cancel_n@2x"] forState:UIControlStateNormal];
            [btn setBackgroundImage:[UIImage imageNamed:@"btn_search_cancel_f@2x"] forState:UIControlStateHighlighted];
        }
    }
    [[_parentViewController.searchBar viewWithTag:100] removeFromSuperview];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bg_searchBar@2x"]];
    imageView.frame = CGRectMake(0, 0, 320, 44);
    imageView.tag = 100;
    [_parentViewController.searchBar insertSubview:imageView atIndex:0];
    [imageView release];
    
    return YES;
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar{
    ABLoggerWarn(@"");
}

- (void)searchDisplayControllerDidEndSearch:(UISearchDisplayController *)controller{
    ABLoggerWarn(@"");
    [self cleanUpSearchBar:_parentViewController.searchBar];
}

- (void)cleanUpSearchBar:(UISearchBar *)searchBar{
    [[_parentViewController.searchBar viewWithTag:100] removeFromSuperview];
    
    [self scrollTableViewToSearchBarAnimated:YES];
    [_parentViewController endSearch];
//    [_mTableView resignFirstResponder];
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
//    [[SearchCoreManager share] Search:searchString searchArray:nil nameMatch:_searchByName phoneMatch:_searchByPhone];
//    [_mTableView reloadData];
    
    return YES;
}

- (void)searchDisplayController:(UISearchDisplayController *)controller didShowSearchResultsTableView:(UITableView *)tableView{
    ABLoggerDebug(@"subViews = %d",[controller.searchResultsTableView.subviews count]);
    for(UIView *subview in controller.searchResultsTableView.subviews) {
        
        if([subview isKindOfClass:[UILabel class]]) {
            [(UILabel*)subview setText:@"无结果"];
        }
    }
}
@end
