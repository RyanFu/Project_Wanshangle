//
//  MovieListTableViewDelegate.m
//  WanShangLe
//
//  Created by stephenliu on 13-6-8.
//  Copyright (c) 2013年 stephenliu. All rights reserved.
//
#import "KTVAllListTableViewDelegate.h"
#import "KTVBuyViewController.h"
#import "KtvAllViewController.h"
#import "KTVTableViewCell.h"
#import "KKTV.h"

#import "KtvManagerSearchController.h"

#define TagTuan 500

@interface KTVAllListTableViewDelegate(){
    UIButton *loadMoreButton;
}
@property(nonatomic,assign) NSMutableArray *mSearchArray;
@property(nonatomic,retain)KtvManagerSearchController *msearchController;
@end

@implementation KTVAllListTableViewDelegate

- (id)init{
    self = [super init];
    if (self) {
        
    }
    return self;
}

- (void)dealloc{
    self.msearchController = nil;
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
    
    return [_mSearchArray count];
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
    
    static NSString *CellIdentifier = @"MKTVCellIdentifier";
    
    KTVTableViewCell * cell = (KTVTableViewCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [self createNewCell];
    }
    
    [self configCell:cell cellForRowAtIndexPath:indexPath];
    
    return cell;
}

-(KTVTableViewCell *)createNewCell{
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
    static NSString *indentifier = @"MKTVCellIdentifier";
    KTVTableViewCell *cell = (KTVTableViewCell*)[tableView dequeueReusableCellWithIdentifier:indentifier];
    
    if (cell == nil) {
        cell = [self createNewCell];
	}
    
    KKTV *ktv = [_mSearchArray objectAtIndex:indexPath.row];
    [self configureCell:cell withObject:ktv];
    
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
    
    if ([_parentViewController.searchBar.text length] <= 0) {//正常模式
        UILabel *headerView = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 320, 30)];
        headerView.backgroundColor = [UIColor colorWithWhite:0.829 alpha:1.000];
        
        NSString *name = [[_mArray objectAtIndex:section] objectForKey:@"name"];
        NSArray *list = [[_mArray objectAtIndex:section] objectForKey:@"list"];
        headerView.text = [NSString stringWithFormat:@"%@",name];
        [headerView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"UITableViewCellSection_bg"]]];
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
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    KTVBuyViewController *ktvBuyController = [[KTVBuyViewController alloc] initWithNibName:iPhone5?@"KTVBuyViewController_5":@"KTVBuyViewController" bundle:nil];
    
    KKTV *aKTV = nil;
    
    if ([_parentViewController.searchBar.text length] <= 0) {//正常模式
        
        NSDictionary *dic = [_mArray objectAtIndex:indexPath.section];
        NSArray *list = [dic objectForKey:@"list"];
        aKTV = [list objectAtIndex:indexPath.row];
        
    } else {//搜索模式
        aKTV = [_mSearchArray objectAtIndex:indexPath.row];
    }
    
    ktvBuyController.mKTV = aKTV;
    [[CacheManager sharedInstance].rootNavController pushViewController:ktvBuyController animated:YES];
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
        
        BOOL done = ([searchArray count]<DataCount);
        //搜索模式
        if (_msearchDisplayController.searchResultsTableView.tableFooterView==nil) {
            [self addSearchLoadMoreButton];
        }
        
        if(!isSuccess || done){
            [loadMoreButton setTitle:@"已全部加载" forState:UIControlStateNormal];
        }
    }];
}

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar{
    ABLoggerWarn(@"");
    [_parentViewController beginSearch];
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
    [_parentViewController endSearch];
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
