//
//  KTVBuyTableViewDelegate.m
//  WanShangLe
//
//  Created by stephenliu on 13-7-5.
//  Copyright (c) 2013年 stephenliu. All rights reserved.
//

#import "KTVBuyTableViewDelegate.h"
#import "KTVBuyViewController.h"
#import "KTVBuyCell.h"

@implementation KTVBuyTableViewDelegate
#pragma mark -
#pragma mark UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [_parentViewController.mArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    ABLoggerMethod();
    static NSString *CellIdentifier = @"mKTVBuyCell";
    
    KTVBuyCell * cell = (KTVBuyCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [self createNewMocieCell];
    }
    
    [self configureCell:cell atIndexPath:indexPath];
    
    return cell;
}

-(KTVBuyCell *)createNewMocieCell{
    ABLoggerMethod();
    KTVBuyCell * cell = [[[NSBundle mainBundle] loadNibNamed:@"KTVBuyCell" owner:self options:nil] objectAtIndex:0];
    [cell setAccessoryType:UITableViewCellAccessoryNone];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

- (void)configureCell:(KTVBuyCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    
    NSArray *_mArray = _parentViewController.mArray;
}

#pragma mark -
#pragma mark UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 44;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
