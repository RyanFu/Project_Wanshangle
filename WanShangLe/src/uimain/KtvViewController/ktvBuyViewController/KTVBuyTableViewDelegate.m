//
//  KTVBuyTableViewDelegate.m
//  WanShangLe
//
//  Created by stephenliu on 13-7-5.
//  Copyright (c) 2013年 stephenliu. All rights reserved.
//

#import "KTVBuyTableViewDelegate.h"
#import "KTVBuyViewController.h"
#import "WebSiteBuyViewController.h"
#import "KTVBuyCell.h"
#import "SIAlertView.h"

@implementation KTVBuyTableViewDelegate
#pragma mark -
#pragma mark UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [_mArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    ABLoggerMethod();
    static NSString *CellIdentifier = @"mKTVBuyCell";
    
    KTVBuyCell * cell = (KTVBuyCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [self createNewCell];
    }
    
    [self setCellCustomBackgroundView:cell cellForRowAtIndexPath:indexPath];
    
    NSDictionary *cellData = [_mArray objectAtIndex:indexPath.row];
    [self configureCell:cell cellForRowAtIndexPath:indexPath withObject:cellData];
    
    return cell;
}

-(KTVBuyCell *)createNewCell{
    ABLoggerMethod();
    KTVBuyCell * cell = [[[NSBundle mainBundle] loadNibNamed:@"KTVBuyCell" owner:self options:nil] objectAtIndex:0];
    [cell setAccessoryType:UITableViewCellAccessoryNone];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    [cell.bg_button addTarget:self action:@selector(clickCellButton:) forControlEvents:UIControlEventTouchUpInside];
    
    return cell;
}

- (void)setCellCustomBackgroundView:(KTVBuyCell *)cell cellForRowAtIndexPath:(NSIndexPath *)indexPath{
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

- (void)configureCell:(KTVBuyCell *)cell cellForRowAtIndexPath:(NSIndexPath *)indexPath withObject:(NSDictionary *)dataDic {
    
//    if (indexPath.row==0) {
//        cell.lowPriceImg.hidden = NO;
//    }else{
//        cell.lowPriceImg.hidden = YES;
//    }
    cell.tuan_imgView.image = [UIImage imageNamed:@"tag_tuan@2x"];
    cell.vendor_name.text = [dataDic objectForKey:@"supplierName"];
    float tprice = [[dataDic objectForKey:@"price"] floatValue];
    if (tprice<0) {
         cell.price.text = [NSString stringWithFormat:@"暂无价格"];
    }else{
        cell.price.text = [NSString stringWithFormat:@"%0.0f元",tprice];
    }
   
}

- (void)clickCellButton:(id)sender{
    UIButton *bt = (UIButton *)sender;
    
    KTVBuyCell *cell = (KTVBuyCell *)[[bt superview] superview];
    NSIndexPath *indexPath = [_mTableView indexPathForCell:cell];
    NSDictionary *dataDic = [_mArray objectAtIndex:indexPath.row];
    NSString *urlstr = [dataDic objectForKey:@"murl"];
    [self skipToBuyWebSite:urlstr];
    
//    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
//    NSNumber *buy_hint_bool = [userDefault objectForKey:BuyInfo_HintType];
//    
//    if(isNull(buy_hint_bool) || ![buy_hint_bool boolValue]){
//        NSString *supplierName = [dataDic objectForKey:@"supplierName"];
//        SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"你将被跳转到%@完成购买",supplierName]
//                                                         andMessage:@"\n\n\n"];
//        [alertView addButtonWithTitle:@"取消"
//                                 type:SIAlertViewButtonTypeCancel
//                              handler:^(SIAlertView *alertView) {
//                              }];
//        [alertView addButtonWithTitle:@"继续"
//                                 type:SIAlertViewButtonTypeDefault
//                              handler:^(SIAlertView *alertView) {
//                                  [self skipToBuyWebSite:urlstr];
//                              }];
//        //        alertView.titleFont = [UIFont boldSystemFontOfSize:17];
//        //        alertView.messageFont = [UIFont systemFontOfSize:12];
//        UILabel *promptLabel = [[[UILabel alloc] initWithFrame:CGRectMake(115, 60, 110, 22)] autorelease];
//        promptLabel.backgroundColor = [UIColor clearColor];
//        promptLabel.text = @"下次不再提醒";
//        promptLabel.textColor = [UIColor colorWithWhite:0.400 alpha:1.000];
//        
//        UIButton *checkBox = [UIButton buttonWithType:UIButtonTypeCustom];
//        [checkBox setImage:[UIImage imageNamed:@"btn_checkBox_n@2x"] forState:UIControlStateNormal];
//        [checkBox setImage:[UIImage imageNamed:@"btn_checkBox_f@2x"] forState:UIControlStateSelected];
//        [checkBox addTarget:self action:@selector(clickCheckBox:) forControlEvents:UIControlEventTouchUpInside];
//        checkBox.frame = CGRectMake(85, 62, 20, 20);
//        
//        [alertView show];
//        [alertView.containerView addSubview:checkBox];
//        [alertView.containerView addSubview:promptLabel];
//        
//        [alertView release];
//    }else{
//        [self skipToBuyWebSite:urlstr];
//    }
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
    [[CacheManager sharedInstance].rootNavController pushViewController:webViewController animated:YES];
    [webViewController release];
}
#pragma mark -
#pragma mark UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 45.0f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}
@end
