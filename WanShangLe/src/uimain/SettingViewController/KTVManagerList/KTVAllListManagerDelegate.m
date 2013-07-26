//
//  MovieListTableViewDelegate.m
//  WanShangLe
//
//  Created by stephenliu on 13-6-8.
//  Copyright (c) 2013年 stephenliu. All rights reserved.
//
#import "KTVAllListManagerDelegate.h"
#import "KtvManagerViewController.h"
#import "KtvManagerSearchController.h"
#import "KTVManagerCell.h"
#import "KKTV.h"

#define TagTuan 500

@interface KTVAllListManagerDelegate(){
    UIButton *loadMoreButton;
}
@property(nonatomic,retain)KtvManagerSearchController *msearchController;
@end

@implementation KTVAllListManagerDelegate

- (id)init{
    self = [super init];
    if (self) {
        
    }
    return self;
}

- (void)dealloc{
    self.msearchController = nil;
//    self.msearchDisplayController = nil;
    [super dealloc];
}

#pragma mark -
#pragma mark initData
- (KtvManagerSearchController *)msearchController{
    if (_msearchController!=nil) {
        return _msearchController;
    }
    
    [self initSearchController];
    return _msearchController;
}

- (void)initSearchController{
    if (_msearchController==nil) {
        self.msearchController = [[[KtvManagerSearchController alloc] init] autorelease];
    }
}

#pragma mark -
#pragma mark UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (tableView != self.msearchDisplayController.searchResultsTableView) {//正常模式
        [_parentViewController hiddenRefreshTailerView];
        return [_mArray count]+1;
    }
    //搜索模式
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    if (tableView != self.msearchDisplayController.searchResultsTableView) {//正常模式
        if (section==0) {
            return [_mFavoriteArray count];
        }
        return [[[_mArray objectAtIndex:section-1] objectForKey:@"list"] count];
    }
    
    return [self.mSearchArray count];
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
    
     //搜索模式
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

    
    KKTV *aKTV = nil;
    
    if ([_parentViewController.searchBar.text length] <= 0) {//正常模式
        
        NSIndexPath *selectedIndexPath = [_mTableView indexPathForCell:cell];
        int row = selectedIndexPath.row;
        int section = selectedIndexPath.section;
        
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

            if ([_mFavoriteArray containsObject:aKTV]) {//如何收藏里包含了这个aKTV才可以删除，如果没有包含删除动画会crash
                [_mFavoriteArray removeObject:aKTV];
                [_mTableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:deleteRow inSection:0]] withRowAnimation:UITableViewRowAnimationRight];
            }
            
            if (refreshSection >0 && refreshRow >=0) {
                ABLoggerDebug(@"section ===== %d row ===== %d",refreshSection,refreshRow);
                [_mTableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:refreshRow inSection:refreshSection]] withRowAnimation:UITableViewRowAnimationNone];
            }
        }
        
        [_mTableView endUpdates];
        
        
    }else{//搜索模式
        
        NSIndexPath *selectedIndexPath = [self.msearchDisplayController.searchResultsTableView indexPathForCell:cell];
        int row = selectedIndexPath.row;
        int section = selectedIndexPath.section;
        
        aKTV = [_mSearchArray objectAtIndex:row];
        if (!bt.selected) {
            [[DataBaseManager sharedInstance] addFavoriteKTVWithId:aKTV.uid];
            bt.selected = YES;
            [cell.ktvFavoriteButton setImage:[UIImage imageNamed:@"btn_favorite_n@2x"] forState:UIControlStateNormal];
            ABLoggerDebug(@"添加收藏KTV ======  %@",aKTV.name);
            [_mFavoriteArray addObject:aKTV];
            
            [_parentViewController formatKTVDataFilterAll:[NSArray arrayWithObject:aKTV]];
        }else{
            [[DataBaseManager sharedInstance] deleteFavoriteKTVWithId:aKTV.uid];
            bt.selected = NO;
            [cell.ktvFavoriteButton setImage:[UIImage imageNamed:@"btn_unFavorite_n@2x"] forState:UIControlStateNormal];
            [_mFavoriteArray removeObject:aKTV];
        }
    } 
}

- (void)resetRefreshTailerView{
   _refreshTailerView.frame = CGRectMake(0.0f, _mTableView.contentSize.height, _mTableView.frame.size.width, _mTableView.bounds.size.height);
}

- (void)configCell:(KTVManagerCell *)cell cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    KKTV *aKTV = nil;
    int row = indexPath.row;
    int section = indexPath.section;
    if (indexPath.section==0) {
        aKTV = [_mFavoriteArray objectAtIndex:row];
        ABLoggerDebug(@"收藏的1111111 section == %d row == %d name == %@",indexPath.section,row,aKTV.name);
        
        for (int i=0;i<[_mFavoriteArray count];i++) {
            KKTV *aktvt = [_mFavoriteArray objectAtIndex:i];
            ABLoggerDebug(@" index %d == %@",i,aktvt.name);
        }
    }else{
        NSArray *list = [[_mArray objectAtIndex:indexPath.section-1] objectForKey:@"list"];
        aKTV = [list objectAtIndex:row];
        ABLoggerDebug(@"全部的2222222  section == %d row == %d name == %@",indexPath.section,row,aKTV.name);
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
#pragma mark 搜索 Cell for row
- (UITableViewCell *)ktvSearchtableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *CellIdentifier = @"KTVManagerCell";
    
    KTVManagerCell * cell = (KTVManagerCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [self createNewMocieCell];
    }
    
    [self configSearchCell:cell cellForRowAtIndexPath:indexPath];
    
    return cell;
}

