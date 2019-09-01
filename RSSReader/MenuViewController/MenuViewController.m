//
//  MenuViewController.m
//  RSSReader
//
//  Created by Dzmitry Noska on 8/29/19.
//  Copyright © 2019 Dzmitry Noska. All rights reserved.
//

#import "MenuViewController.h"
#import "MenuTableViewCell.h"
#import "MenuHeaderView.h"
#import "RSSURLValidator.h"
#import "FeedResource.h"

@interface MenuViewController () <UITableViewDataSource, UITableViewDelegate, MenuHeaderViewListener>
@property (strong, nonatomic) UITableView* tableView;
@property (strong, nonatomic) NSMutableArray<FeedResource *>* feedsResources;
@property (strong, nonatomic) UISearchBar* searchBar;
@property (strong, nonatomic) FeedResource* feedResource;
@property (strong, nonatomic) RSSURLValidator* urlValidator;
@end

static NSString* URL_TO_PARSE = @"https://news.tut.by/rss/index.rss";
static NSString* CELL_IDENTIFIER = @"Cell";
static NSString* const HEADER_IDENTIFIER = @"header";
NSString* const MenuViewControllerFeedResourceWasAddedNotification = @"MenuViewControllerFeedResourceWasAddedNotification";

@implementation MenuViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blueColor];
    [self tableViewSetUp];
    self.urlValidator = [[RSSURLValidator alloc] init];
    FeedResource* tutBY = [[FeedResource alloc] initWithName:@"TUT.BY" url:[NSURL URLWithString:URL_TO_PARSE]];
    self.feedsResources = [[NSMutableArray alloc] initWithObjects:tutBY, nil];
}

- (void) tableViewSetUp {
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    [self.tableView registerClass:[MenuTableViewCell class] forCellReuseIdentifier:CELL_IDENTIFIER];
    [self.tableView registerClass:[MenuHeaderView class] forHeaderFooterViewReuseIdentifier:HEADER_IDENTIFIER];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    self.tableView.rowHeight = 90;
    self.tableView.backgroundColor = [UIColor darkGrayColor];
    [self.view addSubview:self.tableView];
    
    self.tableView.translatesAutoresizingMaskIntoConstraints = NO;
    [NSLayoutConstraint activateConstraints:@[
                                              [self.tableView.leadingAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.leadingAnchor],
                                              [self.tableView.trailingAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.trailingAnchor],
                                              [self.tableView.topAnchor constraintEqualToAnchor:self.view.topAnchor],
                                              [self.tableView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor]
                                              ]];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.feedsResources count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MenuTableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:CELL_IDENTIFIER forIndexPath:indexPath];
    cell.newsLabel.text = self.feedsResources[indexPath.row].name;
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    MenuHeaderView* menuHeader = (MenuHeaderView*)[tableView dequeueReusableHeaderFooterViewWithIdentifier:HEADER_IDENTIFIER];
    menuHeader.listener = self;
    return menuHeader;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)didTapOnAddResourceButton:(MenuHeaderView *)addResourceButton {
    NSLog(@"didTap");
    UIAlertController* addFeedAlert = [UIAlertController alertControllerWithTitle:@"Add new feed"
                                                                          message:@"Enter feed name and URL"
                                                                   preferredStyle:UIAlertControllerStyleAlert];
    
    [addFeedAlert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"Feed name";
    }];
    [addFeedAlert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"Feed URL";
    }];
    
    [addFeedAlert addAction:[UIAlertAction actionWithTitle:@"Cancel"
                                                     style:UIAlertActionStyleCancel handler:nil]];
    [addFeedAlert addAction:[UIAlertAction actionWithTitle:@"Save"
                                                     style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                                                         NSArray<UITextField*>* textField = addFeedAlert.textFields;
                                                         UITextField* feedTextField = [textField firstObject];
                                                         UITextField* urlTextField = [textField lastObject];
                                                         
                                                         if (![feedTextField.text isEqualToString:@""] && ![urlTextField.text isEqualToString:@""]) {
                                                             
                                                             NSString* inputString = urlTextField.text;
                                                             NSURL* urlForParse = [self.urlValidator parseFeedResoursecFromURL:[NSURL URLWithString:inputString]];
                                                             if (urlForParse) {
                                                                 FeedResource* resource = [[FeedResource alloc] initWithName:feedTextField.text url:urlForParse];
                                                                 [self.feedsResources addObject:resource];
                                                                 [self.tableView reloadData];
                                                                 NSDictionary* dictionary = [NSDictionary dictionaryWithObject:resource forKey:@"resource"];
                                                                 [[NSNotificationCenter defaultCenter] postNotificationName:MenuViewControllerFeedResourceWasAddedNotification
                                                                                                                     object:nil
                                                                                                                   userInfo:dictionary];
                                                             } else {
                                                                 // TODO add exeption alert
                                                                 NSLog(@"exeption");
                                                             }
                                                         }
                                                     }]];
    
    [self presentViewController:addFeedAlert animated:YES completion:nil];
}


@end
