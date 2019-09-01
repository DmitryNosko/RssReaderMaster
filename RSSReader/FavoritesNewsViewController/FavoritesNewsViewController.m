//
//  FavoritesNewsViewController.m
//  RSSReader
//
//  Created by USER on 9/1/19.
//  Copyright © 2019 Dzmitry Noska. All rights reserved.
//

#import "FavoritesNewsViewController.h"
#import "FavoritesNewsTableViewCell.h"
#import "DetailsViewController.h"
#import "WebViewController.h"
#import "FileManager.h"

@interface FavoritesNewsViewController () <UITableViewDelegate, UITableViewDataSource, FavoritesNewsTableViewCellListener>
@property (strong, nonatomic) UITableView* tableView;
@end

static NSString* CELL_IDENTIFIER = @"Cell";
static NSString* FILE_NAME= @"testFile.txt";
static NSString* PATTERN_FOR_VALIDATION = @"<\/?[A-Za-z]+[^>]*>";

@implementation FavoritesNewsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self tableViewSetUp];
    [self configureNavigationBar];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[[FileManager shared] readFile:FILE_NAME] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    FavoritesNewsTableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:CELL_IDENTIFIER forIndexPath:indexPath];
    cell.listener = self;
    NSMutableArray<FeedItem*>* feedItem = [[FileManager shared] readFile:FILE_NAME];
    cell.titleLabel.text = [feedItem objectAtIndex:indexPath.row].itemTitle;
    return cell;
    
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    WebViewController* dvc = [[WebViewController alloc] init];
    NSMutableArray<FeedItem*>* feedItem = [[FileManager shared] readFile:FILE_NAME];
    NSString* string = [feedItem objectAtIndex:indexPath.row].link;
    NSString *stringForURL = [string substringWithRange:NSMakeRange(0, [string length]-6)];
    NSURL* url = [NSURL URLWithString:stringForURL];
    dvc.newsURL = url;
    [self.navigationController pushViewController:dvc animated:YES];
}

-(CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 80.f;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return UITableViewAutomaticDimension;
}

#pragma mark - FavoritesNewsTableViewCellListener

- (void)didTapOnInfoButton:(FavoritesNewsTableViewCell *)infoButton {
    NSIndexPath* indexPath = [self.tableView indexPathForCell:infoButton];
    NSMutableArray<FeedItem*>* feedItem = [[FileManager shared] readFile:FILE_NAME];
    FeedItem* item = [feedItem objectAtIndex:indexPath.row];
    
    DetailsViewController* dvc = [[DetailsViewController alloc] init];
    dvc.itemTitleString = item.itemTitle;
    dvc.itemDateString = item.pubDate;
    dvc.itemURLString = item.imageURL;
    dvc.itemDescriptionString = [self correctDescription:item.itemDescription];
    
    [self.navigationController pushViewController:dvc animated:YES];
}

- (NSString*) correctDescription:(NSString *) string {
    NSRegularExpression* regularExpression = [NSRegularExpression regularExpressionWithPattern:PATTERN_FOR_VALIDATION
                                                                                       options:NSRegularExpressionCaseInsensitive
                                                                                         error:nil];
    string = [regularExpression stringByReplacingMatchesInString:string
                                                         options:0
                                                           range:NSMakeRange(0, [string length])
                                                    withTemplate:@""];
    return string;
}

#pragma mark - ViewControllerSetUp

- (void) configureNavigationBar {
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationController.navigationBar.tintColor = [UIColor darkGrayColor];
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    self.navigationItem.leftBarButtonItem.tintColor = [UIColor whiteColor];
    self.navigationItem.title = @"Favorites news";
}

- (void) tableViewSetUp {
    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    [self.tableView registerClass:[FavoritesNewsTableViewCell class] forCellReuseIdentifier:CELL_IDENTIFIER];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    [self.view addSubview:self.tableView];
    
    self.tableView.translatesAutoresizingMaskIntoConstraints = NO;
    [NSLayoutConstraint activateConstraints:@[
                                              [self.tableView.leadingAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.leadingAnchor],
                                              [self.tableView.trailingAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.trailingAnchor],
                                              [self.tableView.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor],
                                              [self.tableView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor]
                                              ]];
}

@end
