//
//  MovieListTableViewDelegate.m
//  WanShangLe
//
//  Created by stephenliu on 13-6-8.
//  Copyright (c) 2013年 stephenliu. All rights reserved.
//
#import "MovieCinemaAllListDelegate.h"
#import "CinemaAllViewController.h"
#import "MovieCinemaCell.h"
#import "MCinema.h"

#import "ScheduleViewController.h"
#import "CinemaMovieViewController.h"
#import "CinemaManagerSearchController.h"
#import "CinemaViewController.h"

#import "UILabel+AFNetworking.h"
#import "MMovie.h"
#import "MCinema.h"

#define TagTuan 500

@interface MovieCinemaAllListDelegate(){
    UIButton *loadMoreButton;
}
@property(nonatomic,assign) NSMutableArray *mSearchArray;
@property(nonatomic,retain)CinemaManagerSearchController *msearchController;
@end

@implementation MovieCinemaAllListDelegate

- (id)init{
    if (self = [super init]) {
    }
    return self;
}

- (void)dealloc{
    self.msearchController = nil;
    [super dealloc];
}

- (void)clearScheduleCache{
    [[UILabel af_sharedJsonCache].scheduleCache removeAllObjects];
    [[UILabel af_sharedJsonRequestOperationQueue] cancelAllOperations];
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
        
        if (_mArray==nil || [_mArray count]<=0) {
            _refreshTailerView.hidden = YES;
        }else{
            _refreshTailerView.hidden = NO;
        }
        
        //解决上啦刷新箭头错位Bug
        double delayInSeconds = 1.0;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^{
            _refreshTailerView.frame = CGRectMake(0.0f, _mTableView.contentSize.height, _mTableView.frame.size.width, _mTableView.bounds.size.height);
        });
        
        return [_mArray count];
    }
    //搜索模式
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    if ([_parentViewController.searchBar.text length] <= 0) {//正常模式
            
        return [[[_mArray objectAtIndex:section] objectForKey:@"list"] count];
    }
    
    return [self.mSearchArray count];
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
    
    static NSString *CellIdentifier = @"MovieCinemaCell";
    
    MovieCinemaCell * cell = (MovieCinemaCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [self createNewCinemaCell];
    }
    
    if ([_mArray count]<=0 || _mArray==nil) {
        return cell;
    }
    NSArray *list = [[_mArray objectAtIndex:indexPath.section] objectForKey:@"list"];
    MCinema *cinema = [list objectAtIndex:indexPath.row];
    
    [self configCell:cell withCinema:cinema];
    
    return cell;
}

-(MovieCinemaCell *)createNewCinemaCell{
    ABLoggerMethod();
    MovieCinemaCell * cell = [[[NSBundle mainBundle] loadNibNamed:@"MovieCinemaCell" owner:self options:nil] objectAtIndex:0];
    [cell setAccessoryType:UITableViewCellAccessoryNone];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

- (void)configCell:(MovieCinemaCell *)cell withCinema:(MCinema *)cinema{
    
    cell.cinema_name.text = cinema.name;
    cell.cinema_address.text = cinema.address;
    
    MMovie *aMovie = [_parentViewController.mParentController mMovie];
    cell.cinema_price.text = @"";
    
    [cell.cinema_scheduleCount setJSONWithWithMovie:aMovie
                                             cinema:cinema
                                        placeholder:@"亲,正在加载..."
                                            success:^(NSURLRequest *request, NSHTTPURLResponse *response, NSString *resultString) {
                                                cell.cinema_price.text = resultString;
                                            } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                                                ABLoggerError(@" error == %@",[error description]);
                                            }];

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
    static NSString *indentifier = @"MovieCinemaCell";
    
    MovieCinemaCell *cell = (MovieCinemaCell*)[tableView dequeueReusableCellWithIdentifier:indentifier];
    
    if (cell == nil) {
        cell = [self createNewCinemaCell];
	}
    MCinema *cinema = [_mSearchArray objectAtIndex:indexPath.row];
    [self configCell:cell withCinema:cinema];
    return cell;
}
#pragma mark -
#pragma mark UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if ([_parentViewController.searchBar.text length] <= 0) {//正常模式
        return 85.0f;
    }
    
    return 85.0f;
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
    
    MCinema *mCinema = nil;
    
    if ([_parentViewController.searchBar.text length] <= 0) {//正常模式
        
        NSDictionary *dic = [_mArray objectAtIndex:indexPath.section];
        NSArray *list = [dic objectForKey:@"list"];
        mCinema = [list objectAtIndex:indexPath.row];
        
    } else {//搜索模式
        mCinema = [_mSearchArray objectAtIndex:indexPath.row];
    }
    
    MMovie *mMovie = [_parentViewController.mParentController mMovie];
    
    //    BOOL isMoviePanel = [CacheManager sharedInstance].isMoviePanel;
    UINavigationController *rootNavigationController = [CacheManager sharedInstance].rootNavController;
    
    ScheduleViewController *scheduleViewController = [[ScheduleViewController alloc]
                                                      initWithNibName:(iPhone5?@"ScheduleViewController_5":@"ScheduleViewController")
                                                      bundle:nil];
    scheduleViewController.mCinema = mCinema;
    scheduleViewController.mMovie = mMovie;
    [rootNavigationController pushViewController:scheduleViewController animated:YES];
    [scheduleViewController release];
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
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
