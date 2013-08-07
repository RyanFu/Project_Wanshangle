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
#import "UIImageView+WebCache.h"
#import "WebSiteBuyViewController.h"
#import "SIAlertView.h"

@interface BuyInfoTableViewDelegate()
@end

@implementation BuyInfoTableViewDelegate

- (id)init{
    self = [super init];
    if (self) {
    }
    return self;
}

- (void)dealloc{
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
    return [_mArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *CellIdentifier = @"BuyInfoTableViewCell";
    
    BuyInfoTableViewCell *cell = (BuyInfoTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (!cell) {
        cell = [self createNewCell];
    }
    
    [self setCellCustomBackgroundView:cell cellForRowAtIndexPath:indexPath];
    
    NSDictionary *cellData = [_mArray objectAtIndex:indexPath.row];
    [self configureCell:cell cellForRowAtIndexPath:indexPath withObject:cellData];
    
    return cell;
}

- (void)setCellCustomBackgroundView:(BuyInfoTableViewCell *)cell cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    int row = indexPath.row;
    int count = [_mArray count];
    
    if (count==1) {//只有一条数据
        [cell.bg_button setBackgroundImage:[UIImage imageNamed:@"cell_one_n@2x"] forState:UIControlStateNormal];
        [cell.bg_button setBackgroundImage:[UIImage imageNamed:@"cell_one_f@2x"] forState:UIControlStateHighlighted];
    }else if(count>1 && row==0){
        [cell.bg_button setBackgroundImage:[UIImage imageNamed:@"cell_top_n@2x"] forState:UIControlStateNormal];
        [cell.bg_button setBackgroundImage:[UIImage imageNamed:@"cell_top_f@2x"] forState:UIControlStateHighlighted];
    }else if(count>1 && row==(count-1)){
        [cell.bg_button setBackgroundImage:[UIImage imageNamed:@"cell_bottom_n@2x"] forState:UIControlStateNormal];
        [cell.bg_button setBackgroundImage:[UIImage imageNamed:@"cell_bottom_f@2x"] forState:UIControlStateHighlighted];
    }else{
        [cell.bg_button setBackgroundImage:[UIImage imageNamed:@"cell_middle_n@2x"] forState:UIControlStateNormal];
        [cell.bg_button setBackgroundImage:[UIImage imageNamed:@"cell_middle_f@2x"] forState:UIControlStateHighlighted];
    }
}

- (void)configureCell:(BuyInfoTableViewCell *)cell cellForRowAtIndexPath:(NSIndexPath *)indexPath withObject:(NSDictionary *)dataDic {
    
    if (indexPath.row==0) {
        cell.lowPriceImg.hidden = NO;
    }else{
        cell.lowPriceImg.hidden = YES;
    }
    
    UIImage *tuanTypeImg = nil;
    switch ([[dataDic objectForKey:@"type"] intValue]) {
        case TuanGou:
            tuanTypeImg = [UIImage imageNamed:@"tag_tuan@2x"];
            break;
        case TuanJuan:
            tuanTypeImg = [UIImage imageNamed:@"tag_juan@2x"];
            break;
        case XuanZuo:
            tuanTypeImg = [UIImage imageNamed:@"tag_seat@2x"];
            break;
        default:
            tuanTypeImg = [UIImage imageNamed:@"tag_tuan@2x"];
            break;
    }
    cell.tuan_imgView.image = tuanTypeImg;
    cell.vendor_name.text = [dataDic objectForKey:@"supplierName"];
    cell.price.text = [NSString stringWithFormat:@"%@元",[dataDic objectForKey:@"price"]];
}

-(BuyInfoTableViewCell *)createNewCell{
    
    BuyInfoTableViewCell * cell = [[[NSBundle mainBundle] loadNibNamed:@"BuyInfoTableViewCell" owner:self options:nil] objectAtIndex:0];
    [cell setAccessoryType:UITableViewCellAccessoryNone];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    [cell.bg_button addTarget:self action:@selector(clickCellButton:) forControlEvents:UIControlEventTouchUpInside];
    return cell;
}

- (void)clickCellButton:(id)sender{
    UIButton *bt = (UIButton *)sender;
    
    BuyInfoTableViewCell *cell = (BuyInfoTableViewCell *)[[bt superview] superview];
    NSIndexPath *indexPath = [_mTableView indexPathForCell:cell];
    NSDictionary *dataDic = [_mArray objectAtIndex:indexPath.row];
    NSString *urlstr = [dataDic objectForKey:@"extpayurl"];
    
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    NSNumber *buy_hint_bool = [userDefault objectForKey:BuyInfo_HintType];
    
    if(isNull(buy_hint_bool) || ![buy_hint_bool boolValue]){
        NSString *supplierName = [dataDic objectForKey:@"supplierName"];
        SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"你将被跳转到%@完成购买",supplierName]
                                                         andMessage:@"\n\n\n"];
        [alertView addButtonWithTitle:@"取消"
                                 type:SIAlertViewButtonTypeCancel
                              handler:^(SIAlertView *alertView) {
                              }];
        [alertView addButtonWithTitle:@"继续"
                                 type:SIAlertViewButtonTypeDefault
                              handler:^(SIAlertView *alertView) {
                                  [self skipToBuyWebSite:urlstr];
                              }];
        //        alertView.titleFont = [UIFont boldSystemFontOfSize:17];
        //        alertView.messageFont = [UIFont systemFontOfSize:12];
        UILabel *promptLabel = [[[UILabel alloc] initWithFrame:CGRectMake(115, 60, 110, 22)] autorelease];
        promptLabel.backgroundColor = [UIColor clearColor];
        promptLabel.text = @"下次不再提醒";
        promptLabel.textColor = [UIColor colorWithWhite:0.400 alpha:1.000];
        
        UIButton *checkBox = [UIButton buttonWithType:UIButtonTypeCustom];
        [checkBox setImage:[UIImage imageNamed:@"btn_checkBox_n@2x"] forState:UIControlStateNormal];
        [checkBox setImage:[UIImage imageNamed:@"btn_checkBox_f@2x"] forState:UIControlStateSelected];
        [checkBox addTarget:self action:@selector(clickCheckBox:) forControlEvents:UIControlEventTouchUpInside];
        checkBox.frame = CGRectMake(85, 62, 20, 20);
        
        [alertView show];
        [alertView.containerView addSubview:checkBox];
        [alertView.containerView addSubview:promptLabel];
        
        [alertView release];
    }else{
        [self skipToBuyWebSite:urlstr];
    }
}

- (void)clickCheckBox:(id)sender{
    UIButton *bt = (UIButton *)sender;
    if (bt.selected) {
        bt.selected = NO;
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:BuyInfo_HintType];
    }else{
        bt.selected = YES;
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:BuyInfo_HintType];
    }
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)skipToBuyWebSite:(NSString *)wapURL{
    WebSiteBuyViewController *webViewController = [[WebSiteBuyViewController alloc] initWithNibName:(iPhone5?@"WebSiteBuyViewController_5":@"WebSiteBuyViewController") bundle:nil];
    webViewController.mURLStr = wapURL;
    [_parentViewController.navigationController pushViewController:webViewController animated:YES];
    [webViewController release];
}
#pragma mark -
#pragma mark UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return 45.0f;
}

#pragma mark - Table view delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
