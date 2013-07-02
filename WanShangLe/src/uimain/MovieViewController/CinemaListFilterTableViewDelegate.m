//
//  CinemaListTableViewDelegate.m
//  WanShangLe
//
//  Created by stephenliu on 13-6-8.
//  Copyright (c) 2013年 stephenliu. All rights reserved.
//

#import "CinemaListFilterTableViewDelegate.h"
#import "CinemaViewController.h"
#import "CinemaTableViewCell.h"
#import "CinemaTableViewCellSection.h"
#import "ScheduleViewController.h"
#import "CinemaMovieViewController.h"
#import "MovieViewController.h"
#import "SearchCoreManager.h"
#import "MCinema.h"
#import <QuartzCore/QuartzCore.h>
#import"OHAttributedLabel.h"
#import "NSAttributedString+Attributes.h"
#import "OHASBasicMarkupParser.h"

static NSInteger const kAttributedLabelTag = 100;
static CGFloat const kLabelWidth = 300;
static CGFloat const kLabelVMargin = 10;

@interface CinemaListFilterTableViewDelegate(){
    
}
@property (nonatomic,assign) NSArray *mArray;;
@end

@implementation CinemaListFilterTableViewDelegate

- (id)init{
    self = [super init];
    if (self) {
        [self initData];
    }
    return self;
}

- (void)dealloc{
    
    [super dealloc];
}

- (void)initData{
    _mArray = _parentViewController.cinemasArray;
}

#pragma mark -
#pragma mark UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    _mArray = _parentViewController.cinemasArray;
    return [_mArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    _mArray = _parentViewController.cinemasArray;
    static NSString *CellIdentifier = @"mCinemaCell";
    
    CinemaTableViewCell *cell = (CinemaTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell==nil) {
        cell = [self createNewMocieCell];
    }
    
    MCinema *aCinema = [_mArray objectAtIndex:indexPath.row];
    
    [self configureCell:cell withObject:aCinema];
    
    return cell;
    
}

- (void)configureCell:(CinemaTableViewCell *)cell withObject:(MCinema *)cinema {
    
    cell.cinema_name.text = cinema.name;
    cell.cinema_address.text = cinema.address;
    
    if (_isFavoriteList) {
        cell.cinema_image_location.hidden = YES;
        cell.cinema_distance.hidden = YES;
    }else{
        cell.cinema_image_location.hidden = NO;
        cell.cinema_distance.hidden = NO;
        
        NSString *kmStr = nil;
        int distance = [cinema.nearby intValue];
        if (distance>1000) {
           kmStr = [NSString stringWithFormat:@"%0.2fkm",distance/1000.0f];
        }else{
           kmStr = [NSString stringWithFormat:@"%dm",distance]; 
        }
        
        cell.cinema_distance.text = kmStr;
    }
    
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

-( CinemaTableViewCell *)createNewMocieCell{
    ABLoggerMethod();
    CinemaTableViewCell * cell = [[[NSBundle mainBundle] loadNibNamed:@"CinemaTableViewCell" owner:self options:nil] objectAtIndex:0];
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

#pragma mark - Table view delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    _mArray = _parentViewController.cinemasArray;
    MCinema *mCinema = [_mArray objectAtIndex:indexPath.row];
    
    if (!_parentViewController.movieDetailButton.hidden) {
        ScheduleViewController *scheduleViewController = [[ScheduleViewController alloc]
                                                          initWithNibName:(iPhone5?@"ScheduleViewController_5":@"ScheduleViewController")
                                                          bundle:nil];
        scheduleViewController.mCinema = mCinema;
        scheduleViewController.mMovie = _parentViewController.mMovie;
        [_parentViewController.mparentController.navigationController pushViewController:scheduleViewController animated:YES];
        [scheduleViewController release];
    }else{
        CinemaMovieViewController *cinemaMovieController = [[CinemaMovieViewController alloc]
                                                            initWithNibName:(iPhone5?@"CinemaMovieViewController_5":@"CinemaMovieViewController")
                                                            bundle:nil];
        cinemaMovieController.mCinema = mCinema;
        cinemaMovieController.mMovie = _parentViewController.mMovie;
        [_parentViewController.mparentController.navigationController pushViewController:cinemaMovieController animated:YES];
        [cinemaMovieController release];
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
