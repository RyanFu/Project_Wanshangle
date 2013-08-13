//
//  MovieListTableViewDelegate.m
//  WanShangLe
//
//  Created by stephenliu on 13-6-8.
//  Copyright (c) 2013年 stephenliu. All rights reserved.
//
#import "MovieListTableViewDelegate.h"
#import "MovieViewController.h"
#import "MovieTableViewCell.h"
#import "CinemaViewController.h"
#import "UIImageView+WebCache.h"
#import "MMovie.h"

#define TuanViewTag 500

@interface MovieListTableViewDelegate(){

}

@end

@implementation MovieListTableViewDelegate
@synthesize mTableView = _mTableView;

- (id)init{
    self = [super init];
    if (self) {

    }
    return self;
}

- (void)dealloc{
    [super dealloc];
}

#pragma mark -
#pragma mark UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [_parentViewController.moviesArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    ABLoggerMethod();
    static NSString *CellIdentifier = @"mMovieCell";
    
    MovieTableViewCell *cell = (MovieTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [self createNewMocieCell];
    }
    
    [self configureCell:cell atIndexPath:indexPath];
    
    return cell;
}

- (void)configureCell:(MovieTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    
    MMovie *movie = [_parentViewController.moviesArray objectAtIndex:indexPath.row];
    [cell.movie_imageView setImageWithURL:[NSURL URLWithString:movie.webImg]
                         placeholderImage:[UIImage imageNamed:@"movie_placeholder@2x"] options:SDWebImageRetryFailed];
    
    [cell.movie_imageView setFrame:CGRectMake(6, 9, 65, 87)];//解决图片显示尺寸不正常的Bug
    
    cell.rating_from = [NSString stringWithFormat:@"%@评分: ",movie.ratingFrom];
    int ratingPeople = [movie.ratingpeople intValue];
    if (ratingPeople >10000) {
//        float tratingPeople = ratingPeople/10000.0f;
         cell.movie_rating.text = [NSString stringWithFormat:@"%0.1f",[movie.rating floatValue]];
    }else{
         cell.movie_rating.text = [NSString stringWithFormat:@"%0.1f",[movie.rating floatValue]];
    }
    
   
    cell.movie_word.text = movie.aword;
    cell.movie_name.text = movie.name;
    [[cell viewWithTag:TuanViewTag] removeFromSuperview];
    
     NSMutableArray *array = [NSMutableArray arrayWithCapacity:3];
    if ([movie.isHot boolValue]) {
        [array addObject:cell.movie_image_hot];
    }
    if ([movie.isNew boolValue]) {
        [array addObject:cell.movie_image_new];
    }
    if ([movie.iMAX3D boolValue]) {
        [array addObject:cell.movie_image_3dimx];
    }
    if ([movie.iMAX boolValue]) {
        [array addObject:cell.movie_image_imx];
    }
    if ([movie.v3D boolValue]) {
        [array addObject:cell.movie_image_3d];
    }
    
    int twidth = 0;
    UIView *tuanView = [[UIView alloc] initWithFrame:CGRectZero];
    for (int i=0;i<[array count];i++) {
        
        UIView *tview = [array objectAtIndex:i];
        CGRect tframe = tview.frame;
        
        tframe.origin.x = twidth;
        twidth += tframe.size.width + 5;
        
        tview.frame = tframe;
        [tuanView addSubview:tview];
    }
    
    CGRect tFrame = [(UIView *)[array lastObject] frame];
    int tuanWidth = tFrame.origin.x+ tFrame.size.width;
    
    [cell addSubview:tuanView];
    tuanView.tag = TuanViewTag;
    [tuanView release];
    
//    int rightGap_of_postImg = 10;
    int cellWidth = cell.bounds.size.width;
    int postImgWidth = cell.movie_imageView.bounds.size.width;
    int postImgLeftMargin = cell.movie_imageView.bounds.origin.y;
    CGSize nameSize = [cell.movie_name.text sizeWithFont:[cell.movie_name font]
                              constrainedToSize:CGSizeMake((cellWidth-postImgLeftMargin-postImgWidth),MAXFLOAT)];

    int tuanGap = 0;
    if (nameSize.height<=cell.movie_name.bounds.size.height) {
        tuanGap = 10;
    }
    
    CGRect cell_newFrame = cell.movie_name.frame;
    cell_newFrame.size.width = nameSize.width;
    cell.movie_name.frame = cell_newFrame;
    
    int view_x = cell.movie_name.frame.origin.x+cell.movie_name.bounds.size.width +tuanGap;
    int tuanHeight = 15;
    [tuanView setFrame:CGRectMake(view_x, 0, tuanWidth, tuanHeight)];
    CGPoint newCenter = tuanView.center;
    newCenter.y = cell.movie_name.center.y;
    tuanView.center = newCenter;
    
    ABLoggerDebug(@"movie name %@",movie.name);
    ABLoggerDebug(@"nameSize == 111%@",NSStringFromCGSize(nameSize));
    ABLoggerInfo(@"cell.movie_name ===== 222 %@",NSStringFromCGRect(cell.movie_name.frame));
    ABLoggerInfo(@"tuan view frame ===== 333 %@",NSStringFromCGRect(tuanView.frame));
}

-(MovieTableViewCell *)createNewMocieCell{
    ABLoggerMethod();
    MovieTableViewCell * cell = [[[NSBundle mainBundle] loadNibNamed:@"MovieTableViewCell" owner:self options:nil] objectAtIndex:0];
    [cell setAccessoryType:UITableViewCellAccessoryNone];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;

    UIView *bgView = [[[UIView alloc] initWithFrame:cell.bounds] autorelease];
    [bgView setBackgroundColor:[UIColor colorWithWhite:0.996 alpha:1.000]];
    [cell setBackgroundView:bgView];
    
    cell.movie_imageView = [[[UIImageView alloc] init] autorelease];
    [cell.contentView addSubview:cell.movie_imageView];
    
    return cell;
}

#pragma mark -
#pragma mark UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 107.0f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    _parentViewController.cinemaViewController.movieDetailButton.hidden = NO;
    _parentViewController.cinemaViewController.mMovie = [_parentViewController.moviesArray objectAtIndex:indexPath.row];
    ABLoggerDebug(@"_parentViewController.cinemaViewController.mMovie  === %@",_parentViewController.cinemaViewController.mMovie);
    [_parentViewController pushMovieCinemaAnimation];
    
}


#pragma mark -
#pragma mark Data Source Loading / Reloading Methods

- (void)reloadTableViewDataSource{
	_reloading = YES;
	[_parentViewController loadNewData];
}

- (void)doneReLoadingTableViewData
{
	//  model should call this when its done loading
	_reloading = NO;
	[_refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:_mTableView];
}

#pragma mark -
#pragma mark UIScrollViewDelegate Methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    [_refreshHeaderView egoRefreshScrollViewDidScroll:scrollView];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
	[_refreshHeaderView egoRefreshScrollViewDidEndDragging:scrollView];
}


#pragma mark -
#pragma mark EGORefreshTableHeaderDelegate Methods

- (void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView*)view{
	if (view.tag == EGOHeaderView) {
        [self reloadTableViewDataSource];
        [self performSelector:@selector(doneReLoadingTableViewData) withObject:nil afterDelay:3.0];
    }
}

- (BOOL)egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView*)view{
	return _reloading; // should return if data source model is reloading
}

- (NSDate*)egoRefreshTableHeaderDataSourceLastUpdated:(EGORefreshTableHeaderView*)view{
	
	return [[DataBaseManager sharedInstance] date]; // should return date data source was last changed
	
}



@end
