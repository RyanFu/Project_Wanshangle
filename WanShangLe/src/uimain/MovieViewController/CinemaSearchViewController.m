//
//  ViewController.m
//  SearchCoreTest
//
//  Created by Apple on 28/01/13.
//  Copyright (c) 2013 kewenya. All rights reserved.
//

#import "CinemaSearchViewController.h"
#import "SearchCoreManager.h"
#import "MCinema.h"
#import <QuartzCore/QuartzCore.h>
#import"OHAttributedLabel.h"
#import "NSAttributedString+Attributes.h"
#import "OHASBasicMarkupParser.h"

static NSInteger const kAttributedLabelTag = 100;
static CGFloat const kLabelWidth = 300;
static CGFloat const kLabelVMargin = 10;

@interface CinemaSearchViewController(){
}
@end

@implementation CinemaSearchViewController
@synthesize tableView;
@synthesize searchBar;
@synthesize contactDic;
@synthesize searchByName;
@synthesize searchByPhone;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
    
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(keyboardWillShown:)
                                                     name:UIKeyboardWillShowNotification
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(keyboardWasHidden:)
                                                     name:UIKeyboardWillHideNotification
                                                   object:nil];
    }
    
    return self;
}

-(void)dealloc{
    
    self.contactDic = nil;
    self.searchByName = nil;
    self.searchByPhone = nil;
    self.strongSearchDisplayController = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [super dealloc];
}

- (void)tableViewInit {
    self.tableView = [[[UITableView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, iPhoneAppFrame.size.width, iPhoneAppFrame.size.height)] autorelease];
    self.tableView.dataSource=self;
	self.tableView.delegate=self;
	self.tableView.backgroundColor=[UIColor clearColor];
    
    UIView *headerView = [[UIView alloc] initWithFrame:self.searchBar.frame];
    headerView.hidden = YES;
    self.tableView.tableHeaderView = headerView;
    [headerView release];
    
    [self.tableView addSubview:self.searchBar];
    
    // The search bar is hidden when the view becomes visible the first time
    self.tableView.contentOffset = CGPointMake(0, CGRectGetHeight(self.searchBar.bounds));
    
    /*
     [self.tableView addSubview:self.searchBar];
     self.tableView.contentInset = UIEdgeInsetsMake(CGRectGetHeight(self.searchBar.bounds), 0, 0, 0);
     self.tableView.scrollIndicatorInsets = UIEdgeInsetsMake(CGRectGetHeight(self.searchBar.bounds), 0, 0, 0);
     */
    
    [self.view addSubview:self.tableView];
}
- (void)searchBarInit {
    
    self.searchBar = [[[UISearchBar alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.view.bounds.size.width, 44.0f)] autorelease];
    
    self.searchBar.autocorrectionType = UITextAutocorrectionTypeNo;
	self.searchBar.autocapitalizationType = UITextAutocapitalizationTypeNone;
	self.searchBar.keyboardType = UIKeyboardTypeDefault;
	self.searchBar.backgroundColor=[UIColor clearColor];
	self.searchBar.translucent=YES;
	self.searchBar.placeholder=@"搜索";
	self.searchBar.delegate = self;
	self.searchBar.barStyle=UIBarStyleDefault;
    
    self.searchBar.backgroundColor=[UIColor clearColor];
    [[self.searchBar.subviews objectAtIndex:0]removeFromSuperview];
    for (UIView *subview in self.searchBar.subviews)
    {
        if ([subview isKindOfClass:NSClassFromString(@"UISearchBarBackground")])
        {
            [subview removeFromSuperview];
            break;
        }
    }
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"searchBarBackground"]];
    imageView.frame = CGRectMake(0, 0, 320, 44);
    [self.searchBar insertSubview:imageView atIndex:0];
    
    self.strongSearchDisplayController = [[UISearchDisplayController alloc] initWithSearchBar:self.searchBar contentsController:self];
    self.searchDisplayController.searchResultsDataSource = self;
    self.searchDisplayController.searchResultsDelegate = self;
    self.searchDisplayController.delegate = self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    [self searchBarInit];
    
    [self tableViewInit];
    
    
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    self.contactDic = dic;
    [dic release];
    
    NSMutableArray *nameIDArray = [[NSMutableArray alloc] init];
    self.searchByName = nameIDArray;
    [nameIDArray release];
    NSMutableArray *phoneIDArray = [[NSMutableArray alloc] init];
    
    self.searchByPhone = phoneIDArray;
    [phoneIDArray release];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSArray *array = [[DataBaseManager sharedInstance] getAllCinemasListFromCoreData];
        for (int i=0; i<[array count]; i++) {
            MCinema *cienma = [array objectAtIndex:i];
            [[SearchCoreManager share] AddContact:cienma.uid name:cienma.name phone:nil];
            [self.contactDic setObject:cienma forKey:cienma.uid];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
        });
    });
    
    /*
     UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
     backButton.frame = CGRectMake(0, 0, 40, 30);
     [backButton setBackgroundColor:[UIColor colorWithRed:0.190 green:0.703 blue:1.000 alpha:1.000]];
     [backButton setTitle:@"返回" forState:UIControlStateNormal];
     [backButton addTarget:self action:@selector(clickBackButton:) forControlEvents:UIControlEventTouchUpInside];
     [self.view addSubview:backButton];
     */
}

