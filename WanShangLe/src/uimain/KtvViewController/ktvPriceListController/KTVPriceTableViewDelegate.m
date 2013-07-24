//
//  KTVPriceTableViewDelegate.m
//  WanShangLe
//
//  Created by stephenliu on 13-7-5.
//  Copyright (c) 2013年 stephenliu. All rights reserved.
//

#import "KTVPriceTableViewDelegate.h"
#import "KTVPriceListViewController.h"
#import "KTVPriceTableViewCell.h"
#import "KTVPriceCellSection.h"

@implementation KTVPriceTableViewDelegate
#pragma mark -
#pragma mark UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [_mArray count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.isOpen) {
        if (self.selectIndex.section == section) {
            return [[[_mArray objectAtIndex:section] objectForKey:@"rooms"] count]+1;;
        }
    }
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (self.isOpen&&self.selectIndex.section == indexPath.section&&indexPath.row!=0) {
        return [self cinemaCelltableView:tableView cellForRowAtIndexPath:indexPath];
    }else
    {
        return [self cinemaSectiontableView:tableView cellForRowAtIndexPath:indexPath];
    }
}

-(UITableViewCell *)cinemaCelltableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"KTVPriceTableViewCell";
    
    KTVPriceTableViewCell *cell = (KTVPriceTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (!cell) {
        ABLoggerMethod();
        cell = [[[NSBundle mainBundle] loadNibNamed:@"KTVPriceTableViewCell" owner:self options:nil] objectAtIndex:0];
        [cell setAccessoryType:UITableViewCellAccessoryNone];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    NSArray *list = [[_mArray objectAtIndex:self.selectIndex.section] objectForKey:@"rooms"];
    
    [self configureCell:cell withObject:[list objectAtIndex:indexPath.row-1]];
    
    return cell;
}


- (void)configureCell:(KTVPriceTableViewCell *)cell withObject:(NSDictionary *)roomDic {
    cell.room_name.text = [[roomDic allKeys] lastObject];
    cell.room_price.text = [NSString stringWithFormat:@"%@元起",[[roomDic allValues] lastObject]];
}

-(UITableViewCell *)cinemaSectiontableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"KTVPriceCellSection";
    
    KTVPriceCellSection *cell = (KTVPriceCellSection *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        cell = [self createNewCellSection];
    }
    
    NSDictionary *roomDic = [_mArray objectAtIndex:indexPath.section];
    NSString *starttime = [roomDic objectForKey:@"starttime"];
    NSString *endtime = [roomDic objectForKey:@"endtime"];
    NSArray *list = [roomDic objectForKey:@"rooms"];
    
    cell.room_time.text = [NSString stringWithFormat:@"%@到%@",starttime,endtime];
    cell.room_count.text = [NSString stringWithFormat:@"%d种包厢价格",[list count]];
    [cell changeArrowWithUp:([self.selectIndex isEqual:indexPath]?YES:NO)];
    return cell;
    
}

-(KTVPriceCellSection *)createNewCellSection{
    ABLoggerMethod();
    KTVPriceCellSection * cell = [[[NSBundle mainBundle] loadNibNamed:@"KTVPriceCellSection" owner:self options:nil] objectAtIndex:0];
    [cell setAccessoryType:UITableViewCellAccessoryNone];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

#pragma mark -
#pragma mark UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (indexPath.row!=0) {
        return 35.0f;
    }
    return 30.0f;
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
        
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)didSelectCellRowFirstDo:(BOOL)firstDoInsert nextDo:(BOOL)nextDoInsert
{
    self.isOpen = firstDoInsert;
    
    KTVPriceCellSection *cell = (KTVPriceCellSection *)[_mTableView cellForRowAtIndexPath:self.selectIndex];
    [cell changeArrowWithUp:firstDoInsert];
    
    [_mTableView beginUpdates];
    
    int section = self.selectIndex.section;
    int contentCount = [[[_mArray objectAtIndex:section] objectForKey:@"rooms"] count];
	NSMutableArray* rowToInsert = [[NSMutableArray alloc] init];
	for (NSUInteger i = 1; i < contentCount + 1; i++) {
		NSIndexPath* indexPathToInsert = [NSIndexPath indexPathForRow:i inSection:section];
		[rowToInsert addObject:indexPathToInsert];
	}
	
	if (firstDoInsert)
    {   [_mTableView insertRowsAtIndexPaths:rowToInsert withRowAnimation:UITableViewRowAnimationTop];
    }
	else
    {
        [_mTableView deleteRowsAtIndexPaths:rowToInsert withRowAnimation:UITableViewRowAnimationTop];
    }
    
	[rowToInsert release];
	
	[_mTableView endUpdates];
    
    if (nextDoInsert) {
        self.isOpen = YES;
        self.selectIndex = [_mTableView indexPathForSelectedRow];
        [self didSelectCellRowFirstDo:YES nextDo:NO];
    }
    if (self.isOpen) [_mTableView scrollToNearestSelectedRowAtScrollPosition:UITableViewScrollPositionTop animated:YES];
}
@end