- (void)configSearchCell:(KTVManagerCell *)cell cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    KKTV *aKTV = nil;
    int row = indexPath.row;
    aKTV = [_mSearchArray objectAtIndex:row];
    
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
#pragma mark UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 70.0f;
}

#pragma mark -
#pragma mark UITableViewDelegate
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    
     if (tableView == self.msearchDisplayController.searchResultsTableView) {//搜索模式
         return nil;
     }
    
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
    
    if (tableView == self.msearchDisplayController.searchResultsTableView) {//搜索模式
        return 0;
    }
    
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
    
    return [[DataBaseManager sharedInstance] date]; // should return date data source was last changed
}

#pragma mark UISearchBarDelegate methods
- (void)scrollTableViewToSearchBarAnimated:(BOOL)animated
{
    [self.mTableView setContentOffset:CGPointMake(0, 44) animated:animated];
}

//点击 取消 按钮
- (void)searchBarCancelButtonClicked:(UISearchBar *) searchBar{
    ABLoggerWarn(@"");
}

//点击 搜索 按钮
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    ABLoggerInfo(@"searchBar.text ====== %@",searchBar.text);
    
     if ([_parentViewController.searchBar.text length] <= 0) {//正常模式
         return;
     }
    
    [self.msearchController startKTVSearchForSearchString:searchBar.text complete:^(NSMutableArray *searchArray, BOOL isSuccess) {
        self.mSearchArray = searchArray;
        [self.msearchDisplayController.searchResultsTableView reloadData];
        //搜索模式
        if (_msearchDisplayController.searchResultsTableView.tableFooterView==nil) {
            [self addSearchLoadMoreButton];
        }else if(!isSuccess){
            [loadMoreButton setTitle:@"已全部加载" forState:UIControlStateNormal];
        }
    }];
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


#pragma mark -
#pragma mark UISearchDisplayDelegate
- (void)searchDisplayController:(UISearchDisplayController *)controller didLoadSearchResultsTableView:(UITableView *)tableView{
    [self initSearchController];
}

- (void)searchDisplayControllerDidEndSearch:(UISearchDisplayController *)controller{
    ABLoggerWarn(@"");
    [self cleanUpSearchBar:_parentViewController.searchBar];
    
    self.msearchController = nil;
    self.mSearchArray = nil;
    [_mTableView reloadData];//解决退出搜索后，新添加的TKV收藏列表没有刷新的Bug
}

- (void)cleanUpSearchBar:(UISearchBar *)searchBar{
    [[_parentViewController.searchBar viewWithTag:100] removeFromSuperview];
    [self scrollTableViewToSearchBarAnimated:YES];
}

- (void)searchDisplayController:(UISearchDisplayController *)controller didShowSearchResultsTableView:(UITableView *)tableView{

}

- (void)addSearchLoadMoreButton{
    UIButton *bt = [UIButton buttonWithType:UIButtonTypeCustom];
    bt.frame = CGRectMake(0, 0, 320, 40);
    [bt setTitle:@"加载更多.." forState:UIControlStateNormal];
    [bt setBackgroundColor:[UIColor colorWithWhite:0.800 alpha:1.000]];
    [bt addTarget:self action:@selector(clickLoadMoreSearchButton:) forControlEvents:UIControlEventTouchUpInside];
    loadMoreButton = bt;
    _msearchDisplayController.searchResultsTableView.tableFooterView = bt;
}

- (void)clickLoadMoreSearchButton:(id)sender{
    if ([_parentViewController.searchBar.text length] <= 0) {//正常模式
        return;
    }
    
    [self.msearchController loadSearchMoreDataForSearchString:_parentViewController.searchBar.text complete:^(NSMutableArray *searchArray, BOOL isSuccess) {
        self.mSearchArray = searchArray;
        [self.msearchDisplayController.searchResultsTableView reloadData];
        //搜索模式
        if (_msearchDisplayController.searchResultsTableView.tableFooterView==nil) {
            [self addSearchLoadMoreButton];
        }else if(!isSuccess){
            [loadMoreButton setTitle:@"已全部加载" forState:UIControlStateNormal];
        }
    }];
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    ABLoggerDebug(@"要搜索的字符串 ======= %@",searchString);
    
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 0.001);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        for (UIView* v in controller.searchResultsTableView.subviews) {
            if ([v isKindOfClass: [UILabel class]] &&
                [[(UILabel*)v text] isEqualToString:@"No Results"]) {
                [(UILabel*)v setText:@""];
                break;
            }
        }
    });
    
    return YES;
}
@end
