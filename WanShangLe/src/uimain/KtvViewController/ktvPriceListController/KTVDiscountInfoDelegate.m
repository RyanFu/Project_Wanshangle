//
//  BuyInfoTableViewDelegate.m
//  WanShangLe
//
//  Created by liu on 6/13/13.
//  Copyright (c) 2013 stephenliu. All rights reserved.
//

#import "KTVDiscountInfoDelegate.h"
#import "KTVPriceListViewController.h"
#import "KTVDiscountTableViewCell.h"

#define CellInfoLabelHeight 20

@interface KTVDiscountInfoDelegate(){
    
}
//@property(nonatomic,retain) UITableViewCell *topCell;
//@property(nonatomic,retain) UITableViewCell *bottomCell;
@end

@implementation KTVDiscountInfoDelegate

- (id)init{
    self = [super init];
    if (self) {
        [self initData];
    }
    return self;
}

- (void)dealloc{
//    self.topCell = nil;
//    self.bottomCell = nil;
    [super dealloc];
}

- (void)initData{
}
#pragma mark -
#pragma mark UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    //3是因为头和尾的圆角cell
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_mArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
//    int section = indexPath.section;
//    switch (section) {
//        case 0:{
//            if (_topCell==nil) {
//                _topCell = [[UITableViewCell alloc] initWithFrame:CGRectMake(0, 0, iPhoneAppFrame.size.width, 45)];
//                UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 0, iPhoneAppFrame.size.width-20, _topCell.bounds.size.height)];
//                imgView.image = [UIImage imageNamed:@"cell_top_n@2x"];
//                [_topCell.contentView addSubview:imgView];
//                [imgView release];
//                
//                UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(20, 12, 79, 21)];
//                label.backgroundColor = [UIColor clearColor];
//                label.text = @"折扣详情";
//                [_topCell.contentView addSubview:label];
//                [label release];
//                
//                _topCell.contentView.backgroundColor = [UIColor clearColor];
//                _topCell.backgroundColor = [UIColor clearColor];
//            }
//
//            return _topCell;
//        }
//            
//        case 2:{
//            if (_bottomCell==nil) {
//                _bottomCell = [[UITableViewCell alloc] initWithFrame:CGRectMake(0, 0, iPhoneAppFrame.size.width, 45)];
//                UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 0, iPhoneAppFrame.size.width-20, _topCell.bounds.size.height)];
//                imgView.image = [UIImage imageNamed:@"cell_bottom_n@2x"];
//                [_bottomCell.contentView addSubview:imgView];
//                [imgView release];
//                
//                _bottomCell.contentView.backgroundColor = [UIColor clearColor];
//                _bottomCell.backgroundColor = [UIColor clearColor];
//            }
//            return _bottomCell;
//        }
//    }
    
    static NSString *CellIdentifier = @"KTVDiscountTableViewCell";
    
    KTVDiscountTableViewCell *cell = (KTVDiscountTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (!cell) {
        cell = [self createNewCell];
    }
    
    NSDictionary *cellData = [_mArray objectAtIndex:indexPath.row];
    [self configureCell:cell cellForRowAtIndexPath:indexPath withObject:cellData];
    
    return cell;
}

- (void)configureCell:(KTVDiscountTableViewCell *)cell cellForRowAtIndexPath:(NSIndexPath *)indexPath withObject:(NSDictionary *)dataDic {
    
    cell.contentView.backgroundColor = [UIColor clearColor];
    cell.backgroundColor = [UIColor clearColor];
    
    int row = indexPath.row+1;
    [cell.badgeButton setTitle:[NSString stringWithFormat:@"%d",row] forState:UIControlStateNormal];
    
    if ([[dataDic objectForKey:@"longterm"] boolValue]) {
        cell.discount_time.text = @"长期可用";
    }else{
        NSString *starttime =[[DataBaseManager sharedInstance] getYMDFromDate:[dataDic objectForKey:@"starttime"]] ;
        NSString *endtime = [[DataBaseManager sharedInstance] getYMDFromDate:[dataDic objectForKey:@"endtime"]];
        cell.discount_time.text = [NSString stringWithFormat:@"%@至%@",starttime,endtime];
    }
    
    cell.discount_info.text = [dataDic objectForKey:@"info"];
    
    CGSize size = [cell.discount_info.text sizeWithFont:[UIFont systemFontOfSize:17] constrainedToSize:CGSizeMake(280, MAXFLOAT)];
    if (size.height>CellInfoLabelHeight) {
        int dHeight = size.height-CellInfoLabelHeight;
        CGRect newFrame = cell.discount_info.frame;
        newFrame.size.height +=dHeight;
        cell.discount_info.frame = newFrame;
    }
}

-(KTVDiscountTableViewCell *)createNewCell{
    
    KTVDiscountTableViewCell * cell = [[[NSBundle mainBundle] loadNibNamed:@"KTVDiscountTableViewCell" owner:self options:nil] objectAtIndex:0];
    [cell setAccessoryType:UITableViewCellAccessoryNone];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

#pragma mark -
#pragma mark UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
        
    NSDictionary *cellData = [_mArray objectAtIndex:indexPath.row];
    NSString *discountInfo = [cellData objectForKey:@"info"];
    CGSize size = [discountInfo sizeWithFont:[UIFont systemFontOfSize:17] constrainedToSize:CGSizeMake(280, MAXFLOAT)];
    
    if (size.height>CellInfoLabelHeight) {
        int dHeight = size.height-CellInfoLabelHeight;
        return (80+dHeight);
    }
    return 80.0f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 0;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section;{
    return 0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    return nil;
}// custom view for header. will be adjusted to default or specified header height
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    return nil;
    
}// custom view for footer. will be adjusted to default or specified footer height

#pragma mark - Table view delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
//    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    [_parentViewController expandDiscountTableView];
}

@end
