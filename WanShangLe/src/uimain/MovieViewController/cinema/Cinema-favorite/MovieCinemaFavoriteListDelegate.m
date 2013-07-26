//
//  MovieListTableViewDelegate.m
//  WanShangLe
//
//  Created by stephenliu on 13-6-8.
//  Copyright (c) 2013年 stephenliu. All rights reserved.
//
#import "MovieCinemaFavoriteListDelegate.h"
#import "CinemaFavoriteViewController.h"
#import "CinemaTableViewCell.h"
#import "MCinema.h"

#import "ScheduleViewController.h"
#import "CinemaMovieViewController.h"
#import "CinemaViewController.h"

#define TagTuan 500

@interface MovieCinemaFavoriteListDelegate(){
    
}
@end

@implementation MovieCinemaFavoriteListDelegate

#pragma mark -
#pragma mark UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return [_mArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [self ktvCelltableView:tableView cellForRowAtIndexPath:indexPath];
}

#pragma mark -
#pragma mark 正常模式Cell
- (UITableViewCell *)ktvCelltableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *CellIdentifier = @"mCinemaCell";
    
    CinemaTableViewCell * cell = (CinemaTableViewCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [self createNewMocieCell];
    }
    
    [self configCell:cell cellForRowAtIndexPath:indexPath];
    
    return cell;
}

-(CinemaTableViewCell *)createNewMocieCell{
    ABLoggerMethod();
    CinemaTableViewCell * cell = [[[NSBundle mainBundle] loadNibNamed:@"CinemaTableViewCell" owner:self options:nil] objectAtIndex:0];
    [cell setAccessoryType:UITableViewCellAccessoryNone];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

- (void)configCell:(CinemaTableViewCell *)cell cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    MCinema *aCinema = [_mArray objectAtIndex:indexPath.row];
    
    [self configureCell:cell withObject:aCinema];
}

- (void)configureCell:(CinemaTableViewCell *)cell withObject:(MCinema *)cinema {
    
    
    cell.cinema_name.text = cinema.name;
    cell.cinema_address.text = cinema.address;
    
    cell.cinema_image_location.hidden = YES;
    cell.cinema_distance.hidden = YES;
    
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
#pragma mark UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 80.0f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
        
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

@end
