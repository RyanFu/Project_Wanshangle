//
//  CinemaListTableViewDelegate.m
//  WanShangLe
//
//  Created by stephenliu on 13-6-8.
//  Copyright (c) 2013年 stephenliu. All rights reserved.
//

#import "CinemaListTableViewDelegate.h"
#import "CinemaViewController.h"
#import "CinemaTableViewCell.h"
#import "CinemaTableViewCellSection.h"
#import "ScheduleViewController.h"
#import "CinemaMovieViewController.h"
#import "MCinema.h"

@interface CinemaListTableViewDelegate(){
    
}
@property (nonatomic,retain)NSIndexPath *selectIndex;
@end

@implementation CinemaListTableViewDelegate

#pragma mark -
#pragma mark UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [_parentViewController.cinemasArray count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.isOpen) {
        if (self.selectIndex.section == section) {
            return [[[_parentViewController.cinemasArray objectAtIndex:section] objectForKey:@"list"] count]+1;;
        }
    }
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (self.isOpen&&self.selectIndex.section == indexPath.section&&indexPath.row!=0) {
        
       static NSString *CellIdentifier = @"mCinemaCell";
        static BOOL nibsRegistered = NO;
        if (!nibsRegistered) {
            UINib *nib = [UINib nibWithNibName:@"CinemaTableViewCell" bundle:nil];
            [tableView registerNib:nib forCellReuseIdentifier:CellIdentifier];
            nibsRegistered = YES;
        }

        CinemaTableViewCell *cell = (CinemaTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        if (!cell) {
            cell = [[[NSBundle mainBundle] loadNibNamed:@"CinemaTableViewCell" owner:self options:nil] objectAtIndex:0];
        }
        NSArray *list = [[_parentViewController.cinemasArray objectAtIndex:self.selectIndex.section] objectForKey:@"list"];
        
        [self configureCell:cell withObject:[list objectAtIndex:indexPath.row-1]];
        
        return cell;
    }else
    {
        
        static NSString *CellIdentifier = @"mCinemaDistrictCell";
        static BOOL nibsRegistered = NO;
        if (!nibsRegistered) {
            UINib *nib = [UINib nibWithNibName:@"CinemaTableViewCellSection" bundle:nil];
            [tableView registerNib:nib forCellReuseIdentifier:CellIdentifier];
            nibsRegistered = YES;
        }
        
        CinemaTableViewCellSection *cell = (CinemaTableViewCellSection *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (!cell) {
            [self createNewMocieCell];
        }
        
        NSString *name = [[_parentViewController.cinemasArray objectAtIndex:indexPath.section] objectForKey:@"name"];
        NSArray *list = [[_parentViewController.cinemasArray objectAtIndex:self.selectIndex.section] objectForKey:@"list"];
        cell.cinema_district.text = [NSString stringWithFormat:@"%@  (共%d家)",name,[list count]];
        [cell changeArrowWithUp:([self.selectIndex isEqual:indexPath]?YES:NO)];
        return cell;
    }
}

- (void)configureCell:(CinemaTableViewCell *)cell withObject:(MCinema *)cinema {
    
    cell.cinema_name.text = cinema.name;
    cell.cinema_address.text = cinema.address;
    cell.cinema_count.text = [NSString stringWithFormat:@"34场"];
    cell.cinema_price.text = [NSString stringWithFormat:@"25-75元"];
    cell.cinema_tuan.hidden = NO;
}

-(CinemaTableViewCell *)createNewMocieCell{
    ABLoggerMethod();
    CinemaTableViewCell * cell = [[[NSBundle mainBundle] loadNibNamed:@"CinemaTableViewCellSection" owner:self options:nil] objectAtIndex:0];
    [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    //    cell.selectedBackgroundView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"history_menu_cell_background"]] autorelease];
    return cell;
}

#pragma mark -
#pragma mark UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (indexPath.row!=0) {
        return 80.0f;
    }
    return 44.0f;
}

#pragma mark - Table view delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        if ([indexPath isEqual:self.selectIndex]) {
            self.isOpen = NO;
            [self didSelectCellRowFirstDo:NO nextDo:NO];
            self.selectIndex = nil;
            
        }else
        {
            if (!self.selectIndex) {
                self.selectIndex = indexPath;
                [self didSelectCellRowFirstDo:YES nextDo:NO];
                
            }else
            {
                
                [self didSelectCellRowFirstDo:NO nextDo:YES];
            }
        }
        
    }else
    {
        NSDictionary *dic = [_parentViewController.cinemasArray objectAtIndex:indexPath.section];
        NSArray *list = [dic objectForKey:@"list"];
        MCinema *mCinema = [list objectAtIndex:indexPath.row-1];

        if (_parentViewController.isMovie_Cinema) {
            ScheduleViewController *scheduleViewController = [[ScheduleViewController alloc]
                                                              initWithNibName:(iPhone5?@"ScheduleViewController_5":@"ScheduleViewController")
                                                              bundle:nil];
            scheduleViewController.mCinema = mCinema;
            scheduleViewController.mMovie = _parentViewController.mMovie;
            [_parentViewController.navigationController pushViewController:scheduleViewController animated:YES];
            [scheduleViewController release];
        }else{
            CinemaMovieViewController *cinemaMovieController = [[CinemaMovieViewController alloc]
                                                                initWithNibName:(iPhone5?@"CinemaMovieViewController_5":@"CinemaMovieViewController")
                                                                bundle:nil];
            cinemaMovieController.mCinema = mCinema;
            cinemaMovieController.mMovie = _parentViewController.mMovie;
            [_parentViewController.navigationController pushViewController:cinemaMovieController animated:YES];
            [cinemaMovieController release];
        }
        
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)didSelectCellRowFirstDo:(BOOL)firstDoInsert nextDo:(BOOL)nextDoInsert
{
    self.isOpen = firstDoInsert;
    
    CinemaTableViewCellSection *cell = (CinemaTableViewCellSection *)[_parentViewController.cinemaTableView cellForRowAtIndexPath:self.selectIndex];
    [cell changeArrowWithUp:firstDoInsert];
    
    [_parentViewController.cinemaTableView beginUpdates];
    
    int section = self.selectIndex.section;
    int contentCount = [[[_parentViewController.cinemasArray objectAtIndex:section] objectForKey:@"list"] count];
	NSMutableArray* rowToInsert = [[NSMutableArray alloc] init];
	for (NSUInteger i = 1; i < contentCount + 1; i++) {
		NSIndexPath* indexPathToInsert = [NSIndexPath indexPathForRow:i inSection:section];
		[rowToInsert addObject:indexPathToInsert];
	}
	
	if (firstDoInsert)
    {   [_parentViewController.cinemaTableView insertRowsAtIndexPaths:rowToInsert withRowAnimation:UITableViewRowAnimationTop];
    }
	else
    {
        [_parentViewController.cinemaTableView deleteRowsAtIndexPaths:rowToInsert withRowAnimation:UITableViewRowAnimationTop];
    }
    
	[rowToInsert release];
	
	[_parentViewController.cinemaTableView endUpdates];
    if (nextDoInsert) {
        self.isOpen = YES;
        self.selectIndex = [_parentViewController.cinemaTableView indexPathForSelectedRow];
        [self didSelectCellRowFirstDo:YES nextDo:NO];
    }
    if (self.isOpen) [_parentViewController.cinemaTableView scrollToNearestSelectedRowAtScrollPosition:UITableViewScrollPositionTop animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 0;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    return nil;
}
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    return nil;
}
@end
