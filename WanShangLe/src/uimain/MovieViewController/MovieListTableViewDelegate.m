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

typedef enum {
    EGOHeaderView = 0,
    EGOBottomView
} EGORefreshView;

@interface MovieListTableViewDelegate(){

}

@end

@implementation MovieListTableViewDelegate

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
#pragma mark Data Source Loading / Reloading Methods

- (void)reloadTableViewDataSource{
    
    //    [_model reload];
	_reloading = YES;
	
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
	
	return [NSDate date]; // should return date data source was last changed
	
}


#pragma mark -
#pragma mark UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [_parentViewController.moviesArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    ABLoggerMethod();
    static NSString *CellIdentifier = @"mMovieCell";
    static BOOL nibsRegistered = NO;
    if (!nibsRegistered) {
        UINib *nib = [UINib nibWithNibName:@"MovieTableViewCell" bundle:nil];
        [tableView registerNib:nib forCellReuseIdentifier:CellIdentifier];
        nibsRegistered = YES;
    }
    
    MovieTableViewCell * cell = (MovieTableViewCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
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
    cell.movie_name.text = movie.name;
    cell.movie_new.hidden = YES;
    if ([movie.newMovie boolValue]) {
        cell.movie_new.hidden = NO;
    }
    cell.movie_rating.text = [NSString stringWithFormat:@"%@ : %0.1f (%d 万人)",movie.ratingFrom,[movie.rating floatValue],[movie.ratingpeople intValue]/10000];
    cell.movie_word.text = movie.aword;
    
}

-(MovieTableViewCell *)createNewMocieCell{
    ABLoggerMethod();
    MovieTableViewCell * cell = [[[NSBundle mainBundle] loadNibNamed:@"MovieTableViewCell" owner:self options:nil] objectAtIndex:0];
    [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    //    cell.selectedBackgroundView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"history_menu_cell_background"]] autorelease];
    return cell;
}

#pragma mark -
#pragma mark UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 80.0f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    _parentViewController.cinemaViewController.movieDetailButton.hidden = NO;
    _parentViewController.cinemaViewController.mMovie = [_parentViewController.moviesArray objectAtIndex:indexPath.row];
    [_parentViewController pushMovieCinemaAnimation];
}



@end
