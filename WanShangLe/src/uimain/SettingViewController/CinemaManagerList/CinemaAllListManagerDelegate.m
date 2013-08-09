//
//  MovieListTableViewDelegate.m
//  WanShangLe
//
//  Created by stephenliu on 13-6-8.
//  Copyright (c) 2013年 stephenliu. All rights reserved.
//
#import "CinemaAllListManagerDelegate.h"
#import "CinemaManagerViewController.h"
#import "CinemaManagerSearchController.h"
#import "CinemaManagerCell.h"
#import "MCinema.h"
#import "NSMutableArray+TKCategory.h"

#define TagTuan 500

@interface CinemaAllListManagerDelegate(){
    UIButton *loadMoreButton;
}
@property(nonatomic,retain)CinemaManagerSearchController *msearchController;
@end

@implementation CinemaAllListManagerDelegate

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
- (CinemaManagerSearchController *)msearchController{
    if (_msearchController!=nil) {
        return _msearchController;
    }
    
    [self initSearchController];
    return _msearchController;
}

- (void)initSearchController{
    if (_msearchController==nil) {
        self.msearchController = [[[CinemaManagerSearchController alloc] init] autorelease];
    }
}

#pragma mark -
#pragma mark UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if ([_parentViewController.searchBar.text length] <= 0) {//正常模式
        
        [_parentViewController hiddenRefreshTailerView];
        
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
    
    return [self.mSearchArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([_parentViewController.searchBar.text length] <= 0) {//正常模式
        [self resetRefreshTailerView];
        
        return [self CinemaCelltableView:tableView cellForRowAtIndexPath:indexPath];
    }
    
     //搜索模式
    return [self CinemaSearchtableView:tableView cellForRowAtIndexPath:indexPath];
}

#pragma mark -
#pragma mark 正常模式Cell
- (UITableViewCell *)CinemaCelltableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    ABLoggerMethod();
    
    static NSString *CellIdentifier = @"CinemaManagerCell";
    
    CinemaManagerCell * cell = (CinemaManagerCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [self createNewMocieCell];
    }
    
    if (indexPath.section!=0) {
        if ([_mArray count]<=0 || _mArray==nil) {
            return cell;
        }
    }
    
    [self configCell:cell cellForRowAtIndexPath:indexPath];
    
    return cell;
}

-(CinemaManagerCell *)createNewMocieCell{
    ABLoggerMethod();
    CinemaManagerCell * cell = [[[NSBundle mainBundle] loadNibNamed:@"CinemaManagerCell" owner:self options:nil] objectAtIndex:0];
    [cell setAccessoryType:UITableViewCellAccessoryNone];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    [cell.cinemaFavoriteButton addTarget:self action:@selector(clickFavoriteButton:) forControlEvents:UIControlEventTouchUpInside];
    
    return cell;
}

- (void)clickFavoriteButton:(id)sender{
    UIButton *bt = (UIButton *)sender;
    CinemaManagerCell *cell = (CinemaManagerCell*)[[bt superview] superview];

    
    MCinema *aCinema = nil;
    
    if ([_parentViewController.searchBar.text length] <= 0) {//正常模式
        
        NSIndexPath *selectedIndexPath = [_mTableView indexPathForCell:cell];
        int row = selectedIndexPath.row;
        int section = selectedIndexPath.section;
        
        if (section==0) {
            aCinema = [_mFavoriteArray objectAtIndex:row];
        }else{
            NSArray *list = [[_mArray objectAtIndex:section-1] objectForKey:@"list"];
            aCinema = [list objectAtIndex:row];
        }
        
        [_mTableView beginUpdates];
        
        if ([_mFavoriteArray count]==0) {
            [_mTableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationNone];//解决第一次收藏Cinema的时候，第一个区视图不显示Bug
        }
        
        if (!bt.selected) {
            [[DataBaseManager sharedInstance] addFavoriteCinemaWithId:aCinema.uid];
            bt.selected = YES;
            [cell.cinemaFavoriteButton setImage:[UIImage imageNamed:@"btn_favorite_n@2x"] forState:UIControlStateNormal];
            [_mFavoriteArray addObject:aCinema];
            [_mTableView insertRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:[_mFavoriteArray count]-1 inSection:0]] withRowAnimation:UITableViewRowAnimationLeft];
            
        }else{
            [[DataBaseManager sharedInstance] deleteFavoriteCinemaWithId:aCinema.uid];
            bt.selected = NO;
            [cell.cinemaFavoriteButton setImage:[UIImage imageNamed:@"btn_unFavorite_n@2x"] forState:UIControlStateNormal];
            int deleteRow = [_mFavoriteArray indexOfObject:aCinema];
            
            int refreshSection = -1;
            int refreshRow = -1;
            for (int i=0;i<[_mArray count];i++) {
                NSString *districtName = [[_mArray objectAtIndex:i] objectForKey:@"name"];
                if ([aCinema.district isEqualToString:districtName]) {
                    refreshSection = i;
                    NSArray *list = [[_mArray objectAtIndex:refreshSection] objectForKey:@"list"];
                    refreshRow = [list indexOfObject:aCinema];
                    refreshSection ++;//第一个区是收藏区，全部list是从第二个区
                }
            }

            if ([_mFavoriteArray containsObject:aCinema]) {//如何收藏里包含了这个aCinema才可以删除，如果没有包含删除动画会crash
                [_mFavoriteArray removeObject:aCinema];
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
        
        aCinema = [_mSearchArray objectAtIndex:row];
        if (!bt.selected) {
            [[DataBaseManager sharedInstance] addFavoriteCinemaWithId:aCinema.uid];
            bt.selected = YES;
            [cell.cinemaFavoriteButton setImage:[UIImage imageNamed:@"btn_favorite_n@2x"] forState:UIControlStateNormal];
            ABLoggerDebug(@"添加收藏Cinema ======  %@",aCinema.name);
            [_mFavoriteArray addObject:aCinema];
            
            [_parentViewController formatCinemaDataFilterAll:[NSArray arrayWithObject:aCinema]];
        }else{
            [[DataBaseManager sharedInstance] deleteFavoriteCinemaWithId:aCinema.uid];
            bt.selected = NO;
            [cell.cinemaFavoriteButton setImage:[UIImage imageNamed:@"btn_unFavorite_n@2x"] forState:UIControlStateNormal];
            [_mFavoriteArray filterUsingPredicate:[NSPredicate predicateWithFormat:@"uid != %@",aCinema.uid]];//解决了 收藏数组 删除 搜索数组 中取消收藏的影院
        }
    } 
}

