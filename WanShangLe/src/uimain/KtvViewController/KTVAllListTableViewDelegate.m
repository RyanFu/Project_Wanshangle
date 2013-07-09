//
//  MovieListTableViewDelegate.m
//  WanShangLe
//
//  Created by stephenliu on 13-6-8.
//  Copyright (c) 2013年 stephenliu. All rights reserved.
//
#import "KTVAllListTableViewDelegate.h"
#import "KTVBuyViewController.h"
#import "KtvViewController.h"
#import "KTVTableViewCell.h"
#import "KKTV.h"

#define TagTuan 500

@interface KTVAllListTableViewDelegate(){
    
}
@property(nonatomic,readonly) NSFilterKTVListType filterKTVListType;
@end

@implementation KTVAllListTableViewDelegate

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
        return [[[_mArray objectAtIndex:section] objectForKey:@"list"] count];
    }
    
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([_parentViewController.searchBar.text length] <= 0) {//正常模式
        
        if ([_mArray count]<=0 || _mArray==nil) {
            return nil;
        }
        
        return [self ktvCelltableView:tableView cellForRowAtIndexPath:indexPath];
    }
    
    return [self ktvSearchtableView:tableView cellForRowAtIndexPath:indexPath];
}

#pragma mark -
#pragma mark 正常模式Cell
- (UITableViewCell *)ktvCelltableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    ABLoggerMethod();
    
    static NSString *CellIdentifier = @"MKTVCellIdentifier";
    
    KTVTableViewCell * cell = (KTVTableViewCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [self createNewMocieCell];
    }
    
    [self configCell:cell cellForRowAtIndexPath:indexPath];
    
    return cell;
}

-(KTVTableViewCell *)createNewMocieCell{
    ABLoggerMethod();
    KTVTableViewCell * cell = [[[NSBundle mainBundle] loadNibNamed:@"KTVTableViewCell" owner:self options:nil] objectAtIndex:0];
    [cell setAccessoryType:UITableViewCellAccessoryNone];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

- (void)configCell:(KTVTableViewCell *)cell cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    KKTV *aKTV = nil;
    int row = indexPath.row;
    
    cell.ktv_distance.hidden = YES;
    cell.ktv_image_location.hidden = YES;
    
    NSArray *list = [[_mArray objectAtIndex:indexPath.section] objectForKey:@"list"];
    aKTV = [list objectAtIndex:row];
    
    [self configureCell:cell withObject:aKTV];
}

- (void)configureCell:(KTVTableViewCell *)cell withObject:(KKTV *)aKTV {
    
    cell.ktv_name.text = aKTV.name;
    cell.ktv_address.text = aKTV.address;
    
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:4];
    if ([aKTV.zhekou boolValue]) {
        [array addObject:cell.ktv_image_zhekou];
    }
    if ([aKTV.juan boolValue]) {
        [array addObject:cell.ktv_image_juan];
    }
    if ([aKTV.seat boolValue]) {
        [array addObject:cell.ktv_image_seat];
    }
    if ([aKTV.tuan boolValue]) {
        [array addObject:cell.ktv_image_tuan];
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
    
    int nameSize_width = (cell.bounds.size.width-width-cell.ktv_name.frame.origin.x);
    
    CGSize nameSize = [aKTV.name sizeWithFont:cell.ktv_name.font
                            constrainedToSize:CGSizeMake(nameSize_width,MAXFLOAT)];
    
    CGRect cell_newFrame = cell.ktv_name.frame;
    cell_newFrame.size.width = nameSize.width;
    cell.ktv_name.frame = cell_newFrame;
    
    int view_x = cell.ktv_name.frame.origin.x+cell.ktv_name.frame.size.width +10;
    [view setFrame:CGRectMake(view_x, 0, width, 15)];
    CGPoint newCenter = view.center;
    newCenter.y = cell.ktv_name.center.y;
    view.center = newCenter;
}

#pragma mark -
#pragma mark 搜索Cell
- (UITableViewCell *)ktvSearchtableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *indentifier = @"KTVCellSearch";
    
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
    return 70.0f;
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
    
    KTVBuyViewController *ktvBuyController = [[KTVBuyViewController alloc] initWithNibName:iPhone5?@"KTVBuyViewController_5":@"KTVBuyViewController" bundle:nil];
    
    KKTV *aKTV = nil;
    int row = indexPath.row;
    
    NSArray *list = [[_mArray objectAtIndex:indexPath.section] objectForKey:@"list"];
    aKTV = [list objectAtIndex:row];
    
    ktvBuyController.mKTV = aKTV;
    [_parentViewController.navigationController pushViewController:ktvBuyController animated:YES];
    [ktvBuyController release];
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
    [_mTableView resignFirstResponder];
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    //    [[SearchCoreManager share] Search:searchString searchArray:nil nameMatch:_searchByName phoneMatch:_searchByPhone];
    
    [_mTableView reloadData];
    
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