- (void)clickBackButton:(id)sender{
    [self.navigationController popViewControllerAnimated:YES];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)_tableView
{
    return 1;
}

- (CGFloat)tableView:(UITableView *)_tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return 44;
}
- (NSInteger)tableView:(UITableView *)_tableView numberOfRowsInSection:(NSInteger)section
{
    if ([self.searchBar.text length] <= 0) {
        return [self.contactDic count];
    } else {
        return [self.searchByName count] + [self.searchByPhone count];
    }
}


- (UITableViewCell *)tableView:(UITableView *)_tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *indentifier = @"Cell";
    UITableViewCell *cell = (UITableViewCell*)[_tableView dequeueReusableCellWithIdentifier:indentifier];
    OHAttributedLabel* attrLabel = nil;
    
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:indentifier] autorelease];
		cell.selectionStyle=UITableViewCellSelectionStyleNone;
        
        attrLabel = [[OHAttributedLabel alloc] initWithFrame:CGRectMake(10,kLabelVMargin,kLabelWidth,tableView.rowHeight-2*kLabelVMargin)];
        attrLabel.centerVertically = YES;
        attrLabel.backgroundColor = [UIColor clearColor];
        attrLabel.tag = kAttributedLabelTag;
        [cell addSubview:attrLabel];
        [attrLabel release];
	}
    
    if ([self.searchBar.text length] <= 0) {
        MCinema *contact = [[self.contactDic allValues] objectAtIndex:indexPath.row];
        attrLabel = (OHAttributedLabel*)[cell viewWithTag:kAttributedLabelTag];
        [attrLabel setText:contact.name];
        return cell;
    }
    
    NSNumber *localID = nil;
    NSMutableString *matchString = [NSMutableString string];
    NSMutableArray *matchPos = [NSMutableArray array];
    NSRange cHRange = NSMakeRange(-1, -1);
    if (indexPath.row < [searchByName count]) {
        localID = [self.searchByName objectAtIndex:indexPath.row];
        
        if ([self.searchBar.text length]) {
            [[SearchCoreManager share] GetPinYin:localID pinYin:matchString matchPos:matchPos matchCNPos:&cHRange];
        }
    } else {
        localID = [self.searchByPhone objectAtIndex:indexPath.row-[searchByName count]];
        NSMutableArray *matchPhones = [NSMutableArray array];
        
        if ([self.searchBar.text length]) {
            [[SearchCoreManager share] GetPhoneNum:localID phone:matchPhones matchPos:matchPos];
            [matchString appendString:[matchPhones objectAtIndex:0]];
        }
    }
    MCinema *contact = [self.contactDic objectForKey:localID];
    
    attrLabel = (OHAttributedLabel*)[cell viewWithTag:kAttributedLabelTag];
    [attrLabel setText:contact.name];
    
    if (!(cHRange.location == -1) && !(cHRange.length == -1)) {
        if ([contact.name length]<cHRange.length) {
            cHRange.length = [contact.name length];
        }
        
        NSMutableAttributedString* attrStr = [attrLabel.attributedText mutableCopy];
        [attrStr setTextColor:[UIColor colorWithRed:0.082 green:0.587 blue:0.827 alpha:1.000] range:cHRange];
        //[attrStr setFontFamily:@"helvetica" size:25 bold:YES italic:YES range:cHRange];
        [attrStr setTextBold:YES range:cHRange];
        attrLabel.attributedText = attrStr;
        [attrStr release];
    }
    
    
    return cell;
}