- (void)resetRefreshTailerView{
   _refreshTailerView.frame = CGRectMake(0.0f, _mTableView.contentSize.height, _mTableView.frame.size.width, _mTableView.bounds.size.height);
}

- (void)configCell:(CinemaManagerCell *)cell cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    MCinema *aCinema = nil;
    int row = indexPath.row;
    int section = indexPath.section;
    if (indexPath.section==0) {
        aCinema = [_mFavoriteArray objectAtIndex:row];
        ABLoggerDebug(@"收藏的1111111 section == %d row == %d name == %@",indexPath.section,row,aCinema.name);
        
        for (int i=0;i<[_mFavoriteArray count];i++) {
            MCinema *aCinemat = [_mFavoriteArray objectAtIndex:i];
            ABLoggerDebug(@" index %d == %@",i,aCinemat.name);
        }
    }else{
        NSArray *list = [[_mArray objectAtIndex:indexPath.section-1] objectForKey:@"list"];
        aCinema = [list objectAtIndex:row];
        ABLoggerDebug(@"全部的2222222  section == %d row == %d name == %@",indexPath.section,row,aCinema.name);
    }
    
    
    [self configureCell:cell withObject:aCinema];
}

- (void)configureCell:(CinemaManagerCell *)cell withObject:(MCinema *)aCinema {
    
    cell.cinemaFavoriteButton.selected = NO;
    [cell.cinemaFavoriteButton setImage:[UIImage imageNamed:@"btn_unFavorite_n@2x"] forState:UIControlStateNormal];
    
    cell.cinema_name.text = aCinema.name;
    cell.cinema_address.text = aCinema.address;

    if ([aCinema.favorite boolValue]) {
        cell.cinemaFavoriteButton.selected = YES;
        [cell.cinemaFavoriteButton setImage:[UIImage imageNamed:@"btn_favorite_n@2x"] forState:UIControlStateNormal];
    }
}

#pragma mark -
#pragma mark 搜索 Cell for row
- (UITableViewCell *)CinemaSearchtableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *CellIdentifier = @"CinemaManagerCell";
    
    CinemaManagerCell * cell = (CinemaManagerCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [self createNewMocieCell];
    }
    
    [self configSearchCell:cell cellForRowAtIndexPath:indexPath];
    
    return cell;
}

- (void)configSearchCell:(CinemaManagerCell *)cell cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    MCinema *aCinema = nil;
    int row = indexPath.row;
    aCinema = [_mSearchArray objectAtIndex:row];
    
    cell.cinemaFavoriteButton.selected = NO;
    [cell.cinemaFavoriteButton setImage:[UIImage imageNamed:@"btn_unFavorite_n@2x"] forState:UIControlStateNormal];
    
    cell.cinema_name.text = aCinema.name;
    cell.cinema_address.text = aCinema.address;
    
    if ([[DataBaseManager sharedInstance] isFavoriteCinemaWithId:aCinema.uid]) {
        cell.cinemaFavoriteButton.selected = YES;
        [cell.cinemaFavoriteButton setImage:[UIImage imageNamed:@"btn_favorite_n@2x"] forState:UIControlStateNormal];
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
        headerView.text = [NSString stringWithFormat:@"已收藏的影院"];
        return [headerView autorelease];
    }
    
    if (section==1) {
        UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 50.0f)];
        
        UILabel *label1 = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 320, 30.0f)];
        label1.backgroundColor = [UIColor colorWithWhite:0.502 alpha:1.000];
        label1.text = [NSString stringWithFormat:@"全部影院"];
        
        UILabel *label2 = [[UILabel alloc] initWithFrame:CGRectMake(0, 30, 320, 20.0f)];
        label2.backgroundColor = [UIColor colorWithWhite:0.829 alpha:1.000];
        NSString *name = [[_mArray objectAtIndex:section-1] objectForKey:@"name"];
        NSArray *list = [[_mArray objectAtIndex:section-1] objectForKey:@"list"];
        label2.text = [NSString stringWithFormat:@"%@",name];
        
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
    headerView.text = [NSString stringWithFormat:@"%@",name];
    
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
    
    if (_refreshTailerView.hidden)return;
    
    [_refreshTailerView egoRefreshScrollViewDidScroll:scrollView];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    
    if (_refreshTailerView.hidden)return;
    
    [_refreshTailerView egoRefreshScrollViewDidEndDragging:scrollView];
}


#pragma mark -
#pragma mark EGORefreshTableHeaderDelegate Methods

- (void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView*)view{
    
    if (view.tag == EGOBottomView && !view.hidden)
    {
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
    
    [self.msearchController startCinemaSearchForSearchString:searchBar.text complete:^(NSMutableArray *searchArray, BOOL isSuccess) {
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
    [_mTableView reloadData];//解决退出搜索后，新添加的影院收藏列表没有刷新的Bug
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
