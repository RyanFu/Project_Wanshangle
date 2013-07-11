//
//  MovieListTableViewDelegate.m
//  WanShangLe
//
//  Created by stephenliu on 13-6-8.
//  Copyright (c) 2013年 stephenliu. All rights reserved.
//
#import "KTVAllListManagerDelegate.h"
#import "KtvManagerViewController.h"
#import "KTVManagerCell.h"
#import "KKTV.h"

#define TagTuan 500

@interface KTVAllListManagerDelegate(){
    
}
@end

@implementation KTVAllListManagerDelegate

#pragma mark -
#pragma mark UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if ([_parentViewController.searchBar.text length] <= 0) {//正常模式
        return [_mArray count]+1;
    }
    //搜索模式
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    if ([_parentViewController.searchBar.text length] <= 0) {//正常模式
        if (section==0) {
            return [_mFavoriteArray count];
        }
        return [[[_mArray objectAtIndex:section-1] objectForKey:@"list"] count];
    }
    
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([_parentViewController.searchBar.text length] <= 0) {//正常模式
        [self resetRefreshTailerView];
        if (indexPath.section!=0) {
            if ([_mArray count]<=0 || _mArray==nil) {
                return nil;
            }
        }
        
        return [self ktvCelltableView:tableView cellForRowAtIndexPath:indexPath];
    }
    
    return [self ktvSearchtableView:tableView cellForRowAtIndexPath:indexPath];
}

#pragma mark -
#pragma mark 正常模式Cell
- (UITableViewCell *)ktvCelltableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    ABLoggerMethod();
    
    static NSString *CellIdentifier = @"KTVManagerCell";
    
    KTVManagerCell * cell = (KTVManagerCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [self createNewMocieCell];
    }
    
    [self configCell:cell cellForRowAtIndexPath:indexPath];
    
    return cell;
}

-(KTVManagerCell *)createNewMocieCell{
    ABLoggerMethod();
    KTVManagerCell * cell = [[[NSBundle mainBundle] loadNibNamed:@"KTVManagerCell" owner:self options:nil] objectAtIndex:0];
    [cell setAccessoryType:UITableViewCellAccessoryNone];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    [cell.ktvFavoriteButton addTarget:self action:@selector(clickFavoriteButton:) forControlEvents:UIControlEventTouchUpInside];
    
    return cell;
}

- (void)clickFavoriteButton:(id)sender{
    UIButton *bt = (UIButton *)sender;
    KTVManagerCell *cell = (KTVManagerCell*)[[bt superview] superview];
    NSIndexPath *selectedIndexPath = [_mTableView indexPathForCell:cell];
    
    int row = selectedIndexPath.row;
    int section = selectedIndexPath.section;

    KKTV *aKTV = nil;
    if (section==0) {
        aKTV = [_mFavoriteArray objectAtIndex:row];
    }else{
        NSArray *list = [[_mArray objectAtIndex:section-1] objectForKey:@"list"];
        aKTV = [list objectAtIndex:row];
    }
    
    [_mTableView beginUpdates];
    
    if ([_mFavoriteArray count]==0) {
        [_mTableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationNone];//解决第一次收藏KTV的时候，第一个区视图不显示Bug
    }
    
    if (!bt.selected) {
        [[DataBaseManager sharedInstance] addFavoriteKTVWithId:aKTV.uid];
        bt.selected = YES;
        [cell.ktvFavoriteButton setImage:[UIImage imageNamed:@"btn_favorite_n@2x"] forState:UIControlStateNormal];
        [_mFavoriteArray addObject:aKTV];
        [_mTableView insertRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:[_mFavoriteArray count]-1 inSection:0]] withRowAnimation:UITableViewRowAnimationLeft];
        
    }else{
        [[DataBaseManager sharedInstance] deleteFavoriteKTVWithId:aKTV.uid];
        bt.selected = NO;
         [cell.ktvFavoriteButton setImage:[UIImage imageNamed:@"btn_unFavorite_n@2x"] forState:UIControlStateNormal];
        int deleteRow = [_mFavoriteArray indexOfObject:aKTV];
        
        int refreshSection = -1;
        int refreshRow = -1;
        for (int i=0;i<[_mArray count];i++) {
            NSString *districtName = [[_mArray objectAtIndex:i] objectForKey:@"name"];
            if ([aKTV.district isEqualToString:districtName]) {
                refreshSection = i;
                NSArray *list = [[_mArray objectAtIndex:refreshSection] objectForKey:@"list"];
                refreshRow = [list indexOfObject:aKTV];
                refreshSection ++;//第一个区是收藏区，全部list是从第二个区
            }
        }

        
        [_mFavoriteArray removeObject:aKTV];
        [_mTableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:deleteRow inSection:0]] withRowAnimation:UITableViewRowAnimationRight];
        
        if (refreshSection >0 && refreshRow >=0) {
            ABLoggerDebug(@"section ===== %d row ===== %d",refreshSection,refreshRow);
            [_mTableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:refreshRow inSection:refreshSection]] withRowAnimation:UITableViewRowAnimationNone];
        }
    }
    
   [_mTableView endUpdates];
