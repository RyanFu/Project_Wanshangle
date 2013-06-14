//
//  BuyInfoTableViewDelegate.m
//  WanShangLe
//
//  Created by liu on 6/13/13.
//  Copyright (c) 2013 stephenliu. All rights reserved.
//

#import "BuyInfoTableViewDelegate.h"
#import "BuyInfoViewController.h"
#import "BuyInfoTableViewCell.h"

@interface BuyInfoTableViewDelegate()
@property (nonatomic,retain)NSIndexPath *newselectIndex;
@property (nonatomic,retain)NSIndexPath *oldselectIndex;
@end

@implementation BuyInfoTableViewDelegate

- (void)dealloc{
    self.newselectIndex = nil;
    self.oldselectIndex = nil;
    [super dealloc];
}
#pragma mark -
#pragma mark UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSLog(@"numberOfRowsInSection == %d",[_parentViewController.marray count]);
    return [_parentViewController.marray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSLog(@"cellForRowAtIndexPath ====== %d",indexPath.row);
    
    static NSString *CellIdentifier = @"BuyInfoTableViewCell";
    static BOOL nibsRegistered = NO;
    if (!nibsRegistered) {
        UINib *nib = [UINib nibWithNibName:@"BuyInfoTableViewCell" bundle:nil];
        [tableView registerNib:nib forCellReuseIdentifier:CellIdentifier];
        nibsRegistered = YES;
    }
    
    BuyInfoTableViewCell *cell = (BuyInfoTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (!cell) {
        cell = [self createNewMocieCell];
    }
    
    cell.expansionView.hidden = YES;
    
    [self configureCell:cell cellForRowAtIndexPath:indexPath withObject:nil];
    
    return cell;
}

- (void)configureCell:(BuyInfoTableViewCell *)cell cellForRowAtIndexPath:(NSIndexPath *)indexPath withObject:(NSDictionary *)dataDic {
    
    if (_newselectIndex.row == indexPath.row) {
        cell.expansionView.hidden = NO;
    }else if(_oldselectIndex.row == indexPath.row){
        cell.expansionView.hidden = YES;
    }
}

-(BuyInfoTableViewCell *)createNewMocieCell{
    
    BuyInfoTableViewCell * cell = [[[NSBundle mainBundle] loadNibNamed:@"CinemaTableViewCellSection" owner:self options:nil] objectAtIndex:0];
    [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
    cell.selectionStyle = UITableViewCellSelectionStyleBlue;
    //    cell.selectedBackgroundView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"history_menu_cell_background"]] autorelease];
    return cell;
}

#pragma mark -
#pragma mark UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    //If this is the selected index we need to return the height of the cell
    //in relation to the label height otherwise we just return the minimum label height with padding
    if(_newselectIndex.row == indexPath.row)
    {
        return 410.0f;
    }
    else if(indexPath.row == 0){
        return 80.0f;
    }else{
        return 44.0f;
    }
}

#pragma mark - Table view delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    self.oldselectIndex = self.newselectIndex;
    
    if (self.newselectIndex.row == indexPath.row) {
        self.newselectIndex = [NSIndexPath indexPathForRow:-1 inSection:-1];
    }else{
        self.newselectIndex = indexPath;
    }
    
    
    NSLog(@"oldselectIndex section = %d row = %d",_oldselectIndex.section,_oldselectIndex.row);
    NSLog(@"newselectIndex section = %d row = %d",_newselectIndex.section,_newselectIndex.row);
    
    [self didExpansionCell];
}

- (void)didExpansionCell{
    
    [_parentViewController.mTableView beginUpdates];
    
    if (_oldselectIndex.row != -1 && _oldselectIndex.row != _newselectIndex.row) {
        [_parentViewController.mTableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:_oldselectIndex, nil] withRowAnimation:UITableViewRowAnimationFade];
    }
    
    if (_newselectIndex.row != -1) {
        [_parentViewController.mTableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:_newselectIndex, nil] withRowAnimation:UITableViewRowAnimationFade];
    }
    
    [_parentViewController.mTableView endUpdates];
    
    if (_newselectIndex.row != -1) {
        [_parentViewController.mTableView scrollToRowAtIndexPath:_newselectIndex atScrollPosition:UITableViewScrollPositionTop animated:YES];
    }
    
}

@end
