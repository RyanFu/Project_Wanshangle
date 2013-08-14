//
//  MovieListTableViewDelegate.m
//  WanShangLe
//
//  Created by stephenliu on 13-6-8.
//  Copyright (c) 2013年 stephenliu. All rights reserved.
//
#import "MovieCinemaNearByListDelegate.h"
#import "CinemaNearByViewController.h"
#import "MovieCinemaCell.h"
#import "MCinema.h"

#import "ScheduleViewController.h"
#import "CinemaMovieViewController.h"
#import "CinemaViewController.h"
#import "UILabel+AFNetworking.h"

#define TagTuan 500

@interface MovieCinemaNearByListDelegate(){
    
}
@end

@implementation MovieCinemaNearByListDelegate

#pragma mark -
#pragma mark UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (_mArray==nil || [_mArray count]<=0 || _parentViewController.isLoadDone) {//每次刷新表的时候检测是否有数据
        _refreshTailerView.hidden = YES;
    }else{
        _refreshTailerView.hidden = NO;
    }
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
  return [_mArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  return [self ktvCelltableView:tableView cellForRowAtIndexPath:indexPath];
}

#pragma mark -
#pragma mark 正常模式Cell
- (UITableViewCell *)ktvCelltableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    ABLoggerMethod();
    static NSString *CellIdentifier = @"MovieCinemaCell";

    MovieCinemaCell * cell = (MovieCinemaCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
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

-(MovieCinemaCell *)createNewMocieCell{
    ABLoggerMethod();
    MovieCinemaCell * cell = [[[NSBundle mainBundle] loadNibNamed:@"MovieCinemaCell" owner:self options:nil] objectAtIndex:0];
    [cell setAccessoryType:UITableViewCellAccessoryNone];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

- (void)configCell:(MovieCinemaCell *)cell cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    MCinema *aCinema = [_mArray objectAtIndex:indexPath.row];
    
    [self configureCell:cell withObject:aCinema];
}

- (void)configureCell:(MovieCinemaCell *)cell withObject:(MCinema *)cinema {
    
    
    cell.cinema_name.text = cinema.name;
    cell.cinema_address.text = cinema.address;
    cell.cinema_name.text = cinema.name;
    [[cell viewWithTag:TagTuan] removeFromSuperview];
    
    cell.cinema_image_location.hidden = NO;
    cell.cinema_distance.hidden = NO;
    
    MMovie *aMovie = [_parentViewController.mParentController mMovie];
    cell.cinema_price.text = @"";
    [cell.cinema_scheduleCount setJSONWithWithMovie:aMovie
                                             cinema:cinema
                                        placeholder:@"亲,正在加载..."
                                            success:^(NSURLRequest *request, NSHTTPURLResponse *response, NSDictionary *resultDic) {
                                                
                                                int priceInt = [[resultDic objectForKey:@"lowestPrice"] intValue];
                                                NSString *price = nil;
                                                if (priceInt<0) {
                                                    price = @"暂无价格";
                                                }else{
                                                    price = [NSString stringWithFormat:@"%d元",priceInt];
                                                }
                                                cell.cinema_price.text = price;

                                                NSMutableArray *array = [NSMutableArray arrayWithCapacity:3];
                                                NSArray *flagArray = [resultDic objectForKey:@"pricetype"];
                                                if ([[flagArray objectAtIndex:2] boolValue]) {
                                                    [array addObject:cell.cinema_image_juan];
                                                }
                                                if ([[flagArray objectAtIndex:0] boolValue]) {
                                                    [array addObject:cell.cinema_image_seat];
                                                }
                                                if ([[flagArray objectAtIndex:1] boolValue]) {
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
                                                 view.tag = TagTuan;
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

                                                
                                            } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                                                ABLoggerError(@" error == %@",[error description]);
                                            }];
    
}

#pragma mark -
#pragma mark UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 80.0f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
//    NSDictionary *dic = [_mArray objectAtIndex:indexPath.section];
//    NSArray *list = [dic objectForKey:@"list"];
    MCinema *mCinema = [_mArray objectAtIndex:indexPath.row];
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