- (void)tableView:(UITableView *)_tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

#pragma mark -
#pragma mark UIScrollViewDelegate
- (void)scrollTableViewToSearchBarAnimated:(BOOL)animated
{
    [self.tableView scrollRectToVisible:self.searchBar.frame animated:animated];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView.contentOffset.y < 44) {
        self.tableView.scrollIndicatorInsets = UIEdgeInsetsMake(CGRectGetHeight(self.searchBar.bounds) - MAX(scrollView.contentOffset.y, 0), 0, 0, 0);
    } else {
        self.tableView.scrollIndicatorInsets = UIEdgeInsetsZero;
    }
    
    CGRect searchBarFrame = self.searchBar.frame;
    searchBarFrame.origin.y = MIN(scrollView.contentOffset.y, 0);
    
    
    self.searchBar.frame = searchBarFrame;
}


#pragma mark -
#pragma mark UISearchBarDelegate methods
/*
 - (void)searchBar:(UISearchBar *)_searchBar textDidChange:(NSString *)searchText
 {
 [[SearchCoreManager share] Search:searchText searchArray:nil nameMatch:searchByName phoneMatch:self.searchByPhone];
 
 [self.tableView reloadData];
 }
 
 - (void)searchBarCancelButtonClicked:(UISearchBar *) searchBar{
 [self.searchBar resignFirstResponder];
 }
 - (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
 {
 [self.searchBar resignFirstResponder];
 }
 */

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar{
    self.searchBar.showsScopeBar = YES;
    [self.searchBar sizeToFit];
    [self.searchBar setShowsCancelButton:YES animated:YES];
    
    for(id cc in [self.searchBar subviews])
    {
        if([cc isKindOfClass:[UIButton class]])
        {
            UIButton *btn = (UIButton *)cc;
            [btn setTitle:@"取消"  forState:UIControlStateNormal];
            [btn setBackgroundImage:[UIImage imageNamed:@"searchBarBackground"] forState:UIControlStateNormal];
            [btn setBackgroundImage:[UIImage imageNamed:@"searchBarBackground2"] forState:UIControlStateSelected];
            [btn setBackgroundImage:[UIImage imageNamed:@"searchBarBackground2"] forState:UIControlStateHighlighted];
        }
    }
    
    return YES;
}

- (void) searchDisplayControllerDidEndSearch:(UISearchDisplayController *)controller{
    [self.searchByName removeAllObjects];
    [self.searchByPhone removeAllObjects];
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    ABLoggerMethod();
    [[SearchCoreManager share] Search:searchString searchArray:nil nameMatch:searchByName phoneMatch:self.searchByPhone];
    
    [self.tableView reloadData];
    
    return YES;
}

#pragma mark -
#pragma mark UIKeyboardNotification methods
- (void) keyboardWillShown:(NSNotification*) aNotification
{
	NSDictionary* info = [aNotification userInfo];
    float durationTime = [[info objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
	
	// Get the size of the keyboard.
	CGSize keyboardSize = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
	
	CGRect newFrame = self.tableView.frame;
	newFrame.size.height = iPhoneAppFrame.size.height-keyboardSize.height;
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationCurve:UIViewAnimationCurveLinear];
    [UIView setAnimationDuration:durationTime];
    self.tableView.frame = newFrame;
    [UIView commitAnimations];
}

- (void)keyboardWasHidden:(NSNotification*)aNotification
{
    NSDictionary * info = [aNotification userInfo];
    float durationTime = [[info objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    
    CGRect newFrame = self.tableView.frame;
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationCurve:UIViewAnimationCurveLinear];
    [UIView setAnimationDuration:durationTime];
    //newFrame.size.height = iPhoneAppFrame.size.height-self.searchBar.frame.size.height;
    newFrame.size.height = iPhoneAppFrame.size.height;
    self.tableView.frame = newFrame;
    [UIView commitAnimations];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    ABLoggerWarn(@"接收到内存警告了");
    // Dispose of any resources that can be recreated.
}

@end
