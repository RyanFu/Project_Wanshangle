//
//  MovieListTableViewDelegate.m
//  WanShangLe
//
//  Created by stephenliu on 13-6-8.
//  Copyright (c) 2013年 stephenliu. All rights reserved.
//
#import "KTVFavoriteListTableViewDelegate.h"
#import "KTVBuyViewController.h"
#import "KtvViewController.h"
#import "KTVTableViewCell.h"
#import "KKTV.h"

#define TagTuan 500

@interface KTVFavoriteListTableViewDelegate(){
    
}
@property(nonatomic,readonly) NSFilterKTVListType filterKTVListType;
@end

@implementation KTVFavoriteListTableViewDelegate

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
    ABLoggerMethod();
    
    static NSString *CellIdentifier = @"MKTVCellIdentifier";
    
    KTVTableViewCell * cell = (KTVTableViewCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [self createNewMocieCell];
    }
    
    [self configCell:cell cellForRowAtIndexPath:indexPath];
    
    return cell;
}

-(KTVTableViewCell *)createNewMocieCell{
    ABLoggerMethod();
    KTVTableViewCell * cell = [[[NSBundle mainBundle] loadNibNamed:@"KTVTableViewCell" owner:self options:nil] objectAtIndex:0];
    [cell setAccessoryType:UITableViewCellAccessoryNone];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

- (void)configCell:(KTVTableViewCell *)cell cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    KKTV *aKTV = nil;
    int row = indexPath.row;

    _filterKTVListType = _parentViewController.filterKTVListType;
    
    cell.ktv_distance.hidden = YES;
    cell.ktv_image_location.hidden = YES;

    aKTV = [_mArray objectAtIndex:row];

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
#pragma mark UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 70.0f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    KTVBuyViewController *ktvBuyController = [[KTVBuyViewController alloc] initWithNibName:iPhone5?@"KTVBuyViewController_5":@"KTVBuyViewController" bundle:nil];
    
    int row = indexPath.row;
    _filterKTVListType = _parentViewController.filterKTVListType;
    KKTV *aKTV = [_mArray objectAtIndex:row];

    ktvBuyController.mKTV = aKTV;
    [_parentViewController.navigationController pushViewController:ktvBuyController animated:YES];
    [ktvBuyController release];
}

@end
