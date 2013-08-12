//
//  MovieListTableViewDelegate.m
//  WanShangLe
//
//  Created by stephenliu on 13-6-8.
//  Copyright (c) 2013年 stephenliu. All rights reserved.
//
#import "ScheduleTableViewDelegate.h"
#import "ScheduleTableViewCell.h"
#import "ScheduleViewController.h"
#import "BuyInfoViewController.h"
#import "MSchedule.h"
#import "MMovie.h"

@implementation ScheduleTableViewDelegate

#pragma mark -
#pragma mark UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [_parentViewController.schedulesArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    ABLoggerMethod();
    static NSString *CellIdentifier = @"mScheduleCell";
//    static BOOL nibsRegistered = NO;
//    if (!nibsRegistered) {
//        UINib *nib = [UINib nibWithNibName:@"ScheduleTableViewCell" bundle:nil];
//        [tableView registerNib:nib forCellReuseIdentifier:CellIdentifier];
//        nibsRegistered = YES;
//    }
    
    ScheduleTableViewCell * cell = (ScheduleTableViewCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [self createNewMocieCell];
    }
    
    [self configureCell:cell atIndexPath:indexPath];
    
    return cell;
}

- (void)configureCell:(ScheduleTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    
    NSArray *_mArray = _parentViewController.schedulesArray;
    NSDictionary *tDic = [_mArray objectAtIndex:indexPath.row];
    
    cell.tuan_seat_imgView.hidden = ![[tDic objectForKey:@"extpay"] boolValue];

    cell.schedule_time.text = [[DataBaseManager sharedInstance] getTimeFromDate:[tDic objectForKey:@"time"]];
    cell.schedule_price.text = [NSString stringWithFormat:@"%@元起",[[tDic objectForKey:@"lowestprice"] stringValue]];
    cell.schedule_timeLong.text = [NSString stringWithFormat:@"预计%@结束",
                                   [[DataBaseManager sharedInstance] timeByAddingTimeInterval:[_parentViewController.mMovie.duration intValue] fromDate:[tDic objectForKey:@"time"]]];
    
    NSString *viewType = @"3D";
    NSArray *tarray = [tDic objectForKey:@"viewtypes"];
    for (int i=0;i<[tarray count];i++) {
        
        if ([[tarray objectAtIndex:i] intValue]==0) {
            continue;
        }
        switch (i) {
            case 0:
                viewType = @"3DIMAX";
                break;
            case 1:
                viewType = @"IMAX";
                break;
                
            default:
                viewType = @"3D";
                break;
        }
        
        break;
    }
    cell.schedule_view.text = [NSString stringWithFormat:@"%@",viewType];
}

-(ScheduleTableViewCell *)createNewMocieCell{
    ABLoggerMethod();
     ScheduleTableViewCell * cell = [[[NSBundle mainBundle] loadNibNamed:@"ScheduleTableViewCell" owner:self options:nil] objectAtIndex:0];
    [cell setAccessoryType:UITableViewCellAccessoryNone];
    cell.selectionStyle = UITableViewCellSelectionStyleGray;

    UIView *selectedBgView = [[UIView alloc] initWithFrame:cell.bounds];
    selectedBgView.backgroundColor = Color8;
    [cell setSelectedBackgroundView:selectedBgView];
    [selectedBgView release];
    
    return cell;
}

#pragma mark -
#pragma mark UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 57;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSArray *_mArray = _parentViewController.schedulesArray;
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSDictionary *tDic = [_mArray objectAtIndex:indexPath.row];
    
    BuyInfoViewController *buyInfoController = [[BuyInfoViewController alloc] initWithNibName:(iPhone5?@"BuyInfoViewController_5":@"BuyInfoViewController") bundle:nil];
    buyInfoController.mSchedule = [tDic objectForKey:@"time"];
    buyInfoController.mPrice = [NSString stringWithFormat:@"%d",[[tDic objectForKey:@"lowestprice"] intValue]];
    buyInfoController.mMovie = _parentViewController.mMovie;
    buyInfoController.mCinema = _parentViewController.mCinema;
    [[CacheManager sharedInstance].rootNavController pushViewController:buyInfoController animated:YES];
    [buyInfoController release];
}


@end