//    [_parentViewController formatKTVDataFilterFavorite];
//    [_mTableView reloadData];
    
}

- (void)resetRefreshTailerView{
   _refreshTailerView.frame = CGRectMake(0.0f, _mTableView.contentSize.height, _mTableView.frame.size.width, _mTableView.bounds.size.height);
}

- (void)configCell:(KTVManagerCell *)cell cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    KKTV *aKTV = nil;
    int row = indexPath.row;
    if (indexPath.section==0) {
        aKTV = [_mFavoriteArray objectAtIndex:row];
    }else{
        NSArray *list = [[_mArray objectAtIndex:indexPath.section-1] objectForKey:@"list"];
        aKTV = [list objectAtIndex:row];
    }
    
    [self configureCell:cell withObject:aKTV];
}

- (void)configureCell:(KTVManagerCell *)cell withObject:(KKTV *)aKTV {
    
    cell.ktvFavoriteButton.selected = NO;
    [cell.ktvFavoriteButton setImage:[UIImage imageNamed:@"btn_unFavorite_n@2x"] forState:UIControlStateNormal];
    
    cell.ktv_name.text = aKTV.name;
    cell.ktv_address.text = aKTV.address;
    
    if ([aKTV.favorite boolValue]) {
        cell.ktvFavoriteButton.selected = YES;
        [cell.ktvFavoriteButton setImage:[UIImage imageNamed:@"btn_favorite_n@2x"] forState:UIControlStateNormal];
    }
}

#pragma mark -
#pragma mark 搜索Cell
- (UITableViewCell *)ktvSearchtableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *indentifier = @"KTVManagerCell";
    
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
    if (section==0) {
        UILabel *headerView = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 320, 30.0f)];
        headerView.backgroundColor = [UIColor colorWithWhite:0.502 alpha:1.000];
        headerView.text = [NSString stringWithFormat:@"已收藏的KTV店"];
        return [headerView autorelease];
    }
    
    if (section==1) {
        UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 50.0f)];
        
        UILabel *label1 = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 320, 30.0f)];
        label1.backgroundColor = [UIColor colorWithWhite:0.502 alpha:1.000];
        label1.text = [NSString stringWithFormat:@"全部KTV店"];
        
        UILabel *label2 = [[UILabel alloc] initWithFrame:CGRectMake(0, 30, 320, 20.0f)];
        label2.backgroundColor = [UIColor colorWithWhite:0.829 alpha:1.000];
        NSString *name = [[_mArray objectAtIndex:section-1] objectForKey:@"name"];
        NSArray *list = [[_mArray objectAtIndex:section-1] objectForKey:@"list"];
        label2.text = [NSString stringWithFormat:@"%@  (共%d家)",name,[list count]];
        
        [headerView addSubview:label1];
        [headerView addSubview:label2];
        [label1 release];
        [label2 release];
        return [headerView autorelease];
    }
    
    UILabel *headerView = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 320, 20.0f)];
    headerView.backgroundColor = [UIColor colorWithWhite:0.829 alpha:1.000];
    
    NSString *name = [[_mArray objectAtIndex:section-1] objectForKey:@"name"];
    NSArray *list = [[_mArray objectAtIndex:section-1] objectForKey:@"list"];
    headerView.text = [NSString stringWithFormat:@"%@  (共%d家)",name,[list count]];
    
    return [headerView autorelease];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (section==0) {
        if (_mFavoriteArray==nil || [_mFavoriteArray count]<=0) {
            return 0.0f;
        }
        return 30.0f;
    }
    
    if (section==1) {
        return 50.0f;
    }
    return 20.0f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
}

#pragma mark -
#pragma mark Data Source Loading / Reloading Methods
/*加载更多*/
- (void)loadMoreTableViewDataSource {
    _reloading = YES;
    [_parentViewController loadMoreData];
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
    [_refreshTailerView egoRefreshScrollViewDidScroll:scrollView];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    [_refreshTailerView egoRefreshScrollViewDidEndDragging:scrollView];
}


#pragma mark -
#pragma mark EGORefreshTableHeaderDelegate Methods

- (void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView*)view{
    
    if (view.tag == EGOBottomView)
    {
        [self loadMoreTableViewDataSource];
    }
}

- (BOOL)egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView*)view{
    return _reloading; // should return if data source model is reloading
}

- (NSDate*)egoRefreshTableHeaderDataSourceLastUpdated:(EGORefreshTableHeaderView*)view{
    
    return [NSDate date]; // should return date data source was last changed
}

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
    
    _parentViewController.searchBar.showsScopeBar = YES;
    [_parentViewController.searchBar sizeToFit];
    [_parentViewController.searchBar setShowsCancelButton:YES animated:YES];
    
    for(id cc in [_parentViewController.searchBar subviews])
    {
        if([cc isKindOfClass:[UIButton class]])
        {
            UIButton *btn = (UIButton *)cc;
            [btn setTitle:@""  forState:UIControlStateNormal];
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
    [_mTableView resignFirstResponder];
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
