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
#import "UIImageView+WebCache.h"
#import "MMovie.h"

@implementation MovieListTableViewDelegate

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
                         placeholderImage:[UIImage imageNamed:@"placeholder"] options:SDWebImageRetryFailed];
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
    [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
    cell.selectionStyle = UITableViewCellSelectionStyleBlue;
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
}


@end
